extends Node
class_name SystemConfig

var config: Dictionary = {}
var system_name: String
#var path: String
var prog_url: String
var log_folder: String
var launch: String


func load_config_from_file(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		
		if error == OK:
			config = json.get_data()
			return true
		else:
			print("Failed to parse JSON: ", json.get_error_message())
			return false
	else:
		print("Failed to open file: ", file_path)
		return false

func get_config_value(path: String, default = null):
	var keys = path.split("/")
	var current = config
	for key in keys:
		if key in current:
			current = current[key]
		else:
			return default
	
	return current

func _ready():
	var file_path = "res://config/config.json"
	
	if load_config_from_file(file_path):
		print("Configuration loaded successfully!")
		var abxy_button_swap_citra = get_config_value("config/abxy_button_swap/citra", false)
		print("ABXY Button Swap for Citra: ", abxy_button_swap_citra)
		var font = get_config_value("config/options/font", "1")
		print("Font: ", font)
		var es_de_program_url = get_config_value("config/es-de/program_url", "")
		print("ES-DE Program URL: ", es_de_program_url)
	else:
		print("Failed to load configuration.")
