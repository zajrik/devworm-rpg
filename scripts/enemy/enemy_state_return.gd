extends EnemyState

var spawn_position := Vector2.ZERO

func _ready() -> void:
    super()
    spawn_position = owner.global_position
    #_animate()


func enter(previous_state: NodePath, data: Dictionary = {}) -> void:
    enemy.navigation.velocity_computed.connect(_on_velocity_computed)
    print('returning home!')


func exit() -> void:
    enemy.navigation.velocity_computed.disconnect(_on_velocity_computed)


func physics_process(delta: float) -> void:
    _return_to_spawn()


func _animate() -> void:
    enemy.animation.flip_h = enemy.facing == Enum.Facing.LEFT
    match enemy.facing:
        Enum.Facing.FRONT: enemy.animation.play(&'move_front')
        Enum.Facing.BACK: enemy.animation.play(&'move_back')
        _: enemy.animation.play(&'move_side')


func _return_to_spawn() -> void:
    var spawn_distance: float = enemy.global_position.distance_to(spawn_position)

    if spawn_distance <= 5.0:
        enemy.set_velocity(Vector2.ZERO)
        transition.emit(IDLE)
        return

    enemy.navigation.set_target_position(spawn_position)

    var next_path_position: Vector2 = enemy.navigation.get_next_path_position()
    var direction: Vector2 = enemy.global_position.direction_to(next_path_position)

    if enemy.navigation.avoidance_enabled:
        enemy.navigation.set_velocity(direction * enemy.speed)
        enemy.face_velocity()
        _animate()

    else:
        _on_velocity_computed(direction * enemy.speed)

    enemy.handle_movement()


func _on_velocity_computed(safe_velocity: Vector2) -> void:
    enemy.set_velocity(safe_velocity)
    enemy.face_velocity()
    _animate()
