import os
import joblib
import pandas as pd
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
MODEL_PATH = BASE_DIR / "models" / "logistic_regression.pkl"

model = joblib.load(MODEL_PATH)

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
def predict_best_node(nodes):
    """
    Predict the best communication node for routing.

    Parameters:
        nodes (list):
            List of dictionaries representing nearby network nodes.

    Returns:
        dict:
            A dictionary containing:
            - status: Routing status.
            - best_node: Selected node ID.
            - probability: AI confidence score.
            - ranking: Ranked list of all candidate nodes.
    """

def predict_best_node(nodes):
    nodes_df = pd.DataFrame(nodes)
    nodes_df["battery_signal_score"] = (
    nodes_df["battery"]
    * nodes_df["signal_strength"]
) / 100

    nodes_df["network_quality_score"] = (
        (100 - nodes_df["congestion"])
        + (100 - (nodes_df["packet_loss"] * 2.5))
    ) / 2

    X = nodes_df[feature_columns]

    nodes_df["prediction"] = model.predict(X)

    nodes_df["ai_probability"] = (
        model.predict_proba(X)[:, 1]
    )

    nodes_df.loc[
        nodes_df["available"] == 0,
        "ai_probability"
    ] = 0

    ranked_nodes = nodes_df.sort_values(
        by="ai_probability",
        ascending=False
    )

    MINIMUM_PROBABILITY = 0.50

    available_nodes = ranked_nodes[
        ranked_nodes["available"] == 1
    ]

    if available_nodes.empty:

        return {
            "status": "No available node",
            "best_node": None,
            "probability": 0,
            "ranking": ranked_nodes.to_dict("records")
        }

    best_node = available_nodes.iloc[0]

    if best_node["ai_probability"] < MINIMUM_PROBABILITY:

        return {
            "status": "No suitable node",
            "best_node": None,
            "probability": 0,
            "ranking": ranked_nodes.to_dict("records")
        }

    return {
        "status": "Success",
        "best_node": best_node["node_id"],
        "probability": float(best_node["ai_probability"]),
        "ranking": ranked_nodes.to_dict("records")
    }

if __name__ == "__main__":
    sample_nodes = [
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

    result = predict_best_node(sample_nodes)

    print(result)