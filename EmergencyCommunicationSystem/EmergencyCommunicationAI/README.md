# AI-Based Emergency Communication Routing System

## Overview

This project implements an AI-based routing module for an Emergency Communication System. The system evaluates nearby communication nodes using device and network parameters and intelligently selects the most suitable next-hop node for reliable message forwarding.

The routing module combines Machine Learning with battery-aware, multi-hop, and adaptive routing mechanisms to improve communication reliability under changing network conditions.

---

## AI Module Objectives

The AI module is designed to:

- Evaluate nearby communication nodes.
- Predict whether a node is suitable for routing.
- Rank candidate nodes based on AI confidence.
- Select the best next-hop node.
- Avoid unavailable and critically low-battery nodes.
- Support multi-hop message forwarding.
- Adapt routing decisions when network conditions change.
- Automatically recalculate routes when better alternatives are available.

---

## Network Parameters

The following parameters are considered during routing:

| Parameter | Description |
|---|---|
| Battery | Remaining battery percentage of the node |
| Signal Strength | Communication signal quality |
| Distance | Distance between communicating nodes |
| Congestion | Current network load |
| Packet Loss | Percentage of packets lost |
| Availability | Online/offline status of the node |
| Latency | Communication delay |
| Queue Size | Number of messages waiting for transmission |

---

## Dataset Preparation

A synthetic routing dataset containing 10,000 samples was generated to simulate different communication and network conditions.

Each node was assigned a reliability score based on:

- Battery level
- Signal strength
- Distance
- Network congestion
- Packet loss
- Availability
- Latency
- Queue size

The generated reliability score was used to create the target variable.

Nodes were classified as:

- `1` - Suitable routing node
- `0` - Unsuitable routing node

The generated dataset is stored as:

```text
dataset/routing_dataset.csv
```

---

## Data Preprocessing

The preprocessing pipeline includes:

- Missing-value detection
- Duplicate detection and removal
- Feature-range validation
- Target-class distribution analysis
- Feature engineering
- Train-test splitting

The dataset was divided into:

- 80% training data
- 20% testing data

A stratified train-test split was used to maintain the target-class distribution in both training and testing datasets.

The processed dataset is stored as:

```text
dataset/processed_dataset.csv
```

---

## Feature Engineering

Two additional features were created to improve the representation of routing conditions.

### Battery-Signal Score

The battery-signal score combines the battery level and signal strength of a node.

```text
battery_signal_score =
(battery × signal_strength) / 100
```

A node with both high battery and strong signal receives a higher battery-signal score.

### Network Quality Score

The network-quality score combines congestion and packet-loss conditions.

```text
network_quality_score =
[(100 - congestion) + (100 - packet_loss × 2.5)] / 2
```

Since packet loss ranges from 0 to 40, it is multiplied by 2.5 to normalize it approximately to a 0-100 scale.

Lower congestion and lower packet loss result in a higher network-quality score.

---

## Machine Learning Models

Three supervised machine-learning classification models were trained and evaluated:

1. Logistic Regression
2. Decision Tree
3. Random Forest

The models predict whether a communication node is suitable for routing.

The trained models are stored using Joblib so that they can be reused without retraining whenever a routing decision is required.

---

## Model Performance

The models were evaluated using Accuracy, Precision, Recall, F1 Score, Confusion Matrix, ROC Curve, and AUC.

| Model | Accuracy | Precision | Recall | F1 Score | AUC |
|---|---:|---:|---:|---:|---:|
| Logistic Regression | 98.00% | 88.67% | 100.00% | 93.99% | 0.9989 |
| Decision Tree | 96.20% | 85.59% | 91.05% | 88.24% | 0.9473 |
| Random Forest | 97.55% | 91.51% | 92.97% | 92.23% | 0.9957 |

Logistic Regression achieved the highest accuracy and recall among the evaluated models and is used as the current routing prediction model.

---

## Confusion Matrix Results

The confusion matrices obtained on the test dataset were:

### Logistic Regression

```text
[[1647   40]
 [   0  313]]
```

### Decision Tree

```text
[[1639   48]
 [  28  285]]
```

### Random Forest

```text
[[1660   27]
 [  22  291]]
```

The Logistic Regression model correctly identified all 313 suitable nodes in the test set, resulting in a recall of 1.0 for the positive class.

---

## Random Forest Feature Importance

Random Forest was also used to analyze the relative importance of the routing features.

The most influential features included:

- Availability
- Battery-signal score
- Battery
- Signal strength
- Distance
- Network-quality score

This analysis provides insight into which network parameters have the greatest influence on routing-node classification.

---

## AI-Based Next-Hop Prediction

The trained AI model evaluates nearby communication nodes and estimates their suitability for routing.

The routing workflow is:

