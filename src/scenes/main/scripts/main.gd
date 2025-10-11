extends Control

@onready var esde_item_list: ItemList = %ESDEItemList
@onready var esde_panel: Panel = %ESDEPanel
var json_settings:= JsonSettings.new()

func _ready():
	esde_item_list.item_selected.connect(_on_item_selected)
	print ("App Version: ", json_settings.application_version)
	print ("App Description: ", json_settings.application_description)
	json_settings.application_version="0.0.1"
	print ("App Version: ", json_settings.application_version)
#	if JsonSettings.load_xml_settings("/home/tim/ES-DE/settings/es_settings.xml"):
	# Get values with type conversion
	var fullscreen = json_settings.get_value("video_driver")
	print (fullscreen)
	json_settings.set_value("video_driver", "vulkan")
	json_settings.save_to_file("/home/tim/Applications/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/retroarch.cfg")
	print (json_settings.get_value("video_driver"))
func _on_item_selected(index: int):
	match index:
		0:
			esde_panel.visible = true
		1:
			esde_panel.visible = false
