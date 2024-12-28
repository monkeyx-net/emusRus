extends Node

# make json config for these? 
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
	OS_TYPE = OS.get_name();
	if OS_TYPE != "Windows":
		# Get Basic Host Information
		execute_command("uname", ["-n"], true)
		HOSTNAME = result["output"]
		execute_command("lsb_release", ["-ds"], true)
		OS_DISTRO = result["output"].replace ('"', '')
		execute_command("lsb_release", ["-rs"], true)
		OS_VERSION = result["output"]
	# Get EMUSRUS Information
	
	# Get RetroArch Information
	DEFAULT_RA_PATH_LINUX = OS.get_environment("HOME") + "/.config/retroarch/retroarch.cfg"
	if FileAccess.file_exists(DEFAULT_RA_PATH_LINUX):
		RA_PATH = DEFAULT_RA_PATH_LINUX.get_base_dir()
	else:
		DEFAULT_RA_PATH_LINUX=""

func find_app() -> Dictionary:
	pass
	var bob: Dictionary
	# Pass param system to look for config file in known locations ie~/.local etc
	# system_name:true/false
	return bob
	
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
