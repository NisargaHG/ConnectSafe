from math import radians, sin, cos, sqrt, atan2

from .models import MeshNode


def calculate_distance(lat1, lon1, lat2, lon2):
    """Return distance in kilometers."""

    R = 6371.0

    lat1 = radians(lat1)
    lon1 = radians(lon1)
    lat2 = radians(lat2)
    lon2 = radians(lon2)

    dlat = lat2 - lat1
    dlon = lon2 - lon1

    a = (
        sin(dlat / 2) ** 2
        + cos(lat1)
        * cos(lat2)
        * sin(dlon / 2) ** 2
    )

    c = 2 * atan2(
        sqrt(a),
        sqrt(1 - a)
    )

    return R * c


def build_multi_hop_route(emergency_message):
    """
    Build a simple multi-hop route using active mesh nodes.

    Nodes are ordered based on distance from the emergency.
    """

    active_nodes = MeshNode.objects.filter(
        status="ACTIVE"
    )

    if not active_nodes.exists():
        return {
            "status": "Failed",
            "message": "No active mesh nodes available.",
            "route": []
        }

    node_data = []

    for node in active_nodes:

        distance = calculate_distance(
            emergency_message.latitude,
            emergency_message.longitude,
            node.latitude,
            node.longitude
        )

        node_data.append({
            "node": node,
            "distance": distance
        })

    # Closest nodes first
    node_data.sort(
        key=lambda item: item["distance"]
    )

    route = []

    for item in node_data:

        node = item["node"]

        route.append({
            "node_id": node.id,
            "node_name": node.node_name,
            "distance_km": round(
                item["distance"],
                2
            ),
            "battery": node.battery_level,
            "signal_strength": node.signal_strength
        })

    return {
        "status": "Success",
        "message": "Multi-hop route created.",
        "hop_count": len(route),
        "route": route
    }