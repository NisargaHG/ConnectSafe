from rest_framework import serializers
from .models import SelfHealingLog


class SelfHealingLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = SelfHealingLog
        fields = "__all__"