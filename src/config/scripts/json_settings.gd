extends Node
class_name JsonSettings

var shared_functions:= SharedFunctions.new()
var settings_data: Dictionary = {}
var settings_path: String = "res://config/settings.json"
var xml_settings_data: Dictionary = {}
var home_path: String = OS.get_environment("USERPROFILE")  if OS.has_feature("windows") else OS.get_environment("HOME")
var esde_path: String = home_path + "/ES-DE/"
var esde_settings: String = esde_path + "settings/es_settings.xml"
var _config_data: Dictionary = {}

var application: Dictionary:
	get: return settings_data.get("emusrus", {})    
var application_description: String:
	get: return application.get("description", "")  
var application_path: String:
	get: return application.get("app_folder", "")  
var application_version: String:
	get: return application.get("version", "")   
	set(value):
		application["version"] = value
		save_settings()
var esde_installed: bool: 
	get: return FileAccess.file_exists(esde_settings)
	
func _init():
	load_settings()
	load_config()
	if esde_installed:
		load_xml_settings(esde_settings)
	else:
		print ("Error loading ", esde_settings)

func esde_version() -> String:
	var param: Array = ["--version"]
	var output: Array = []
	var fresult = shared_functions.find_file_in_directory("/home/tim/", "ES-DE_x64.AppImage")
	OS.execute(fresult, param, output, true)
	var version: String = str(output).replace('"', '').replace('[', '').replace(']', '').replace('\\n', '')
	return version

