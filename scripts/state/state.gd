class_name State extends Node

## Emitted when the state finishes and wants to transition to another state.
signal finished(next_state: NodePath, data: Dictionary)

## The components composing this state, if any.
@onready var components: Array[Node] = find_children('*', 'StateComponent')

## Called by the state machine when receiving unhandled input events.
func handle_input(event: InputEvent) -> void:
    pass

## Called by the state machine during _process()
func process(delta: float) -> void:
    pass

## Called by the state machine during _physics_process()
func physics_process(delta: float) -> void:
    pass

## Called by the state machine upon entering this state.
func enter(_previous_state: NodePath, _data: Dictionary = {}) -> void:
    for component: StateComponent in components:
        component.enter()

## Called by the state machine when exiting this state.
func exit() -> void:
    for component: StateComponent in components:
        component.exit()
