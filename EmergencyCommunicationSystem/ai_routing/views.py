from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status

from math import radians, sin, cos, sqrt, atan2

from emergency_messages.models import EmergencyMessage
from mesh_network.models import MeshNode

from .models import AIRoute
from .serializers import AIRouteSerializer
from .ai_service import route_emergency


def calculate_distance(lat1, lon1, lat2, lon2):
    """
    Calculate distance between two GPS coordinates in kilometers.
    Uses the Haversine formula.
    """

    R = 6371.0

    lat1 = radians(lat1)
    lon1 = radians(lon1)
    lat2 = radians(lat2)
    lon2 = radians(lon2)

    dlat = lat2 - lat1
    dlon = lon2 - lon1

    a = (
        sin(dlat / 2) ** 2
        + cos(lat1)
        * cos(lat2)
        * sin(dlon / 2) ** 2
    )

    c = 2 * atan2(sqrt(a), sqrt(1 - a))

    return R * c


class AIRoutingView(APIView):

    permission_classes = [IsAuthenticated]

    def post(self, request, message_id):

        # --------------------------------------------------
        # 1. Get emergency message
        # --------------------------------------------------

        try:
            emergency_message = EmergencyMessage.objects.get(
                id=message_id,
                user=request.user
            )

        except EmergencyMessage.DoesNotExist:

            return Response(
                {
                    "status": "error",
                    "message": "Emergency message not found."
                },
                status=status.HTTP_404_NOT_FOUND
            )

        # --------------------------------------------------
        # 2. Get active mesh nodes
        # --------------------------------------------------

        active_nodes = MeshNode.objects.filter(
            status="ACTIVE"
        )

        if not active_nodes.exists():

            return Response(
                {
                    "status": "error",
                    "message": "No active mesh nodes available."
                },
                status=status.HTTP_404_NOT_FOUND
            )

        # --------------------------------------------------
        # 3. Convert mesh nodes into AI input
        # --------------------------------------------------

        nodes = []

        for node in active_nodes:

            distance = calculate_distance(
                emergency_message.latitude,
                emergency_message.longitude,
                node.latitude,
                node.longitude
            )

            nodes.append(
                {
                    "node_id": str(node.id),

                    "battery": float(
                        node.battery_level
                    ),

                    "signal_strength": float(
                        node.signal_strength
                    ),

                    "distance": round(
                        distance,
                        2
                    ),

                    # Temporary values
                    # These will be replaced when
                    # real mesh telemetry is available.

                    "congestion": 0.0,

                    "packet_loss": 0.0,

                    "available": 1,

                    "latency": 0.0,

                    "queue_size": 0
                }
            )

        # --------------------------------------------------
        # 4. Send nodes to AI
        # --------------------------------------------------

        ai_result = route_emergency(nodes)

        if ai_result.get("status") != "Success":

            return Response(
                {
                    "status": "error",
                    "message": "AI routing failed.",
                    "ai": ai_result
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

        # --------------------------------------------------
        # 5. Get selected node
        # --------------------------------------------------

        best_node_id = ai_result.get(
            "best_node"
        )

        try:

            best_node = MeshNode.objects.get(
                id=int(best_node_id),
                status="ACTIVE"
            )

        except (
            MeshNode.DoesNotExist,
            TypeError,
            ValueError
        ):

            return Response(
                {
                    "status": "error",
                    "message": "AI selected an invalid mesh node.",
                    "ai": ai_result
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

        # --------------------------------------------------
        # 6. Save AI route
        # --------------------------------------------------

        ai_route, created = AIRoute.objects.update_or_create(

            emergency_message=emergency_message,

            defaults={
                "selected_node": best_node,

                "recommended_route":
                    "AI Optimized Route",

                "confidence_score":
                    ai_result.get(
                        "confidence",
                        0
                    ),
            }
        )

        # --------------------------------------------------
        # 7. Serialize result
        # --------------------------------------------------

        serializer = AIRouteSerializer(
            ai_route
        )

        # --------------------------------------------------
        # 8. Return response
        # --------------------------------------------------

        return Response(
            {
                "status": "Success",

                "message":
                    "AI route generated successfully.",

                "ai": ai_result,

                "data": serializer.data
            },

            status=status.HTTP_200_OK
        )
    
# ==========================================================
# AI ASSISTANT
# ==========================================================

class AIAssistantView(APIView):

    permission_classes = [IsAuthenticated]

    def post(self, request):

        message = request.data.get("message", "")

        if not isinstance(message, str):
            message = str(message)

        message = message.strip()

        if not message:
            return Response(
                {
                    "status": "error",
                    "message": "Please enter a message."
                },
                status=status.HTTP_400_BAD_REQUEST
            )

        text = message.lower()

        # --------------------------------------------------
        # FIRE
        # --------------------------------------------------

        if "fire" in text:

            response = (
                "If there is a fire, move away from the affected "
                "area immediately. Avoid smoke and use stairs instead "
                "of elevators. Move to a safe open area and contact "
                "emergency services if available."
            )

        # --------------------------------------------------
        # ROAD ACCIDENT
        # --------------------------------------------------

        elif (
            "accident" in text
            or "crash" in text
            or "collision" in text
        ):

            response = (
                "If you are involved in a road accident, move to a "
                "safe location if possible. Stay away from moving "
                "traffic, check for injuries, and seek emergency "
                "medical assistance. You can also use the ConnectSafe "
                "SOS feature to share your location with your contacts."
            )

        # --------------------------------------------------
        # FLOOD
        # --------------------------------------------------

        elif (
            "flood" in text
            or "flooding" in text
        ):

            response = (
                "During a flood, move to higher ground and stay away "
                "from fast-moving water. Do not walk or drive through "
                "flooded roads. Keep your phone charged and use "
                "ConnectSafe SOS if you need emergency assistance."
            )

        # --------------------------------------------------
        # EARTHQUAKE
        # --------------------------------------------------

        elif "earthquake" in text:

            response = (
                "During an earthquake, drop, cover, and hold on. "
                "Stay away from windows and objects that may fall. "
                "After the shaking stops, move carefully to a safe "
                "area and avoid damaged buildings."
            )

        # --------------------------------------------------
        # MEDICAL
        # --------------------------------------------------

        elif (
            "medical" in text
            or "injury" in text
            or "injured" in text
            or "hurt" in text
            or "bleeding" in text
        ):

            response = (
                "For a medical emergency, seek professional medical "
                "help immediately. If there is severe bleeding, apply "
                "firm pressure with a clean cloth if it is safe to do "
                "so. Use ConnectSafe SOS to alert your emergency contacts."
            )

        # --------------------------------------------------
        # CYCLONE / STORM
        # --------------------------------------------------

        elif (
            "cyclone" in text
            or "storm" in text
        ):

            response = (
                "During a cyclone or severe storm, stay indoors and "
                "away from windows. Follow official emergency "
                "instructions and avoid unnecessary travel. Keep your "
                "emergency contacts informed if you are at risk."
            )

        # --------------------------------------------------
        # LANDSLIDE
        # --------------------------------------------------

        elif (
            "landslide" in text
            or "land slide" in text
        ):

            response = (
                "If there is a landslide risk, move away from slopes "
                "and unstable ground immediately. Avoid areas where "
                "rocks, mud, or debris are moving and follow evacuation "
                "instructions."
            )

        # --------------------------------------------------
        # SOS / IMMEDIATE DANGER
        # --------------------------------------------------

        elif (
            "danger" in text
            or "emergency" in text
            or "help me" in text
            or "help" in text
        ):

            response = (
                "If you are in immediate danger, move to a safe "
                "location if possible and use the ConnectSafe SOS "
                "button to send your emergency information and "
                "location. You can also contact local emergency "
                "services."
            )

        # --------------------------------------------------
        # GREETING
        # --------------------------------------------------

        elif (
            "hello" in text
            or "hi" in text
            or "hey" in text
        ):

            response = (
                "Hello! I'm your ConnectSafe AI Assistant. "
                "You can ask me about emergency situations such "
                "as fire, accidents, floods, medical emergencies, "
                "earthquakes, cyclones, and landslides."
            )

        # --------------------------------------------------
        # DEFAULT
        # --------------------------------------------------

        else:

            response = (
                "I'm your ConnectSafe safety assistant. I can provide "
                "basic guidance for emergencies such as fire, road "
                "accidents, floods, medical emergencies, earthquakes, "
                "cyclones, and landslides. If you are in immediate "
                "danger, use the SOS button and move to a safe location "
                "if possible."
            )

        return Response(
            {
                "status": "Success",
                "response": response
            },
            status=status.HTTP_200_OK
        )

