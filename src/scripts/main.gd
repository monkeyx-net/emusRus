extends Control

var menu_items: Array[Dictionary] = []

func _ready():
	# Initialize menu items
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
	
	# Create the carousel
	create_carousel()

func create_carousel():
	# Create a horizontal box container for the carousel items
	var hbox = $Carousel#HBoxContainer.new()
	hbox.name = "Carousel"
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.size_flags_vertical = Control.SIZE_FILL

	# Enable scrolling for the carousel
	var scroll = ScrollContainer.new()
	scroll.name = "ScrollContainer"
	scroll.custom_minimum_size = Vector2(800, 150)  # Adjust width for your desired view
	scroll.add_child(hbox)
	add_child(scroll)

	# Create buttons for each menu item
	for item in menu_items:
		var button = create_carousel_button(item)
		hbox.add_child(button)

	# Add a tween for infinite scrolling
	setup_infinite_scroll(scroll, hbox)

func create_carousel_button(item: Dictionary) -> Button:
	var button = Button.new()
	button.text = item["name"]
	button.custom_minimum_size = Vector2(150, 150)
	button.connect("pressed", Callable(self, "_on_button_pressed").bind(item["id"]))

	# Load and scale the icon
	var texture = load(item["icon"])
	if texture:
		var icon = TextureRect.new()
		icon.texture = texture
		icon.custom_minimum_size = Vector2(150, 150)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		button.add_child(icon)
	else:
		print("Warning: Icon not found for item: ", item["name"])

	return button

func setup_infinite_scroll(scroll: ScrollContainer, hbox: HBoxContainer):
	var tween = create_tween()
	tween.set_loops()  # Infinite looping
	tween.tween_property(scroll, "scroll_horizontal", hbox.get_combined_minimum_size().x, 10.0)
	tween.tween_callback(scroll.set.bind("scroll_horizontal", 0))  # Reset scroll position
	tween.tween_interval(0.5)  # Small delay before restarting

func _on_button_pressed(id: int):
	print("Button with ID: %d pressed" % id)
	# Add your logic here for button presses
