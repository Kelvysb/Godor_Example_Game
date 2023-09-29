extends Node3D

@export var Geometry : Node3D
@export var Speed : float = 7.0
@export var SprintSpeed : float = 10.0
@export var JumpSpeed : float = 6.0
@export var RotationSpeed : float = 2.0
@export var MouseSensitivity : float = 0.05
@export var CameraHeight : float = 0.5
@export var CameraDistance : float = 5.0
@export var CameraSmooth : bool = true
@export var CameraDelay : float = 0.1
@export var CameraMaxDisplacement : float = 0.5
@export var CameraFixRotation : bool = false

@export var Acelleration : float = 0.1
@export var Deacelleration : float = 0.01
@export var ReverseAcelleration : float = 0.6

@export var RotationAcelleration : float = 0.1
@export var RotationDeacelleration : float = 0.01
@export var RotationReverseAcelleration : float = 0.6


@onready var parent = $".." as RigidBody3D
@onready var CameraPivot = $Pivot as Node3D
@onready var Camera = $Pivot/Camera
@onready var originalCameraPosition = Camera.position

func _ready():
	CameraPivot.position.y = CameraHeight
	Camera.position.z = CameraDistance
	parent.axis_lock_linear_z = true
	parent.axis_lock_angular_y = true
	parent.axis_lock_angular_x = true
	parent.gravity_scale = 0

func _input(event):
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
		
 
func _process(delta):
	HandleMovement(delta)
	HandleRotation(delta)
	HandleCameraMovement()

func HandleMovement(delta):
	var currentSpeed = Speed * delta	
	if(Input.is_action_pressed("sprint")):
		currentSpeed = SprintSpeed * delta
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (parent.transform.basis * Vector3(input_dir.x, -input_dir.y, 0)).normalized()
	if direction:
		parent.apply_impulse(direction * currentSpeed)
	else:
		parent.linear_velocity.x = move_toward(parent.linear_velocity.x, 0, Deacelleration)
		parent.linear_velocity.y = move_toward(parent.linear_velocity.y, 0, Deacelleration)

func HandleRotation(delta):
	var rotationZ = 0.0
	if Input.is_action_pressed("rotateLeft"):
		rotationZ = -1
	elif Input.is_action_pressed("rotateRight"):
		rotationZ = 1
	
	if rotationZ:
		parent.apply_torque_impulse(Vector3(0,0, (RotationSpeed * delta) * rotationZ))
	

	

func HandleCameraMovement():
	if CameraSmooth:
		if parent.linear_velocity.length() > 0:
			var yDisplacement = remap(parent.linear_velocity.y, -SprintSpeed, SprintSpeed, -CameraMaxDisplacement, CameraMaxDisplacement) *-1
			var xDisplacement = remap(parent.linear_velocity.x, -SprintSpeed, SprintSpeed, -CameraMaxDisplacement, CameraMaxDisplacement) *-1
			Camera.position.y = lerpf(Camera.position.y, yDisplacement + CameraHeight, CameraDelay)
			Camera.position.x = lerpf(Camera.position.x, xDisplacement, CameraDelay)
		else:
			Camera.position.y = lerpf(Camera.position.y, originalCameraPosition.y, CameraDelay)
			Camera.position.x = lerpf(Camera.position.x, originalCameraPosition.x, CameraDelay)
