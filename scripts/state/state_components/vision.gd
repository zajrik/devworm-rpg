@tool

## StateComponent node that allows an entity to detect a player and switch to the
## associated Chase state when the player becomes visible to the enemy (unobstructed
## line of sight to the player within the configured range).
class_name VisionStateComponent extends StateComponent

@export_category('Associated states')
## The associated Chase State node that will be transitioned to a player has been seen.
@export_node_path(&'State') var chase_state: NodePath

## The associated Idle State node that will be transitioned to when sight of the
## player has been lost.
@export_node_path(&'State') var idle_state: NodePath

@export_category('Vision parameters')
## The range at which the entity is capable of detecting the player. Leaving this
## range returns to the associated Idle state.
@export var detection_range: int
@export var vision_range: int

@warning_ignore('unused_parameter')
func enter(previous_state: NodePath, data: Dictionary) -> void:
    pass

func exit() -> void:
    pass
