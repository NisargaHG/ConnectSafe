from routing_ai import predict_best_node

MIN_BATTERY_THRESHOLD = 20

def battery_aware_route(nodes):
    """
    Select the best next-hop node while avoiding
    nodes with critically low battery.

    Parameters:
        nodes (list):
            List of nearby network nodes.

    Returns:
        dict:
            AI routing result after battery filtering.
    """

    eligible_nodes = []

    for node in nodes:

        if (
            node["available"] == 1
            and node["battery"] >= MIN_BATTERY_THRESHOLD
        ):
            eligible_nodes.append(node)

    if not eligible_nodes:

        return {
            "status": "No battery-safe routing node",
            "best_node": None,
            "probability": 0,
            "ranking": []
        }

    return predict_best_node(eligible_nodes)

if __name__ == "__main__":

    test_nodes = [
        {
            "node_id": "Node_B",
            "battery": 8,
            "signal_strength": 95,
            "distance": 10,
            "congestion": 5,
            "packet_loss": 1,
            "available": 1,
            "latency": 20,
            "queue_size": 1
        },

        {
            "node_id": "Node_C",
            "battery": 75,
            "signal_strength": 85,
            "distance": 30,
            "congestion": 15,
            "packet_loss": 3,
            "available": 1,
            "latency": 40,
            "queue_size": 2
        },

        {
            "node_id": "Node_D",
            "battery": 55,
            "signal_strength": 75,
            "distance": 50,
            "congestion": 25,
            "packet_loss": 5,
            "available": 1,
            "latency": 60,
            "queue_size": 4
        }
    ]

    result = battery_aware_route(test_nodes)

    print("\n----- BATTERY-AWARE ROUTING -----")

    print("Status:", result["status"])
    print("Best Node:", result["best_node"])

    print(
        "AI Probability:",
        f"{result['probability'] * 100:.2f}%"
    )

