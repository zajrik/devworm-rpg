extends EnemyState

signal wander_destination_reached
signal wander_aborted

@onready var wander_timer: Timer = $WanderTimer

var wander_destination := Vector2.ZERO
var spawn_position := Vector2.ZERO

func _ready() -> void:
    super()
    spawn_position = owner.global_position


func enter(previous_state: NodePath, _data: Dictionary = {}) -> void:
    enemy.navigation.velocity_computed.connect(_on_velocity_computed)

    _choose_wander_destination()
    _animate()

    wander_timer.start(randf_range(6, 10))
    wander_destination_reached.connect(func(): transition.emit(previous_state))

func exit() -> void:
    wander_timer.stop()
    enemy.navigation.velocity_computed.disconnect(_on_velocity_computed)

    for connection: Dictionary in wander_destination_reached.get_connections():
        wander_destination_reached.disconnect(connection['callable'])

func physics_process(_delta: float) -> void:
    _navigate()

    enemy.handle_movement()

    if enemy.navigation.is_navigation_finished():
        wander_destination_reached.emit()

func _animate() -> void:
    enemy.animation.flip_h = enemy.facing == Enum.Facing.LEFT
    match enemy.facing:
        Enum.Facing.FRONT: enemy.animation.play(&'move_front')
        Enum.Facing.BACK: enemy.animation.play(&'move_back')
        _: enemy.animation.play(&'move_side')

func _choose_wander_destination() -> void:
    wander_destination = spawn_position + (Vector2.UP.rotated(deg_to_rad(randi_range(0, 360))) * randi_range(40, 80))

    enemy.navigation.set_target_position(wander_destination)

func _navigate() -> void:
    var next_path_position: Vector2 = enemy.navigation.get_next_path_position()
    var direction: Vector2 = enemy.global_position.direction_to(next_path_position)

    if enemy.navigation.avoidance_enabled:
        enemy.navigation.set_velocity(direction * enemy.speed)
        enemy.face_velocity()
        _animate()

    else:
        _on_velocity_computed(direction * enemy.speed)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
    enemy.set_velocity(safe_velocity)
    enemy.face_velocity()
    _animate()

func _on_wander_timer_timeout() -> void:
    wander_destination_reached.emit()
