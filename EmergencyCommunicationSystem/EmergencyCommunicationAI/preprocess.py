import pandas as pd
import numpy as np
import os

from sklearn.model_selection import train_test_split

# Path of the raw dataset

input_file = os.path.join(
    "dataset",
    "routing_dataset.csv"
)

# Load dataset

df = pd.read_csv(input_file)
#reads yesterday's CSV and converts it back into a Pandas DataFrame.

print("Dataset loaded successfully!")

print("\nDataset shape:")
print(df.shape)
#gives the number of rows and columns in the dataset.

print("\nFirst 5 rows:")
print(df.head())

print("\nColumn names:")
print(df.columns.tolist())

print("\nData types:")
print(df.dtypes)
#This matters because ML models require numerical input.

print("\nMissing values:")
print(df.isnull().sum())
#ML models generally can't simply consume arbitrary missing values.
#Our generated dataset should have none, but we still perform and document the check.

df = df.dropna()
#removes the missing values from the dataset, if any.Later, with real data, we may use imputation instead of simply dropping rows.

duplicate_count = df.duplicated().sum()

print("\nDuplicate rows:")
print(duplicate_count)

df = df.drop_duplicates()
#Again, our synthetic data likely has zero exact duplicate rows because node_id is unique.

print("\nFeature ranges:")

features_to_check = [
    "battery",
    "signal_strength",
    "distance",
    "congestion",
    "packet_loss",
    "available",
    "latency",
    "queue_size"
]

for feature in features_to_check:
    print(
        feature,
        "Min:", df[feature].min(),
        "Max:", df[feature].max()
    )

print("\nTarget distribution:")

print(df["good_node"].value_counts())

print("\nTarget percentage:")

print(
    df["good_node"].value_counts(normalize=True) * 100
)
#Percentage of suitable vs unsuitable nodes in the dataset. This is important for understanding class balance, which can affect model performance.

df["battery_signal_score"] = (
    df["battery"] * df["signal_strength"]
) / 100

df["network_quality_score"] = (
    (100 - df["congestion"])
    + (100 - (df["packet_loss"] * 2.5))
) / 2

#2.5 because packet loss ranges from 0 to 40 we will convert it to 0 to 100 by multiplying by 2.5.
#Lower congestion + Lower packet loss = Higher network quality

print("\nNew features created successfully!")

print(
    df[
        [
            "battery",
            "signal_strength",
            "battery_signal_score",
            "congestion",
            "packet_loss",
            "network_quality_score"
        ]
    ].head()
)

# Select features for machine learning

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

X = df[feature_columns]

y = df["good_node"]

# X is the info given to ai and y is the target variable we want to predict.
# also the reliability score is not included in the features(X) because That would cause target leakage and make our model results misleading. So we're intentionally excluding it.

# Split dataset into training and testing data

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.20,
    random_state=42,
    stratify=y
)

#helps maintain approximately the same ratio in both training and testing data. So instead of accidentally getting a strange split, we should have roughly:we will get ratios in numbers

print("\nTraining samples:")
print(len(X_train))

print("\nTesting samples:")
print(len(X_test))

print("\nTraining target distribution:")
print(y_train.value_counts())

print("\nTesting target distribution:")
print(y_test.value_counts())

# Save processed dataset

output_file = os.path.join(
    "dataset",
    "processed_dataset.csv"
)

df.to_csv(output_file, index=False)

print("\nProcessed dataset saved successfully!")
print("Saved at:", output_file)
