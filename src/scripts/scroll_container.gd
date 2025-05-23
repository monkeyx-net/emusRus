extends ScrollContainer

@export var button_template: PackedScene = preload("res://scenes/button.tscn")

var items = [
	{"graphic": "res://assets/graphics/emusRus_icon.png", "description": "EMUSRUS"},
	{"graphic": "res://assets/graphics/systems/org.es_de.frontend.svg", "description": "ES DE"},
	{"graphic": "res://assets/graphics/systems/retroarch_inv.svg", "description": "RETROARCH"},
	{"graphic": "res://assets/graphics/systems/batocera-icon.png", "description": "BATOCERA"},
	{"graphic": "res://icon.svg", "description": "GODOT"},
]

var current_selected_button: Button = null
var current_selected_index: int = -1

@onready var grid_container: GridContainer = $GridContainer

func _ready():
	var config_reader = SystemConfig.new()
	var file_path = "res://config/config.json"
	if config_reader.load_config_from_file(file_path):
		print("Configuration loaded successfully!")
		var abxy_button_swap_citra = config_reader.get_config_value("config/abxy_button_swap/citra", false)
		print("ABXY Button Swap for Citra: ", abxy_button_swap_citra)
		var font = config_reader.get_config_value("config/options/font", "1")
		print("Font: ", font)
		var es_de_program_url = config_reader.get_config_value("config/es-de/program_url", "")
		print("ES-DE Program URL: ", es_de_program_url)
	else:
		print("Failed to load configuration.")
	# Center the GridContainer within the ScrollContainer
	grid_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid_container.anchor_left = 0.5
	grid_container.anchor_right = 0.5
	grid_container.anchor_top = 0.5
	grid_container.anchor_bottom = 0.5

	grid_container.columns = items.size()
	self.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	self.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO

	for item in items:
		var button_instance = button_template.instantiate()
		button_instance.name = item["description"]

		var texture_rect: TextureRect = button_instance.get_node("TextureRect")
		var label: Label = button_instance.get_node("Label")
		var texture = load(item["graphic"])
		if texture:
			texture_rect.texture = texture
		else:
			print("Failed to load texture: ", item["graphic"])
		label.text = item["description"]

		button_instance.pressed.connect(_on_button_pressed.bind(button_instance))

		# Create a MarginContainer for each button
		var margin_container = MarginContainer.new()
		margin_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		margin_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		margin_container.add_theme_constant_override("margin_left", 20)
		margin_container.add_theme_constant_override("margin_right", 20)
		margin_container.add_theme_constant_override("margin_top", 20)
		margin_container.add_theme_constant_override("margin_bottom", 20)
		margin_container.add_child(button_instance)

		# Center the button within the MarginContainer
		button_instance.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button_instance.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		grid_container.add_child(margin_container)

	if grid_container.get_child_count() > 0:
		select_button(grid_container.get_child(0).get_child(0) as Button, 0)

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		move_selection(-1 if event.keycode == KEY_LEFT else 1 if event.keycode == KEY_RIGHT else 0)

func move_selection(direction: int):
	var button_count = grid_container.get_child_count()
	if button_count == 0: return

	var new_index = (current_selected_index + direction) % button_count
	if new_index < 0: new_index = button_count - 1

	select_button(grid_container.get_child(new_index).get_child(0) as Button, new_index)

func select_button(button: Button, index: int):
	if current_selected_button:
		tween_button_scale(current_selected_button, Vector2(1, 1))
		reset_margins(current_selected_button)

	current_selected_button = button
	current_selected_index = index
	tween_button_scale(button, Vector2(2.0, 2.0))
	adjust_margins_for_selected(button)

func _on_button_pressed(button: Button):
	for i in range(grid_container.get_child_count()):
		if grid_container.get_child(i).get_child(0) == button:
			select_button(button, i)
			print(button.name)
			break

func tween_button_scale(button: Button, target_scale: Vector2):
	create_tween().tween_property(button, "scale", target_scale, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func adjust_margins_for_selected(button: Button):
	var margin_container = button.get_parent() as MarginContainer
	if margin_container:
		margin_container.add_theme_constant_override("margin_left", 80)
		margin_container.add_theme_constant_override("margin_right", 280)
		margin_container.add_theme_constant_override("margin_top", -200)
		margin_container.add_theme_constant_override("margin_bottom", 50)

func reset_margins(button: Button):
	var margin_container = button.get_parent() as MarginContainer
	if margin_container:
		margin_container.add_theme_constant_override("margin_left", 20)
		margin_container.add_theme_constant_override("margin_right", 20)
		margin_container.add_theme_constant_override("margin_top", 20)
		margin_container.add_theme_constant_override("margin_bottom", 20)
