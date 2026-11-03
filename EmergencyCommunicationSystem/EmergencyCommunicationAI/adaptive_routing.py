from multi_hop_routing import find_multi_hop_route


def update_node_condition(
    network,
    node_id,
    parameter,
    new_value
):
    """
    Update a network parameter for a specific node.

    Examples:
        battery
        signal_strength
        congestion
        packet_loss
        available
        latency
        queue_size
    """

    updated = False

    for neighbors in network.values():

        for node in neighbors:

            if node["node_id"] == node_id:
                node[parameter] = new_value
                updated = True

    return updated


def adaptive_route(
    source,
    destination,
    network,
    max_hops=5
):
    """
    Calculate the current best route based on
    the latest network conditions.
    """

    return find_multi_hop_route(
        source=source,
        destination=destination,
        network=network,
        max_hops=max_hops
    )


if __name__ == "__main__":

    network = {

        "Node_A": [
            {
                "node_id": "Node_B",
                "battery": 85,
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
                "battery": 70,
                "signal_strength": 75,
                "distance": 35,
                "congestion": 20,
                "packet_loss": 4,
                "available": 1,
                "latency": 50,
                "queue_size": 3
            }
        ],

        "Node_B": [
            {
                "node_id": "Node_D",
                "battery": 85,
                "signal_strength": 95,
                "distance": 15,
                "congestion": 5,
                "packet_loss": 1,
                "available": 1,
                "latency": 20,
                "queue_size": 1
            }
        ],

        "Node_C": [
            {
                "node_id": "Node_D",
                "battery": 80,
                "signal_strength": 90,
                "distance": 20,
                "congestion": 8,
                "packet_loss": 1,
                "available": 1,
                "latency": 25,
                "queue_size": 1
            }
        ],

        "Node_D": [
            {
                "node_id": "Node_E",
                "battery": 75,
                "signal_strength": 92,
                "distance": 15,
                "congestion": 5,
                "packet_loss": 1,
                "available": 1,
                "latency": 20,
                "queue_size": 1
            }
        ],

        "Node_E": []
    }

    # -----------------------------------
    # Calculate initial route
    # -----------------------------------

    initial_result = adaptive_route(
        source="Node_A",
        destination="Node_E",
        network=network
    )

    print("\n----- INITIAL ROUTE -----")

    print("Status:", initial_result["status"])

    print(
        "Route:",
        " -> ".join(initial_result["route"])
    )

    print(
        "Number of Hops:",
        initial_result["hops"]
    )

    # -----------------------------------
    # Simulate Node_B packet loss increase
    # -----------------------------------

    print("\nNode_B packet loss has increased!")

    update_node_condition(
        network,
        "Node_B",
        "packet_loss",
        40
    )

    # -----------------------------------
    # Recalculate route
    # -----------------------------------

    new_result = adaptive_route(
        source="Node_A",
        destination="Node_E",
        network=network
    )

    print("\n----- ADAPTIVE ROUTE -----")

    print("Status:", new_result["status"])

    print(
        "Route:",
        " -> ".join(new_result["route"])
    )

    print(
        "Number of Hops:",
        new_result["hops"]
    )

    # -----------------------------------
    # Check whether rerouting occurred
    # -----------------------------------

    if initial_result["route"] != new_result["route"]:

        print(
            "\nNetwork change detected."
            " Route recalculated successfully!"
        )

    else:

        print(
            "\nNo route change was required."
        )
