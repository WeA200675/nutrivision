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
var touch_points: Dictionary = {}
var pinch_distance := 0.0
var foliage: Array[Node3D] = []
var clouds: Array[Node3D] = []
var ground_material: StandardMaterial3D
var foliage_materials: Array[StandardMaterial3D] = []
var grass: Array[Node3D] = []
var pond_material: ShaderMaterial
var last_season := -1
var seasonal_particles: CPUParticles3D
var chimney_smoke: CPUParticles3D
var health_label: Label
var sun_light: DirectionalLight3D
var moon_node: MeshInstance3D
var moon_light: DirectionalLight3D
var stars: Array[Node3D] = []
var fireflies: Array[Node3D] = []
var butterflies: Array[Node3D] = []

func _ready() -> void:
	rng.seed = 82341
	_load_state()
	_build_environment()
	_build_cabin()
	_build_landscape_details()
	_build_grass()
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
		body.scale.x = 1.0 + sin(Time.get_ticks_msec() * 0.008 + item.phase) * 0.08
		fish[fish.find(item)] = item
	_update_camera()
	var current_season := _season_for_month(Time.get_datetime_dict_from_system().month)
	if current_season != last_season:
		_apply_season()
	_apply_health_visuals()
	var wind := Time.get_ticks_msec() * 0.001
	if sun_light:
		var now := Time.get_datetime_dict_from_system()
		var daylight: float = float(now.hour) + float(now.minute) / 60.0
		sun_light.rotation_degrees = Vector3(-25.0 - sin(daylight / 24.0 * TAU) * 35.0, -35.0 + daylight * 7.0, 0)
		var night_factor: float = clampf(abs(daylight - 12.0) / 6.0, 0.0, 1.0)
		if moon_node:
			moon_node.position = Vector3(cos(daylight / 24.0 * TAU) * 15.0, 8.0 + sin(daylight / 24.0 * TAU) * 5.0, -12.0)
			moon_node.visible = night_factor > 0.18
		if moon_light:
			moon_light.light_energy = 0.22 * night_factor
		for star in stars:
			star.visible = night_factor > 0.32
		for i in fireflies.size():
			fireflies[i].visible = night_factor > 0.25
			fireflies[i].position.y += sin(Time.get_ticks_msec() * 0.0015 + i) * 0.0015
		var day_factor: float = 1.0 - night_factor
		for i in butterflies.size():
			butterflies[i].visible = day_factor > 0.35
			butterflies[i].position += Vector3(sin(Time.get_ticks_msec() * 0.001 + i) * 0.002, cos(Time.get_ticks_msec() * 0.0014 + i) * 0.002, sin(Time.get_ticks_msec() * 0.0008 + i) * 0.002)
	for i in foliage.size():
		foliage[i].rotation.z = sin(wind * 0.8 + i * 0.7) * 0.035
		foliage[i].position.x += sin(wind * 0.45 + i) * 0.0008
	for i in grass.size():
		grass[i].rotation.z = sin(wind * 1.7 + i * 0.31) * 0.12
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
		var motion: Vector2 = event.relative
		camera_yaw -= motion.x * 0.006
		camera_pitch = clamp(camera_pitch - motion.y * 0.004, -1.0, -0.12)
	elif event is InputEventScreenTouch:
		if event.pressed:
			touch_points[event.index] = event.position
		else:
			touch_points.erase(event.index)
		dragging = touch_points.size() == 1
		if touch_points.size() == 2:
			var points: Array = touch_points.values()
			pinch_distance = points[0].distance_to(points[1])
	elif event is InputEventScreenDrag and dragging:
		if touch_points.has(event.index):
			touch_points[event.index] = event.position
		if touch_points.size() == 2:
			var points: Array = touch_points.values()
			var next_distance: float = points[0].distance_to(points[1])
			if pinch_distance > 0.0:
				camera.position *= clampf(1.0 - (next_distance - pinch_distance) * 0.002, 0.88, 1.12)
			pinch_distance = next_distance
		else:
			camera_yaw -= event.relative.x * 0.006
			camera_pitch = clamp(camera_pitch - event.relative.y * 0.004, -1.0, -0.12)

