## Owner is expected to have hit and kill signals.
class_name AttackableStateComponent extends StateComponent

@export var hurt_state: NodePath
@export var dead_state: NodePath

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
