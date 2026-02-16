"""
URL configuration for moto project.
"""

from django.contrib import admin
from django.http import HttpRequest, JsonResponse
from django.urls import path
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView


def health_check(request: HttpRequest) -> JsonResponse:
    """Simple health check endpoint"""
    return JsonResponse({"status": "healthy", "service": "moto-backend"})


urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/v1/health/", health_check, name="health-check"),
    # API v1
    # API documentation
    path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
    path(
        "api/schema/swagger-ui/",
        SpectacularSwaggerView.as_view(url_name="schema"),
        name="swagger-ui",
    ),
]
