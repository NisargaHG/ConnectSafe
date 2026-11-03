
from .models import StoredMessage


def forward_message(emergency_message):
    """
    Forward an emergency message through the node
    selected by AI routing.
    """

    # Get the AI-selected node
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

    # Create or get the stored message
    stored_message, created = StoredMessage.objects.get_or_create(
        emergency_message=emergency_message,
        defaults={
            "selected_node": selected_node,
            "status": "PENDING"
        }
    )

    # Node is available
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

    # Node is unavailable
    stored_message.selected_node = selected_node
    stored_message.status = "STORED"
    stored_message.retry_count += 1
    stored_message.save()

    return {
        "status": "Stored",
        "message": (
            "Mesh node unavailable. "
            "Emergency message stored for later forwarding."
        ),
        "stored_message_id": stored_message.id,
        "node": selected_node.node_name
    }
