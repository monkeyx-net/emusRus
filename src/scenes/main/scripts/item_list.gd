extends ItemList

func _ready() -> void:
	# set focus to first item in Item List
	%ESDEItemList.grab_focus()
	%ESDEItemList.select(0)
	%ESDEPanel.visible = true
	%ItemList.max_columns = 3
	%ItemList.fixed_column_width = 450
	%ItemList.same_column_width = true
	#%ItemList.add_item("ES DE Installed: ", null,false)
	#%ItemList.add_item(str(JsonSettings.esde_installed),null,false)
	#%ItemList.add_item("Install",null,false)
	#%ItemList.add_item("ES DE Version: ", null,false)
	#%ItemList.add_item(str(JsonSettings.esde_version()),null,false)
	#%ItemList.add_item("",null,false)
	#%ItemList.add_item("ES DE Settings found: ", null,false)
	#%ItemList.add_item(str(JsonSettings.esde_installed),null,false)
	#%ItemList.add_item("",null,false)
	#%ItemList.add_item("ES DE Rom Folder: ", null,false)
	#%ItemList.add_item(JsonSettings.get_rom_directory(),null,false)
	#%ItemList.add_item("",null,false)
	#%ItemList.add_item("ES DE Theme Folder: ", null,false)
	#%ItemList.add_item(str(JsonSettings.esde_installed),null,false)
	#%ItemList.add_item("",null,false)
	#%ItemList.add_item("ES DE Media Folder:", null,false)
	#%ItemList.add_item(str(JsonSettings.esde_installed),null,false)
	#%ItemList.add_item("",null,false)
	var items = [
		["ES-DE Installed: ", str(JsonSettings.esde_installed), "Install"],
		["ES-DE Version: ", str(JsonSettings.esde_version()), ""],
		["ES-DE Settings Found: ", str(JsonSettings.esde_installed), ""],
		["ES-DE Settings Path: ", JsonSettings.esde_settings, ""],
		["ES-DE Rom Folder: ", JsonSettings.get_rom_directory(), ""],
		["ES-DE Theme Folder: ", JsonSettings.get_theme_directory(), ""],
		["ES-DE Media Folder: ", JsonSettings.get_media_directory(), ""]
	]
	
	create_info(%ItemList, items)


func create_info(item_list: ItemList, items: Array) -> void:
	item_list.clear()
	
	for item_group in items:
		item_list.add_item(item_group[0], null, false)
		item_list.add_item(item_group[1], null, false)
		item_list.add_item(item_group[2], null, false)
