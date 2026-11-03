
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status

from emergency_messages.models import EmergencyMessage
from ai_routing.models import AIRoute
from mesh_network.models import MeshNode

from .models import StoredMessage
from .serializers import StoredMessageSerializer


class StoreForwardView(APIView):

    permission_classes = [IsAuthenticated]

    def post(self, request, message_id):

        # -----------------------------------------
        # 1. Get emergency message
        # -----------------------------------------

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

        # -----------------------------------------
        # 2. Get AI route
        # -----------------------------------------

        try:

            ai_route = AIRoute.objects.get(
                emergency_message=emergency_message
            )

        except AIRoute.DoesNotExist:

            return Response(
                {
                    "status": "error",
                    "message": "AI route not found. Run AI routing first."
                },
                status=status.HTTP_404_NOT_FOUND
            )

        selected_node = ai_route.selected_node

        # -----------------------------------------
        # 3. Check selected node
        # -----------------------------------------

        if selected_node is None:

            return Response(
                {
                    "status": "error",
                    "message": "No mesh node selected."
                },
                status=status.HTTP_400_BAD_REQUEST
            )

        # -----------------------------------------
        # 4. Create or update stored message
        # -----------------------------------------

        stored_message, created = (
            StoredMessage.objects.get_or_create(
                emergency_message=emergency_message,
                defaults={
                    "selected_node": selected_node,
                    "status": "PENDING"
                }
            )
        )

        # -----------------------------------------
        # 5. Check node availability
        # -----------------------------------------

        if selected_node.status == "ACTIVE":

            stored_message.selected_node = selected_node
            stored_message.status = "FORWARDED"
            stored_message.save()

            message = (
                "Emergency message forwarded through "
                f"{selected_node.node_name}."
            )

        else:

            stored_message.status = "STORED"
            stored_message.retry_count += 1
            stored_message.save()

            message = (
                "Mesh node unavailable. "
                "Emergency message stored for later forwarding."
            )

        serializer = StoredMessageSerializer(
            stored_message
        )

        return Response(
            {
                "status": "Success",
                "message": message,
                "data": serializer.data
            },
            status=(
                status.HTTP_201_CREATED
                if created
                else status.HTTP_200_OK
            )
        )

    # -----------------------------------------
    # Get stored messages
    # -----------------------------------------

    def get(self, request):

        stored_messages = StoredMessage.objects.filter(
            emergency_message__user=request.user
        )

        serializer = StoredMessageSerializer(
            stored_messages,
            many=True
        )

        return Response(serializer.data)

