from django.urls import path
from .views import SelfHealingView

urlpatterns = [
    path(
        "self-healing/<int:route_id>/",
        SelfHealingView.as_view(),
        name="self-healing",
    ),
]