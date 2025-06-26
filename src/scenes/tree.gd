extends Tree

func _ready():
	columns = 4
	# Configure columns
	set_column_title(0, "System")
	set_column_title(1, "Path")
	set_column_title(2, "Size")
	set_column_title(3, "Date")
	
	# Optional: Set column widths
	set_column_expand(0, true)
	set_column_expand(1, true)
	set_column_expand(2, false)
	set_column_expand(3, false)
	set_column_custom_minimum_width(0, 100)
	set_column_custom_minimum_width(1, 200)
	set_column_custom_minimum_width(2, 80)
	set_column_custom_minimum_width(3, 120)
	
	# Create items
	var root = create_item()  # This creates the hidden root
	
	# First item
	var item1 = create_item(root)
	item1.set_text(0, "Windows")
	item1.set_text(1, "C:/Program Files/Game")
	item1.set_text(2, "1.2 GB")
	item1.set_text(3, "2023-05-15")
	
	# Second item
	var item2 = create_item(root)
	item2.set_text(0, "Linux")
	item2.set_text(1, "/usr/local/games")
	item2.set_text(2, "856 MB")
	item2.set_text(3, "2023-06-20")
	
	# Third item
	var item3 = create_item(root)
	item3.set_text(0, "macOS")
	item3.set_text(1, "/Applications/Game.app")
	item3.set_text(2, "2.4 GB")
	item3.set_text(3, "2023-04-10")
