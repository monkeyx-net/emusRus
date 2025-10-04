extends TabContainer

var icon_width: int = 64

func _ready() -> void:
	set_tab_icon(0, ResourceLoader.load("res://assets/graphics/systems/org.es_de.frontend.svg"))
	set_tab_icon_max_width(0,icon_width)
	set_tab_icon(1, ResourceLoader.load("res://assets/graphics/org.gtk.IconBrowser4.png"))
	set_tab_icon_max_width(0,icon_width)	
	set_tab_icon(2, ResourceLoader.load("res://assets/graphics/icons/Xelu_Free_Controller&Key_Prompts/Xbox Series/XboxSeriesX_Menu.png"))
	set_tab_icon_max_width(0,icon_width)
	set_tab_disabled(1, true)
