import sys
from pathlib import Path

# Path to EmergencyCommunicationAI
AI_REPOSITORY_PATH = (
    Path(__file__).resolve().parent.parent / "EmergencyCommunicationAI"
)

# Make the AI repository importable
if str(AI_REPOSITORY_PATH) not in sys.path:
    sys.path.insert(0, str(AI_REPOSITORY_PATH))

from ai_interface import get_routing_decision


def route_emergency(nodes):
    """
    Send communication-node information to the AI
    and return the AI routing decision.
    """

    if not nodes:
        return {
            "status": "error",
            "message": "No communication nodes provided."
        }

    try:
        result = get_routing_decision(nodes)

        return result

    except Exception as e:
        return {
            "status": "error",
            "message": str(e)
        }