```text
Nearby Nodes
      ↓
Feature Preparation
      ↓
AI Model
      ↓
Suitability Prediction
      ↓
Probability Calculation
      ↓
Node Ranking
      ↓
Best Next-Hop Selection
```

Each candidate node receives an AI probability representing its suitability.

Nodes are ranked according to this probability, and the most suitable eligible node is selected as the next hop.

Unavailable nodes are prevented from being selected.

---

## Battery-Aware Routing

Battery-aware routing prevents devices with critically low battery levels from being used unnecessarily as relay nodes.

A minimum battery threshold of:

```text
20%
```

is applied before AI-based node selection.

The battery-aware routing workflow is:

```text
Nearby Nodes
      ↓
Availability Check
      ↓
Battery Threshold Check
      ↓
Eligible Nodes
      ↓
AI Prediction
      ↓
Best Next-Hop Node
```

Nodes below the battery threshold are removed from consideration.

This helps preserve the battery life of devices participating in the emergency communication network.

---

## Multi-Hop Routing

The system supports multi-hop communication when the destination cannot be reached directly.

Instead of relying on a single communication link, messages can travel through multiple intermediate devices.

Example:

```text
Node_A → Node_C → Node_D → Node_E
```

At each stage, the system evaluates the available neighboring nodes and selects an appropriate next hop.

The multi-hop implementation includes:

- AI-assisted next-hop selection
- Battery-aware node filtering
- Visited-node tracking
- Routing-loop prevention
- Maximum-hop protection
- Route-failure detection

If no suitable next-hop node is available, the system reports that the route could not be completed.

---

## Adaptive Routing

Network conditions can change while communication is taking place. Therefore, the system supports adaptive route recalculation.

The adaptive-routing module can update parameters such as:

- Battery
- Signal strength
- Congestion
- Packet loss
- Availability
- Latency
- Queue size

After a network condition changes, the route is recalculated using the latest information.

### Node Failure Example

Initial route:

```text
Node_A → Node_B → Node_D → Node_E
```

After Node_B becomes unavailable:

```text
Node_A → Node_C → Node_D → Node_E
```

The system automatically identifies an alternative path.

### Signal Degradation

The system was also tested by significantly reducing the signal strength of a previously preferred node.

The routing algorithm successfully reevaluated the available nodes and selected an alternative route when another node became more suitable.

### Congestion and Network Load

Adaptive routing was tested under severe congestion conditions by increasing:

- Network congestion
- Latency
- Queue size

The system successfully recalculated the route when the degraded network conditions made an alternative node more suitable.

### Packet-Loss Variation

Packet-loss changes were also tested.

A change in a single parameter does not necessarily force a route change. The AI evaluates the overall network condition and retains the existing route when it remains the most suitable option.

This prevents unnecessary route switching.

---

## Adaptive Routing Logic

The adaptive routing process can be represented as:

```text
Network Condition Changes
          ↓
Update Node Parameters
          ↓
Reevaluate Available Nodes
          ↓
Recalculate Route
          ↓
Is Another Route Better?
       /        \
     Yes         No
      ↓           ↓
Change Route   Keep Existing Route
```

This provides a basic self-adaptive routing mechanism for changing emergency communication conditions.

---

## Backend Integration

A dedicated backend-facing AI interface is provided through:

```text
ai_interface.py
```

The main integration function is:

```python
get_routing_decision(nodes)
```

This allows the backend to provide nearby-node information without directly interacting with the internal machine-learning implementation.

---

## AI Interface Input

The backend should provide a list of nearby nodes.

Each node must contain:

```text
node_id
battery
signal_strength
distance
congestion
packet_loss
available
latency
queue_size
```

Example:

```python
nodes = [
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
```

---

## AI Interface Output

The interface returns a routing result containing:

- Routing status
- Best node
- AI confidence
- Ranked node information

Example:

```python
{
    "status": "Success",
    "best_node": "Node_B",
    "confidence": 0.99,
    "ranking": [...]
}
```

This structure allows the AI module to be integrated with the project's backend.

---

## Input Validation

The AI interface validates incoming node information before routing.

It checks:

- Whether the input is a list
- Whether the node list is empty
- Whether all required network parameters are present

Invalid input produces an error response instead of being passed directly to the routing model.

---

## System Workflow

The complete AI-routing workflow is:

```text
Mobile Application
        ↓
Backend
        ↓
AI Interface
        ↓
Input Validation
        ↓
Battery-Aware Filtering
        ↓
Machine Learning Model
        ↓
Node Suitability Prediction
        ↓
Probability-Based Ranking
        ↓
Best Next-Hop Selection
        ↓
Multi-Hop / Adaptive Routing
        ↓
Backend
        ↓
Mobile Application
```

---

## Project Structure

