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
@export var engage_proximity: float = 20.0

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

func enter(_previous_state: NodePath, data: Dictionary = {}) -> void:
    print('Chasing %s!' % data['target'].name)

    vision.entity_lost.connect(_on_entity_lost)

func _on_entity_lost(_entity: CharacterBody2D) -> void:
    transition.emit(disengage_state, {})
