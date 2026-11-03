from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from emergency_messages.responder_service import find_responders
from mesh_network.multihop_service import forward_multi_hop


from .models import (
    EmergencyMessage,
    EmergencyContact,
    EmergencyResponder,
)
from .serializers import (
    EmergencyMessageSerializer,
    EmergencyContactSerializer,
    EmergencyResponderSerializer,
)
from .utils import calculate_distance


from emergency_messages.models import EmergencyMessage
from mesh_network.models import MeshNode
from ai_routing.models import AIRoute
from ai_routing.ai_service import route_emergency

from ai_routing.serializers import AIRouteSerializer
from store_forward.services import forward_message
from mesh_network.routing import build_multi_hop_route


class EmergencyMessageView(APIView):
    permission_classes = [IsAuthenticated]

    # CREATE EMERGENCY MESSAGE
    def post(self, request):
        contact_ids = request.data.get("contact_ids", [])

        serializer = EmergencyMessageSerializer(
            data=request.data
        )

        if serializer.is_valid():
            emergency = serializer.save(
                user=request.user
            )

            # Attach selected emergency contacts
            if contact_ids:
                contacts = EmergencyContact.objects.filter(
                    id__in=contact_ids,
                    user=request.user
                )

                emergency.contacts.set(contacts)

            return Response(
                {
                    "message": "Emergency message created successfully.",
                    "data": EmergencyMessageSerializer(
                        emergency
                    ).data
                },
                status=status.HTTP_201_CREATED
            )

        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )

    # GET ALL EMERGENCY MESSAGES
    def get(self, request):
        messages = EmergencyMessage.objects.filter(
            user=request.user
        )

        serializer = EmergencyMessageSerializer(
            messages,
            many=True
        )

        return Response(serializer.data)

    # UPDATE EMERGENCY MESSAGE
    def put(self, request, pk):
        try:
            message = EmergencyMessage.objects.get(
                pk=pk,
                user=request.user
            )
        except EmergencyMessage.DoesNotExist:
            return Response(
                {
                    "error": "Message not found."
                },
                status=status.HTTP_404_NOT_FOUND
            )

        contact_ids = request.data.get(
            "contact_ids",
            []
        )

        serializer = EmergencyMessageSerializer(
            message,
            data=request.data
        )

        if serializer.is_valid():
            emergency = serializer.save(
                user=request.user
            )

            if contact_ids:
                contacts = EmergencyContact.objects.filter(
                    id__in=contact_ids,
                    user=request.user
                )

                emergency.contacts.set(contacts)

            return Response(
                {
                    "message": "Emergency message updated successfully.",
                    "data": EmergencyMessageSerializer(
                        emergency
                    ).data
                },
                status=status.HTTP_200_OK
            )

        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )

    # DELETE EMERGENCY MESSAGE
    def delete(self, request, pk):
        try:
            message = EmergencyMessage.objects.get(
                pk=pk,
                user=request.user
            )
        except EmergencyMessage.DoesNotExist:
            return Response(
                {
                    "error": "Message not found."
                },
                status=status.HTTP_404_NOT_FOUND
            )

        message.delete()

        return Response(
            {
                "message": "Emergency message deleted successfully."
            },
            status=status.HTTP_200_OK
        )


class EmergencyContactView(APIView):
    permission_classes = [IsAuthenticated]

    # GET CONTACTS
    def get(self, request):
        contacts = EmergencyContact.objects.filter(
            user=request.user
        )

        serializer = EmergencyContactSerializer(
            contacts,
            many=True
        )

        return Response(serializer.data)

    # ADD CONTACT
    def post(self, request):
        serializer = EmergencyContactSerializer(
            data=request.data
        )

        if serializer.is_valid():
            serializer.save(
                user=request.user
            )

            return Response(
                serializer.data,
                status=status.HTTP_201_CREATED
            )

        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )

    # UPDATE CONTACT
    def put(self, request, pk):
        try:
            contact = EmergencyContact.objects.get(
                pk=pk,
                user=request.user
            )
        except EmergencyContact.DoesNotExist:
            return Response(
                {
                    "error": "Contact not found."
                },
                status=status.HTTP_404_NOT_FOUND
            )

        serializer = EmergencyContactSerializer(
            contact,
            data=request.data
        )

        if serializer.is_valid():
            serializer.save()

            return Response(
                serializer.data,
                status=status.HTTP_200_OK
            )

        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )

    # DELETE CONTACT
    def delete(self, request, pk):
        try:
            contact = EmergencyContact.objects.get(
                pk=pk,
                user=request.user
            )
        except EmergencyContact.DoesNotExist:
            return Response(
                {
                    "error": "Contact not found."
                },
                status=status.HTTP_404_NOT_FOUND
            )

        contact.delete()

        return Response(
            {
                "message": "Contact deleted successfully."
            },
            status=status.HTTP_200_OK
        )




