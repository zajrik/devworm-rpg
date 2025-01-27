@tool

## The base class for all components that can be attached to entities.
class_name Component extends Node

## A reference to the parent ComponentContainer.
@onready var components: ComponentContainer = get_parent()
