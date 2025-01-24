@tool

class_name ChaseOnSightStateComponent extends StateComponent

## The SimpleVision node that will be used to detect entities to chase.
@export var vision: SimpleVision:
    set(value):
        vision = value
        update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
    if vision == null:
        return ['Vision node is not set.']

    return []

func enter(_previous_state: NodePath, _data: Dictionary) -> void:
    if vision == null: return

    vision.entity_sighted.connect(_on_entity_sighted)
    vision.entity_sight_lost.connect(_on_entity_sight_lost)

func exit() -> void:
    pass

func _on_entity_sighted(_entity: CharacterBody2D) -> void:
    pass

func _on_entity_sight_lost(_entity: CharacterBody2D) -> void:
    pass
