extends Node2D
class_name CarouselMenu

@export var button_spacing: float = 360.0
@export var scroll_speed: float = 1000.0
@export var normal_size: Vector2 = Vector2(200, 200)
@export var selected_size: Vector2 = Vector2(300, 300)
@export var elevation_height: float = 150.0
@export var wrap_around: bool = true
@export var input_repeat_delay: float = 0.5
@export var input_repeat_interval: float = 0.1
@export var icon_padding: int = 15
@export var background_texture: Texture2D

var background: TextureRect
var buttons: Array[Button] = []
var menu_items: Array[Dictionary] = []
var container: Node2D
var target_position: float = 0.0
var is_scrolling: bool = false
var current_index: int = 0
var total_width: float = 0.0
var input_hold_time: float = 0.0
var last_input_time: float = 0.0
var description_label: RichTextLabel

func _ready():
	setup_background()
	container = Node2D.new()
	add_child(container)
	
	# Create the RichTextLabel for descriptions
	description_label = RichTextLabel.new()
	description_label.bbcode_enabled = true
	description_label.fit_content = true
	description_label.scroll_active = false
	description_label.custom_minimum_size = Vector2(400, 100)  # Adjust size as needed
	description_label.position = Vector2(100, 300)  # Position below the carousel
	add_child(description_label)
	
	menu_items = [
		{"id": 1, "name": "EMUSRUS", "icon": "res://assets/graphics/emusRus_icon.png", "description": "[center]EmusRus is a retro gaming hub.[/center]"},
		{"id": 2, "name": "ES-DE", "icon": "res://assets/graphics/systems/org.es_de.frontend.svg", "description": "[center]ES-DE is a frontend for emulators.[/center]"},
		{"id": 3, "name": "RETROARCH", "icon": "res://assets/graphics/systems/retroarch_inv.svg", "description": "[center]RetroArch is a powerful emulator.[/center]"},
		{"id": 4, "name": "BATOCERA", "icon": "res://assets/graphics/systems/batocera-icon.png", "description": "[center]Batocera is a retro gaming OS.[/center]"},
		{"id": 5, "name": "GODOT", "icon": "res://icon.svg", "description": "[center]Godot is a game engine.[/center]"},
		{"id": 6, "name": "EMUSRUS", "icon": "res://assets/graphics/emusRus_icon.png", "description": "[center]EmusRus is a retro gaming hub.[/center]"},
		{"id": 7, "name": "ES-DE", "icon": "res://assets/graphics/systems/org.es_de.frontend.svg", "description": "[center]ES-DE is a frontend for emulators.[/center]"},
		{"id": 8, "name": "RETROARCH", "icon": "res://assets/graphics/systems/retroarch_inv.svg", "description": "[center]RetroArch is a powerful emulator.[/center]"},
		{"id": 9, "name": "BATOCERA", "icon": "res://assets/graphics/systems/batocera-icon.png", "description": "[center]Batocera is a retro gaming OS.[/center]"},
		{"id": 10, "name": "GODOT", "icon": "res://icon.svg", "description": "[center]Godot is a game engine.[/center]"}
	]
	setup_buttons()
	update_selection()
	adjust_to_viewport()
	get_viewport().connect("size_changed", Callable(self, "_on_viewport_resized"))

func setup_background():
	background = TextureRect.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.texture = background_texture
	add_child(background)
	move_child(background, 0)

func setup_buttons():
	total_width = button_spacing * menu_items.size()
	for i in range(menu_items.size()):
		var button = create_button(i)
		button.custom_minimum_size = normal_size
		button.size = normal_size
		buttons.append(button)
		container.add_child(button)
	update_button_positions()

func create_button(index: int) -> Button:
	var button = Button.new()
	button.custom_minimum_size = normal_size
	button.size = normal_size
	var vbox = VBoxContainer.new()
	vbox.size = button.size
	vbox.custom_minimum_size = button.size
	button.add_child(vbox)
	var texture_rect = TextureRect.new()
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.custom_minimum_size = Vector2(button.size.x - icon_padding * 2, button.size.y - icon_padding * 2 - 30)
	var texture = load(menu_items[index]["icon"]) as Texture2D
	if texture:
		texture_rect.texture = texture
	vbox.add_child(texture_rect)
	var label = Label.new()
	label.text = menu_items[index]["name"]
	label.custom_minimum_size = Vector2(0, 30)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vbox.add_child(label)
	return button

func update_button_positions():
	for i in range(buttons.size()):
		var button = buttons[i]
		var is_selected = i == current_index
		var target_size = selected_size if is_selected else normal_size		
		# Create a tween for the button size and position
		var tween = create_tween()
		tween.set_parallel(true)  # Run size and position tweens in parallel
		tween.tween_property(button, "custom_minimum_size", target_size, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "size", target_size, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		var relative_index = i - current_index
		var x_pos = relative_index * button_spacing  # Use button_spacing for spacing
		var base_y_pos = -button.size.y / 2
		var y_pos = base_y_pos - (elevation_height if is_selected else 0.0)
		tween.tween_property(button, "position", Vector2(x_pos, y_pos), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		# Update the VBoxContainer and its children
		var vbox = button.get_child(0) as VBoxContainer
		vbox.custom_minimum_size = target_size
		vbox.size = target_size
		var texture_rect = vbox.get_child(0) as TextureRect
		texture_rect.custom_minimum_size = Vector2(target_size.x - icon_padding * 2, target_size.y - icon_padding * 2 - 30)
		var label = vbox.get_child(1) as Label
		label.custom_minimum_size = Vector2(0, 30)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		if is_selected:
			label.add_theme_font_size_override("font_size", 40)
		else:
			label.remove_theme_font_size_override("font_size")

func _process(delta: float):
	if is_scrolling:
		update_selection()
		var direction = sign(target_position - container.position.x)
		var movement = scroll_speed * delta * direction
		if abs(target_position - container.position.x) <= abs(movement):
			container.position.x = target_position
			is_scrolling = false
		else:
			container.position.x += movement
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
		input_hold_time += delta
		if input_hold_time >= input_repeat_delay:
			var time_since_last = Time.get_ticks_msec() / 1000.0 - last_input_time
			if time_since_last >= input_repeat_interval:
				var direction = 1 if Input.is_action_pressed("ui_right") else -1
				move_carousel(direction)
				last_input_time = Time.get_ticks_msec() / 1000.0
	else:
		input_hold_time = 0.0

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_left"):
		move_carousel(-1)
	elif event.is_action_pressed("ui_right"):
		move_carousel(1)
	elif event.is_action_pressed("ui_accept"):
		print("Selected item: ", menu_items[current_index]["name"])

func move_carousel(direction: int):
	if is_scrolling:
		return
	var new_index = current_index + direction
	if wrap_around:
		new_index = wrapi(new_index, 0, menu_items.size())
	else:
		new_index = clamp(new_index, 0, menu_items.size() - 1)
	
	if new_index == current_index:
		return
	current_index = new_index
	target_position = 0
	is_scrolling = true
	update_selection()

func update_selection():
	update_button_positions()
	if current_index >= 0 and current_index < buttons.size():
		buttons[current_index].grab_focus()
		# Update the description label with the current item's description
		description_label.text = menu_items[current_index]["description"]

func adjust_to_viewport():
	var viewport_size = get_viewport_rect().size
	position = viewport_size / 2
	container.position.x = 0
	if background:
		background.position = -viewport_size / 2
	# Adjust the description label position
	#description_label.position = Vector2(0, viewport_size.y / 2 + 100)  # Adjust Y position as needed

func _on_viewport_resized():
	adjust_to_viewport()
	update_button_positions()
