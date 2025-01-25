@tool

extends EnemyState

## The SimpleVision node that will be used to detect entities we're chasing.
@export var vision: SimpleVision:
    set(value):
        vision = value
        update_configuration_warnings()

## The engage State to transition to when an entity is reached.
@export_node_path(&'State') var engage_state: NodePath:
    set(value):
        engage_state = value
        update_configuration_warnings()

## The disengage State to transition to when an entity is lost.
@export_node_path(&'State') var disengage_state: NodePath:
    set(value):
        disengage_state = value
        update_configuration_warnings()

## The distance in pixels from the target entity at which the engage State will
## be transitioned to.
@export var engage_proximity: float = 50.0

func _get_configuration_warnings() -> PackedStringArray:
    var result := []

    if vision == null:
        result.append(
            'A SimpleVision node must be set for the component to see entities.'
        )

    if engage_state.is_empty():
        result.append(
            'An engage State must be set for the component to transition to when an entity is reached.'
        )

    if disengage_state.is_empty():
        result.append(
            'A disengage State must be set for the component to transition to when an entity is lost.'
        )

    return result


var target_entity: CharacterBody2D
var navigation_target := Vector2.ZERO


func enter(_previous_state: NodePath, data: Dictionary = {}) -> void:
    assert(data['target'] != null, 'Chase target data must be provided.')

    print('Chasing %s!' % data['target'].name)

    target_entity = data['target'] as CharacterBody2D

    enemy.navigation.velocity_computed.connect(_on_velocity_computed)
    vision.entity_lost.connect(_on_entity_lost)


func exit() -> void:
    enemy.navigation.velocity_computed.disconnect(_on_velocity_computed)


func physics_process(_delta: float) -> void:
    _chase_target()


func _animate() -> void:
    enemy.animation.flip_h = enemy.facing == Enum.Facing.LEFT
    match enemy.facing:
        Enum.Facing.FRONT: enemy.animation.play(&'move_front')
        Enum.Facing.BACK: enemy.animation.play(&'move_back')
        _: enemy.animation.play(&'move_side')


func _chase_target() -> void:
    if target_entity == null: return

    var target_position: Vector2 = target_entity.global_position
    var target_distance: float = enemy.global_position.distance_to(target_position)

    #DebugDraw2D.set_text('target_distance', target_distance)

    if target_distance <= engage_proximity and vision.can_see(target_entity):
        enemy.set_velocity(Vector2.ZERO)
        transition.emit(engage_state, {'target': target_entity})

    if navigation_target.distance_to(target_position) > engage_proximity - 5.0:
        navigation_target = target_position
        enemy.navigation.set_target_position(target_position)

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


func _on_entity_lost(_entity: CharacterBody2D) -> void:
    transition.emit(disengage_state, {})
