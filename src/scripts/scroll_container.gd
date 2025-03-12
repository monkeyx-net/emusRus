extends ScrollContainer

@export var button_template: PackedScene = preload("res://button.tscn")

var items = [
	{"graphic": "res://assets/graphics/emusRus_icon.png", "description": "Item 1"},
	{"graphic": "res://assets/graphics/systems/org.es_de.frontend.svg", "description": "Item 2"},
	{"graphic": "res://assets/graphics/systems/retroarch_inv.svg", "description": "Item 3"},
	{"graphic": "res://assets/graphics/systems/batocera-icon.png", "description": "Item 4"},
	{"graphic": "res://icon.svg", "description": "Item 5"},
]

var current_selected_button: Button = null
var current_selected_index: int = -1

@onready var grid_container: GridContainer = $GridContainer

func _ready():
	grid_container.columns = items.size()
	grid_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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

		var margin_container = MarginContainer.new()
		margin_container.add_theme_constant_override("margin_left", 80)
		margin_container.add_theme_constant_override("margin_right", 80)
		margin_container.add_child(button_instance)
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

func reset_margins(button: Button):
	var margin_container = button.get_parent() as MarginContainer
	if margin_container:
		margin_container.add_theme_constant_override("margin_left", 20)
		margin_container.add_theme_constant_override("margin_right", 20)
