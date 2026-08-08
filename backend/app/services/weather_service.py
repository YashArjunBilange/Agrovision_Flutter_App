import logging
from typing import Any, Dict, List, Optional
import httpx

logger = logging.getLogger(__name__)

# WMO Weather interpretation codes
WMO_WEATHER_CODES: Dict[int, Dict[str, str]] = {
    0: {"en": "Clear sky", "mr": "निरभ्र आकाश", "icon": "sunny"},
    1: {"en": "Mainly clear", "mr": "बहुतांश निरभ्र", "icon": "partly_cloudy"},
    2: {"en": "Partly cloudy", "mr": "अंशतः ढगाळ", "icon": "partly_cloudy"},
    3: {"en": "Overcast", "mr": "पूर्णतः ढगाळ", "icon": "cloudy"},
    45: {"en": "Fog", "mr": "धुके", "icon": "fog"},
    48: {"en": "Depositing rime fog", "mr": "दाट धुके", "icon": "fog"},
    51: {"en": "Light drizzle", "mr": "हलकी रिमझिम", "icon": "rainy"},
    53: {"en": "Moderate drizzle", "mr": "रिमझिम पाऊस", "icon": "rainy"},
    55: {"en": "Dense drizzle", "mr": "सलग रिमझिम पाऊस", "icon": "rainy"},
    61: {"en": "Slight rain", "mr": "हलका पाऊस", "icon": "rainy"},
    63: {"en": "Moderate rain", "mr": "मध्यम पाऊस", "icon": "rainy"},
    65: {"en": "Heavy rain", "mr": "जोरदार मुसळधार पाऊस", "icon": "heavy_rain"},
    80: {"en": "Slight rain showers", "mr": "पावसाच्या हलक्या सरी", "icon": "rainy"},
    81: {"en": "Moderate rain showers", "mr": "पावसाच्या मध्यम सरी", "icon": "rainy"},
    82: {"en": "Violent rain showers", "mr": "मुसळधार पावसाच्या सरी", "icon": "heavy_rain"},
    95: {"en": "Thunderstorm", "mr": "वादळी पाऊस व विजा", "icon": "thunderstorm"},
    96: {"en": "Thunderstorm with slight hail", "mr": "विजांसह हलकी गारपीट", "icon": "thunderstorm"},
    99: {"en": "Thunderstorm with heavy hail", "mr": "विजांसह जोरदार गारपीट", "icon": "thunderstorm"},
}