func _update_camera() -> void:
	if camera == null:
		return
	var distance: float = clampf(camera.position.distance_to(Vector3.ZERO), 8.0, 28.0)
	var offset: Vector3 = Vector3(sin(camera_yaw) * cos(camera_pitch), -sin(camera_pitch), cos(camera_yaw) * cos(camera_pitch)) * distance
	camera.position = offset
	camera.look_at(Vector3(0, 0, 0))

func _build_environment() -> void:
	var sun := DirectionalLight3D.new()
	sun_light = sun
	sun.rotation_degrees = Vector3(-52, -28, 0)
	sun.light_energy = 1.15
	add_child(sun)
	moon_light = DirectionalLight3D.new()
	moon_light.light_color = Color("#b7c9ff")
	moon_light.shadow_enabled = true
	add_child(moon_light)
	moon_node = MeshInstance3D.new()
	var moon_mesh := SphereMesh.new()
	moon_mesh.radius = 1.05
	moon_mesh.height = 2.1
	moon_node.mesh = moon_mesh
	moon_node.position = Vector3(0, 12, -12)
	var moon_mat := StandardMaterial3D.new()
	moon_mat.albedo_color = Color("#eef2ff")
	moon_mat.emission_enabled = true
	moon_mat.emission = Color("#aebeff")
	moon_mat.emission_energy_multiplier = 0.7
	moon_node.material_override = moon_mat
	add_child(moon_node)
	for i in 36:
		var star := MeshInstance3D.new()
		var star_mesh := SphereMesh.new()
		star_mesh.radius = 0.035
		star_mesh.height = 0.07
		star.mesh = star_mesh
		star.position = Vector3(-18.0 + fmod(float(i) * 7.31, 36.0), 8.5 + fmod(float(i) * 2.17, 7.0), -13.0 - fmod(float(i) * 1.9, 8.0))
		var star_mat := StandardMaterial3D.new()
		star_mat.albedo_color = Color("#fff8d2")
		star_mat.emission_enabled = true
		star_mat.emission = Color("#fff2b3")
		star_mat.emission_energy_multiplier = 1.6
		star.material_override = star_mat
		star.visible = false
		add_child(star)
		stars.append(star)
	for i in 18:
		var firefly := MeshInstance3D.new()
		var glow_mesh := SphereMesh.new()
		glow_mesh.radius = 0.045
		glow_mesh.height = 0.09
		firefly.mesh = glow_mesh
		firefly.position = Vector3(-9.0 + fmod(float(i) * 1.17, 16.0), 0.8 + fmod(float(i) * 0.42, 2.2), 0.5 + fmod(float(i) * 0.91, 5.5))
		var glow_mat := StandardMaterial3D.new()
		glow_mat.albedo_color = Color("#f5e77d")
		glow_mat.emission_enabled = true
		glow_mat.emission = Color("#f5d94e")
		glow_mat.emission_energy_multiplier = 2.3
		firefly.material_override = glow_mat
		firefly.visible = false
		add_child(firefly)
		fireflies.append(firefly)
	for i in 8:
		var butterfly := MeshInstance3D.new()
		var wing_mesh := SphereMesh.new()
		wing_mesh.radius = 0.12
		wing_mesh.height = 0.06
		butterfly.mesh = wing_mesh
		butterfly.scale = Vector3(1.5, 0.35, 0.8)
		butterfly.position = Vector3(-8.0 + fmod(float(i) * 1.83, 14.0), 1.0 + fmod(float(i) * 0.33, 1.8), 0.8 + fmod(float(i) * 0.74, 5.0))
		var wing_mat := StandardMaterial3D.new()
		wing_mat.albedo_color = Color("#f6b6d1") if i % 2 == 0 else Color("#9bd4ee")
		butterfly.material_override = wing_mat
		add_child(butterfly)
		butterflies.append(butterfly)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("#9edbf0")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("#fff1db")
	env.environment.ambient_light_energy = 0.65
	env.environment.fog_enabled = true
	env.environment.fog_light_color = Color("#acd9e6")
	env.environment.fog_density = 0.006
	add_child(env)
	var ground := _add_box("Ground", Vector3(0, -0.75, 0), Vector3(34, 1.0, 24), Color("#78b965"))
	ground_material = ground.material_override
	var pond := _add_cylinder("Pond", pond_center, Vector3(7.3, 0.18, 4.5), Color("#3d9fc0"))
	pond_material = pond.material_override
	_add_box("Dock", Vector3(6.2, 0.15, 3.4), Vector3(3.8, 0.22, 1.5), Color("#a8754c"))
	for i in 10:
		var x := -13.0 + i * 2.9
		_add_tree(Vector3(x, 0, -5.0 - (i % 2) * 2.0), 0.85 + (i % 3) * 0.12)
	_add_imported_nature_models()
	_add_imported_building()
	for i in 5:
		_add_cloud(Vector3(-15.0 + i * 7.5, 8.5 + (i % 2), -8.0 - i))

