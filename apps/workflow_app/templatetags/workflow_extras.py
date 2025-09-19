from django import template
from math import floor

register = template.Library()

@register.filter
def minutes(value):
    """Calculates the whole number of minutes from a total number of seconds."""
    try:
        total_seconds = int(value)
        return floor(total_seconds / 60)
    except (ValueError, TypeError):
        return 0

@register.filter
def seconds_part(value):
    """Calculates the remaining seconds part from a total number of seconds."""
    try:
        total_seconds = int(value)
        return total_seconds % 60
    except (ValueError, TypeError):
        return 0
