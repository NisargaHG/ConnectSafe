
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status



from .models import MeshNode
from .serializers import MeshNodeSerializer


class MeshNodeView(APIView):

    permission_classes = [IsAuthenticated]

    def post(self, request):

        device_id = request.data.get("device_id")

        if not device_id:
            return Response(
                {
                    "status": "error",
                    "message": "device_id is required."
                },
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            node = MeshNode.objects.get(
                device_id=device_id
            )

            # Update existing phone node
            node.node_name = request.data.get(
                "node_name",
                node.node_name
            )
            node.latitude = request.data.get(
                "latitude",
                node.latitude
            )
            node.longitude = request.data.get(
                "longitude",
                node.longitude
            )
            node.battery_level = request.data.get(
                "battery_level",
                node.battery_level
            )
            node.signal_strength = request.data.get(
                "signal_strength",
                node.signal_strength
            )
            node.status = request.data.get(
                "status",
                "ACTIVE"
            )

            node.save()

            return Response(
                {
                    "status": "Success",
                    "message": "Mesh node updated successfully.",
                    "data": MeshNodeSerializer(node).data
                },
                status=status.HTTP_200_OK
            )

        except MeshNode.DoesNotExist:

            serializer = MeshNodeSerializer(
                data=request.data
            )

            if serializer.is_valid():

                node = serializer.save()

                return Response(
                    {
                        "status": "Success",
                        "message": "Mesh node created successfully.",
                        "data": serializer.data
                    },
                    status=status.HTTP_201_CREATED
                )

            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )

    def get(self, request):

        nodes = MeshNode.objects.all()

        serializer = MeshNodeSerializer(
            nodes,
            many=True
        )

        return Response(serializer.data)


class MeshNodeHeartbeatView(APIView):

    permission_classes = [IsAuthenticated]

    def post(self, request):

        node, created = MeshNode.objects.update_or_create(
            user=request.user,
            defaults={
                "node_name": request.data.get(
                    "node_name",
                    f"Node-{request.user.id}"
                ),
                "latitude": request.data.get("latitude"),
                "longitude": request.data.get("longitude"),
                "battery_level": request.data.get(
                    "battery_level",
                    100
                ),
                "signal_strength": request.data.get(
                    "signal_strength",
                    0
                ),
                "status": "ACTIVE",
            }
        )

        serializer = MeshNodeSerializer(node)

        return Response(
            {
                "status": "Success",
                "message": "Mesh node heartbeat received.",
                "data": serializer.data
            },
            status=status.HTTP_200_OK
        )

