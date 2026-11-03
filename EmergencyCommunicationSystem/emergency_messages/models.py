from django.db import models
from django.contrib.auth.models import User


class EmergencyContact(models.Model):

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="emergency_contacts"
    )

    name = models.CharField(max_length=100)

    phone = models.CharField(max_length=20)

    relationship = models.CharField(
        max_length=50,
        blank=True
    )

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} - {self.name}"


class EmergencyMessage(models.Model):

    PRIORITY_CHOICES = [
        ("HIGH", "High"),
        ("MEDIUM", "Medium"),
        ("LOW", "Low"),
    ]

    INCIDENT_TYPE_CHOICES = [
        ("GENERAL", "General Emergency"),
        ("FLOOD", "Flood"),
        ("EARTHQUAKE", "Earthquake"),
        ("FIRE", "Fire"),
        ("CYCLONE", "Cyclone"),
        ("THUNDERSTORM", "Thunderstorm"),
        ("LANDSLIDE", "Landslide"),
        ("TSUNAMI", "Tsunami"),
        ("HEAVY_RAIN", "Heavy Rain"),
        ("HEATWAVE", "Heatwave"),
        ("LIGHTNING", "Lightning"),
        ("INDUSTRIAL", "Industrial Accident"),
        ("CHEMICAL_LEAK", "Chemical Leak"),
        ("ROAD_ACCIDENT", "Road Accident"),
        ("MEDICAL", "Medical Emergency"),
        ("MISSING_PERSON", "Missing Person"),
        ("PERSONAL_SAFETY", "Personal Safety"),
    ]

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="emergency_messages"
    )

    message = models.TextField()

    latitude = models.FloatField()

    longitude = models.FloatField()

    priority = models.CharField(
        max_length=10,
        choices=PRIORITY_CHOICES,
        default="MEDIUM"
    )

    emergency_type = models.CharField(
        max_length=30,
        choices=INCIDENT_TYPE_CHOICES,
        default="GENERAL"
    )

    # Selected emergency contacts for this emergency
    contacts = models.ManyToManyField(
    EmergencyContact,
    blank=True,
    related_name="emergencies"
)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return (
            f"{self.user.username} - "
            f"{self.emergency_type} - "
            f"{self.priority}"
        )
class EmergencyResponder(models.Model):

    RESPONDER_TYPES = [
        ("POLICE", "Police"),
        ("HOSPITAL", "Hospital"),
        ("AMBULANCE", "Ambulance"),
        ("FIRE", "Fire & Rescue"),
        ("RESCUE", "Rescue"),
    ]

    STATUS_CHOICES = [
        ("ACTIVE", "Active"),
        ("INACTIVE", "Inactive"),
    ]

    name = models.CharField(max_length=150)

    responder_type = models.CharField(
        max_length=20,
        choices=RESPONDER_TYPES
    )

    phone = models.CharField(max_length=20)

    latitude = models.FloatField()

    longitude = models.FloatField()

    status = models.CharField(
        max_length=10,
        choices=STATUS_CHOICES,
        default="ACTIVE"
    )

    created_at = models.DateTimeField(
        auto_now_add=True
    )

    def __str__(self):
        return f"{self.name} ({self.responder_type})"