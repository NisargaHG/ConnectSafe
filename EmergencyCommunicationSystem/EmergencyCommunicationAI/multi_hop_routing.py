from battery_aware_routing import battery_aware_route

def find_multi_hop_route(
    source,
    destination,
    network,
    max_hops=5
):
    """
    Build a multi-hop route by repeatedly selecting
    the best battery-safe AI-predicted next-hop node.
    """

    route = [source]
    current_node = source

    visited = {source}

    for _ in range(max_hops):

        # Destination reached
        if current_node == destination:
            return {
                "status": "Success",
                "route": route,
                "hops": len(route) - 1
            }

        # Get neighboring nodes
        nearby_nodes = network.get(current_node, [])

        if not nearby_nodes:
            return {
                "status": "Route Failed - No Neighbors",
                "route": route,
                "hops": len(route) - 1
            }

        # Prevent routing loops
        candidate_nodes = [
            node
            for node in nearby_nodes
            if node["node_id"] not in visited
        ]

        if not candidate_nodes:
            return {
                "status": "Route Failed - No Unvisited Nodes",
                "route": route,
                "hops": len(route) - 1
            }

        # Battery-aware AI selection
        result = battery_aware_route(candidate_nodes)

        if result["best_node"] is None:
            return {
                "status": "Route Failed - No Suitable Node",
                "route": route,
                "hops": len(route) - 1
            }

        next_node = result["best_node"]

        route.append(next_node)
        visited.add(next_node)

        current_node = next_node

    if current_node == destination:
        return {
            "status": "Success",
            "route": route,
            "hops": len(route) - 1
        }

    return {
        "status": "Route Failed - Maximum Hops Reached",
        "route": route,
        "hops": len(route) - 1
    }
if __name__ == "__main__":

    network = {

        "Node_A": [
            {
                "node_id": "Node_B",
                "battery": 10,
                "signal_strength": 95,
                "distance": 15,
                "congestion": 5,
                "packet_loss": 1,
                "available": 1,
                "latency": 20,
                "queue_size": 1
            },

            {
                "node_id": "Node_C",
                "battery": 80,
                "signal_strength": 90,
                "distance": 25,
                "congestion": 10,
                "packet_loss": 2,
                "available": 1,
                "latency": 30,
                "queue_size": 2
            }
        ],

        "Node_C": [
            {
                "node_id": "Node_D",
                "battery": 70,
                "signal_strength": 88,
                "distance": 30,
                "congestion": 12,
                "packet_loss": 2,
                "available": 1,
                "latency": 35,
                "queue_size": 2
            }
        ],

        "Node_D": [
            {
                "node_id": "Node_E",
                "battery": 10,
                "signal_strength": 92,
                "distance": 20,
                "congestion": 8,
                "packet_loss": 1,
                "available": 1,
                "latency": 25,
                "queue_size": 1
            }
        ],

        "Node_E": []
    }

    result = find_multi_hop_route(
        source="Node_A",
        destination="Node_E",
        network=network
    )

    print("\n----- MULTI-HOP AI ROUTING -----")
    print("Status:", result["status"])
    print("Route:", " -> ".join(result["route"]))
    print("Number of Hops:", result["hops"])
