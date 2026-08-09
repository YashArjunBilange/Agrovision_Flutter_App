import base64
import json
import logging
from datetime import date, timedelta
from typing import Dict, Any, Optional
import httpx

from fastapi import HTTPException
from app.core.config import settings

logger = logging.getLogger(__name__)

class SentinelService:
    TOKEN_URL = "https://services.sentinel-hub.com/oauth/token"
    PROCESS_URL = "https://services.sentinel-hub.com/api/v1/process"
    STATISTICS_URL = "https://services.sentinel-hub.com/api/v1/statistics"

    @classmethod
    async def get_access_token(cls) -> str:
        client_id = getattr(settings, "SENTINEL_CLIENT_ID", None)
        client_secret = getattr(settings, "SENTINEL_CLIENT_SECRET", None)

        if not client_id or not client_secret:
            raise HTTPException(
                status_code=503,
                detail="Sentinel-2 API credentials are not configured on the server."
            )

        data = {
            "grant_type": "client_credentials",
            "client_id": client_id,
            "client_secret": client_secret,
        }

        async with httpx.AsyncClient() as client:
            response = await client.post(cls.TOKEN_URL, data=data)
            if response.status_code != 200:
                logger.error(f"Failed to get Sentinel token: {response.text}")
                raise HTTPException(status_code=502, detail="Failed to authenticate with satellite provider.")
            return response.json().get("access_token")

    @classmethod
    async def fetch_latest_observation(
        cls, 
        polygon_geojson: str,
        start_date: Optional[date] = None,
        end_date: Optional[date] = None,
        max_cloud_cover: float = 20.0
    ) -> Dict[str, Any]:
        """
        Fetches the latest Sentinel-2 true-color image and calculates NDVI statistics 
        for the given farm polygon.
        """
        try:
            geojson_dict = json.loads(polygon_geojson)
            if geojson_dict.get("type") != "Polygon":
                raise ValueError("GeoJSON must be a Polygon")
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid polygon GeoJSON provided.")

        if not end_date:
            end_date = date.today()
        if not start_date:
            start_date = end_date - timedelta(days=30)

        token = await cls.get_access_token()

        evalscript_true_color = """
        //VERSION=3
        function setup() {
            return {
                input: ["B02", "B03", "B04", "dataMask"],
                output: { bands: 4 }
            };
        }
        function evaluatePixel(sample) {
            return [sample.B04 * 2.5, sample.B03 * 2.5, sample.B02 * 2.5, sample.dataMask];
        }
        """

        evalscript_ndvi = """
        //VERSION=3
        function setup() {
            return {
                input: ["B04", "B08", "dataMask"],
                output: { id: "default", bands: 4 }
            };
        }
        function evaluatePixel(sample) {
            let ndvi = (sample.B08 - sample.B04) / (sample.B08 + sample.B04);
            
            // Map NDVI values to a color gradient from red to green
            let val = (ndvi + 1) / 2; // Normalize to 0-1
            let r = val < 0.5 ? 1 : 2 * (1 - val);
            let g = val > 0.5 ? 1 : 2 * val;
            let b = 0;
            
            return [r, g, b, sample.dataMask];
        }
        """

        request_payload_tc = {
            "input": {
                "bounds": {
                    "geometry": geojson_dict,
                    "properties": {"crs": "http://www.opengis.net/def/crs/EPSG/0/4326"}
                },
                "data": [
                    {
                        "type": "sentinel-2-l2a",
                        "dataFilter": {
                            "timeRange": {
                                "from": f"{start_date}T00:00:00Z",
                                "to": f"{end_date}T23:59:59Z"
                            },
                            "maxCloudCoverage": max_cloud_cover
                        }
                    }
                ]
            },
            "output": {
                "width": 512,
                "height": 512,
                "responses": [{"identifier": "default", "format": {"type": "image/jpeg"}}]
            },
            "evalscript": evalscript_true_color
        }

        request_payload_ndvi = dict(request_payload_tc)
        request_payload_ndvi["evalscript"] = evalscript_ndvi

        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
            "Accept": "application/tar"
        }

        # We execute the process API call for True Color
        async with httpx.AsyncClient(timeout=30.0) as client:
            tc_response = await client.post(
                cls.PROCESS_URL,
                json=request_payload_tc,
                headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json", "Accept": "image/jpeg"}
            )
            
            if tc_response.status_code == 404:
                 raise HTTPException(status_code=404, detail="No suitable satellite imagery found for this period and cloud cover limit.")
            elif tc_response.status_code != 200:
                logger.error(f"Process API failed: {tc_response.text}")
                raise HTTPException(status_code=502, detail="Failed to process satellite imagery.")
            
            tc_image_base64 = base64.b64encode(tc_response.content).decode("utf-8")
            
            # Execute for NDVI
            ndvi_response = await client.post(
                cls.PROCESS_URL,
                json=request_payload_ndvi,
                headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json", "Accept": "image/jpeg"}
            )
            
            ndvi_image_base64 = None
            if ndvi_response.status_code == 200:
                 ndvi_image_base64 = base64.b64encode(ndvi_response.content).decode("utf-8")

        # Call Statistical API to get min/max/mean
        stats_payload = {
            "input": request_payload_tc["input"],
            "aggregation": {
                "timeRange": {
                    "from": f"{start_date}T00:00:00Z",
                    "to": f"{end_date}T23:59:59Z"
                },
                "aggregationInterval": {"of": "P1D"},
                "evalscript": """
                //VERSION=3
                function setup() {
                    return {
                        input: ["B04", "B08", "dataMask"],
                        output: [
                            { id: "ndvi", bands: 1, sampleType: "FLOAT32" },
                            { id: "dataMask", bands: 1 }
                        ]
                    };
                }
                function evaluatePixel(sample) {
                    let ndvi = (sample.B08 - sample.B04) / (sample.B08 + sample.B04);
                    return {
                        ndvi: [ndvi],
                        dataMask: [sample.dataMask]
                    };
                }
                """
            }
        }

        async with httpx.AsyncClient(timeout=30.0) as client:
            stats_resp = await client.post(
                cls.STATISTICS_URL,
                json=stats_payload,
                headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
            )

        mean_ndvi, min_ndvi, max_ndvi = 0.0, 0.0, 0.0
        obs_date = end_date
        
        if stats_resp.status_code == 200:
            stats_data = stats_resp.json()
            if "data" in stats_data and len(stats_data["data"]) > 0:
                valid_stats = [d for d in stats_data["data"] if d.get("outputs", {}).get("ndvi", {}).get("bands", {}).get("B0", {}).get("stats", {}).get("sampleCount", 0) > 0]
                if valid_stats:
                    latest_stat = valid_stats[-1]
                    s = latest_stat["outputs"]["ndvi"]["bands"]["B0"]["stats"]
                    mean_ndvi = s.get("mean", 0.0)
                    min_ndvi = s.get("min", 0.0)
                    max_ndvi = s.get("max", 0.0)
                    obs_date = latest_stat.get("interval", {}).get("to", f"{end_date}T").split("T")[0]
                    # Parse obs_date to date object
                    try:
                        obs_date = date.fromisoformat(obs_date)
                    except:
                        pass
        
        return {
            "observation_date": obs_date,
            "cloud_cover": max_cloud_cover, # Approximate request bound
            "satellite": "Sentinel-2",
            "true_color_image_base64": f"data:image/jpeg;base64,{tc_image_base64}",
            "ndvi_image_base64": f"data:image/jpeg;base64,{ndvi_image_base64}" if ndvi_image_base64 else None,
            "ndvi_mean": mean_ndvi,
            "ndvi_min": min_ndvi,
            "ndvi_max": max_ndvi,
        }
