@tool

## Owner is expected to have hit and kill signals.
class_name AttackableStateComponent extends StateComponent

## The associated Hurt State node that will be transitioned to when hit.
@export_node_path(&'State') var hurt_state: NodePath:
    set(state):
        hurt_state = state.slice(-1)

## The associated Dead State node that will be transitioned to when killed.
@export_node_path(&'State') var dead_state: NodePath:
    set(state):
        dead_state = state.slice(-1)

func enter() -> void:
    owner.hit.connect(_on_hit)
    owner.kill.connect(_on_kill)

func exit() -> void:
    owner.hit.disconnect(_on_hit)
    owner.kill.disconnect(_on_kill)

func _on_hit() -> void:
    state.finished.emit(hurt_state)

func _on_kill() -> void:
    state.finished.emit(dead_state)
