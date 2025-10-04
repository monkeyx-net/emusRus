extends ItemList

func _ready() -> void:
	# set focus to first item in Item List
	%ESDEItemList.grab_focus()
	%ESDEItemList.select(0)
	%ESDEPanel.visible = true
	%ItemList.max_columns = 3
	%ItemList.fixed_column_width = 350
	%ItemList.same_column_width = true
	%ItemList.add_item("ES DE Installed: ", null,false)
	%ItemList.add_item(str(JsonSettings.esde_installed),null,false)
	%ItemList.add_item("",null,false)
	%ItemList.add_item("ES DE Version: ", null,false)
	%ItemList.add_item(str(JsonSettings.esde_version()),null,false)
	%ItemList.add_item("",null,false)
	%ItemList.add_item("ES DE Settings found: ", null,false)
	%ItemList.add_item(str(JsonSettings.esde_installed),null,false)
	%ItemList.add_item("",null,false)
	%ItemList.add_item("ES DE Rom Folder: ", null,false)
	%ItemList.add_item(JsonSettings.get_rom_directory(),null,false)
	%ItemList.add_item("Install",null,true)
	%ItemList.add_item("ES DE Theme Folder: ", null,false)
	%ItemList.add_item(str(JsonSettings.esde_installed),null,false)
	%ItemList.add_item("",null,false)
	%ItemList.add_item("ES DE Media Folder:", null,false)
	%ItemList.add_item(str(JsonSettings.esde_installed),null,false)
	%ItemList.add_item("",null,false)
