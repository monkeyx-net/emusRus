extends ScrollContainer

# Preload the button template
@export var button_template: PackedScene = preload("res://button.tscn")

# Example data for the buttons
var items = [
	{"graphic": "res://assets/graphics/emusRus_icon.png", "description": "Item 1"},
	{"graphic": "res://assets/graphics/systems/org.es_de.frontend.svg", "description": "Item 2"},
	{"graphic": "res://assets/graphics/systems/retroarch_inv.svg", "description": "Item 3"},
	{"graphic": "res://assets/graphics/systems/batocera-icon.png", "description": "Item 4"},
	{"graphic": "res://icon.svg", "description": "Item 5"},
	{"graphic": "res://assets/graphics/emusRus_icon.png", "description": "Item 6"},
	{"graphic": "res://assets/graphics/emusRus_icon.png", "description": "Item 7"},
	{"graphic": "res://assets/graphics/emusRus_icon.png", "description": "Item 8"},
]

# Track the currently selected button
var current_selected_button: Button = null
var current_selected_index: int = -1

# Cache the HBoxContainer reference
@onready var hbox_container: GridContainer = $GridContainer

func _ready():
	for item in items:
		var button_instance = button_template.instantiate()
		
		# Set the graphic and description
		var texture_rect: TextureRect = button_instance.get_node("TextureRect")
		var label: Label = button_instance.get_node("Label")
		
		# Load the texture with error handling
		var texture = load(item["graphic"])
		if texture:
			texture_rect.texture = texture
		else:
			print("Failed to load texture: ", item["graphic"])
		
		label.text = item["description"]
		
		# Connect the button's pressed signal to a function using Callable
		button_instance.pressed.connect(_on_button_pressed.bind(button_instance))
		
		# Add the button to the HBoxContainer
		hbox_container.add_child(button_instance)

	# Select the first button by default if there are any buttons
	if hbox_container.get_child_count() > 0:
		select_button(hbox_container.get_child(0) as Button, 0)

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_LEFT:
				move_selection(-1)
			elif event.keycode == KEY_RIGHT:
				move_selection(1)

func move_selection(direction: int):
	var new_index = current_selected_index + direction
	var button_count = hbox_container.get_child_count()
	
	if new_index >= 0 and new_index < button_count:
		select_button(hbox_container.get_child(new_index) as Button, new_index)

func select_button(button: Button, index: int):
	# Restore previous spacing before changing selection
	$GridContainer.set("theme_override_constants/h_separation", 20)  # Default spacing
	
	# If a button is already selected, scale it back
	if current_selected_button:
		tween_button_scale(current_selected_button, Vector2(1, 1))
	
	# Set new selected button
	current_selected_button = button
	current_selected_index = index
	
	# Increase spacing to prevent overlap
	$GridContainer.set("theme_override_constants/h_separation", 100)  # Increased spacing
	
	# Tween the new button to be larger
	tween_button_scale(button, Vector2(1.5, 1.5))  # Adjusted scale
	
	# Ensure proper centering in the ScrollContainer
	ensure_button_visible(button)

func ensure_button_visible(button: Button):
	var button_rect = button.get_global_rect()
	var scroll_rect = get_global_rect()
	var container_size = size.x  # Width of ScrollContainer
	var scaled_width = button.size.x * button.scale.x  # Adjusted width
	
	# Calculate the target scroll position to center the button
	var target_x = button_rect.position.x - scroll_rect.position.x - (container_size / 2) + (scaled_width / 2)
	
	# Apply a margin to prevent overlap with the right-hand button
	target_x -= 50  # Adjust this value as needed
	
	# Ensure the target scroll position is within bounds
	scroll_horizontal = clamp(target_x, 0, hbox_container.size.x - container_size)

func _on_button_pressed(button: Button):
	var index = hbox_container.get_children().find(button)
	if index != -1:
		select_button(button, index)
		print(button.name)

func tween_button_scale(button: Button, target_scale: Vector2):
	# Create a new tween for the button
	var tween = create_tween()
	
	# Animate the scale property
	tween.tween_property(
		button,
		"scale",
		target_scale,
		0.3  # Duration of the tween
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
