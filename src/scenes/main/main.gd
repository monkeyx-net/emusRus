extends Control

@onready var esde_item_list: ItemList = %ESDEItemList
@onready var esde_panel: Panel = %ESDEPanel

func _ready():
	esde_item_list.item_selected.connect(_on_item_selected)
	
func _on_item_selected(index: int):
	match index:
		0:
			esde_panel.visible = true
		1:
			esde_panel.visible = false
