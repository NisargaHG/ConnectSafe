
from ai_routing.models import AIRoute
from .services import heal_route


def check_and_heal_routes():
    """
    Check all AI routes and automatically heal routes
    whose selected mesh node is inactive.
    """

    routes = AIRoute.objects.select_related(
        "emergency_message",
        "selected_node"
    ).filter(
        selected_node__status="INACTIVE"
    )

    results = []

    for route in routes:

        result = heal_route(route)

        results.append(result)

    return results

