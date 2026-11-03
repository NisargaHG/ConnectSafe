import os
import joblib
import pandas as pd
import matplotlib.pyplot as plt

from sklearn.model_selection import train_test_split
from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    confusion_matrix,
    ConfusionMatrixDisplay,
    roc_curve,
    roc_auc_score
)
os.makedirs("graphs", exist_ok=True)
# -----------------------------------
# Load processed dataset
# -----------------------------------

input_file = os.path.join(
    "dataset",
    "processed_dataset.csv"
)

df = pd.read_csv(input_file)

print("Processed dataset loaded successfully!")

print("\nDataset shape:")
print(df.shape)

# -----------------------------------
# Select features and target
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
#These must be in the same order used during training.

X = df[feature_columns]

y = df["good_node"]

# -----------------------------------
# Recreate train-test split
# -----------------------------------

_, X_test, _, y_test = train_test_split(
    X,
    y,
    test_size=0.20,
    random_state=42,
    stratify=y
)

print("\nTesting samples:", len(X_test))
# We only need the test set for evaluation.
# Using the same random_state and stratify reproduces the Day 3 test split.


# -----------------------------------
# Load trained models
# -----------------------------------

logistic_model = joblib.load(
    os.path.join("models", "logistic_regression.pkl")
)

decision_tree_model = joblib.load(
    os.path.join("models", "decision_tree.pkl")
)

random_forest_model = joblib.load(
    os.path.join("models", "random_forest.pkl")
)

print("\nAll trained models loaded successfully!")

# -----------------------------------
# Generate predictions
# -----------------------------------

logistic_predictions = logistic_model.predict(X_test)

decision_tree_predictions = decision_tree_model.predict(X_test)

random_forest_predictions = random_forest_model.predict(X_test)

print("\nPredictions generated successfully!")

#each model has to predict a total of 2,000 samples, which is the size of the test set.

# -----------------------------------
# Logistic Regression Evaluation
# -----------------------------------

logistic_accuracy = accuracy_score(
    y_test,
    logistic_predictions
)

logistic_precision = precision_score(
    y_test,
    logistic_predictions,
    zero_division=0
)

logistic_recall = recall_score(
    y_test,
    logistic_predictions,
    zero_division=0
)

logistic_f1 = f1_score(
    y_test,
    logistic_predictions,
    zero_division=0
)

print("\n----- Logistic Regression -----")

print("Accuracy :", round(logistic_accuracy, 4))
print("Precision:", round(logistic_precision, 4))
print("Recall   :", round(logistic_recall, 4))
print("F1 Score :", round(logistic_f1, 4))

#class 1 denotes good nodes and class 0 denotes bad nodes. 

# -----------------------------------
# Decision Tree Evaluation
# -----------------------------------

decision_tree_accuracy = accuracy_score(
    y_test,
    decision_tree_predictions
)

decision_tree_precision = precision_score(
    y_test,
    decision_tree_predictions,
    zero_division=0
)

decision_tree_recall = recall_score(
    y_test,
    decision_tree_predictions,
    zero_division=0
)

decision_tree_f1 = f1_score(
    y_test,
    decision_tree_predictions,
    zero_division=0
)

print("\n----- Decision Tree -----")

print("Accuracy :", round(decision_tree_accuracy, 4))
print("Precision:", round(decision_tree_precision, 4))
print("Recall   :", round(decision_tree_recall, 4))
print("F1 Score :", round(decision_tree_f1, 4))

# -----------------------------------
# Random Forest Evaluation
# -----------------------------------

random_forest_accuracy = accuracy_score(
    y_test,
    random_forest_predictions
)

random_forest_precision = precision_score(
    y_test,
    random_forest_predictions,
    zero_division=0
)

random_forest_recall = recall_score(
    y_test,
    random_forest_predictions,
    zero_division=0
)

random_forest_f1 = f1_score(
    y_test,
    random_forest_predictions,
    zero_division=0
)

print("\n----- Random Forest -----")

print("Accuracy :", round(random_forest_accuracy, 4))
print("Precision:", round(random_forest_precision, 4))
print("Recall   :", round(random_forest_recall, 4))
print("F1 Score :", round(random_forest_f1, 4))

# -----------------------------------
# Confusion Matrices
# -----------------------------------

logistic_cm = confusion_matrix(
    y_test,
    logistic_predictions
)

decision_tree_cm = confusion_matrix(
    y_test,
    decision_tree_predictions
)

random_forest_cm = confusion_matrix(
    y_test,
    random_forest_predictions
)

print("\n----- Confusion Matrices -----")

print("\nLogistic Regression:")
print(logistic_cm)

print("\nDecision Tree:")
print(decision_tree_cm)

print("\nRandom Forest:")
print(random_forest_cm)

# -----------------------------------
# Logistic Regression Confusion Matrix
# -----------------------------------

ConfusionMatrixDisplay(
    confusion_matrix=logistic_cm,
    display_labels=["Bad Node", "Good Node"]
).plot()

plt.title("Logistic Regression Confusion Matrix")
plt.tight_layout()

plt.savefig(
    os.path.join(
        "graphs",
        "logistic_confusion_matrix.png"
    )
)

plt.close()

# -----------------------------------
# Decision Tree Confusion Matrix
# -----------------------------------

