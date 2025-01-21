@tool

## A component to be applied to StateMachine State nodes to allow composing
## state behaviors at runtime.
##
## StateComponents have an enter and exit method that will be called automatically
## when the respective State methods are called as long super() is called.
##
## Note: Classes extending StateComponent must also have the @tool annotation
## to allow editor hints to be shown for configuration warnings.
class_name StateComponent extends Node

## The parent state of this
@onready var state: State = get_parent()

func _notification(what: int) -> void:
    if what == NOTIFICATION_PARENTED:
        update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
    if not get_parent() is State:
        return ['Parent node must be a State node.']

    return []

func enter() -> void:
    pass

func exit() -> void:
    pass
