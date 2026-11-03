from django.db import models
from django.contrib.auth.models import User


class MeshNode(models.Model):

    NODE_STATUS = [
        ("ACTIVE", "Active"),
        ("INACTIVE", "Inactive"),
    ]

    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name="mesh_node",
        null=True,
        blank=True
    )

    node_name = models.CharField(max_length=100)

    device_id = models.CharField(
        max_length=200,
        null=True,
        blank=True,
        unique=True
    )

    latitude = models.FloatField()
    longitude = models.FloatField()

    battery_level = models.IntegerField()
    signal_strength = models.IntegerField()

    status = models.CharField(
        max_length=10,
        choices=NODE_STATUS,
        default="ACTIVE"
    )

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.node_name