from django.urls import path

from .views import (
    EmergencyMessageView,
    EmergencyContactView,
    SOSView,
    EmergencyResponderView,
)

urlpatterns = [

    path(
        "messages/",
        EmergencyMessageView.as_view(),
        name="messages"
    ),

    path(
        "messages/<int:pk>/",
        EmergencyMessageView.as_view(),
        name="message-detail"
    ),

    path(
        "emergency-contacts/",
        EmergencyContactView.as_view(),
        name="emergency-contacts"
    ),

    path(
        "emergency-contacts/<int:pk>/",
        EmergencyContactView.as_view(),
        name="emergency-contact-detail"
    ),

    path(
        "emergency-responders/",
        EmergencyResponderView.as_view(),
        name="emergency-responders"
    ),

    path(
        "sos/",
        SOSView.as_view(),
        name="sos"
    ),
]