class WeatherService:
    BASE_URL = "https://api.open-meteo.com/v1/forecast"

    @classmethod
    async def fetch_weather_forecast(
        cls,
        latitude: float,
        longitude: float,
    ) -> Dict[str, Any]:
        params = {
            "latitude": latitude,
            "longitude": longitude,
            "current": [
                "temperature_2m",
                "relative_humidity_2m",
                "precipitation",
                "weather_code",
                "wind_speed_10m",
                "wind_direction_10m",
                "surface_pressure",
            ],
            "hourly": [
                "temperature_2m",
                "relative_humidity_2m",
                "precipitation_probability",
                "precipitation",
                "weather_code",
                "wind_speed_10m",
            ],
            "daily": [
                "weather_code",
                "temperature_2m_max",
                "temperature_2m_min",
                "precipitation_sum",
                "precipitation_probability_max",
                "wind_speed_10m_max",
            ],
            "timezone": "Asia/Kolkata",
            "forecast_days": 7,
        }

        try:
            async with httpx.AsyncClient(timeout=8.0) as client:
                response = await client.get(cls.BASE_URL, params=params)
                if response.status_code == 200:
                    raw_data = response.json()
                    return cls._format_weather_data(raw_data, latitude, longitude)
                else:
                    logger.warning(f"Open-Meteo returned status {response.status_code}, using fallback")
        except Exception as e:
            logger.warning(f"Error fetching Open-Meteo weather: {e}, using fallback data")

        return cls._generate_fallback_weather(latitude, longitude)

    @classmethod
    def _format_weather_data(cls, raw: Dict[str, Any], lat: float, lon: float) -> Dict[str, Any]:
        current_raw = raw.get("current", {})
        hourly_raw = raw.get("hourly", {})
        daily_raw = raw.get("daily", {})

        cur_temp = current_raw.get("temperature_2m", 28.0)
        cur_humidity = current_raw.get("relative_humidity_2m", 65)
        cur_code = current_raw.get("weather_code", 0)
        cur_wind = current_raw.get("wind_speed_10m", 8.0)
        cur_precip = current_raw.get("precipitation", 0.0)

        condition_meta = WMO_WEATHER_CODES.get(cur_code, {"en": "Clear", "mr": "निरभ्र", "icon": "sunny"})

        # Spray Window Advisory
        spray_advisory = cls.calculate_spray_advisory(
            temp=cur_temp,
            wind_speed=cur_wind,
            rain_prob=0,
            precipitation=cur_precip,
        )

        # Agricultural Risk Alerts
        alerts = cls.evaluate_agricultural_risks(
            temp=cur_temp,
            humidity=cur_humidity,
            wind_speed=cur_wind,
            daily_precip_sums=daily_raw.get("precipitation_sum", [0.0]),
        )

        # Format 24-hr Hourly Forecast
        hourly_list = []
        times = hourly_raw.get("time", [])[:24]
        temps = hourly_raw.get("temperature_2m", [])[:24]
        humidities = hourly_raw.get("relative_humidity_2m", [])[:24]
        precip_probs = hourly_raw.get("precipitation_probability", [])[:24]
        codes = hourly_raw.get("weather_code", [])[:24]
        winds = hourly_raw.get("wind_speed_10m", [])[:24]

        for i in range(len(times)):
            code = codes[i] if i < len(codes) else 0
            w_meta = WMO_WEATHER_CODES.get(code, {"en": "Clear", "mr": "निरभ्र", "icon": "sunny"})
            hourly_list.append({
                "time": times[i],
                "temperature": temps[i] if i < len(temps) else cur_temp,
                "humidity": humidities[i] if i < len(humidities) else cur_humidity,
                "precipitation_probability": precip_probs[i] if i < len(precip_probs) else 0,
                "weather_code": code,
                "condition_en": w_meta["en"],
                "condition_mr": w_meta["mr"],
                "icon": w_meta["icon"],
                "wind_speed": winds[i] if i < len(winds) else cur_wind,
            })

        # Format 7-Day Forecast
        daily_list = []
        d_times = daily_raw.get("time", [])
        d_max_temps = daily_raw.get("temperature_2m_max", [])
        d_min_temps = daily_raw.get("temperature_2m_min", [])
        d_precips = daily_raw.get("precipitation_sum", [])
        d_precip_probs = daily_raw.get("precipitation_probability_max", [])
        d_codes = daily_raw.get("weather_code", [])
        d_winds = daily_raw.get("wind_speed_10m_max", [])

        for i in range(len(d_times)):
            code = d_codes[i] if i < len(d_codes) else 0
            w_meta = WMO_WEATHER_CODES.get(code, {"en": "Clear", "mr": "निरभ्र", "icon": "sunny"})
            daily_list.append({
                "date": d_times[i],
                "temp_max": d_max_temps[i] if i < len(d_max_temps) else 30.0,
                "temp_min": d_min_temps[i] if i < len(d_min_temps) else 20.0,
                "precipitation_sum": d_precips[i] if i < len(d_precips) else 0.0,
                "precipitation_probability": d_precip_probs[i] if i < len(d_precip_probs) else 0,
                "weather_code": code,
                "condition_en": w_meta["en"],
                "condition_mr": w_meta["mr"],
                "icon": w_meta["icon"],
                "wind_speed_max": d_winds[i] if i < len(d_winds) else 10.0,
            })

        return {
            "latitude": lat,
            "longitude": lon,
            "current": {
                "temperature": cur_temp,
                "humidity": cur_humidity,
                "precipitation": cur_precip,
                "wind_speed": cur_wind,
                "wind_direction": current_raw.get("wind_direction_10m", 180),
                "weather_code": cur_code,
                "condition_en": condition_meta["en"],
                "condition_mr": condition_meta["mr"],
                "icon": condition_meta["icon"],
            },
            "spray_advisory": spray_advisory,
            "agricultural_alerts": alerts,
            "hourly_forecast": hourly_list,
            "daily_forecast": daily_list,
        }

    @classmethod
    def calculate_spray_advisory(
        cls,
        temp: float,
        wind_speed: float,
        rain_prob: int = 0,
        precipitation: float = 0.0,
    ) -> Dict[str, Any]:
        """Evaluates whether current conditions are suitable for pesticide or foliar fertilizer spraying."""
        reasons_en = []
        reasons_mr = []
        score = 100

        # Rain / Precipitation check
        if precipitation > 0.2 or rain_prob > 50:
            score -= 60
            reasons_en.append("High rain risk will wash away sprayed chemicals.")
            reasons_mr.append("पावसामुळे फवारलेली औषधे धुवून जाण्याची शक्यता आहे.")
        elif rain_prob > 25:
            score -= 20
            reasons_en.append("Chance of light rain. Keep a 3-hour rain-fast window.")
            reasons_mr.append("हलक्या पावसाची शक्यता. औषध सुकण्यासाठी ३ तास मिळणे आवश्यक.")

        # Wind speed check
        if wind_speed > 18.0:
            score -= 50
            reasons_en.append(f"High wind ({wind_speed:.1f} km/h) causes severe chemical spray drift.")
            reasons_mr.append(f"वेगाने वाहणारा वारा ({wind_speed:.1f} km/h) औषधाचा हवेत अपव्यय करतो.")
        elif wind_speed > 12.0:
            score -= 15
            reasons_en.append("Moderate wind. Use hollow cone / drift-reduction nozzles.")
            reasons_mr.append("मध्यम वारा. योग्य नोझलचा वापर करून फवारणी करा.")
        elif wind_speed < 2.0:
            score -= 10
            reasons_en.append("Very low wind speed may cause thermal inversion in midday.")
            reasons_mr.append("अतिशय शांत हवा दुपारी फवारणीसाठी सावधगिरीची ठरू शकते.")

        # Temperature check
        if temp > 34.0:
            score -= 40
            reasons_en.append(f"High temperature ({temp:.1f}°C) causes rapid chemical evaporation and leaf scorch.")
            reasons_mr.append(f"जास्त तापमान ({temp:.1f}°C) औषध बाष्पीभवन आणि पानांवर करपा आणू शकते.")
        elif temp < 15.0:
            score -= 15
            reasons_en.append("Low temperature reduces plant systemic absorption.")
            reasons_mr.append("कमी तापमानामुळे झाडाची औषध शोषून घेण्याची गती मंदावते.")

        score = max(0, min(100, score))

        if score >= 75:
            status = "ideal"
            title_en = "Ideal Spray Window"
            title_mr = "फवारणीसाठी उत्तम वेळ ✅"
            badge_color = "#2E7D32"
        elif score >= 45:
            status = "caution"
            title_en = "Moderate Conditions (Spray with Caution)"
            title_mr = "मध्यम अनुकूलता (काळजीपूर्वक फवारणी करा) ⚠️"
            badge_color = "#F57F17"
        else:
            status = "unfavorable"
            title_en = "Unfavorable for Spraying"
            title_mr = "फवारणीसाठी प्रतिकूल (फवारणी टाळा) ❌"
            badge_color = "#C62828"

        return {
            "status": status,
            "score": score,
            "title_en": title_en,
            "title_mr": title_mr,
            "badge_color": badge_color,
            "reasons_en": reasons_en if reasons_en else ["Wind, temperature, and moisture levels are optimal."],
            "reasons_mr": reasons_mr if reasons_mr else ["वारा, तापमान आणि आर्द्रता फवारणीसाठी अत्यंत अनुकूल आहेत."],
        }

    @classmethod
    def evaluate_agricultural_risks(
        cls,
        temp: float,
        humidity: int,
        wind_speed: float,
        daily_precip_sums: List[float],
    ) -> List[Dict[str, Any]]:
        alerts = []

        # 1. Fungal Disease Risk (Turcicum / Maydis Leaf Blight)
        if humidity >= 78 and (20.0 <= temp <= 30.0):
            alerts.append({
                "type": "disease_risk",
                "severity": "high",
                "title_en": "High Fungal Blight Risk Alert",
                "title_mr": "बुरशीजन्य करपा रोगाचा वाढता धोका ⚠️",
                "description_en": f"High humidity ({humidity}%) and warm temperatures favor rapid spread of Turcicum Leaf Blight. Scout lower leaves.",
                "description_mr": f"जास्त आर्द्रता ({humidity}%) आणि उबदार वातावरणामुळे मक्यावर तुर्सिकम करपा रोगाचा प्रादुर्भाव वाढू शकतो. खालच्या पानांची तपासणी करा.",
                "action_en": "Preventive spray with Mancozeb (2.5g/L) or Azoxystrobin (1ml/L).",
                "action_mr": "प्रतिबंधात्मक उपाय म्हणून मॅन्कोझेब (२.५ ग्रॅम/लिटर) फवारा.",
            })

        # 2. Heat & Moisture Stress Warning
        if temp >= 35.0:
            alerts.append({
                "type": "heat_stress",
                "severity": "warning",
                "title_en": "Heat Stress Warning",
                "title_mr": "उष्णतेचा ताण व सिंचन इशारा ☀️",
                "description_en": f"High ambient temperature ({temp:.1f}°C) increases soil evapotranspiration and risks tassel drying.",
                "description_mr": f"जास्त तापमान ({temp:.1f}°C) मक्याच्या तुऱ्यातील परागीभवनावर परिणाम करू शकते. शेतात ओलावा टिकवून ठेवा.",
                "action_en": "Provide light irrigation during early morning or evening hours.",
                "action_mr": "सकाळच्या किंवा संध्याकाळच्या वेळी पिकास हलके पाणी द्या.",
            })

        # 3. Heavy Rainfall & Waterlogging Alert
        total_2day_rain = sum(daily_precip_sums[:2]) if len(daily_precip_sums) >= 2 else 0.0
        if total_2day_rain >= 40.0:
            alerts.append({
                "type": "excess_rain",
                "severity": "high",
                "title_en": "Excess Rainfall & Drainage Alert",
                "title_mr": "अतिवृष्टी व निचरा व्यवस्थापन इशारा 🌧️",
                "description_en": f"Heavy rain forecast ({total_2day_rain:.1f} mm in 48h). Maize is extremely sensitive to root waterlogging.",
                "description_mr": f"पुढील ४८ तासांत मुसळधार पावसाचा अंदाज ({total_2day_rain:.1f} मिमी). मक्याच्या मुळाशी पाणी साचू न देण्यासाठी पाण्याचा निचरा करा.",
                "action_en": "Clear field drainage channels immediately to prevent root suffocation.",
                "action_mr": "शेतातील पाण्याचा निचरा होण्यासाठी तातडीने चर मोकळे करा.",
            })

        # 4. High Wind Lodging Risk
        if wind_speed >= 30.0:
            alerts.append({
                "type": "wind_lodging",
                "severity": "warning",
                "title_en": "High Wind Lodging Threat",
                "title_mr": "जोरदार वाऱ्यामुळे पीक लोळण्याचा धोका 💨",
                "description_en": f"Gusty winds ({wind_speed:.1f} km/h) can cause lodging in tall vegetative/tasseling maize.",
                "description_mr": f"जोरदार वाऱ्यामुळे मका पीक आडवे पडू शकते. पिकास मातीची भर लावा.",
                "action_en": "Ensure proper earthing-up (मातीची भर) around plant base.",
                "action_mr": "झाडांच्या मुळाशी मातीची भर व्यवस्थित आहे याची खात्री करा.",
            })

        return alerts

    @classmethod
    def _generate_fallback_weather(cls, lat: float, lon: float) -> Dict[str, Any]:
        """Provides realistic agricultural weather data if external API is unreachable."""
        import datetime

        today = datetime.date.today()
        cur_temp = 29.5
        cur_humidity = 68
        cur_wind = 9.2

        spray_advisory = cls.calculate_spray_advisory(cur_temp, cur_wind, 10, 0.0)
        alerts = cls.evaluate_agricultural_risks(cur_temp, cur_humidity, cur_wind, [0.0, 5.0, 0.0])

        daily_list = []
        for d in range(7):
            day_date = (today + datetime.timedelta(days=d)).isoformat()
            daily_list.append({
                "date": day_date,
                "temp_max": round(31.0 + (d % 3) * 0.5, 1),
                "temp_min": round(21.0 + (d % 2) * 0.4, 1),
                "precipitation_sum": 0.0 if d % 3 != 0 else 4.5,
                "precipitation_probability": 15 if d % 3 != 0 else 45,
                "weather_code": 1 if d % 3 != 0 else 61,
                "condition_en": "Mainly clear" if d % 3 != 0 else "Slight rain",
                "condition_mr": "बहुतांश निरभ्र" if d % 3 != 0 else "हलका पाऊस",
                "icon": "partly_cloudy" if d % 3 != 0 else "rainy",
                "wind_speed_max": round(10.0 + (d % 4), 1),
            })

        hourly_list = []
        for h in range(24):
            time_str = f"{today.isoformat()}T{h:02d}:00"
            hourly_list.append({
                "time": time_str,
                "temperature": round(24.0 + 8.0 * (1.0 - abs(h - 14) / 12.0), 1),
                "humidity": round(80 - 30 * (1.0 - abs(h - 14) / 12.0)),
                "precipitation_probability": 10 if h < 14 else 25,
                "weather_code": 1,
                "condition_en": "Mainly clear",
                "condition_mr": "बहुतांश निरभ्र",
                "icon": "partly_cloudy",
                "wind_speed": round(6.0 + 4.0 * (h % 5), 1),
            })

        return {
            "latitude": lat,
            "longitude": lon,
            "current": {
                "temperature": cur_temp,
                "humidity": cur_humidity,
                "precipitation": 0.0,
                "wind_speed": cur_wind,
                "wind_direction": 220,
                "weather_code": 1,
                "condition_en": "Mainly clear",
                "condition_mr": "बहुतांश निरभ्र",
                "icon": "partly_cloudy",
            },
            "spray_advisory": spray_advisory,
            "agricultural_alerts": alerts,
            "hourly_forecast": hourly_list,
            "daily_forecast": daily_list,
        }
