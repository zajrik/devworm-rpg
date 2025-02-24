@tool

## StateComponent node that allows an entity to be attacked while in the state
## the component node is attached to.
##
## Owner is expected to have hit and kill signals.
class_name AttackableStateComponent extends StateComponent

## The associated Hurt State node that will be transitioned to when hit.
@export_node_path(&'State') var hurt_state: NodePath

## The associated Dead State node that will be transitioned to when killed.
@export_node_path(&'State') var dead_state: NodePath

@warning_ignore('unused_parameter')
func enter(previous_state: NodePath, data: Dictionary) -> void:
    owner.hit.connect(_on_hit)
    owner.kill.connect(_on_kill)

func exit() -> void:
    owner.hit.disconnect(_on_hit)
    owner.kill.disconnect(_on_kill)

func _on_hit() -> void:
    state.transition.emit(hurt_state)

func _on_kill() -> void:
    state.transition.emit(dead_state)
