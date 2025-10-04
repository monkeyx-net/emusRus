extends ItemList

func _ready() -> void:
	# set focus to first item in Item List
	%ESDEItemList.grab_focus()
	%ESDEItemList.select(0)
	%ESDEPanel.visible = true