```text
EmergencyCommunicationAI/
│
├── dataset/
│   ├── routing_dataset.csv
│   └── processed_dataset.csv
│
├── models/
│   ├── logistic_regression.pkl
│   ├── decision_tree.pkl
│   └── random_forest.pkl
│
├── graphs/
│   ├── logistic_confusion_matrix.png
│   ├── decision_tree_confusion_matrix.png
│   ├── random_forest_confusion_matrix.png
│   ├── model_comparison.png
│   ├── feature_importance.png
│   ├── roc_curve.png
│   └── model_comparison.csv
│
├── generate_dataset.py
├── preprocess.py
├── train_models.py
├── evaluate_models.py
├── predict_route.py
├── routing_ai.py
├── battery_aware_routing.py
├── multi_hop_routing.py
├── adaptive_routing.py
├── ai_interface.py
├── requirements.txt
└── README.md
```

---

## Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
```

Move into the project directory:

```bash
cd EmergencyCommunicationAI
```

### 2. Create a Virtual Environment

```bash
python -m venv venv
```

### 3. Activate the Virtual Environment

On Windows:

```bash
venv\Scripts\activate
```

### 4. Install Dependencies

```bash
pip install -r requirements.txt
```

---

## Required Dependencies

The project uses:

```text
numpy
pandas
scikit-learn
matplotlib
joblib
```

---

## Running the Project

### Generate the Dataset

```bash
python generate_dataset.py
```

### Preprocess the Dataset

```bash
python preprocess.py
```

### Train the Machine-Learning Models

```bash
python train_models.py
```

### Evaluate the Models

```bash
python evaluate_models.py
```

### Test AI Next-Hop Prediction

```bash
python predict_route.py
```

### Test the Reusable AI Routing Module

```bash
python routing_ai.py
```

### Test Battery-Aware Routing

```bash
python battery_aware_routing.py
```

### Test Multi-Hop Routing

```bash
python multi_hop_routing.py
```

### Test Adaptive Routing

```bash
python adaptive_routing.py
```

### Test the Backend AI Interface

```bash
python ai_interface.py
```

---

## Evaluation Outputs

The evaluation module generates several outputs that can be used to analyze and present model performance.

These include:

- Logistic Regression confusion matrix
- Decision Tree confusion matrix
- Random Forest confusion matrix
- Model comparison graph
- Random Forest feature-importance graph
- ROC curve
- Model comparison CSV file

The generated files are stored in:

```text
graphs/
```

---

## Technologies Used

- Python
- NumPy
- Pandas
- Scikit-learn
- Matplotlib
- Joblib
- Machine Learning
- Git
- GitHub

---

## Current AI Capabilities

The completed AI module currently supports:

- AI-based routing-node classification
- Probability-based node ranking
- Best next-hop prediction
- Offline-node handling
- Battery-aware routing
- Low-battery node filtering
- Multi-hop routing
- Routing-loop prevention
- Maximum-hop protection
- Route-failure detection
- Dynamic network-parameter updates
- Adaptive routing
- Node-failure rerouting
- Signal-degradation rerouting
- Congestion-aware route reevaluation
- Packet-loss-aware route reevaluation
- Automatic route recalculation
- Backend-facing AI interface
- Input validation

---

## Key Results

The developed AI-routing system successfully demonstrated:

- Classification of suitable and unsuitable communication nodes.
- 98% test accuracy using Logistic Regression.
- 100% recall for suitable nodes in the evaluated test split.
- AUC of 0.9989 for Logistic Regression.
- AI-based ranking of nearby communication nodes.
- Battery-aware next-hop selection.
- Multi-hop route generation.
- Automatic rerouting after node failure.
- Route adaptation after signal degradation.
- Route adaptation under severe network congestion.
- Route retention when changing conditions do not make an alternative route superior.
- A reusable interface for integration with the project backend.

---

## Future Scope

The current system uses simulated network conditions and a synthetically generated routing dataset.

Future improvements can include:

- Collection of real-device network data.
- Real-time routing using mobile devices.
- GPS-based distance estimation.
- Bluetooth, Wi-Fi Direct, or mesh-network integration.
- Real-time battery and signal monitoring.
- Larger-scale network simulation.
- Dynamic route optimization across larger networks.
- Testing under real emergency communication scenarios.
- Integration with the complete mobile application and backend infrastructure.

---

## Conclusion

The AI-Based Emergency Communication Routing System demonstrates how machine learning can assist routing decisions in a dynamic communication network.

The developed module evaluates multiple network parameters, predicts suitable relay nodes, performs battery-aware next-hop selection, supports multi-hop communication, and adapts routes when network conditions change.

The modular AI interface also enables the routing system to be integrated with the project's backend for further development and end-to-end emergency communication testing.