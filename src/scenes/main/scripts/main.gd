extends Control

@onready var esde_item_list: ItemList = %ESDEItemList
@onready var esde_panel: Panel = %ESDEPanel

func _ready():
	esde_item_list.item_selected.connect(_on_item_selected)
	print ("App Version: ", JsonSettings.application_version)
	print ("App Description: ", JsonSettings.application_description)
	JsonSettings.application_version="0.0.1"
	print ("App Version: ", JsonSettings.application_version)
#	if JsonSettings.load_xml_settings("/home/tim/ES-DE/settings/es_settings.xml"):
	var rom_dir = JsonSettings.get_rom_directory()
	var es_theme = JsonSettings.get_theme()
	var debug_mode = JsonSettings.is_debug_mode()
	print("ROM Directory: ", rom_dir)
	print("Theme: ", es_theme)
	print("Debug Mode: ", debug_mode)
	# move to shared functions
	var fresult = SharedFunctions.find_file_in_directory("/home/tim/", "ES-DE_x64.AppImage")
	print (fresult)

func _on_item_selected(index: int):
	match index:
		0:
			esde_panel.visible = true
		1:
			esde_panel.visible = false
