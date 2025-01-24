@tool

class_name ChaseOnSightStateComponent extends StateComponent

## The SimpleVision node that will be used to detect entities to chase.
@export var vision: SimpleVision:
    set(value):
        vision = value
        update_configuration_warnings()


## The chase State to transition to when an entity is sighted.
@export_node_path(&'State') var chase_state: NodePath:
    set(value):
        chase_state = value
        update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
    var result := []

    if vision == null:
        result.append(
            'A SimpleVision node must be set for the component to see entities.'
        )

    if chase_state.is_empty():
        result.append(
            'A chase State must be set for the component to transition to when an entity is sighted.'
        )

    return result


func enter(_previous_state: NodePath, _data: Dictionary) -> void:
    if not _get_configuration_warnings().is_empty(): return

    vision.entity_sighted.connect(_on_entity_sighted)


func exit() -> void:
    if not _get_configuration_warnings().is_empty(): return

    vision.entity_sighted.disconnect(_on_entity_sighted)


func _on_entity_sighted(_entity: CharacterBody2D) -> void:
    state.transition.emit(chase_state, {'target': _entity})
