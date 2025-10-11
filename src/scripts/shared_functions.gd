extends Node
class_name SharedFunctions

const ESDE_ACTIVE := true
const RA_ACTIVE := true
var result = {}
var OS_TYPE: String
var HOSTNAME: String
var OS_DISTRO: String
var OS_VERSION: String
var RA_PATH: String
var DEFAULT_RA_PATH_LINUX = ""
var DEFAULT_RA_PATH_WINDOWS = ""
var DEFAULT_RA_PATH_ANDROID =  ""
signal command_finished(result: String)

func _ready() -> void:
	pass
	#OS_TYPE = OS.get_name();
	#if OS_TYPE != "Windows":
		## Get Basic Host Information
		#execute_command("uname", ["-n"], true)
		#HOSTNAME = result["output"]
		#execute_command("lsb_release", ["-ds"], true)
		#OS_DISTRO = OS.get_name()# result["output"].replace ('"', '')
		#execute_command("lsb_release", ["-rs"], true)
		#OS_VERSION = OS.get_version()# result["output"]
	## Get EMUSRUS Information
	#
	## Get RetroArch Information
	#DEFAULT_RA_PATH_LINUX = OS.get_environment("HOME") + "/.config/retroarch/retroarch.cfg"
	#if FileAccess.file_exists(DEFAULT_RA_PATH_LINUX):
		#RA_PATH = DEFAULT_RA_PATH_LINUX.get_base_dir()
	#else:
		#DEFAULT_RA_PATH_LINUX=""
	
func button_func(button: Button, grid: GridContainer) -> void:
	match button.name:
		"backups_button", "restore_button":
			if grid.visible == false:
				grid.visible = true
			else:
				grid.visible = false

func wait (seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func array_to_string(arr: Array) -> String:
	var text: String
	for line in arr:
		text = line.strip_edges() + "\n"
	return text

func execute_command(command: String, parameters: Array, console: bool) -> Dictionary:
	var output = []
	print ("exec: " + command + " " + str(parameters))
	var exit_code = OS.execute(command, parameters, output, console) ## add if exit == 0 etc
	result["output"] = array_to_string(output)
	result["exit_code"] = exit_code
	print ("Exit code:" + str(result["exit_code"]) + " " + result["output"])
	return result

func run_command_in_thread(command: String, paramaters: Array, console: bool) -> Dictionary:
	var thread = Thread.new()
	thread.start(execute_command.bind(command,paramaters,console))
	while thread.is_alive():
		await get_tree().process_frame
	emit_signal("command_finished", result)
	return thread.wait_to_finish()

func run_batch(process: String) -> void:
	match process:
		"rclone_setup":
			execute_command("rclone", ["config", "--config=config/rclone/rclone_emu.conf", "update", "emusRus_GoogleDrive"], false)
			run_command_in_thread("rclone", ["--config=config/rclone/rclone_emu.conf", "mkdir", "emusRus_GoogleDrive:emusRus/bob"], false)
			run_command_in_thread("rclone", ["--config=config/rclone/rclone_emu.conf", "mkdir", "emusRus_GoogleDrive:emusRus/saves"], false)
			run_command_in_thread("rclone", ["--config=config/rclone/rclone_emu.conf", "mkdir", "emusRus_GoogleDrive:emusRus/config"], false)


func find_file_in_directory(target_folder: String, filename: String) -> String:
	if not DirAccess.dir_exists_absolute(target_folder):
		print("Error: Target folder does not exist: ", target_folder)
		return ""	
	return _search_recursive(target_folder, filename)

func _search_recursive(current_path: String, filename: String) -> String:
	var dir = DirAccess.open(current_path)
	if dir == null:
		return ""
	dir.list_dir_begin()	
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue
		var full_path = current_path.path_join(file_name)
		if dir.current_is_dir():
			var tresult = _search_recursive(full_path, filename)
			if tresult != "":
				dir.list_dir_end()
				return tresult
		else:
			if file_name == filename:
				dir.list_dir_end()
				return full_path
		file_name = dir.get_next()	
	dir.list_dir_end()
	return ""

func find_all_files_in_directory(target_folder: String, filename: String) -> Array:
	var results = []
	if not DirAccess.dir_exists_absolute(target_folder):
		print("Error: Target folder does not exist: ", target_folder)
		return results
	_search_recursive_all(target_folder, filename, results)
	return results

func _search_recursive_all(current_path: String, filename: String, results: Array):
	var dir = DirAccess.open(current_path)
	if dir == null:
		return	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue
		var full_path = current_path.path_join(file_name)		
		if dir.current_is_dir():
			_search_recursive_all(full_path, filename, results)
		else:
			if file_name == filename:
				results.append(full_path)
		file_name = dir.get_next()
	dir.list_dir_end()
