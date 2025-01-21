@tool

## A node to assist with managing state for an entity.
class_name StateMachine extends Node

@export var initial_state: State:
    set(new_state):
        initial_state = new_state
        update_configuration_warnings()

var state: State = null
var state_path: NodePath = ^''

func _get_configuration_warnings() -> PackedStringArray:
    if initial_state == null:
        return ['Initial state must be configured via the inspector.']

    return []

func _ready() -> void:
    if Engine.is_editor_hint(): return
    if initial_state == null:
        printerr('%s: Initial state has not been set.' % owner.name)
        return

    state = initial_state
    state_path = state.name as String

    await owner.ready

    _activate(state)
    state.enter(^'')

## Forward unhandled input to state.
func _unhandled_input(event: InputEvent) -> void:
    if Engine.is_editor_hint(): return
    state.handle_input(event)

## Forward _process tick to state.
func _process(delta: float) -> void:
    if Engine.is_editor_hint(): return
    state.process(delta)

## Forward _physics_process tick to state.
func _physics_process(delta: float) -> void:
    if Engine.is_editor_hint(): return
    state.physics_process(delta)

## Activate the given state, allowing it to transition to other states.
func _activate(target_state: State) -> void:
    target_state.transition.connect(_transition_state)

## Deactivate the given state, preventing it from transitioning to other states.
##
## Note: This helps prevent non-deterministic state changes. They are still
## possible, however, under the following circumstances:
##
## - State A queues transition to state B.
## - State A transitions to state C before queued transition to B occurs.
## - State C transitions back to state A before queued transition occurs.
## - Queued transition to state B occurs but is non-deterministic because it
##   it wasn't triggered by this most recent occurance of being in state A.
##
## The moral of the story is: Avoid queueing state transitions if you can't
## guarantee the state won't transition in some other way before the queued
## transition occurs.
func _deactivate(target_state: State) -> void:
    target_state.transition.disconnect(_transition_state)

## Transition to the given target state. To be called via the state's `transition` signal.
func _transition_state(target_state: NodePath, data: Dictionary = {}) -> void:
    # NodePaths configured via the inspector are likely relative paths from which
    # we just need the Node name off the end
    if target_state.get_name_count() > 1:
        target_state = target_state.slice(-1)

    if not has_node(target_state):
        printerr('%s: State transition target "%s" does not exist.' % [owner.name, target_state])
        return

    var previous_state: NodePath = state_path
    state_path = target_state

    _deactivate(state)
    state.exit()

    state = get_node(target_state)

    _activate(state)
    state.enter(previous_state, data)

## Whether or not the current state is the given node.
func is_in_state(in_state: NodePath) -> bool:
    return state_path == in_state

## Whether or not the current state is in the given list of nodes.
func is_in_one_of_states(states: Array[NodePath]) -> bool:
    return state_path in states

func state_has_component(component: StringName) -> bool:
    return not state.find_children('*', component).is_empty()
