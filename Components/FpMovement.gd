extends Node3D

@export var Speed : float = 7.0
@export var SprintSpeed : float = 10.0
@export var JumpSpeed : float = 6.0
@export var FallMultiplier : float = 2.5
@export var JumpBuffer : float = 0.2
@export var TurnSpeed : float = 6.0
@export var CoyoteTime : float = 0.2
@export var MouseSensitivity : float = 0.3
@export var TopAngleLimit : float = 75
@export var BottomAngleLimit : float = -75
@export var CameraHeight : float = 0.5
@export var CameraTilt : float = 0.6
@export var CameraDistance : float = 5.0
@export var AirControl : bool = true

signal Jump()
signal Falling()
signal Landed()

@onready var parent = $".." as CharacterBody3D
@onready var Camera = $Camera as Camera3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var canJump = false
var jumping = false
var coyoteTimer = 0.0
var jumpBufferTimer = 0.0

func _ready():
	Camera.position.y = CameraHeight

func _input(event):
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if Input.is_action_just_pressed("jump"):
		jumpBufferTimer = JumpBuffer
		
	HandleCameraMovement(event)
 
func _process(delta):
	HandleGravity(delta)
	HandleJump(delta)
	HandleMovement(delta)
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
		var direction = (parent.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			parent.velocity.x = direction.x * currentSpeed
			parent.velocity.z = direction.z * currentSpeed
		else:
			parent.velocity.x = move_toward(parent.velocity.x, 0, Speed)
			parent.velocity.z = move_toward(parent.velocity.z, 0, Speed)

func HandleCameraMovement(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		parent.rotate_y(deg_to_rad(-(event as InputEventMouseMotion).relative.x * MouseSensitivity))
		Camera.rotate_x(deg_to_rad(-(event as InputEventMouseMotion).relative.y * MouseSensitivity))
		Camera.rotation.x = deg_to_rad(clamp(rad_to_deg(Camera.rotation.x), BottomAngleLimit, TopAngleLimit))
