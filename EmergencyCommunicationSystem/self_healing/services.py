
from math import radians, sin, cos, sqrt, atan2

from ai_routing.ai_service import route_emergency
from ai_routing.models import AIRoute
from mesh_network.models import MeshNode

from .models import SelfHealingLog


def calculate_distance(lat1, lon1, lat2, lon2):
    """
    Calculate distance between two GPS coordinates in kilometers.
    """

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

    c = 2 * atan2(sqrt(a), sqrt(1 - a))

    return R * c


def heal_route(ai_route):
    """
    Automatically heal an AIRoute when its selected
    mesh node becomes inactive.

    Returns a dictionary containing the healing result.
    """

    current_node = ai_route.selected_node

    # --------------------------------------------------
    # 1. Check selected node
    # --------------------------------------------------

    if current_node is None:

        return {
            "status": "error",
            "message": "No node assigned to this route."
        }

    # --------------------------------------------------
    # 2. Check whether healing is necessary
    # --------------------------------------------------

    if current_node.status == "ACTIVE":

        return {
            "status": "skipped",
            "message": "Current node is active.",
            "selected_node": current_node.node_name
        }

    # --------------------------------------------------
    # 3. Get active replacement nodes
    # --------------------------------------------------

    active_nodes = MeshNode.objects.filter(
        status="ACTIVE"
    ).exclude(
        id=current_node.id
    )

    if not active_nodes.exists():

        return {
            "status": "error",
            "message": "No active replacement node available."
        }

    # --------------------------------------------------
    # 4. Get emergency message
    # --------------------------------------------------

    emergency_message = ai_route.emergency_message

    # --------------------------------------------------
    # 5. Prepare AI input
    # --------------------------------------------------

    nodes = []

    for node in active_nodes:

        distance = calculate_distance(
            emergency_message.latitude,
            emergency_message.longitude,
            node.latitude,
            node.longitude
        )

        nodes.append(
            {
                "node_id": str(node.id),

                "battery": float(
                    node.battery_level
                ),

                "signal_strength": float(
                    node.signal_strength
                ),

                "distance": round(
                    distance,
                    2
                ),

                # Temporary telemetry
                "congestion": 0.0,
                "packet_loss": 0.0,
                "available": 1,
                "latency": 0.0,
                "queue_size": 0
            }
        )

    # --------------------------------------------------
    # 6. Ask AI for replacement
    # --------------------------------------------------

    ai_result = route_emergency(nodes)

    if ai_result.get("status") != "Success":

        return {
            "status": "error",
            "message": "AI self-healing routing failed.",
            "ai": ai_result
        }

    # --------------------------------------------------
    # 7. Get AI-selected node
    # --------------------------------------------------

    best_node_id = ai_result.get("best_node")

    try:

        new_node = MeshNode.objects.get(
            id=int(best_node_id),
            status="ACTIVE"
        )

    except (
        MeshNode.DoesNotExist,
        TypeError,
        ValueError
    ):

        return {
            "status": "error",
            "message": "AI selected an invalid replacement node.",
            "ai": ai_result
        }

    # --------------------------------------------------
    # 8. Prevent selecting the failed node
    # --------------------------------------------------

    if new_node.id == current_node.id:

        return {
            "status": "error",
            "message": "AI selected the failed node.",
            "ai": ai_result
        }

    # --------------------------------------------------
    # 9. Store old node
    # --------------------------------------------------

    old_node_name = current_node.node_name

    # --------------------------------------------------
    # 10. Update AIRoute
    # --------------------------------------------------

    ai_route.selected_node = new_node

    ai_route.recommended_route = (
        "AI Self-Healed Route"
    )

    ai_route.confidence_score = ai_result.get(
        "confidence",
        0
    )

    ai_route.save()

    # --------------------------------------------------
    # 11. Create healing log
    # --------------------------------------------------

    SelfHealingLog.objects.create(
        ai_route=ai_route,
        old_node=old_node_name,
        new_node=new_node.node_name
    )

    # --------------------------------------------------
    # 12. Return result
    # --------------------------------------------------

    return {
        "status": "Success",

        "message":
            "Network self-healed using AI.",

        "route_id":
            ai_route.id,

        "old_node":
            old_node_name,

        "new_node":
            new_node.node_name,

        "ai":
            ai_result
    }

