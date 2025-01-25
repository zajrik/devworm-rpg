@tool

## The base class for all entities that can be interacted with in the game.
class_name Entity extends CharacterBody2D


func _get_configuration_warnings() -> PackedStringArray:
    var result := []

    var component_container_nodes := find_children('*', &'ComponentContainer')

    if component_container_nodes.is_empty():
        result.append(
            'An Entity must have a ComponentContainer node.'
        )

    if component_container_nodes.size() > 1:
        result.append(
            'An Entity must have only one ComponentContainer node.'
        )

    return result

func _notification(what: int) -> void:
    if what == NOTIFICATION_CHILD_ORDER_CHANGED:
        update_configuration_warnings()
