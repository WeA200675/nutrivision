extends Node3D

var camera: Camera3D
var fish: Array[Dictionary] = []
var pond_center := Vector3(0, -0.15, 0)
var pond_size := Vector2(13.0, 8.0)
var rng := RandomNumberGenerator.new()
var world_health := 0.72
var save_path := "user://nutriworld_state.json"
var camera_yaw := 0.0
var camera_pitch := -0.42
var dragging := false
var last_pointer := Vector2.ZERO
var foliage: Array[Node3D] = []
var clouds: Array[Node3D] = []
var ground_material: StandardMaterial3D
var foliage_materials: Array[StandardMaterial3D] = []
var pond_material: ShaderMaterial
var last_season := -1
var seasonal_particles: CPUParticles3D
var health_label: Label

func _ready() -> void:
	rng.seed = 82341
	_load_state()
	_build_environment()
	_build_camera()
	_build_fish(8)
	_apply_season()
	_build_hud()
	set_process(true)

func _process(delta: float) -> void:
	for item in fish:
		var body: MeshInstance3D = item.body
		var velocity: Vector3 = item.velocity
		item.turn_time -= delta
		if item.turn_time <= 0.0:
			item.velocity = Vector3(rng.randf_range(-0.9, 0.9), 0, rng.randf_range(-0.45, 0.45)).normalized() * rng.randf_range(0.35, 0.9)
			item.turn_time = rng.randf_range(1.4, 4.0)
			velocity = item.velocity
		body.position += velocity * delta
		if abs(body.position.x - pond_center.x) > pond_size.x * 0.5 or abs(body.position.z - pond_center.z) > pond_size.y * 0.5:
			item.velocity = -velocity
			item.body.rotation.y += PI
		fish[fish.find(item)] = item
		body.position.y = -0.05 + sin(Time.get_ticks_msec() * 0.002 + item.phase) * 0.035
		body.rotation.y = atan2(velocity.x, velocity.z)
		fish[fish.find(item)] = item
	_update_camera()
	var current_season := _season_for_month(Time.get_datetime_dict_from_system().month)
	if current_season != last_season:
		_apply_season()
	_apply_health_visuals()
	var wind := Time.get_ticks_msec() * 0.001
	for i in foliage.size():
		foliage[i].rotation.z = sin(wind * 0.8 + i * 0.7) * 0.035
		foliage[i].position.x += sin(wind * 0.45 + i) * 0.0008
	for cloud in clouds:
		cloud.position.x += delta * 0.18
		if cloud.position.x > 19.0:
			cloud.position.x = -19.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			last_pointer = event.position
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.position *= 0.92
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.position *= 1.08
	elif event is InputEventMouseMotion and dragging:
		var motion := event.relative
		camera_yaw -= motion.x * 0.006
		camera_pitch = clamp(camera_pitch - motion.y * 0.004, -1.0, -0.12)
	elif event is InputEventScreenTouch:
		dragging = event.pressed
		last_pointer = event.position
	elif event is InputEventScreenDrag and dragging:
		camera_yaw -= event.relative.x * 0.006
		camera_pitch = clamp(camera_pitch - event.relative.y * 0.004, -1.0, -0.12)

func _update_camera() -> void:
	if camera == null:
		return
	var distance := clamp(camera.position.distance_to(Vector3.ZERO), 8.0, 28.0)
	var offset := Vector3(sin(camera_yaw) * cos(camera_pitch), -sin(camera_pitch), cos(camera_yaw) * cos(camera_pitch)) * distance
	camera.position = offset
	camera.look_at(Vector3(0, 0, 0))

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
	var ground := _add_box("Ground", Vector3(0, -0.75, 0), Vector3(34, 1.0, 24), Color("#78b965"))
	ground_material = ground.material_override
	var pond := _add_cylinder("Pond", pond_center, Vector3(7.3, 0.18, 4.5), Color("#3d9fc0"))
	pond_material = pond.material_override
	_add_box("Dock", Vector3(6.2, 0.15, 3.4), Vector3(3.8, 0.22, 1.5), Color("#a8754c"))
	for i in 10:
		var x := -13.0 + i * 2.9
		_add_tree(Vector3(x, 0, -5.0 - (i % 2) * 2.0), 0.85 + (i % 3) * 0.12)
	for i in 5:
		_add_cloud(Vector3(-15.0 + i * 7.5, 8.5 + (i % 2), -8.0 - i))

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
		fish.append({"body": fish_body, "velocity": Vector3(rng.randf_range(-0.9, 0.9), 0, rng.randf_range(-0.35, 0.35)).normalized() * 0.55, "phase": rng.randf_range(0, 6.28), "turn_time": rng.randf_range(1.4, 4.0)})

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
	foliage.append(crown)
	foliage_materials.append(mat)