ConfusionMatrixDisplay(
    confusion_matrix=decision_tree_cm,
    display_labels=["Bad Node", "Good Node"]
).plot()

plt.title("Decision Tree Confusion Matrix")
plt.tight_layout()

plt.savefig(
    os.path.join(
        "graphs",
        "decision_tree_confusion_matrix.png"
    )
)

plt.close()

# -----------------------------------
# Random Forest Confusion Matrix
# -----------------------------------

ConfusionMatrixDisplay(
    confusion_matrix=random_forest_cm,
    display_labels=["Bad Node", "Good Node"]
).plot()

plt.title("Random Forest Confusion Matrix")
plt.tight_layout()

plt.savefig(
    os.path.join(
        "graphs",
        "random_forest_confusion_matrix.png"
    )
)

plt.close()

print("\nConfusion matrix graphs saved successfully!")

# -----------------------------------
# Model Comparison Graph
# -----------------------------------

comparison_df = pd.DataFrame({
    "Model": [
        "Logistic Regression",
        "Decision Tree",
        "Random Forest"
    ],

    "Accuracy": [
        logistic_accuracy,
        decision_tree_accuracy,
        random_forest_accuracy
    ],

    "Precision": [
        logistic_precision,
        decision_tree_precision,
        random_forest_precision
    ],

    "Recall": [
        logistic_recall,
        decision_tree_recall,
        random_forest_recall
    ],

    "F1 Score": [
        logistic_f1,
        decision_tree_f1,
        random_forest_f1
    ]
})

print("\n----- Model Comparison -----")
print(comparison_df)

comparison_df.set_index("Model").plot(
    kind="bar",
    figsize=(10, 6)
)

plt.title("Machine Learning Model Comparison")
plt.ylabel("Score")
plt.xlabel("Model")
plt.ylim(0, 1.05)

plt.xticks(rotation=0)

plt.tight_layout()

plt.savefig(
    os.path.join(
        "graphs",
        "model_comparison.png"
    )
)

plt.close()

print("\nModel comparison graph saved successfully!")

# -----------------------------------
# Random Forest Feature Importance
# -----------------------------------

feature_importance = pd.Series(
    random_forest_model.feature_importances_,
    index=feature_columns
).sort_values(ascending=False)

print("\n----- Random Forest Feature Importance -----")
print(feature_importance)

feature_importance.plot(
    kind="bar",
    figsize=(10, 6)
)

plt.title("Random Forest Feature Importance")

plt.xlabel("Network Feature")
plt.ylabel("Importance")

plt.xticks(rotation=45, ha="right")

plt.tight_layout()

plt.savefig(
    os.path.join(
        "graphs",
        "feature_importance.png"
    )
)

plt.close()

print("\nFeature importance graph saved successfully!")

comparison_df.to_csv(
    os.path.join(
        "graphs",
        "model_comparison.csv"
    ),
    index=False
)

print("\nModel comparison results saved!")

# -----------------------------------
# ROC Curve and AUC
# -----------------------------------

# Probability that each test sample belongs to class 1
logistic_probabilities = logistic_model.predict_proba(X_test)[:, 1]

decision_tree_probabilities = decision_tree_model.predict_proba(X_test)[:, 1]

random_forest_probabilities = random_forest_model.predict_proba(X_test)[:, 1]


# Calculate ROC curves

logistic_fpr, logistic_tpr, _ = roc_curve(
    y_test,
    logistic_probabilities
)

decision_tree_fpr, decision_tree_tpr, _ = roc_curve(
    y_test,
    decision_tree_probabilities
)

random_forest_fpr, random_forest_tpr, _ = roc_curve(
    y_test,
    random_forest_probabilities
)


# Calculate AUC scores

logistic_auc = roc_auc_score(
    y_test,
    logistic_probabilities
)

decision_tree_auc = roc_auc_score(
    y_test,
    decision_tree_probabilities
)

random_forest_auc = roc_auc_score(
    y_test,
    random_forest_probabilities
)


print("\n----- AUC Scores -----")

print(
    "Logistic Regression:",
    round(logistic_auc, 4)
)

print(
    "Decision Tree:",
    round(decision_tree_auc, 4)
)

print(
    "Random Forest:",
    round(random_forest_auc, 4)
)
plt.figure(figsize=(8, 6))

plt.plot(
    logistic_fpr,
    logistic_tpr,
    label=f"Logistic Regression (AUC={logistic_auc:.3f})"
)

plt.plot(
    decision_tree_fpr,
    decision_tree_tpr,
    label=f"Decision Tree (AUC={decision_tree_auc:.3f})"
)

plt.plot(
    random_forest_fpr,
    random_forest_tpr,
    label=f"Random Forest (AUC={random_forest_auc:.3f})"
)

# Random-classifier reference line
plt.plot(
    [0, 1],
    [0, 1],
    linestyle="--",
    label="Random Classifier"
)

plt.xlabel("False Positive Rate")
plt.ylabel("True Positive Rate")

plt.title("ROC Curve - Routing Node Classification")

plt.legend()

plt.tight_layout()

plt.savefig(
    os.path.join(
        "graphs",
        "roc_curve.png"
    )
)

plt.close()

print("\nROC curve saved successfully!")
#The ROC curve evaluates how well the model separates:good node and bad node
