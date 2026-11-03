from mesh_network.models import MeshNode


def forward_multi_hop(route):
    """
    Simulate hop-by-hop forwarding through the
    calculated multi-hop route.
    """

    if not route:
        return {
            "status": "Failed",
            "message": "No route available.",
            "hops": []
        }

    hops = []

    for index, hop in enumerate(route):

        node_id = hop["node_id"]

        try:
            node = MeshNode.objects.get(
                id=node_id
            )
        except MeshNode.DoesNotExist:
            return {
                "status": "Failed",
                "message": f"Node {node_id} no longer exists.",
                "hops": hops
            }

        # Node failure
        if node.status != "ACTIVE":

            return {
                "status": "Failed",
                "message": (
                    f"Multi-hop forwarding stopped. "
                    f"{node.node_name} is inactive."
                ),
                "failed_node": node.node_name,
                "failed_hop": index + 1,
                "hops": hops
            }

        hops.append({
            "hop": index + 1,
            "node_id": node.id,
            "node_name": node.node_name,
            "status": "FORWARDED"
        })

    return {
        "status": "Success",
        "message": "Message forwarded through all hops.",
        "hop_count": len(hops),
        "hops": hops
    }