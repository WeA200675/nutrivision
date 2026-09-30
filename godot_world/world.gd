extends Node3D

var camera: Camera3D
var fish: Array[Dictionary] = []
var pond_center := Vector3(0, -0.15, 0)
var pond_size := Vector2(13.0, 8.0)
var rng := RandomNumberGenerator.new()
var world_health := 0.72
var save_path := "user://nutriworld_state.json"

func _ready() -> void:
	rng.seed = 82341
	_load_state()
	_build_environment()
	_build_camera()
	_build_fish(8)
	set_process(true)

func _process(delta: float) -> void:
	for item in fish:
		var body: MeshInstance3D = item.body
		var velocity: Vector3 = item.velocity
		body.position += velocity * delta
		if abs(body.position.x - pond_center.x) > pond_size.x * 0.5 or abs(body.position.z - pond_center.z) > pond_size.y * 0.5:
			item.velocity = -velocity
			item.body.rotation.y += PI
		fish[fish.find(item)] = item
		body.position.y = -0.05 + sin(Time.get_ticks_msec() * 0.002 + item.phase) * 0.035

func _build_environment() -> void:
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, -28, 0)
	sun.light_energy = 1.15
	add_child(sun)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("#9edbf0")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("#fff1db")
	env.environment.ambient_light_energy = 0.65
	add_child(env)
	_add_box("Ground", Vector3(0, -0.75, 0), Vector3(34, 1.0, 24), Color("#78b965"))
	_add_cylinder("Pond", pond_center, Vector3(7.3, 0.18, 4.5), Color("#3d9fc0"))
	_add_box("Dock", Vector3(6.2, 0.15, 3.4), Vector3(3.8, 0.22, 1.5), Color("#a8754c"))
	for i in 10:
		var x := -13.0 + i * 2.9
		_add_tree(Vector3(x, 0, -5.0 - (i % 2) * 2.0), 0.85 + (i % 3) * 0.12)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.position = Vector3(0, 11, 18)
	camera.look_at_from_position(camera.position, Vector3(0, 0, 0))
	add_child(camera)
	camera.current = true

func _build_fish(count: int) -> void:
	for i in count:
		var fish_body := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = 0.32
		mesh.height = 0.22
		fish_body.mesh = mesh
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("#f28c55") if i % 2 == 0 else Color("#e8c35b")
		fish_body.material_override = mat
		fish_body.position = Vector3(rng.randf_range(-5.5, 5.5), -0.05, rng.randf_range(-3.2, 3.2))
		add_child(fish_body)
		fish.append({"body": fish_body, "velocity": Vector3(rng.randf_range(-0.9, 0.9), 0, rng.randf_range(-0.35, 0.35)), "phase": rng.randf_range(0, 6.28)})

func _add_tree(pos: Vector3, scale_factor: float) -> void:
	_add_cylinder("Trunk", pos + Vector3(0, 1.0, 0), Vector3(0.28, 2.0, 0.28), Color("#70452e"))
	var crown := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 1.35 * scale_factor
	mesh.height = 2.2 * scale_factor
	crown.mesh = mesh
	crown.position = pos + Vector3(0, 2.6 * scale_factor, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#4e9b55")
	crown.material_override = mat
	add_child(crown)

func _add_box(label: String, pos: Vector3, size: Vector3, color: Color) -> void:
	var node := MeshInstance3D.new()
	node.name = label
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	node.material_override = mat
	add_child(node)

func _add_cylinder(label: String, pos: Vector3, size: Vector3, color: Color) -> void:
	var node := MeshInstance3D.new()
	node.name = label
	var mesh := CylinderMesh.new()
	mesh.top_radius = size.x
	mesh.bottom_radius = size.x
	mesh.height = size.y
	node.mesh = mesh
	node.position = pos
	node.scale.z = size.z / size.x
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	node.material_override = mat
	add_child(node)

func _load_state() -> void:
	if FileAccess.file_exists(save_path):
		var data = JSON.parse_string(FileAccess.get_file_as_string(save_path))
		if data is Dictionary:
			world_health = float(data.get("world_health", world_health))

func save_world_state() -> void:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"world_health": world_health}))

