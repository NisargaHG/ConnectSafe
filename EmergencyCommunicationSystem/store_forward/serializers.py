from rest_framework import serializers
from .models import StoredMessage


class StoredMessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = StoredMessage
        fields = "__all__"