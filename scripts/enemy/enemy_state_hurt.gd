extends EnemyState

func enter(previous_state: NodePath, data: Dictionary = {}) -> void:
    super(previous_state, data)

    _animate()

    await enemy.animation.animation_finished

    # Return to idle state and cancel knockback if active
    enemy.is_knocked_back = false
    transition.emit(IDLE)

func exit() -> void:
    super()

func physics_process(delta: float) -> void:
    enemy.handle_movement()

func _animate() -> void:
    enemy.animation.flip_h = enemy.facing == Enum.Facing.LEFT
    match enemy.facing:
        Enum.Facing.FRONT: enemy.animation.play(&'hurt_front')
        Enum.Facing.BACK: enemy.animation.play(&'hurt_back')
        _: enemy.animation.play(&'hurt_side')