func _season_for_month(month: int) -> int:
	if month in [12, 1, 2]: return 3
	if month in [3, 4, 5]: return 0
	if month in [6, 7, 8]: return 1
	return 2

func _apply_season() -> void:
	var season := _season_for_month(Time.get_datetime_dict_from_system().month)
	last_season = season
	var ground_color := [Color("#9bcf82"), Color("#78b965"), Color("#a88455"), Color("#d9e1e4")][season]
	var foliage_color := [Color("#69b85c"), Color("#4e9b55"), Color("#c27a3d"), Color("#d7e3e5")][season]
	if ground_material: ground_material.albedo_color = ground_color
	for mat in foliage_materials: mat.albedo_color = foliage_color
	if seasonal_particles:
		seasonal_particles.queue_free()
		seasonal_particles = null
	if season == 0 or season == 2 or season == 3:
		seasonal_particles = CPUParticles3D.new()
		seasonal_particles.amount = 90 if season == 3 else 45
		seasonal_particles.lifetime = 7.0
		seasonal_particles.emitting = true
		seasonal_particles.position = Vector3(0, 7, 0)
		seasonal_particles.direction = Vector3(0, -1, 0)
		seasonal_particles.spread = 24.0
		seasonal_particles.gravity = Vector3(0, -0.35 if season == 3 else -0.08, 0)
		var particle_mesh := QuadMesh.new()
		particle_mesh.size = Vector2(0.09 if season == 3 else 0.16, 0.09 if season == 3 else 0.16)
		seasonal_particles.mesh = particle_mesh
		var particle_mat := StandardMaterial3D.new()
		particle_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		particle_mat.albedo_color = Color("#f4f7ff") if season == 3 else (Color("#d98b3c") if season == 2 else Color("#ffd1e5"))
		particle_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		particle_mesh.material = particle_mat
		add_child(seasonal_particles)
	_apply_health_visuals()

func _apply_health_visuals() -> void:
	var health := clamp(world_health, 0.0, 1.0)
	if ground_material:
		ground_material.albedo_color = ground_material.albedo_color.lerp(Color("#8e9690"), (1.0 - health) * 0.55)
	for mat in foliage_materials:
		mat.albedo_color = mat.albedo_color.lerp(Color("#7e877d"), (1.0 - health) * 0.62)
	if health_label:
		health_label.text = "NutriWorld  •  Lebensenergie %d%%" % int(health * 100.0)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	health_label = Label.new()
	health_label.position = Vector2(24, 20)
	health_label.add_theme_font_size_override("font_size", 20)
	health_label.add_theme_color_override("font_color", Color("#173b35"))
	layer.add_child(health_label)

func set_world_health(value: float) -> void:
	world_health = clamp(value, 0.0, 1.0)
	_apply_health_visuals()
	save_world_state()

func _add_cloud(pos: Vector3) -> void:
	var cloud := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 1.5
	mesh.height = 1.1
	cloud.mesh = mesh
	cloud.position = pos
	cloud.scale = Vector3(2.5, 0.65, 1.0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.96, 0.98, 1.0, 0.78)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cloud.material_override = mat
	add_child(cloud)
	clouds.append(cloud)

func _add_box(label: String, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
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
	return node

func _add_cylinder(label: String, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
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
	if label == "Pond":
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = Color(0.08, 0.48, 0.68, 0.84)
		mat.metallic = 0.12
		mat.roughness = 0.18
		var shader := Shader.new()
		shader.code = """
		shader_type spatial;
		render_mode blend_mix, depth_draw_opaque, cull_disabled;
		uniform vec4 deep_color : source_color = vec4(0.02, 0.25, 0.42, 0.9);
		uniform vec4 light_color : source_color = vec4(0.35, 0.85, 0.95, 0.5);
		void fragment() {
			float wave_a = sin(VERTEX.x * 2.4 + TIME * 1.4) * 0.035;
			float wave_b = cos(VERTEX.z * 3.1 + TIME * 1.1) * 0.025;
			float shimmer = pow(max(0.0, sin(VERTEX.x * 5.0 + VERTEX.z * 2.0 + TIME * 2.0)), 12.0);
			ALBEDO = mix(deep_color.rgb, light_color.rgb, shimmer * 0.35 + wave_a + wave_b);
			ALPHA = 0.86;
			ROUGHNESS = 0.12;
		}
		"""
		var shader_material := ShaderMaterial.new()
		shader_material.shader = shader
		node.material_override = shader_material
		add_child(node)
		return node
	node.material_override = mat
	add_child(node)
	return node

func _load_state() -> void:
	if FileAccess.file_exists(save_path):
		var data = JSON.parse_string(FileAccess.get_file_as_string(save_path))
		if data is Dictionary:
			world_health = float(data.get("world_health", world_health))

func save_world_state() -> void:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"world_health": world_health}))

