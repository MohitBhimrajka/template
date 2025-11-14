# app/core/logging_config.py
import logging
import os
import sys
from logging.config import dictConfig

# Use a third-party library for easy JSON formatting if available,
# otherwise fall back to a basic implementation.
try:
    from pythonjsonlogger import jsonlogger

    formatter_class = "pythonjsonlogger.jsonlogger.JsonFormatter"
except ImportError:
    formatter_class = "logging.Formatter"

LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()


class HealthCheckFilter(logging.Filter):
    """
    Filter out log messages for health check endpoints to reduce log noise.
    """

    def filter(self, record: logging.LogRecord) -> bool:
        # FastAPI/Uvicorn log records have 'scope' in their args
        if len(record.args) >= 3 and isinstance(record.args[2], dict):
            scope = record.args[2]
            path = scope.get("path", "")
            base_path = os.getenv("BASE_PATH", "")
            if path in [f"{base_path}/api/health", "/api/health"]:
                return False
        return True


def setup_logging():
    """
    Configures the logging for the application.
    """
    log_config = {
        "version": 1,
        "disable_existing_loggers": False,
        "formatters": {
            "json": {
                "class": formatter_class,
                "format": "%(asctime)s %(name)s %(process)d %(thread)d %(levelname)s %(message)s",
            },
            "default": {
                "format": "[%(asctime)s] [%(levelname)s] [%(name)s] %(message)s",
                "datefmt": "%Y-%m-%d %H:%M:%S",
            },
        },
        "handlers": {
            "stdout": {
                "class": "logging.StreamHandler",
                "stream": sys.stdout,
                "formatter": (
                    "json" if os.getenv("APP_ENV") == "production" else "default"
                ),
            },
        },
        "loggers": {
            "": {  # Root logger
                "handlers": ["stdout"],
                "level": LOG_LEVEL,
            },
            "uvicorn.access": {
                "handlers": ["stdout"],
                "level": LOG_LEVEL,
                "propagate": False,
                "filters": ["health_check_filter"],
            },
        },
        "filters": {"health_check_filter": {"()": HealthCheckFilter}},
    }
    dictConfig(log_config)
