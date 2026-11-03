
from django.urls import path

from .views import (
    MeshNodeView,
    MeshNodeHeartbeatView,
)


urlpatterns = [

    path(
        "mesh-nodes/",
        MeshNodeView.as_view(),
        name="mesh-nodes"
    ),

    path(
        "mesh-nodes/heartbeat/",
        MeshNodeHeartbeatView.as_view(),
        name="mesh-node-heartbeat"
    ),

]

