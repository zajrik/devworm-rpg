## The container for all components attached to an entity.
class_name ComponentContainer extends Node

func _notification(what: int) -> void:
    if what == NOTIFICATION_CHILD_ORDER_CHANGED:
        update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
    return []


var _components: Dictionary[StringName, Component] = {}

func _ready() -> void:
    for component in get_children():
        if component is Component:
            _components[component.get_name()] = component

func has_component(component: StringName) -> bool:
    return _components.has(component)


func get_component(component: StringName) -> Component:
    return _components[component]
