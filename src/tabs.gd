extends Control

var gameslist_dir = "/run/media/tim/DATA/es-de/.config/ES-DE/gamelists"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var favorites = find_favorites()
	save_favorites(favorites)
	print("Favorite games saved to favorites.xml.")


func find_favorites() -> Array:
	var favorite_games = []
	
	# Open the main directory containing subdirectories
	var dir = DirAccess.open(gameslist_dir)
	if dir == null:
		print("Failed to open directory: ", gameslist_dir)
		return favorite_games
	
	dir.list_dir_begin()
	var folder_name = dir.get_next()
	
	while folder_name != "":
		# Ignore `.` and `..` entries
		if dir.current_is_dir() and folder_name != "." and folder_name != "..":
			var xml_path = gameslist_dir + "/" + folder_name + "/gamelist.xml"
			if FileAccess.file_exists(xml_path):
				favorite_games.append_array(parse_favorites(xml_path))
		
		folder_name = dir.get_next()
	
	dir.list_dir_end()
	return favorite_games

func parse_favorites(xml_path: String) -> Array:
	var favorites = []
	var xml = XMLParser.new()
	
	if xml.open(xml_path) == OK:
		while xml.read() == OK:
			if xml.get_node_type() == XMLParser.NODE_ELEMENT and xml.get_node_name() == "game":
				var game_data = "\n"
				var is_favorite = false
				while xml.read() == OK and not (xml.get_node_type() == XMLParser.NODE_ELEMENT_END and xml.get_node_name() == "game"):
					if xml.get_node_type() == XMLParser.NODE_ELEMENT:
						var element_name = xml.get_node_name()
						xml.read()
						if element_name == "favorite" and xml.get_node_data().strip_edges() == "true":
							is_favorite = true
						# Avoid redundant <game> tags in game_data
						if element_name != "game" or element_name != "desc":
							game_data += "\t<%s>%s</%s>" % [element_name, xml.get_node_data(), element_name] + "\n"

				if is_favorite:
					favorites.append("<game>" + game_data + "</game>")
	
	return favorites

func save_favorites(favorites: Array) -> void:
	var output_path = gameslist_dir + "/favorites.xml"
	var formatted_xml = '<?xml version="1.0" encoding="UTF-8"?>\n<favorites>\n'
	
	for game in favorites:
		var indented_game = ""
		for line in game.split("\n"):
			indented_game += "\t" + line + "\n"
		formatted_xml += indented_game
	
	formatted_xml += "</favorites>"

	var file = FileAccess.open(output_path, FileAccess.WRITE)
	
	if file:
		file.store_string(formatted_xml)
		file.close()
