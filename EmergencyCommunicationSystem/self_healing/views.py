from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status

from ai_routing.models import AIRoute
from .services import heal_route


class SelfHealingView(APIView):

    permission_classes = [IsAuthenticated]

    def post(self, request, route_id):

        try:
            ai_route = AIRoute.objects.select_related(
                "emergency_message",
                "selected_node"
            ).get(id=route_id)

        except AIRoute.DoesNotExist:
            return Response(
                {
                    "status": "error",
                    "message": f"AI Route {route_id} not found."
                },
                status=status.HTTP_404_NOT_FOUND
            )

        # Run self-healing
        result = heal_route(ai_route)

        if result.get("status") == "Success":
            return Response(
                result,
                status=status.HTTP_200_OK
            )

        if result.get("status") == "skipped":
            return Response(
                result,
                status=status.HTTP_200_OK
            )

        return Response(
            result,
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )