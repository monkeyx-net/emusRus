extends Node

static var jsetting: JsonSettings
var settings_data: Dictionary = {}
var settings_path: String = "res://config/settings.json"
var xml_settings_data: Dictionary = {}
var home_path: String = OS.get_environment("USERPROFILE")  if OS.has_feature("windows") else OS.get_environment("HOME")
var esde_path: String = home_path + "/ES-DE/"
var esde_settings: String = esde_path + "settings/es_settings.xml"

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

func esde_version() -> Array:
	var param: Array = ["--version"]
	var output: Array = []
	OS.execute(home_path + "/Applications/ES-DE_x64.AppImage", param, output, true)
	return output

func _init():
	jsetting = self
	load_settings()
	if esde_installed:
		load_xml_settings(esde_settings)
	else:
		print ("Error loading ", esde_settings)

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
		# Parse bool elements
		if line.begins_with("<bool "):
			var name_start = line.find("name=\"") + 6
			var name_end = line.find("\"", name_start)
			var value_start = line.find("value=\"") + 7
			var value_end = line.find("\"", value_start)
			if name_start != -1 and name_end != -1 and value_start != -1 and value_end != -1:
				var setting_name = line.substr(name_start, name_end - name_start)
				var value_str = line.substr(value_start, value_end - value_start)
				xml_settings_data[setting_name] = value_str.to_lower() == "true"
		
		# Parse int elements
		elif line.begins_with("<int "):
			var name_start = line.find("name=\"") + 6
			var name_end = line.find("\"", name_start)
			var value_start = line.find("value=\"") + 7
			var value_end = line.find("\"", value_start)
			if name_start != -1 and name_end != -1 and value_start != -1 and value_end != -1:
				var setting_name = line.substr(name_start, name_end - name_start)
				var value_str = line.substr(value_start, value_end - value_start)
				xml_settings_data[setting_name] = value_str.to_int()
		
		# Parse string elements
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

# Helper methods for XML settings
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
	return get_xml_string("ROMDirectory", "")

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
	if not FileAccess.file_exists(file_path):
		push_error("Settings file not found: " + file_path)
		#create_default_settings()
		return false
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open settings file: Error " + str(FileAccess.get_open_error()))
		return false
	
	var json_text = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(json_text)
	
	if error != OK:
		push_error("JSON Parse Error: " + json.get_error_message() + " at line " + str(json.get_error_line()))
		return false
	
	settings_data = json.get_data()
	print("Settings loaded successfully from: " + file_path)
	return true

func save_settings() -> bool:
	var file = FileAccess.open(settings_path, FileAccess.WRITE)	
	if file == null:
		push_error("Failed to open settings.json for writing")
		return false
	var json_string = JSON.stringify(settings_data, "\t")
	file.store_string(json_string)
	file.close()
	print("Settings saved successfully")
	return true

# Helper methods for specific settings
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
	if encrypted_token.is_empty():
		push_error("No data to decrypt")
		return "Error"
	var decrypted_bytes = crypto.decrypt(keypair, encrypted_token)
	var decrypted_message = decrypted_bytes.get_string_from_utf8()
	return decrypted_message
