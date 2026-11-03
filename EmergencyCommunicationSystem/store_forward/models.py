
from django.db import models
from emergency_messages.models import EmergencyMessage
from mesh_network.models import MeshNode


class StoredMessage(models.Model):

    STATUS_CHOICES = [
        ("PENDING", "Pending"),
        ("STORED", "Stored"),
        ("FORWARDED", "Forwarded"),
        ("DELIVERED", "Delivered"),
        ("FAILED", "Failed"),
    ]

    emergency_message = models.OneToOneField(
        EmergencyMessage,
        on_delete=models.CASCADE,
        related_name="stored_message"
    )

    selected_node = models.ForeignKey(
        MeshNode,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="stored_messages"
    )

    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default="PENDING"
    )

    retry_count = models.PositiveIntegerField(default=0)

    stored_at = models.DateTimeField(auto_now_add=True)

    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return (
            f"Emergency {self.emergency_message.id} - "
            f"{self.status}"
        )