func _build_cabin() -> void:
	_add_box("Cabin", Vector3(-7.0, 1.0, -1.5), Vector3(4.2, 2.8, 3.2), Color("#d9a66b"))
	_add_box("CabinDoor", Vector3(-7.0, 0.65, 0.15), Vector3(0.72, 1.45, 0.08), Color("#5a3b2c"))
	_add_box("CabinWindow", Vector3(-8.15, 1.35, 0.12), Vector3(0.95, 0.72, 0.08), Color("#9dd5df"))
	_add_box("CabinWindow", Vector3(-5.85, 1.35, 0.12), Vector3(0.95, 0.72, 0.08), Color("#9dd5df"))
	var roof_a := _add_box("CabinRoof", Vector3(-7.9, 2.65, -1.5), Vector3(3.0, 0.25, 3.8), Color("#8b4e3b"))
	roof_a.rotation.z = -0.42
	var roof_b := _add_box("CabinRoof", Vector3(-6.1, 2.65, -1.5), Vector3(3.0, 0.25, 3.8), Color("#8b4e3b"))
	roof_b.rotation.z = 0.42
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(-7.0, 1.8, 0.28)
	lamp.light_color = Color("#ffd08a")
	lamp.light_energy = 1.6
	lamp.omni_range = 4.0
	add_child(lamp)
	_add_box("Chimney", Vector3(-6.15, 3.15, -2.1), Vector3(0.55, 1.0, 0.55), Color("#704c43"))
	chimney_smoke = CPUParticles3D.new()
	chimney_smoke.amount = 18
	chimney_smoke.lifetime = 4.5
	chimney_smoke.emitting = false
	chimney_smoke.position = Vector3(-6.15, 3.75, -2.1)
	chimney_smoke.direction = Vector3(0.1, 1, 0)
	chimney_smoke.spread = 18.0
	chimney_smoke.gravity = Vector3(0, 0.05, 0)
	var smoke_mesh := SphereMesh.new()
	smoke_mesh.radius = 0.16
	smoke_mesh.height = 0.28
	chimney_smoke.mesh = smoke_mesh
	var smoke_mat := StandardMaterial3D.new()
	smoke_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	smoke_mat.albedo_color = Color(0.76, 0.78, 0.76, 0.28)
	smoke_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	smoke_mesh.material = smoke_mat
	add_child(chimney_smoke)
	for i in 7:
		var path := _add_box("Path", Vector3(-6.3 + i * 0.85, -0.1, 1.9 + i * 0.35), Vector3(0.72, 0.12, 0.52), Color("#c7a875"))
		path.rotation.y = -0.18
	for i in 5:
		_add_lantern(Vector3(-2.1 + i * 1.8, 0.25, 2.9))
	for i in 5:
		_add_box("FencePost", Vector3(2.0 + i * 0.8, 0.35, 3.6), Vector3(0.12, 0.7, 0.12), Color("#79523b"))
	_add_box("FenceRail", Vector3(3.6, 0.55, 3.6), Vector3(4.0, 0.12, 0.12), Color("#79523b"))

func _add_lantern(pos: Vector3) -> void:
	var post := _add_cylinder("LanternPost", pos + Vector3(0, 0.45, 0), Vector3(0.06, 0.9, 0.06), Color("#493c35"))
	var light := OmniLight3D.new()
	light.position = pos + Vector3(0, 0.95, 0)
	light.light_color = Color("#ffd48b")
	light.light_energy = 0.55
	light.omni_range = 2.2
	add_child(light)

