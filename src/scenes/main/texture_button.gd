extends TextureButton

func _ready():
	self.button_down.connect(_on_button_down)
	self.button_up.connect(_on_button_up)

func _on_button_down():
	self_modulate = Color(0.8, 0.8, 0.8, 0.9)

func _on_button_up():
	self_modulate = Color.WHITE
