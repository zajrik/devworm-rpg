@tool

## A configurable vision/detection node that sees CharacterBody2D physics entities on
## the configured physics layers. Uses only a single raycast per entity within the
## detection radius to attempt to see them.
class_name SimpleVision extends Area2D

@export var detection_radius: float = 100.0
@export var vision_ray_length: int = 50

@export_flags_2d_physics var vision_collision_mask: int = 0


## Emitted when an entity enters the detection radius. This is the point at
## which the vision ray will be aimed at the entity.
signal entity_detected(entity: Node2D)

## Emitted when an entity has left the detection radius.
signal entity_lost(entity: Node2D)

## Emitted when the vision ray hits an entity.
signal entity_sighted(entity: Node2D)

## Emitted when the vision ray no longer hits an entity.
signal entity_sight_lost(entity: Node2D)


## Dictionary mapping entity RID to the entity Node2D of entities within the
## configured detection radius.
var _detected_entities: Dictionary = {}

## Dictionary mapping entity RID to RayCast2D nodes. The existence of a raycast
## node for an entity indicates that the entity is within the detection radius.
var _vision_rays: Dictionary = {}

## Dictionary mapping entity RID to whether or not the entity is visible. Rather
## than the actual boolean value, the existence of a value for the entity RID is
## enough to determine the entity is visible, so truthy/falsey checks are safe.
var _visible_entities: Dictionary = {}


# Clear Area2D configuration warnings about missing collision shape
func _get_configuration_warnings() -> PackedStringArray:
    return []


func _ready() -> void:
    # Set detection area collision mask to detect player
    set_collision_mask(vision_collision_mask)
    set_collision_layer(0)

    body_entered.connect(_on_entity_detected)
    body_exited.connect(_on_entity_lost)

    var detection_collider := CollisionShape2D.new()
    var detection_collider_shape := CircleShape2D.new()

    detection_collider_shape.set_radius(detection_radius)
    detection_collider.set_shape(detection_collider_shape)

    add_child(detection_collider)


func _physics_process(_delta: float) -> void:
    # For every entity detected, aim the vision ray at the entity and check if it
    # hits that entity.
    for entity_rid in _detected_entities.keys():
        var entity: Node2D = _detected_entities[entity_rid]
        var vision_ray: RayCast2D = _vision_rays[entity_rid]

        vision_ray.look_at(entity.global_position)

        var collider: Node2D = vision_ray.get_collider()

        if not collider is CharacterBody2D: return

        var collider_rid: RID = collider.get_rid()

        # If the collider is the detected entity, the entity is visible
        if collider_rid == entity_rid:
            if not _visible_entities.has(entity_rid):
                _visible_entities[entity_rid] = true
                entity_sighted.emit(entity)

        # If the collider is another entity and the detected entity was visible,
        # the detected entity is no longer visible.
        elif _visible_entities.has(entity_rid):
            _visible_entities.erase(entity_rid)
            entity_sight_lost.emit(entity)



## To be called when an entity has entered the detection radius.
## Tracks the entity and creates a vision ray to aim at it.
func _on_entity_detected(entity: Node2D) -> void:
    if not entity is CharacterBody2D: return

    var entity_rid: RID = entity.get_rid()

    if entity_rid == get_parent().get_rid(): return

    _detected_entities[entity_rid] = entity

    var vision_ray := RayCast2D.new()

    vision_ray.set_collision_mask(vision_collision_mask)
    vision_ray.set_target_position(Vector2(vision_ray_length, 0))
    _vision_rays[entity_rid] = vision_ray

    add_child(vision_ray)

    entity_detected.emit(entity)


## To be called when an entity has left the detection radius.
## Frees resources associated with tracking the entity.
func _on_entity_lost(entity: Node2D) -> void:
    if not entity is CharacterBody2D: return

    var entity_rid: RID = entity.get_rid()
    var vision_ray: RayCast2D = _vision_rays[entity_rid]

    _detected_entities.erase(entity_rid)
    _vision_rays.erase(entity_rid)

    # Visible entity entry should be erased at this point if the sight of the entity
    # was lost, but just in case the entity somehow made it out of the detection radius
    # without breaking the raycast, we'll remove it here for memory safety.
    _visible_entities.erase(entity_rid)

    entity_lost.emit(entity)
    vision_ray.queue_free()


## Whether or not the given entity is detected.
func can_detect(entity: CharacterBody2D) -> bool:
    return _detected_entities.has(entity.get_rid())

## Whether or not the given entity is visible.
func can_see(entity: CharacterBody2D) -> bool:
    return _visible_entities.has(entity.get_rid)
