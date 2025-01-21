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
    if initial_state == null:
        printerr('%s: Initial state has not been set.' % owner.name)
        return

    state = initial_state
    state_path = state.name as String

    # Initialize all child states
    for state_node: State in find_children('*', 'State'):
        state_node.transition.connect(_transition_state)

    await owner.ready
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

## Transition to the given target state. To be called via the state's `transition` signal.
func _transition_state(target_state: NodePath, data: Dictionary = {}) -> void:
    if not has_node(target_state):
        printerr('%s: State transition target "%s" does not exist.' % [owner.name, target_state])
        return

    var previous_state: NodePath = state_path
    state_path = target_state

    state.exit()
    state = get_node(target_state)
    state.enter(previous_state, data)

## Whether or not the current state is the given node.
func is_in_state(in_state: NodePath) -> bool:
    return state_path == in_state

## Whether or not the current state is in the given list of nodes.
func is_in_one_of_states(states: Array[NodePath]) -> bool:
    return state_path in states

func state_has_component(component: StringName) -> bool:
    return not state.find_children('*', component).is_empty()
