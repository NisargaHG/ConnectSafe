import numpy as np
import pandas as pd
import os

NUM_SAMPLES = 10000

np.random.seed(42)

battery = np.random.randint(5, 101, NUM_SAMPLES)

signal_strength = np.random.randint(10, 101, NUM_SAMPLES)

distance = np.random.randint(1, 301, NUM_SAMPLES)

congestion = np.random.randint(0, 101, NUM_SAMPLES)
#Network load

packet_loss = np.random.randint(0, 41, NUM_SAMPLES)

available = np.random.randint(0, 2, NUM_SAMPLES)
#online/offline

latency = np.random.randint(10, 501, NUM_SAMPLES)
#Communication delay

queue_size = np.random.randint(0, 21, NUM_SAMPLES)
#Messages waiting

# Convert negative parameters into scores where higher = better

distance_score = 100 * (1 - distance / 300)

congestion_score = 100 - congestion

packet_loss_score = 100 * (1 - packet_loss / 40)

latency_score = 100 * (1 - latency / 500)

queue_score = 100 * (1 - queue_size / 20)

# Calculate overall reliability of each node

reliability_score = (
    0.25 * battery
    + 0.25 * signal_strength
    + 0.15 * distance_score
    + 0.10 * congestion_score
    + 0.10 * packet_loss_score
    + 0.05 * latency_score
    + 0.05 * queue_score
    + 0.05 * (available * 100)
)

# Offline nodes cannot be selected for routing

reliability_score = np.where(
    available == 1,
    reliability_score,
    0
)

# Target variable
# 1 = suitable node
# 0 = unsuitable node

good_node = (reliability_score >= 60).astype(int)

# Create unique node observation IDs

node_ids = [
    f"Node_{i+1}"
    for i in range(NUM_SAMPLES)
]

# Create dataset

df = pd.DataFrame({
    "node_id": node_ids,
    "battery": battery,
    "signal_strength": signal_strength,
    "distance": distance,
    "congestion": congestion,
    "packet_loss": packet_loss,
    "available": available,
    "latency": latency,
    "queue_size": queue_size,
    "reliability_score": reliability_score.round(2),
    "good_node": good_node
})

# Path where dataset will be stored

output_file = os.path.join(
    "dataset",
    "routing_dataset.csv"
)

# Save DataFrame as CSV

df.to_csv(output_file, index=False)
print("Dataset generated successfully!")

print("\nTotal samples:")
print(len(df))

print("\nFirst 5 rows:")
print(df.head())

print("\nGood/Bad node distribution:")
print(df["good_node"].value_counts())