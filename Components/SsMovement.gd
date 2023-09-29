extends Node3D

@export var Geometry : Node3D
@export var Speed : float = 7.0
@export var SprintSpeed : float = 10.0
@export var JumpSpeed : float = 6.0
@export var FallMultiplier : float = 2.5
@export var JumpBuffer : float = 0.2
@export var TurnSpeed : float = 10.0
@export var CoyoteTime : float = 0.2
@export var MouseSensitivity : float = 0.3
@export var CameraHeight : float = 0.5
@export var CameraDistance : float = 5.0
@export var CameraSmooth : bool = true
@export var CameraDelay : float = 0.1
@export var CameraMaxDisplacement : float = 0.5
@export var AirControl : bool = true

signal Jump()
signal Falling()
signal Landed()

@onready var parent = $".." as CharacterBody3D
@onready var CameraPivot = $Pivot as Node3D
@onready var Camera = $Pivot/Camera
@onready var originalCameraPosition = Camera.position

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var canJump = false
var jumping = false
var coyoteTimer = 0.0
var jumpBufferTimer = 0.0

func _ready():
	CameraPivot.position.y = CameraHeight
	Camera.position.z = CameraDistance
	parent.axis_lock_linear_z = true

func _input(event):
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if Input.is_action_just_pressed("jump"):
		jumpBufferTimer = JumpBuffer
		
 
func _process(delta):
	HandleGravity(delta)
	HandleJump(delta)
	HandleMovement(delta)
	HandleCameraMovement()
	parent.move_and_slide()

func HandleGravity(delta):
	if not parent.is_on_floor():
		if parent.velocity.y > 0:				
			parent.velocity.y -= gravity * delta
		else:			
			parent.velocity.y -= (gravity * FallMultiplier) * delta
			Falling.emit()
		
func HandleJump(delta):
	if parent.is_on_floor():
		coyoteTimer = CoyoteTime
	
	coyoteTimer -= delta
	jumpBufferTimer -= delta
	
	if jumping and parent.is_on_floor():
		jumping = false		
		Landed.emit()

	if jumpBufferTimer > 0 and (parent.is_on_floor() or (coyoteTimer > 0 and not jumping)):
		jumping = true
		parent.velocity.y = JumpSpeed
		Jump.emit()

func HandleMovement(delta):
	if(parent.is_on_floor() || AirControl):
		var currentSpeed = Speed	
		if(Input.is_action_pressed("sprint")):
			currentSpeed = SprintSpeed
		var input_dir = Input.get_vector("left", "right", "up", "down")
		var direction = (parent.transform.basis * Vector3(input_dir.x, 0, 0)).normalized()
		if direction:
			parent.velocity.x = direction.x * currentSpeed
			var prev_y = Geometry.rotation.y
			Geometry.look_at(Vector3(parent.position.x, parent.position.y, parent.position.z) + direction)
			var target_y = Geometry.rotation.y
			Geometry.rotation.y = lerp_angle(prev_y, target_y, delta * TurnSpeed)
		else:
			parent.velocity.x = move_toward(parent.velocity.x, 0, Speed)

func HandleCameraMovement():
	if CameraSmooth:
		if parent.velocity.length() > 0:
			var yDisplacement = remap(parent.velocity.y, -SprintSpeed, SprintSpeed, -CameraMaxDisplacement, CameraMaxDisplacement) *-1
			var xDisplacement = remap(parent.velocity.x, -SprintSpeed, SprintSpeed, -CameraMaxDisplacement, CameraMaxDisplacement) *-1
			Camera.position.y = lerpf(Camera.position.y, yDisplacement + CameraHeight, CameraDelay)
			Camera.position.x = lerpf(Camera.position.x, xDisplacement, CameraDelay)
		else:
			Camera.position.y = lerpf(Camera.position.y, originalCameraPosition.y, CameraDelay)
			Camera.position.x = lerpf(Camera.position.x, originalCameraPosition.x, CameraDelay)
