from rest_framework import serializers
from .models import AIRoute


class AIRouteSerializer(serializers.ModelSerializer):
    selected_node = serializers.CharField(
        source="selected_node.node_name",
        read_only=True
    )

    class Meta:
        model = AIRoute
        fields = [
            "id",
            "selected_node",
            "recommended_route",
            "confidence_score",
            "created_at",
        ]