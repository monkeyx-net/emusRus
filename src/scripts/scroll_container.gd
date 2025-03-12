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
	#{"graphic": "res://assets/graphics/emusRus_icon.png", "description": "Item 6"},
	#{"graphic": "res://assets/graphics/emusRus_icon.png", "description": "Item 7"},
	#{"graphic": "res://assets/graphics/emusRus_icon.png", "description": "Item 8"},
]

# Track the currently selected button
var current_selected_button: Button = null
var current_selected_index: int = -1

# Cache the GridContainer reference
@onready var grid_container: GridContainer = $GridContainer

func _ready():
	# Set the GridContainer to have one row (horizontal layout)
	grid_container.columns = items.size()  # Set columns to the number of items for horizontal layout
	grid_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Allow horizontal expansion

	# Ensure the ScrollContainer scrolls horizontally
	self.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED  # Disable vertical scrolling
	self.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO  # Enable horizontal scrolling

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
		
		# Create a new MarginContainer for each button
		var margin_container = MarginContainer.new()
		margin_container.add_theme_constant_override("margin_left", 80)  # Default left margin
		margin_container.add_theme_constant_override("margin_right", 80) # Default right margin
		margin_container.add_child(button_instance)
		
		# Add the MarginContainer (with the button inside) to the grid_container
		grid_container.add_child(margin_container)
		
	# Select the first button by default if there are any buttons
	if grid_container.get_child_count() > 0:
		select_button(grid_container.get_child(0).get_child(0) as Button, 0)

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_LEFT:
				move_selection(-1)
			elif event.keycode == KEY_RIGHT:
				move_selection(1)

func move_selection(direction: int):
	var new_index = current_selected_index + direction
	var button_count = grid_container.get_child_count()
	if new_index >= 0 and new_index < button_count:
		select_button(grid_container.get_child(new_index).get_child(0) as Button, new_index)

func select_button(button: Button, index: int):
	# If a button is already selected, reset its scale and margins
	if current_selected_button:
		tween_button_scale(current_selected_button, Vector2(1, 1))
		reset_margins(current_selected_button)
	
	# Set new selected button
	current_selected_button = button
	current_selected_index = index
	
	# Tween the new button to be larger and adjust its margins
	tween_button_scale(button, Vector2(1.65, 1.65))  # Scale up the selected button
	adjust_margins_for_selected(button)

func _on_button_pressed(button: Button):
	var index = -1
	for i in range(grid_container.get_child_count()):
		if grid_container.get_child(i).get_child(0) == button:
			index = i
			break
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
		0.4  # Duration of the tween
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func adjust_margins_for_selected(button: Button):
	# Get the MarginContainer parent of the button
	var margin_container = button.get_parent() as MarginContainer
	if margin_container:
		# Reduce margins for the selected button
		margin_container.add_theme_constant_override("margin_left", 0)  # Smaller left margin
		margin_container.add_theme_constant_override("margin_right", 160) # Smaller right margin

func reset_margins(button: Button):
	# Get the MarginContainer parent of the button
	var margin_container = button.get_parent() as MarginContainer
	if margin_container:
		# Reset margins to default
		margin_container.add_theme_constant_override("margin_left", 20)  # Default left margin
		margin_container.add_theme_constant_override("margin_right", 20) # Default right margin
