extends EnemyState

func enter(previous_state: NodePath, _data: Dictionary = {}) -> void:
    _animate()

    await enemy.animation.animation_finished

    # Return to previous state and cancel knockback if active
    enemy.is_knocked_back = false
    finished.emit(previous_state)

func exit() -> void:
    pass

func physics_process(delta: float) -> void:
    enemy.handle_movement()

func _animate() -> void:
    enemy.animation.flip_h = enemy.facing == Enum.Facing.LEFT
    match enemy.facing:
        Enum.Facing.FRONT: enemy.animation.play(&'hurt_front')
        Enum.Facing.BACK: enemy.animation.play(&'hurt_back')
        _: enemy.animation.play(&'hurt_side')
