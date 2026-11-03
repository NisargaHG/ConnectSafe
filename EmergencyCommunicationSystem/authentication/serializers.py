from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from rest_framework import serializers


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        try:
            user = User.objects.get(email__iexact=data["email"].strip())
        except User.DoesNotExist:
            raise serializers.ValidationError({
                "message": "Invalid email or password."
            })

        user = authenticate(
            username=user.username,
            password=data["password"],
        )

        if user is None:
            raise serializers.ValidationError({
                "message": "Invalid email or password."
            })

        data["user"] = user
        return data