extends Area3D

@export var reference : Area3D
@export var horizontal: bool = true
@export var variance = 5.0

func _on_body_entered(body):
	var currentVariance = variance
	if horizontal:
		if reference.global_position.x > 0:
			currentVariance * -1
		(body as Node3D).global_position.x = reference.global_position.x + currentVariance 
	else:
		if reference.global_position.x < 0:
			currentVariance * -1
		(body as Node3D).global_position.y = reference.global_position.y + currentVariance
