@tool

## A component to be applied to StateMachine State nodes to allow composing
## state behaviors and transitions at runtime.
##
## StateComponents have an enter and exit method that will be called automatically
## when the respective State methods are called as long as super() is called.
##
## The StateComponent enter method will receive the same data Dictionary
##
## Note: Nodes extending StateComponent must also have the @tool annotation
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

func _ready() -> void:
    if Engine.is_editor_hint(): return

    # Connect to parent state enter and exit signals
    state.entered.connect(enter)
    state.exited.connect(exit)

@warning_ignore('unused_parameter')
func enter(previous_state: NodePath, data: Dictionary) -> void:
    pass

func exit() -> void:
    pass
