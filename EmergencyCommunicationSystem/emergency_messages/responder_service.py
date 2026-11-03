
from .models import EmergencyResponder
from .utils import calculate_distance


# Which responders should receive each emergency type
RESPONDER_MAPPING = {

    "ROAD_ACCIDENT": [
        "POLICE",
        "AMBULANCE",
        "HOSPITAL",
    ],

    "MEDICAL": [
        "AMBULANCE",
        "HOSPITAL",
    ],

    "FIRE": [
        "FIRE",
        "POLICE",
    ],

    "FLOOD": [
        "RESCUE",
        "POLICE",
    ],

    "EARTHQUAKE": [
        "RESCUE",
        "AMBULANCE",
        "POLICE",
        "HOSPITAL",
    ],

    "CYCLONE": [
        "RESCUE",
        "POLICE",
        "AMBULANCE",
    ],

    "LANDSLIDE": [
        "RESCUE",
        "POLICE",
        "AMBULANCE",
    ],

    "THUNDERSTORM": [
        "RESCUE",
        "POLICE",
    ],

    "TSUNAMI": [
        "RESCUE",
        "POLICE",
        "AMBULANCE",
    ],

    "HEAVY_RAIN": [
        "RESCUE",
        "POLICE",
    ],

    "HEATWAVE": [
        "AMBULANCE",
        "HOSPITAL",
    ],

    "LIGHTNING": [
        "AMBULANCE",
        "FIRE",
    ],

    "INDUSTRIAL": [
        "FIRE",
        "POLICE",
        "AMBULANCE",
    ],

    "CHEMICAL_LEAK": [
        "FIRE",
        "RESCUE",
        "AMBULANCE",
        "HOSPITAL",
    ],

    "MISSING_PERSON": [
        "POLICE",
        "RESCUE",
    ],

    "PERSONAL_SAFETY": [
        "POLICE",
    ],

    "GENERAL": [
        "POLICE",
        "AMBULANCE",
    ],
}


def find_responders(emergency):

    emergency_type = emergency.emergency_type

    required_types = RESPONDER_MAPPING.get(
        emergency_type,
        ["POLICE"]
    )

    responders = EmergencyResponder.objects.filter(
        responder_type__in=required_types,
        status="ACTIVE"
    )

    results = []

    for responder in responders:

        distance = calculate_distance(
            emergency.latitude,
            emergency.longitude,
            responder.latitude,
            responder.longitude
        )

        results.append(
            {
                "responder": responder,
                "distance": distance
            }
        )

    # Nearest responders first
    results.sort(
        key=lambda x: x["distance"]
    )

    return results