func _build_landscape_details() -> void:
	for i in 7:
		var hill := MeshInstance3D.new()
		var hill_mesh := SphereMesh.new()
		hill_mesh.radius = 3.2 + (i % 3) * 0.8
		hill_mesh.height = 2.2
		hill.mesh = hill_mesh
		hill.scale = Vector3(1.7, 0.55, 1.1)
		hill.position = Vector3(-13.0 + i * 4.4, -0.25, -9.0 - (i % 2) * 1.8)
		var hill_mat := StandardMaterial3D.new()
		hill_mat.albedo_color = Color("#6fa85d")
		hill.material_override = hill_mat
		add_child(hill)
	for i in 14:
		var angle := float(i) / 14.0 * TAU
		var rock_pos := Vector3(cos(angle) * 6.4, 0.0, sin(angle) * 3.8)
		_add_rock(rock_pos, 0.35 + float(i % 3) * 0.12)
	for i in 28:
		var flower := MeshInstance3D.new()
		var flower_mesh := SphereMesh.new()
		flower_mesh.radius = 0.08
		flower_mesh.height = 0.16
		flower.mesh = flower_mesh
		flower.position = Vector3(-9.0 + fmod(float(i) * 1.37, 18.0), 0.15, 2.0 + fmod(float(i) * 0.83, 7.0))
		var flower_mat := StandardMaterial3D.new()
		flower_mat.albedo_color = Color("#e889a8") if i % 2 == 0 else Color("#f3d45d")
		flower.material_override = flower_mat
		add_child(flower)

func _add_imported_nature_models() -> void:
	var tree_path := "res://assets/imported/kenney_nature/Models/GLTF format/tree_pineTallD_detailed.glb"
	var rock_path := "res://assets/imported/kenney_nature/Models/GLTF format/rock_largeC.glb"
	var tree_scene := load(tree_path)
	var rock_scene := load(rock_path)
	if tree_scene is PackedScene:
		for i in 5:
			var tree := tree_scene.instantiate()
			tree.position = Vector3(-11.0 + i * 5.2, 0, -7.0)
			tree.scale = Vector3.ONE * 1.4
			add_child(tree)
	if rock_scene is PackedScene:
		for i in 6:
			var rock := rock_scene.instantiate()
			rock.position = Vector3(-5.5 + i * 2.1, 0.05, 3.1)
			rock.scale = Vector3.ONE * 0.55
			add_child(rock)

func _add_imported_building() -> void:
	var wall_scene := load("res://assets/imported/kenney_building/Models/GLB format/wall-window-square-detailed.glb")
	var roof_scene := load("res://assets/imported/kenney_building/Models/GLB format/roof-flat-square.glb")
	var door_scene := load("res://assets/imported/kenney_building/Models/GLB format/door-rotate-square-a.glb")
	if wall_scene is PackedScene:
		for data in [[Vector3(-7.0, 1.0, -3.0), 0.0], [Vector3(-7.0, 1.0, 0.0), 0.0], [Vector3(-9.1, 1.0, -1.5), PI * 0.5], [Vector3(-4.9, 1.0, -1.5), PI * 0.5]]:
			var wall := wall_scene.instantiate()
			wall.position = data[0]
			wall.rotation.y = data[1]
			wall.scale = Vector3.ONE * 1.35
			add_child(wall)
	if roof_scene is PackedScene:
		var roof := roof_scene.instantiate()
		roof.position = Vector3(-7.0, 2.65, -1.5)
		roof.scale = Vector3(2.0, 1.0, 1.7)
		add_child(roof)
	if door_scene is PackedScene:
		var door := door_scene.instantiate()
		door.position = Vector3(-7.0, 0.7, 0.08)
		door.scale = Vector3.ONE * 1.2
		add_child(door)
	var path_scene := load("res://assets/imported/kenney_nature/Models/GLTF format/ground_pathStraight.glb")
	var bridge_scene := load("res://assets/imported/kenney_nature/Models/GLTF format/bridge_side_woodRound.glb")
	if path_scene is PackedScene:
		for i in 5:
			var path_piece := path_scene.instantiate()
			path_piece.position = Vector3(-5.0 + i * 1.8, 0.0, 2.0 + i * 0.25)
			path_piece.rotation.y = -0.14
			path_piece.scale = Vector3.ONE * 0.9
			add_child(path_piece)
	if bridge_scene is PackedScene:
		var bridge := bridge_scene.instantiate()
		bridge.position = Vector3(5.8, 0.1, 3.1)
		bridge.rotation.y = PI * 0.5
		bridge.scale = Vector3.ONE * 1.2
		add_child(bridge)
	var grass_scene := load("res://assets/imported/kenney_nature/Models/GLTF format/grass_large.glb")
	var flower_scene := load("res://assets/imported/kenney_nature/Models/GLTF format/flower_yellowB.glb")
	if grass_scene is PackedScene:
		for i in 18:
			var grass_patch := grass_scene.instantiate()
			grass_patch.position = Vector3(-8.0 + fmod(float(i) * 1.55, 15.0), 0.0, 1.5 + fmod(float(i) * 0.77, 6.0))
			grass_patch.scale = Vector3.ONE * 0.55
			add_child(grass_patch)
	if flower_scene is PackedScene:
		for i in 12:
			var flower := flower_scene.instantiate()
			flower.position = Vector3(-8.0 + fmod(float(i) * 1.9, 15.0), 0.0, 1.0 + fmod(float(i) * 1.13, 6.5))
			flower.scale = Vector3.ONE * 0.45
			add_child(flower)
		for i in 8:
			var sunflower := flower_scene.instantiate()
			sunflower.position = Vector3(-9.0 + i * 0.55, 0.05, 0.2 + (i % 2) * 0.35)
			sunflower.scale = Vector3.ONE * 1.15
			add_child(sunflower)