class SOSView(APIView):

    permission_classes = [IsAuthenticated]

    def post(self, request):

        # ============================================
        # 1. CREATE EMERGENCY
        # ============================================

        serializer = EmergencyMessageSerializer(
            data=request.data
        )

        if not serializer.is_valid():
            return Response(
                {
                    "status": "error",
                    "message": "Invalid emergency data.",
                    "errors": serializer.errors
                },
                status=status.HTTP_400_BAD_REQUEST
            )

        emergency_message = serializer.save(
            user=request.user
        )

        # ============================================
        # 2. GET ACTIVE MESH NODES
        # ============================================

        active_nodes = MeshNode.objects.filter(
            status="ACTIVE"
        )

        if not active_nodes.exists():
            return Response(
                {
                    "status": "error",
                    "message": "No active mesh nodes available.",
                    "emergency_message_id": emergency_message.id
                },
                status=status.HTTP_404_NOT_FOUND
            )

        # ============================================
        # 3. PREPARE NODE DATA FOR AI
        # ============================================

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
                    "battery": float(node.battery_level),
                    "signal_strength": float(node.signal_strength),
                    "distance": round(distance, 2),
                    "congestion": 0.0,
                    "packet_loss": 0.0,
                    "available": 1,
                    "latency": 0.0,
                    "queue_size": 0
                }
            )

        # ============================================
        # 4. AI ROUTING
        # ============================================

        ai_result = route_emergency(nodes)

        if ai_result.get("status") != "Success":

            return Response(
                {
                    "status": "error",
                    "message": "AI routing failed.",
                    "emergency_message_id":
                        emergency_message.id,
                    "ai": ai_result
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

        # ============================================
        # 5. GET BEST NODE
        # ============================================

        best_node_id = ai_result.get("best_node")

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
                    "emergency_message_id":
                        emergency_message.id,
                    "ai": ai_result
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

        # ============================================
        # 6. SAVE AI ROUTE
        # ============================================

        ai_route, created = AIRoute.objects.update_or_create(
            emergency_message=emergency_message,
            defaults={
                "selected_node": best_node,
                "recommended_route":
                    "AI Optimized Route",
                "confidence_score":
                    ai_result.get("confidence", 0)
            }
        )

        # ============================================
        # 7. STORE/FORWARD MESSAGE
        # ============================================

        forward_result = forward_message(
            emergency_message
        )

        # ============================================
        # 8. BUILD MULTI-HOP ROUTE
        # ============================================

        multi_hop_result = build_multi_hop_route(
            emergency_message
        )

        # ============================================
        # MULTI-HOP FORWARDING
        # ============================================

        if multi_hop_result.get("status") == "Success":

            multi_hop_forwarding = forward_multi_hop(
                multi_hop_result["route"]
            )

        else:

            multi_hop_forwarding = {
                "status": "Skipped",
                "message": "Multi-hop route unavailable."
            }

        # ============================================
        # 9. FIND RESPONDERS
        # ============================================

        selected_responders = find_responders(
            emergency_message
        )

        responder_data = []

        for item in selected_responders:

            responder = item["responder"]

            responder_data.append(
                {
                    "id": responder.id,
                    "name": responder.name,
                    "responder_type":
                        responder.responder_type,
                    "phone": responder.phone,
                    "latitude":
                        responder.latitude,
                    "longitude":
                        responder.longitude,
                    "distance_km":
                        round(item["distance"], 2)
                }
            )

        # ============================================
        # 10. RETURN COMPLETE RESULT
        # ============================================

        emergency_serializer = EmergencyMessageSerializer(
            emergency_message
        )

        route_serializer = AIRouteSerializer(
            ai_route
        )

        return Response(
            {
                "status": "Success",
                "message":
                    "Emergency SOS processed successfully.",

                "emergency":
                    emergency_serializer.data,

                "ai":
                    ai_result,

                "route":
                    route_serializer.data,

                "multi_hop": 
                    multi_hop_result,

                "forwarding":
                    forward_result,

                "responders":
                    responder_data,
            },
            status=status.HTTP_201_CREATED
        )



class EmergencyResponderView(APIView):

    permission_classes = [IsAuthenticated]

    # GET ALL ACTIVE RESPONDERS
    def get(self, request):

        responders = EmergencyResponder.objects.filter(
            status="ACTIVE"
        )

        serializer = EmergencyResponderSerializer(
            responders,
            many=True
        )

        return Response(
            serializer.data,
            status=status.HTTP_200_OK
        )

    # ADD RESPONDER
    def post(self, request):

        serializer = EmergencyResponderSerializer(
            data=request.data
        )

        if serializer.is_valid():

            responder = serializer.save()

            return Response(
                {
                    "message":
                        "Emergency responder created successfully.",
                    "data":
                        EmergencyResponderSerializer(
                            responder
                        ).data
                },
                status=status.HTTP_201_CREATED
            )

        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )