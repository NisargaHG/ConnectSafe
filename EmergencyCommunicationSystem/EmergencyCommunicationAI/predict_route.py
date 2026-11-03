import os
import joblib
import pandas as pd

# -----------------------------------
# Load trained routing model
# -----------------------------------

model_path = os.path.join(
    "models",
    "logistic_regression.pkl"
)

model = joblib.load(model_path)

print("AI routing model loaded successfully!")

# -----------------------------------
# Features expected by the model
# -----------------------------------

feature_columns = [
    "battery",
    "signal_strength",
    "distance",
    "congestion",
    "packet_loss",
    "available",
    "latency",
    "queue_size",
    "battery_signal_score",
    "network_quality_score"
]

# -----------------------------------
# Example nearby nodes
# -----------------------------------

nodes = [
    {
        "node_id": "Node_B",
        "battery": 90,
        "signal_strength": 85,
        "distance": 30,
        "congestion": 20,
        "packet_loss": 3,
        "available": 1,
        "latency": 40,
        "queue_size": 2
    },

    {
        "node_id": "Node_C",
        "battery": 65,
        "signal_strength": 95,
        "distance": 15,
        "congestion": 10,
        "packet_loss": 1,
        "available": 1,
        "latency": 25,
        "queue_size": 1
    },

    {
        "node_id": "Node_D",
        "battery": 35,
        "signal_strength": 60,
        "distance": 100,
        "congestion": 55,
        "packet_loss": 15,
        "available": 1,
        "latency": 180,
        "queue_size": 10
    },

    {
        "node_id": "Node_E",
        "battery": 95,
        "signal_strength": 90,
        "distance": 20,
        "congestion": 5,
        "packet_loss": 0,
        "available": 0,
        "latency": 20,
        "queue_size": 0
    }
]

nodes_df = pd.DataFrame(nodes)

print("\nNearby nodes received:")

print(
    nodes_df[
        [
            "node_id",
            "battery",
            "signal_strength",
            "distance",
            "available"
        ]
    ]
)

# -----------------------------------
# Feature engineering
# -----------------------------------

nodes_df["battery_signal_score"] = (
    nodes_df["battery"]
    * nodes_df["signal_strength"]
) / 100


nodes_df["network_quality_score"] = (
    (100 - nodes_df["congestion"])
    + (100 - (nodes_df["packet_loss"] * 2.5))
) / 2

X_nodes = nodes_df[feature_columns]

nodes_df["prediction"] = model.predict(X_nodes)

nodes_df["ai_probability"] = (
    model.predict_proba(X_nodes)[:, 1]
)

# Offline nodes cannot be routing candidates

nodes_df.loc[
    nodes_df["available"] == 0,
    "ai_probability"
] = 0

# -----------------------------------
# Rank routing candidates
# -----------------------------------

ranked_nodes = nodes_df.sort_values(
    by="ai_probability",
    ascending=False
)

print("\n----- AI ROUTING RANKING -----")

for rank, (_, node) in enumerate(
    ranked_nodes.iterrows(),
    start=1
):
    print(
        f"{rank}. {node['node_id']} "
        f"- Probability: "
        f"{node['ai_probability'] * 100:.2f}%"
    )

# -----------------------------------
# Select best next-hop node
# -----------------------------------

MINIMUM_PROBABILITY = 0.50

available_nodes = ranked_nodes[
    ranked_nodes["available"] == 1
]

if available_nodes.empty:

    print("\nNo available routing node found!")

else:

    best_node = available_nodes.iloc[0]

    if best_node["ai_probability"] < MINIMUM_PROBABILITY:

        print("\nNo suitable routing node found!")

    else:

        print("\n----- BEST NEXT HOP -----")

        print("Node:", best_node["node_id"])

        print(
            "AI probability:",
            f"{best_node['ai_probability'] * 100:.8f}%"
        )