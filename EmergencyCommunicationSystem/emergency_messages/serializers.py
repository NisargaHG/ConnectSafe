
from rest_framework import serializers

from .models import (
    EmergencyMessage,
    EmergencyContact,
    EmergencyResponder,
)

from security.encryption import encrypt_message, decrypt_message


class EmergencyContactSerializer(serializers.ModelSerializer):

    class Meta:
        model = EmergencyContact
        fields = [
            "id",
            "name",
            "phone",
            "relationship",
            "created_at",
        ]
        read_only_fields = [
            "id",
            "created_at",
        ]


class EmergencyMessageSerializer(serializers.ModelSerializer):

    contact_ids = serializers.ListField(
        child=serializers.IntegerField(),
        write_only=True,
        required=False
    )

    contacts = EmergencyContactSerializer(
        many=True,
        read_only=True
    )

    class Meta:
        model = EmergencyMessage
        fields = [
            "id",
            "message",
            "latitude",
            "longitude",
            "priority",
            "emergency_type",
            "contacts",
            "contact_ids",
            "created_at",
        ]
        read_only_fields = [
            "id",
            "created_at",
        ]

    def create(self, validated_data):

        contact_ids = validated_data.pop(
            "contact_ids",
            []
        )

        validated_data["message"] = encrypt_message(
            validated_data["message"]
        )

        emergency = super().create(
            validated_data
        )

        if contact_ids:

            contacts = EmergencyContact.objects.filter(
                id__in=contact_ids,
                user=emergency.user
            )

            emergency.contacts.set(contacts)

        return emergency

    def update(self, instance, validated_data):

        contact_ids = validated_data.pop(
            "contact_ids",
            None
        )

        if "message" in validated_data:

            validated_data["message"] = encrypt_message(
                validated_data["message"]
            )

        emergency = super().update(
            instance,
            validated_data
        )

        if contact_ids is not None:

            contacts = EmergencyContact.objects.filter(
                id__in=contact_ids,
                user=emergency.user
            )

            emergency.contacts.set(contacts)

        return emergency

    def to_representation(self, instance):

        data = super().to_representation(
            instance
        )

        try:

            data["message"] = decrypt_message(
                data["message"]
            )

        except Exception:

            pass

        return data


class EmergencyResponderSerializer(
    serializers.ModelSerializer
):

    class Meta:

        model = EmergencyResponder
        fields = "__all__"

