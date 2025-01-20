@tool

## A component to be applied to StateMachine State nodes to allow composing
## state behaviors at runtime.
##
## StateComponents have an enter and exit method that will be called automatically
## when the respective State methods are called as long super() is called.
class_name StateComponent extends Node

## The parent state of this
@onready var state: State = get_parent()

func _get_configuration_warnings() -> PackedStringArray:
    var result := []

    if not state is State:
        result.append('Parent node must be a State node.')

    return result

func enter() -> void:
    pass

func exit() -> void:
    pass
