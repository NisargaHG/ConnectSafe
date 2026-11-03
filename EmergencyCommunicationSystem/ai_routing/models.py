from django.db import models
from emergency_messages.models import EmergencyMessage
from mesh_network.models import MeshNode


class AIRoute(models.Model):

    emergency_message = models.OneToOneField(
        EmergencyMessage,
        on_delete=models.CASCADE,
        related_name="ai_route"
    )

    selected_node = models.ForeignKey(
        MeshNode,
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )

    recommended_route = models.CharField(max_length=100)

    confidence_score = models.FloatField(default=0.0)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.recommended_route