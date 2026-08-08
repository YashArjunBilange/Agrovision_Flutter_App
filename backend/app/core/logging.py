import logging
import sys
import time
import uuid
from typing import Callable
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

# Configure standard structured logger
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] [%(name)s] %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
)

logger = logging.getLogger("agrovision")


class LoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        request_id = request.headers.get("X-Request-ID", str(uuid.uuid4())[:8])
        start_time = time.time()

        # Sanitize path to prevent leaking credentials
        logger.info(f"[{request_id}] --> {request.method} {request.url.path}")

        try:
            response = await call_next(request)
            duration_ms = round((time.time() - start_time) * 1000, 2)
            response.headers["X-Request-ID"] = request_id
            response.headers["X-Response-Time-Ms"] = str(duration_ms)

            logger.info(
                f"[{request_id}] <-- {request.method} {request.url.path} "
                f"status={response.status_code} duration={duration_ms}ms"
            )
            return response
        except Exception as e:
            duration_ms = round((time.time() - start_time) * 1000, 2)
            logger.error(
                f"[{request_id}] <-- {request.method} {request.url.path} "
                f"FAILED error={str(e)} duration={duration_ms}ms"
            )
            raise e
