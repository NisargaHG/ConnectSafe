
from rest_framework import serializers
from .models import MeshNode


class MeshNodeSerializer(serializers.ModelSerializer):

    class Meta:
        model = MeshNode
        fields = "__all__"
        read_only_fields = ["user", "created_at"]

