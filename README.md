# ConnectSafe – AI-Driven Adaptive Routing for Infrastructure-Free Emergency Communication Networks

ConnectSafe is an intelligent emergency communication system designed to enable communication between people during emergencies, especially when conventional network infrastructure such as cellular networks or internet connectivity is unavailable or unreliable.

The system uses Bluetooth Low Energy (BLE), multi-hop communication, store-and-forward messaging, and AI-driven adaptive routing to support reliable message delivery across nearby devices.

## Project Overview

During natural disasters, network failures, accidents, and other emergency situations, conventional communication infrastructure may become unavailable. ConnectSafe aims to address this challenge by enabling decentralized communication between mobile devices without depending entirely on traditional network infrastructure.

The application combines a Flutter-based mobile interface, a Django REST API backend, and an AI-based routing module.

## System Architecture

The project consists of three major components:

### 1. Flutter Mobile Application

The Flutter application provides the user interface for emergency communication.

Key functionalities:
- User registration and authentication.
- Emergency message creation and communication.
- BLE-based device discovery and communication.
- Multi-hop message forwarding.
- Emergency contact and responder-related features.
- Location-related information.
- Integration with backend APIs.

**Technology:** Flutter, Dart, Firebase packages, HTTP, Bluetooth Low Energy.

### 2. Django REST API Backend

The Django backend manages application services, user information, emergency messages, routing operations, and security.

Backend modules include:

| Module | Responsibility |
|---|---|
| authentication | User authentication |
| users | User profile management |
| emergency_messages | Emergency message handling |
| mesh_network | Mesh node and routing management |
| ai_routing | AI-based routing integration |
| store_forward | Message storage and forwarding |
| security | Security and encryption |
| self_healing | Network monitoring and recovery |
| dashboard | Dashboard-related services |

**Technology:** Python, Django, Django REST Framework, SQLite.

### 3. AI-Based Adaptive Routing

The AI module explores intelligent route selection for emergency message transmission.

It considers parameters such as:
- Battery availability.
- Signal strength.
- Distance between nodes.
- Network congestion.
- Packet loss.
- Latency.
- Queue conditions.
- Node availability.

Machine learning models explored in the project include:
- Logistic Regression.
- Decision Tree.
- Random Forest.

The routing module evaluates network conditions to support adaptive path selection and improve message delivery decisions.

## Key Features

- Infrastructure-independent communication concept.
- BLE-based nearby device communication.
- Multi-hop message forwarding.
- Store-and-forward communication.
- AI-assisted adaptive routing.
- Emergency message management.
- Network monitoring and self-healing mechanisms.
- Backend API integration.
- Security-oriented communication design.

## Technology Stack

| Component | Technologies |
|---|---|
| Mobile application | Flutter, Dart |
| Backend | Python, Django |
| API | Django REST Framework |
| AI/ML | Scikit-learn, Pandas, NumPy |
| Database | SQLite |
| Communication | Bluetooth Low Energy (BLE) |
| Development tools | VS Code, Android Studio, Git, GitHub, Postman |

## Repository Structure

```text
ConnectSafe/
│
├── android/                         # Android application
├── ios/                             # iOS application
├── lib/                             # Flutter source code
├── assets/                          # Application assets
├── pubspec.yaml                     # Flutter dependencies
│
├── EmergencyCommunicationSystem/   # Django backend
│   ├── authentication/
│   ├── users/
│   ├── emergency_messages/
│   ├── mesh_network/
│   ├── ai_routing/
│   ├── store_forward/
│   ├── security/
│   ├── self_healing/
│   ├── dashboard/
│   ├── EmergencyCommunicationAI/
│   ├── config/
│   ├── manage.py
│   └── requirements.txt
│
└── README.md
```

## Getting Started

### Prerequisites

Install the following:
- Flutter SDK.
- Dart SDK.
- Python 3.11 or a compatible version.
- Git.
- Android Studio or VS Code.

### 1. Clone the Repository

```bash
git clone https://github.com/NisargaHG/ConnectSafe.git
cd ConnectSafe
```

### 2. Run the Flutter Application

```bash
flutter pub get
flutter run
```

Configure the required Firebase services and Android permissions before running the application.

### 3. Set Up the Django Backend

Open a new terminal:

```bash
cd EmergencyCommunicationSystem
```

Create a virtual environment:

```bash
python -m venv venv
```

Activate it on Windows:

```powershell
.\venv\Scripts\Activate.ps1
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Apply migrations:

```bash
python manage.py migrate
```

Start the development server:

```bash
python manage.py runserver
```

The backend development server runs at:

```text
http://127.0.0.1:8000/
```

Configure the Flutter API base URL according to your development environment.

## AI Routing Module

The AI routing component explores machine learning-based route selection using network-related parameters.

The models are trained and evaluated using generated routing datasets. The predictions are intended to support adaptive routing decisions under changing network conditions.

## Project Scope and Limitations

- BLE communication depends on device proximity and supported Bluetooth capabilities.
- Multi-hop communication requires participating devices to be available.
- AI routing performance depends on the quality and representativeness of training data.
- Development and testing environments may not fully represent real disaster conditions.
- Further large-scale testing and hardware validation are required.

## Future Enhancements

- Real-world multi-device BLE mesh testing.
- Improved routing algorithms.
- Enhanced network reliability and fault tolerance.
- Expanded emergency responder integration.
- Better battery-aware communication.
- Performance evaluation under real-world network conditions.

## Contributors

**Project Team**
- Nisarga H G
- Swati Mishra
- Priya M
- Tanushree R V

**Project Guide:** Dr. Krishna R

## Project Purpose

ConnectSafe explores how decentralized communication, intelligent routing, and mobile technologies can help maintain emergency communication when conventional infrastructure is unavailable.

---

**Repository:** https://github.com/NisargaHG/ConnectSafe
