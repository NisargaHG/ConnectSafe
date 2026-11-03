
from django.urls import path
from .views import AIRoutingView, AIAssistantView

urlpatterns = [
    path(
        "ai-routing/<int:message_id>/",
        AIRoutingView.as_view(),
        name="ai-routing",
    ),

    path(
        "ai-assistant/",
        AIAssistantView.as_view(),
        name="ai-assistant",
    ),
]

