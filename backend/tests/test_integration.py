from __future__ import annotations

from typing import TYPE_CHECKING

import pytest

from tests.api_urls import API_V1_PREFIX

if TYPE_CHECKING:
    from django.test import Client


@pytest.mark.integration
class TestHealthCheck:
    def test_health_check_returns_200(self, client: Client) -> None:
        response = client.get(f"{API_V1_PREFIX}/health/")

        assert response.status_code == 200

    def test_health_check_response_body(self, client: Client) -> None:
        response = client.get(f"{API_V1_PREFIX}/health/")

        data = response.json()
        assert data["status"] == "healthy"
        assert data["service"] == "moto-backend"
