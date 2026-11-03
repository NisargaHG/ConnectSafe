from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from django.contrib.auth.models import User
from emergency_messages.models import EmergencyMessage
from mesh_network.models import MeshNode
from store_forward.models import StoredMessage
from ai_routing.models import AIRoute
from self_healing.models import SelfHealingLog


class DashboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):

        data = {
            "total_users": User.objects.count(),
            "total_messages": EmergencyMessage.objects.count(),
            "total_mesh_nodes": MeshNode.objects.count(),
            "active_mesh_nodes": MeshNode.objects.filter(
                status="ACTIVE"
            ).count(),
            "inactive_mesh_nodes": MeshNode.objects.filter(
                status="INACTIVE"
            ).count(),
            "stored_messages": StoredMessage.objects.count(),
            "ai_routes": AIRoute.objects.count(),
            "self_healing_events": SelfHealingLog.objects.count(),
        }

        return Response(data)