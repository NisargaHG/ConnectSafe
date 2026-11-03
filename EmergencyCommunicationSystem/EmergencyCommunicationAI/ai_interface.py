from battery_aware_routing import battery_aware_route


REQUIRED_FIELDS = [
    "node_id",
    "battery",
    "signal_strength",
    "distance",
    "congestion",
    "packet_loss",
    "available",
    "latency",
    "queue_size"
]


def get_routing_decision(nodes):
    """
    Backend-facing interface for AI-based routing.

    Parameters:
        nodes (list):
            List of nearby communication nodes.

    Returns:
        dict:
            Routing decision containing status,
            best node, confidence and ranking.
    """

    # Check input type
    if not isinstance(nodes, list):
        return {
            "status": "Error",
            "message": "Input must be a list of nodes."
        }

    # Check empty input
    if len(nodes) == 0:
        return {
            "status": "Error",
            "message": "No nearby nodes provided."
        }

    # Validate required fields
    for node in nodes:

        for field in REQUIRED_FIELDS:

            if field not in node:
                return {
                    "status": "Error",
                    "message":
                        f"Missing field '{field}' "
                        f"for node {node.get('node_id', 'Unknown')}"
                }

    # Call existing battery-aware AI routing
    result = battery_aware_route(nodes)

    return {
        "status": result["status"],
        "best_node": result["best_node"],
        "confidence": result["probability"],
        "ranking": result["ranking"]
    }
if __name__ == "__main__":

    sample_nodes = [
        {
            "node_id": "Node_B",
            "battery": 85,
            "signal_strength": 90,
            "distance": 20,
            "congestion": 10,
            "packet_loss": 2,
            "available": 1,
            "latency": 30,
            "queue_size": 1
        },

        {
            "node_id": "Node_C",
            "battery": 60,
            "signal_strength": 75,
            "distance": 40,
            "congestion": 25,
            "packet_loss": 5,
            "available": 1,
            "latency": 60,
            "queue_size": 3
        }
    ]

    result = get_routing_decision(sample_nodes)

    print("\n----- AI BACKEND INTERFACE TEST -----")

    print("Status:", result["status"])
    print("Best Node:", result.get("best_node"))

    if "confidence" in result:
        print(
            "Confidence:",
            f"{result['confidence'] * 100:.2f}%"
        )