func load_xml_settings(xml_path: String) -> bool:
	if not FileAccess.file_exists(xml_path):
		push_error("XML settings file not found: " + xml_path)
		return false
	var file = FileAccess.open(xml_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open XML settings file: Error " + str(FileAccess.get_open_error()))
		return false
	var xml_content = file.get_as_text()
	file.close()
	return parse_xml_settings(xml_content)

func parse_xml_settings(xml_content: String) -> bool:
	xml_settings_data.clear()
	var lines = xml_content.split("\n")
	for line in lines:
		line = line.strip_edges()
		if line.is_empty() or not line.begins_with("<"):
			continue
		if line.begins_with("<bool "):
			var name_start = line.find("name=\"") + 6
			var name_end = line.find("\"", name_start)
			var value_start = line.find("value=\"") + 7
			var value_end = line.find("\"", value_start)
			if name_start != -1 and name_end != -1 and value_start != -1 and value_end != -1:
				var setting_name = line.substr(name_start, name_end - name_start)
				var value_str = line.substr(value_start, value_end - value_start)
				xml_settings_data[setting_name] = value_str.to_lower() == "true"
		elif line.begins_with("<int "):
			var name_start = line.find("name=\"") + 6
			var name_end = line.find("\"", name_start)
			var value_start = line.find("value=\"") + 7
			var value_end = line.find("\"", value_start)
			if name_start != -1 and name_end != -1 and value_start != -1 and value_end != -1:
				var setting_name = line.substr(name_start, name_end - name_start)
				var value_str = line.substr(value_start, value_end - value_start)
				xml_settings_data[setting_name] = value_str.to_int()
		elif line.begins_with("<string "):
			var name_start = line.find("name=\"") + 6
			var name_end = line.find("\"", name_start)
			var value_start = line.find("value=\"") + 7
			var value_end = line.find("\"", value_start)
			
			if name_start != -1 and name_end != -1 and value_start != -1 and value_end != -1:
				var setting_name = line.substr(name_start, name_end - name_start)
				var value = line.substr(value_start, value_end - value_start)
				xml_settings_data[setting_name] = value
	print("XML settings loaded successfully. Total settings: " + str(xml_settings_data.size()))
	return true

func get_xml_setting(setting_name: String, default = null):
	return xml_settings_data.get(setting_name, default)

func get_xml_bool(setting_name: String, default: bool = false) -> bool:
	var value = xml_settings_data.get(setting_name)
	if value is bool:
		return value
	return default

func get_xml_int(setting_name: String, default: int = 0) -> int:
	var value = xml_settings_data.get(setting_name)
	if value is int:
		return value
	return default

func get_xml_string(setting_name: String, default: String = "") -> String:
	var value = xml_settings_data.get(setting_name)
	if value is String:
		return value
	return default

func get_rom_directory() -> String:
	var rom_dir = get_xml_string("ROMDirectory", "")
	return esde_path + "Roms" if rom_dir == "" else rom_dir

func get_theme_directory() -> String:
	var theme_dir = get_xml_string("UserThemeDirectory", "")
	return esde_path + "themes" if theme_dir == "" else theme_dir

func get_media_directory() -> String:
	var media_dir = get_xml_string("MediaDirectory", "")
	return esde_path + "downloaded_media" if media_dir == "" else media_dir

func get_theme() -> String:
	return get_xml_string("Theme", "")

func is_debug_mode() -> bool:
	return get_xml_bool("DebugMode", false)

func get_sound_volume() -> int:
	return get_xml_int("SoundVolumeNavigation", 70)

func load_settings() -> bool:
	var file_path = settings_path
	var file: FileAccess
	var json_text: String
	var json: JSON
	var parse_result: int
	var error_code: int
	var error_message: String
	var error_line: int
	
	if not FileAccess.file_exists(file_path):
		push_error("Settings file not found: " + file_path)
		return false
	file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		error_code = FileAccess.get_open_error()
		push_error("Failed to open settings file: Error " + str(error_code))
		return false
	json_text = file.get_as_text()
	file.close()
	json = JSON.new()
	parse_result = json.parse(json_text)
	if parse_result != OK:
		error_message = json.get_error_message()
		error_line = json.get_error_line()
		push_error("JSON Parse Error: " + error_message + " at line " + str(error_line))
		return false
	settings_data = json.get_data()
	print("Settings loaded successfully from: " + file_path)
	return true

func save_settings() -> bool:
	var file = FileAccess.open(settings_path, FileAccess.WRITE)	
	var json_string = JSON.stringify(settings_data, "\t")
	if file == null:
		push_error("Failed to open settings.json for writing")
		return false
	file.store_string(json_string)
	file.close()
	print("Settings saved successfully")
	return true

func get_option(options_value: String) -> String:
	var options = application.get("options", {})
	return options.get(options_value, "")

func get_url() -> String:
	return "%s:%s" % [application_path, "test"]

func get_full_path(option_name: String) -> String:
	var option: String = get_option(option_name)
	if option.is_empty():
		return ""	
	return "%s:%s%s" % [application_path, "Test", option]

# load from file?
func create_default_settings() -> void:
	settings_data = {
	"emusrus": {
		"config_folder": "$HOME/.config/emusrus",
		"config_file": "emusrus_settings.json",
		"bios_folder": "/run/media/user/DATA/emusrus/bios",
		"borders_folder": "/run/media/user/DATA/emusrus/borders",
		"logs_folder": "/run/media/user/DATA/emusrus/logs",
		"program_url": "",
		"description": "Description here with line breaks? \n Test line break",
		"version": "alpha-001a",
		"options": {
			"font": "1",
			"sound_effects": true,
			"volume_effects": "10"
			}
		},
	"es-de": {
		"config_folder": "$HOME/ES-DE/settings",
		"config_file": "es_settings.xml",
		"logs_folder": "/logs",
		"media_folder": "/downloaded_media",
		"roms_folder": "/run/media/tim/DATA/es-de/roms/",
		"themes_folder": "/themes",
		"launch": "ES-DE_x64.AppImage",
		"program_url": "https://gitlab.com/es-de/emulationstation-de/-/package_files/164503027/download"
	},
	"retroarch": {
		"config_folder": "$HOME/.config/retroarch",
		"config_file": "retroarch.cfg",
		"bios_folder": "/system",
		"borders_folder": "/overlays",
		"cheats_folder": "/cheats",
		"cores_folder": "/cores",
		"logs_folder": "/logs",
		"media_folder": "/downloaded_media",
		"mods_folder": "",
		"roms_folder": "/roms",
		"saves_folder": "/saves",
		"screenshots_folder": "/screenshots",
		"states_folder": "/states",
		"texture_packs_folder": "/texture_packs",
		"themes_folder": "/themes",
		"program_url_stable_linux": "https://buildbot.libretro.com/stable/1.20.0/linux/x86_64/RetroArch.7z",
		"program_url_stable_mac": "#",
		"program_url_stable_windows": "#",
		"program_url_assets": "#"
	},
	"retroarch_cores": {
		"cores_url_nightly_linux": "https://buildbot.libretro.com/nightly/linux/x86_64/RetroArch_cores.7z",
		"cores_url_nightly_mac": "#",
		"cores_url_nightly_windows": "#"
	},
	"mame": {
		"program_url_stable_linux": "https://buildbot.libretro.com/stable/1.20.0/linux/x86_64/RetroArch.7z",
		"program_url_stable_mac": "#",
		"program_url_stable_windows": "#"
	}
}
	if save_settings():
		print("Default settings file created")
	else:
		push_error("Failed to create default settings file")

func reload_settings() -> bool:
	return load_settings()

func reset_to_default() -> bool:
	create_default_settings()
	return load_settings()

func load_or_generate_key(crypto: Crypto) -> CryptoKey:
	var keypair = CryptoKey.new()
	# needs to go user path?
	var private_key: String = "cfg/id_rsa.key"
	var public_key: String = "cfg/id_rsa.pub"
	# Try to load existing private key
	if FileAccess.file_exists(private_key):
		if keypair.load(private_key) == OK:
			# TODO log instead
			print("Loaded existing RSA key")
			return keypair
	# TODO log instead
	print("Generating new RSA key...")
	keypair = crypto.generate_rsa(4096)
	if keypair.save(private_key) == OK and keypair.save(public_key, true) == OK:
		# TODO log instead
		print("New RSA key generated and saved")
	return keypair
	
func encrypt_data(crypto: Crypto, keypair: CryptoKey, message: String) -> String:
	var ciphertext = crypto.encrypt(keypair, message.to_utf8_buffer())
	return Marshalls.raw_to_base64(ciphertext)

func decrypt_data(crypto: Crypto, keypair: CryptoKey, encrypted_token: PackedByteArray) -> String:
	var decrypted_bytes = crypto.decrypt(keypair, encrypted_token)
	var decrypted_message = decrypted_bytes.get_string_from_utf8()
	if encrypted_token.is_empty():
		push_error("No data to decrypt")
		return "Error"
	return decrypted_message

func parse_from_text(config_text: String) -> bool:
	var lines = config_text.split("\n")
	for line in lines:
		line = line.strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue
		# Parse key = value pairs
		if "=" in line:
			var parts = line.split("=", false, 1)
			if parts.size() == 2:
				var key = parts[0].strip_edges()
				var value = parts[1].strip_edges().trim_prefix("\"").trim_suffix("\"")
				_config_data[key] = value
	return true

func get_value(key: String, default: String = "") -> String:
	return _config_data.get(key, default)

func get_bool(key: String, default: bool = false) -> bool:
	var value = get_value(key, "")
	return value == "true" if value == "true" or value == "false" else default

func get_int(key: String, default: int = 0) -> int:
	var value = get_value(key, "")
	return value.to_int() if value.is_valid_int() else default

func get_float(key: String, default: float = 0.0) -> float:
	var value = get_value(key, "")
	return value.to_float() if value.is_valid_float() else default

func set_value(key: String, value: String) -> void:
	_config_data[key] = value

func set_bool(key: String, value: bool) -> void:
	_config_data[key] = "true" if value else "false"

func set_int(key: String, value: int) -> void:
	_config_data[key] = str(value)

func set_float(key: String, value: float) -> void:
	_config_data[key] = str(value)

# Convert to configuration file format
func to_config_text() -> String:
	var output: PackedStringArray = []
	
	for key in _config_data.keys():
		var value = _config_data[key]
		if " " in value or value.is_empty():
			output.append('%s = "%s"' % [key, value])
		else:
			output.append('%s = %s' % [key, value])
	
	return "\n".join(output)

func save_to_file(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(to_config_text())
		file.close()
		return true
	return false

func load_from_file(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		return parse_from_text(content)
	return false

func get_all_data() -> Dictionary:
	return _config_data.duplicate()

func has_key(key: String) -> bool:
	return _config_data.has(key)

func remove_key(key: String) -> bool:
	return _config_data.erase(key)

func clear() -> void:
	_config_data.clear()

func load_config(file_path: String = "/home/tim/Applications/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch/retroarch.cfg") -> bool:
	_config_data.clear()
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open config file: " + file_path)
		return false
	
	while file.get_position() < file.get_length():
		var line = file.get_line().strip_edges()

		if line.is_empty() or line.begins_with("#"):
			continue
		if "=" in line:
			var parts = line.split("=", false, 1)
			if parts.size() == 2:
				var key = parts[0].strip_edges()
				var value = parts[1].strip_edges()
				if value.begins_with('"') and value.ends_with('"'):
					value = value.substr(1, value.length() - 2)
				_config_data[key] = value
				#print("Loaded: ", key, " = ", value)  # Debug output

	file.close()
	print("Successfully loaded ", _config_data.size(), " configuration entries")
	return true
