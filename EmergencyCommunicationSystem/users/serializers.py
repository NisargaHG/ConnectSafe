from rest_framework import serializers
from django.contrib.auth.models import User
from .models import UserProfile


class UserRegistrationSerializer(serializers.ModelSerializer):
    phone_number = serializers.CharField(max_length=15)
    

    class Meta:
        model = User
        fields = [
            "username",
            "email",
            "phone_number",
            "password",
            
            
        ]
        extra_kwargs = {
            "password": {"write_only": True}
        }

    def create(self, validated_data):
        phone_number = validated_data.pop("phone_number")
        

        user = User.objects.create_user(**validated_data)

        UserProfile.objects.create(
            user=user,
            phone_number=phone_number,
            
        )

        return user

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "username", "email"]