@tool
extends Node3D

# -- Creature Settings --
# These variables control the appearance and behavior of the creature. 
# They automatically update the editor preview when changed.

@export var length: int = 15:
	set(value):
		length = value
		update_gizmo()

@export var frequency: float = 1.0:
	set(value):
		frequency = value
		update_gizmo()

@export var start_angle: float = 0.0:
	set(value):
		start_angle = value
		update_gizmo()

@export var base_size: float = 2.0:
	set(value):
		base_size = value
		update_gizmo()

@export var multiplier: float = 3.0:
	set(value):
		multiplier = value
		update_gizmo()

# -- Scenes to spawn --
# Packed scenes for the head and body segments of the creature.
@export var head_scene: PackedScene
@export var body_scene: PackedScene

# -- Internal variables --
var angle_per_segment: float    # Angle spacing between segments
var boid                        # The head of the creature
var body_segments: Array = []   # List of body segment nodes
var gizmo_boxes: Array = []      # Temporary editor-only visualization boxes

# Called when the scene is ready
func _ready():
	# Only generate the actual creature when running the game (not in the editor)
	if not Engine.is_editor_hint():
		generate_creature()

# Editor live update
func _process(delta):
	if Engine.is_editor_hint():
		# While in editor, keep updating the preview gizmo
		update_gizmo()
	else:
		# During gameplay, move the segments
		update_movement(delta)

# ========== Live gizmo preview in editor ==========
func update_gizmo():
	# Remove any previous preview boxes
	for box in gizmo_boxes:
		if is_instance_valid(box):
			box.queue_free()
	gizmo_boxes.clear()

	# Draw new preview boxes based on current settings
	for i in range(length):
		var t = i / float(length)   # Normalize position along the chain
		var angle = start_angle + t * frequency * TAU
		var sine = sin(angle)
		var size = remap(sine, -1.0, 1.0, base_size, base_size * multiplier)

		var box = CSGBox3D.new()
		box.size = Vector3(size, size, size)
		box.position = Vector3(i * 2.0, 0, 0)   # Space out boxes along X
		box.operation = CSGShape3D.OPERATION_UNION

		# Set a light blue material
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.8, 0.8, 1.0)
		box.material = mat

		add_child(box)
		gizmo_boxes.append(box)

# ========== Actual creature generation at runtime ==========
func generate_creature():
	# Clear everything (body, boid, and preview boxes)
	for child in get_children():
		child.queue_free()
	gizmo_boxes.clear()

	body_segments.clear()
	boid = null

	# Spawn the head node
	if head_scene:
		boid = head_scene.instantiate()
		add_child(boid)

		# Optional: if boid has a "pause" control, pause it initially
		if boid.has_method("set_pause"):
			boid.pause = true
		
		# Adjust the size of the head if possible
		var head_box = boid.get_node_or_null("CSGBox3D")
		if head_box:
			head_box.size = Vector3(base_size, base_size, base_size)

	# Precompute spacing between body segments
	angle_per_segment = (PI * 2.0 * frequency) / max(length, 1)

	# Spawn body segments
	if body_scene:
		for i in range(1, length):
			var angle = start_angle + i * angle_per_segment
			var sine_value = sin(angle)
			var size = remap(sine_value, -1.0, 1.0, base_size, base_size * multiplier)

			var body_segment = body_scene.instantiate()

			# If the scene is a CSGBox3D, set its size directly
			var csg = body_segment as CSGBox3D
			if csg:
				csg.size = Vector3(size, size, size)
			else:
				# Otherwise, scale a normal node
				body_segment.scale = Vector3(size, size, size)

			body_segment.position = Vector3(i * 2.0, 0, 0)
			add_child(body_segment)
			body_segments.append(body_segment)
	else:
		print("Warning: body_scene is not assigned!")

# ========== Movement logic ==========
func update_movement(delta):
	# If no head exists, skip
	if boid == null:
		return

	# Move each body segment toward the previous segment
	if body_segments.size() > 0:
		var prev_pos = boid.global_position

		for i in range(body_segments.size()):
			var segment = body_segments[i]
			var direction = (prev_pos - segment.global_position).normalized()
			var distance = prev_pos.distance_to(segment.global_position)

			# If too far, pull the segment toward the previous
			if distance > 1.0:
				segment.global_position += direction * 5.0 * delta

			# Apply a wavy movement effect
			var wave_speed = 5.0
			var wave_strength = 3.0
			var wave_offset = sin(Time.get_ticks_msec() / 1000.0 * wave_speed + i * 0.5) * wave_strength

			segment.translate(Vector3(0, 0, wave_offset) * delta)

			# Update previous position for next segment
			prev_pos = segment.global_position

# Handle input for pausing
func _input(event):
	if event.is_action_pressed("pause_toggle"):
		if boid:
			# Toggle the 'pause' state of the head
			boid.pause = not boid.pause
			print("Pause is now: ", boid.pause)
