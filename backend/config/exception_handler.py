import logging
from typing import Any

from django.core.exceptions import ValidationError as DjangoValidationError
from django.http import Http404
from rest_framework import status
from rest_framework.exceptions import APIException, ValidationError
from rest_framework.response import Response
from rest_framework.views import exception_handler as drf_exception_handler

logger = logging.getLogger("apps")


def exception_handler(exc: Exception, context: dict[str, Any]) -> Response:
    """
    Custom exception handler providing consistent error response format:

    {
        "error": {
            "code": "validation_error",
            "message": "Human-readable summary",
            "details": { ... field-level errors ... }
        }
    }
    """
    # Convert Django ValidationError to DRF ValidationError
    if isinstance(exc, DjangoValidationError):
        if hasattr(exc, "message_dict"):
            exc = ValidationError(detail=exc.message_dict)
        else:
            exc = ValidationError(detail=exc.messages)

    response = drf_exception_handler(exc, context)

    if response is None:
        # Unhandled exception — log full traceback, return 500
        view = context.get("view")
        logger.exception(
            "Unhandled exception in %s: %s",
            view.__class__.__name__ if view else "unknown",
            exc,
        )
        return Response(
            {
                "error": {
                    "code": "internal_error",
                    "message": "An unexpected error occurred.",
                }
            },
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )

    error_code = _get_error_code(exc, response)
    message = _get_error_message(exc, response)

    body = {
        "error": {
            "code": error_code,
            "message": message,
        }
    }

    if isinstance(exc, ValidationError):
        body["error"]["details"] = response.data

    if response.status_code >= 500:
        logger.error("Server error [%s]: %s", error_code, message)
    elif response.status_code >= 400:
        logger.warning("Client error [%s]: %s", error_code, message)

    response.data = body
    return response


def _get_error_code(exc: Exception, response: Response) -> str:
    if isinstance(exc, ValidationError):
        return "validation_error"
    if isinstance(exc, Http404):
        return "not_found"
    if isinstance(exc, APIException):
        return exc.default_code
    return f"error_{response.status_code}"


def _get_error_message(exc: Exception, response: Response) -> str:
    if isinstance(exc, ValidationError):
        return "Invalid input data."
    if isinstance(exc, Http404):
        return "Resource not found."
    if isinstance(exc, APIException):
        return (
            str(exc.detail) if isinstance(exc.detail, str) else str(exc.default_detail)
        )
    return "An error occurred."
