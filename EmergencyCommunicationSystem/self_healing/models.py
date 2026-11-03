
from django.db import models
from ai_routing.models import AIRoute


class SelfHealingLog(models.Model):
    ai_route = models.ForeignKey(
        AIRoute,
        on_delete=models.CASCADE,
        related_name="healing_logs"
    )

    old_node = models.CharField(max_length=100)

    new_node = models.CharField(max_length=100)

    healed_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.old_node} -> {self.new_node}"
