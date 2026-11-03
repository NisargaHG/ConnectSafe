from django.urls import path
from .views import StoreForwardView

urlpatterns = [
    path(
        "store-forward/<int:message_id>/",
        StoreForwardView.as_view(),
        name="store-forward"
    ),
    path(
        "stored-messages/",
        StoreForwardView.as_view(),
        name="stored-messages"
    ),
]