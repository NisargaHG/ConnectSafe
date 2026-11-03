from .models import StoredMessage
from self_healing.services import heal_route


def forward_message(emergency_message):
    """
    Forward an emergency message through the AI-selected node.

    If the selected node becomes unavailable, trigger
    the existing AI self-healing mechanism.
    """

    # ============================================
    # 1. GET AI ROUTE
    # ============================================

    try:
        ai_route = emergency_message.ai_route

    except Exception:
        return {
            "status": "error",
            "message": "AI route not found."
        }

    selected_node = ai_route.selected_node

    if selected_node is None:
        return {
            "status": "error",
            "message": "No mesh node selected."
        }

    # ============================================
    # 2. GET / CREATE STORED MESSAGE
    # ============================================

    stored_message, created = StoredMessage.objects.get_or_create(
        emergency_message=emergency_message,
        defaults={
            "selected_node": selected_node,
            "status": "PENDING"
        }
    )

    # ============================================
    # 3. NODE IS ACTIVE
    # ============================================

    if selected_node.status == "ACTIVE":

        stored_message.selected_node = selected_node
        stored_message.status = "FORWARDED"
        stored_message.save()

        return {
            "status": "Success",
            "message": (
                "Emergency message forwarded through "
                f"{selected_node.node_name}."
            ),
            "stored_message_id": stored_message.id,
            "node": selected_node.node_name
        }

    # ============================================
    # 4. NODE IS INACTIVE → SELF HEAL
    # ============================================

    old_node_name = selected_node.node_name

    stored_message.status = "STORED"
    stored_message.retry_count += 1
    stored_message.save()

    # Call your EXISTING self-healing implementation
    healing_result = heal_route(ai_route)

    # ============================================
    # 5. SELF-HEALING SUCCESSFUL
    # ============================================

    if healing_result.get("status") == "Success":

        new_node = ai_route.selected_node

        stored_message.selected_node = new_node
        stored_message.status = "FORWARDED"
        stored_message.save()

        return {
            "status": "Self-Healed",
            "message": (
                "Original mesh node unavailable. "
                "Emergency successfully rerouted."
            ),
            "stored_message_id": stored_message.id,
            "old_node": old_node_name,
            "new_node": new_node.node_name,
            "retry_count": stored_message.retry_count,
            "self_healing": healing_result
        }

    # ============================================
    # 6. SELF-HEALING FAILED
    # ============================================

    return {
        "status": "Stored",
        "message": (
            "Mesh node unavailable. "
            "Self-healing could not find an alternative. "
            "Emergency stored for later forwarding."
        ),
        "stored_message_id": stored_message.id,
        "node": old_node_name,
        "retry_count": stored_message.retry_count,
        "self_healing": healing_result
    }