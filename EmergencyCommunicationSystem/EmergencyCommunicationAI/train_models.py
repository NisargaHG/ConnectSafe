import pandas as pd
import os
import joblib
#joblib will eventually save trained models

from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier

# Path of processed dataset

input_file = os.path.join(
    "dataset",
    "processed_dataset.csv"
)

# Load dataset

df = pd.read_csv(input_file)

print("Processed dataset loaded successfully!")

print("\nDataset shape:")
print(df.shape)


# Features used by the ML models

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
#We intentionally exlcude the "node_id" and "reliability_score" columns from the features, as they are not relevant for model training.

y = df["good_node"]

# Split data into training and testing sets

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.20,
    random_state=42,
    stratify=y
)

print("\nTraining samples:", len(X_train))
print("Testing samples:", len(X_test))

print("\nTraining Logistic Regression...")

logistic_model = LogisticRegression(
    max_iter=1000,
    class_weight="balanced",
    random_state=42
)
#balanced because our dataset is imbalanced

logistic_model.fit(X_train, y_train)
#Think of .fit() as:X_train Network conditions + y_train Correct labels->LEARNING->Trained Logistic Regression

print("Logistic Regression training completed!")

logistic_predictions = logistic_model.predict(X_test)

print("\nFirst 10 Logistic Regression predictions:")
print(logistic_predictions[:10])


print("\nTraining Decision Tree...")

decision_tree_model = DecisionTreeClassifier(
    max_depth=10,
    class_weight="balanced",
    random_state=42
)

decision_tree_model.fit(X_train, y_train)

decision_tree_predictions = decision_tree_model.predict(X_test)

print("Decision Tree training completed!")

print("\nFirst 10 Decision Tree predictions:")
print(decision_tree_predictions[:10])

print("\nTraining Random Forest...")

random_forest_model = RandomForestClassifier(
    n_estimators=100,
    class_weight="balanced",
    random_state=42,
    n_jobs=-1
)
#100 means building 100 trees

random_forest_model.fit(X_train, y_train)

random_forest_predictions = random_forest_model.predict(X_test)

print("Random Forest training completed!")

print("\nFirst 10 Random Forest predictions:")
print(random_forest_predictions[:10])

# -----------------------------------
# Save trained models
# -----------------------------------

os.makedirs("models", exist_ok=True)

joblib.dump(
    logistic_model,
    os.path.join("models", "logistic_regression.pkl")
)

joblib.dump(
    decision_tree_model,
    os.path.join("models", "decision_tree.pkl")
)

joblib.dump(
    random_forest_model,
    os.path.join("models", "random_forest.pkl")
)
#the dumps save the trained models in the "models" directory as .pkl files, which can be loaded later for making predictions.
print("\nAll trained models saved successfully!")