func _build_grass() -> void:
	for i in 75:
		var blade := MeshInstance3D.new()
		var blade_mesh := BoxMesh.new()
		blade_mesh.size = Vector3(0.035, 0.38 + float(i % 4) * 0.05, 0.035)
		blade.mesh = blade_mesh
		blade.position = Vector3(-14.0 + float((i * 17) % 280) / 10.0, 0.18, 1.0 + float((i * 13) % 70) / 10.0)
		var blade_mat := StandardMaterial3D.new()
		blade_mat.albedo_color = Color("#3f8c4d") if i % 2 == 0 else Color("#5da557")
		blade.material_override = blade_mat
		add_child(blade)
		grass.append(blade)

func _add_rock(pos: Vector3, scale_factor: float) -> void:
	var rock := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = scale_factor
	mesh.height = scale_factor * 0.8
	rock.mesh = mesh
	rock.position = pos + Vector3(0, scale_factor * 0.25, 0)
	rock.rotation.y = rng.randf_range(0, TAU)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#777a70")
	mat.roughness = 0.95
	rock.material_override = mat
	add_child(rock)

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
		var tail := MeshInstance3D.new()
		var tail_mesh := SphereMesh.new()
		tail_mesh.radius = 0.28
		tail_mesh.height = 0.42
		tail.mesh = tail_mesh
		tail.scale = Vector3(0.18, 0.75, 0.55)
		tail.position = Vector3(0, 0, -0.38)
		tail.material_override = mat
		fish_body.add_child(tail)
		var fin := MeshInstance3D.new()
		var fin_mesh := SphereMesh.new()
		fin_mesh.radius = 0.16
		fin_mesh.height = 0.28
		fin.mesh = fin_mesh
		fin.scale = Vector3(0.16, 0.45, 0.65)
		fin.position = Vector3(0, 0.18, 0.02)
		fin.material_override = mat
		fish_body.add_child(fin)
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
	var season: int = _season_for_month(Time.get_datetime_dict_from_system().month)
	last_season = season
	var ground_colors: Array[Color] = [Color("#9bcf82"), Color("#78b965"), Color("#a88455"), Color("#d9e1e4")]
	var foliage_colors: Array[Color] = [Color("#69b85c"), Color("#4e9b55"), Color("#c27a3d"), Color("#d7e3e5")]
	var ground_color: Color = ground_colors[season]
	var foliage_color: Color = foliage_colors[season]
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
	if chimney_smoke:
		var month: int = Time.get_datetime_dict_from_system().month
		var cold_weather := month >= 10 or month <= 3
		chimney_smoke.emitting = cold_weather
	_apply_health_visuals()

func _apply_health_visuals() -> void:
	var health: float = clampf(world_health, 0.0, 1.0)
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

func record_activity_reward(points: float) -> void:
	# Public bridge for NutriVision: positive activity gently restores the world.
	world_health = clampf(world_health + points * 0.01, 0.0, 1.0)
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

