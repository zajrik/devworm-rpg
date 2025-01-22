## Serves as a State for a parent StateMachine.
##
## Note: Nodes extending State must call super() for both enter and exit
## overrides if using StateComponents to ensure the components' enter and
## exit methods get called.
class_name State extends Node

## To be emitted when this state is ready to transition to the next state.
@warning_ignore('unused_signal')
signal transition(next_state: NodePath, data: Dictionary)

## Emitted when this state is entered. Triggered by the state machine.
@warning_ignore('unused_signal')
signal entered(previous_state: NodePath, data: Dictionary)

## Emitted when this state is exited. Triggered by the state machine.
@warning_ignore('unused_signal')
signal exited()

## The components composing this state, if any.
@onready var components: Array[Node] = find_children('*', 'StateComponent')

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
    pass

## Called by the state machine during _process().
func process(_delta: float) -> void:
    pass

## Called by the state machine during _physics_process().
func physics_process(_delta: float) -> void:
    pass

## Called by the state machine upon entering this state.
##
## Note: Avoid awaiting events that may complete after a state has exited in
## the enter method, or at the very least don't trigger state changes after
## awaiting them. This can lead to non-deterministic state transitions which
## are incredibly frustrating to debug.
@warning_ignore('unused_parameter')
func enter(previous_state: NodePath, data: Dictionary = {}) -> void:
    pass

## Called by the state machine when exiting this state.
func exit() -> void:
    pass

## Whether or not this state is the active state for the parent state machine.
func is_active_state() -> bool:
    return get_parent().state == self
