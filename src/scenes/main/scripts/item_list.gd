extends ItemList

var json_settings:= JsonSettings.new()

func _ready() -> void:
	# set focus to first item in Item List
	%ESDEItemList.grab_focus()
	%ESDEItemList.select(0)
	%ESDEPanel.visible = true
	%ItemList.max_columns = 3
	%ItemList.fixed_column_width = 450
	%ItemList.same_column_width = true
	var items = [
		["ES-DE Installed: ", str(json_settings.esde_installed), "Install"],
		["ES-DE Version: ", str(json_settings.esde_version()), ""],
		["ES-DE Settings Found: ", str(json_settings.esde_installed), ""],
		["ES-DE Settings Path: ", json_settings.esde_settings, ""],
		["ES-DE Rom Folder: ", json_settings.get_rom_directory(), ""],
		["ES-DE Theme Folder: ", json_settings.get_theme_directory(), ""],
		["ES-DE Current Theme: ", json_settings.get_theme(), ""],
		["ES-DE Media Folder: ", json_settings.get_media_directory(), ""]
	]

	create_info(%ItemList, items)

func create_info(item_list: ItemList, items: Array) -> void:
	item_list.clear()
	
	for item_group in items:
		item_list.add_item(item_group[0], null, false)
		item_list.add_item(item_group[1], null, false)
		item_list.add_item(item_group[2], null, false)
