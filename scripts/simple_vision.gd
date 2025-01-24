@tool

## A configurable vision/detection node that sees CharacterBody2D physics entities
## on the configured physics layers. Uses only a single raycast per entity within
## the detection radius to attempt to see them.
class_name SimpleVision extends Area2D

## The radius of the area in which entities will be detected, in pixels.
@export_custom(PROPERTY_HINT_NONE, 'suffix:px')
var detection_radius: float = 100.0

## The length of the vision raycast, in pixels.
@export_custom(PROPERTY_HINT_NONE, 'suffix:px')
var vision_ray_length: float = 50.0

## The collision mask for determining entities to detect.
@export_flags_2d_physics
var vision_collision_mask: int = 0

@export_category('Debug')
## Whether or not the detection radius circle should be drawn when 'Visible
## Collision Shapes' is active in the debug menu.
@export var detection_circle_visible: bool = true

## Whether or not vision raycasts for tracked entities should be drawn when
## 'Visible Collision Shapes' is active in the debug menu.
@export var vision_ray_visible: bool = true

## The instance id of the parent node of this SimpleVision node.
@onready var _parent_id: int = get_parent().get_instance_id()


## Emitted when an entity enters the detection radius. This is the point at
## which the vision ray will be aimed at the entity.
signal entity_detected(entity: CharacterBody2D)

## Emitted when an entity has left the detection radius.
signal entity_lost(entity: CharacterBody2D)

## Emitted when the vision ray hits an entity.
signal entity_sighted(entity: CharacterBody2D)

## Emitted when the vision ray no longer hits an entity.
signal entity_sight_lost(entity: CharacterBody2D)


## Dictionary mapping entity instance ids to TrackedEntity objects
var tracked_entities: Dictionary[int, TrackedEntity] = {}


# Clear Area2D configuration warnings about missing collision shape
func _get_configuration_warnings() -> PackedStringArray:
    return []


func _ready() -> void:
    # Set detection area collision mask to detect entities
    set_collision_mask(vision_collision_mask)

    body_entered.connect(_on_entity_detected)
    body_exited.connect(_on_entity_lost)

    var detection_collider := CollisionShape2D.new()
    var detection_collider_shape := CircleShape2D.new()

    detection_collider_shape.set_radius(detection_radius)
    detection_collider.set_shape(detection_collider_shape)

    detection_collider.set_visible(detection_circle_visible)

    add_child(detection_collider)


func _physics_process(_delta: float) -> void:
    # For every entity detected, aim the vision ray at the entity and check if it
    # hits that entity.
    for entity_id: int in tracked_entities.keys():
        var tracked_entity: TrackedEntity = tracked_entities[entity_id]

        tracked_entity.look_at()

        if tracked_entity.is_visible():
            if not tracked_entity.was_visible:
                tracked_entity.was_visible = true
                entity_sighted.emit(tracked_entity.entity)

        elif tracked_entity.was_visible:
            tracked_entity.was_visible = false
            entity_sight_lost.emit(tracked_entity.entity)


## To be called when an entity has entered the detection radius.
## Tracks the entity and creates a vision ray to aim at it.
func _on_entity_detected(entity: Node2D) -> void:
    if not entity is CharacterBody2D: return

    var entity_id: int = entity.get_instance_id()

    if entity_id == _parent_id: return

    var tracked_entity := TrackedEntity.new(
        entity,
        vision_ray_length,
        vision_collision_mask,
        get_parent(),
        vision_ray_visible
    )

    tracked_entities[entity_id] = tracked_entity

    add_child(tracked_entity.vision_ray)

    entity_detected.emit(entity)


## To be called when an entity has left the detection radius.
## Frees resources associated with tracking the entity.
func _on_entity_lost(entity: Node2D) -> void:
    if not entity is CharacterBody2D: return

    var entity_id: int = entity.get_instance_id()

    if not tracked_entities.has(entity_id): return

    var tracked_entity: TrackedEntity = tracked_entities[entity_id]

    tracked_entities.erase(entity_id)
    tracked_entity.vision_ray.queue_free()
    tracked_entity.call_deferred(&'free')

    entity_lost.emit(entity)


## Whether or not the given entity is detected.
func can_detect(entity: CharacterBody2D) -> bool:
    return tracked_entities.has(entity.get_instance_id())


## Whether or not the given entity is visible.
func can_see(entity: CharacterBody2D) -> bool:
    if not tracked_entities.has(entity.get_instance_id()):
        return false

    return tracked_entities[entity.get_instance_id()].is_visible()


class TrackedEntity:
    var entity: CharacterBody2D
    var vision_ray: RayCast2D

    ## Whether or not this tracked entity was visible last time it was checked.
    ## To be set by the SimpleVision node.
    var was_visible: bool = false


    func _init(
        tracked_entity: CharacterBody2D,
        vision_ray_length: float,
        vision_collision_mask: int,
        parent: Node2D,
        vision_ray_debug_visible: bool,
    ):
        entity = tracked_entity

        vision_ray = RayCast2D.new()
        vision_ray.add_exception(parent)
        vision_ray.set_collision_mask(vision_collision_mask)
        vision_ray.set_target_position(Vector2(vision_ray_length, 0.0))
        vision_ray.set_visible(vision_ray_debug_visible)

        look_at()


    ## Make the associated vision ray look at the tracked entity.
    func look_at() -> void:
        vision_ray.look_at(entity.global_position)


    ## Returns whether or not the tracked entity is currently visible.
    func is_visible() -> bool:
        var collider: Node2D = vision_ray.get_collider()

        if collider == null:
            return false

        return collider.get_instance_id() == entity.get_instance_id()
