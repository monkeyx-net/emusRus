extends TabContainer

@onready var http_request: HTTPRequest = %HTTPRequest
const UPDATE_INTERVAL := 0.1
var FIRST_RUN: bool = true
var vbox_list: Array = ["%emusrus_vbox","%retroarch_vbox"]
var download_timer: Timer
signal download_status_changed(status: String, progress: float)
var is_downloading := false
var total_bytes := 0
var downloaded_bytes := 0

func _ready() -> void:
	_connect_signals()
	SharedFunctions.command_finished.connect(_on_command_finished)
	if FIRST_RUN == false:
		%TabContainer.set_tab_hidden(0,true)

func _connect_signals():
	$BACKUPS/backups_button.pressed.connect(SharedFunctions.button_func.bind($BACKUPS/backups_button, %backups_gc ))
	$BACKUPS/restore_button.pressed.connect(SharedFunctions.button_func.bind($BACKUPS/restore_button, %restore_gc ))
	#%backup_1.pressed.connect(SharedFunctions.run_command_in_thread.bind("find", ["/home/tim/", "-name", "*.xcf", "-print"], false))
	#%backup_1.pressed.connect(SharedFunctions.run_command_in_thread.bind("ls", ["-ltr", "config/rclone"], false))
	%backup_1.pressed.connect(SharedFunctions.run_batch.bind("rclone_setup"))
	#%backup_1.pressed.connect(SharedFunctions.run_command_in_thread.bind("rclone", ["config", "--config=config/rclone/rclone_emu.conf", "update", "emusRus_GoogleDrive"], false))
	%backup_2.pressed.connect(SharedFunctions.run_command_in_thread.bind("rclone", ["--config=config/rclone/rclone_emu.conf", "ls", "emusRus_GoogleDrive:emusRus"], false))
	#%backup_2.pressed.connect(SharedFunctions.execute_command.bind("rclone", ["--config=config/rclone/rclone_emu.conf", "ls", "emusRus_GoogleDrive:emusRus"], false))
	%download_button.pressed.connect(download.bind(%download_button, "Bob"))
	%emusrus_button.pressed.connect(show_info.bind(%emusrus_button))
	%retroarch_button.pressed.connect(show_info.bind(%retroarch_button))
	#%CheckButton.pressed.connect(SharedFunctions.run_command_in_thread.bind("journalctl", ["--user", "-u", "test.service"], false))
	%CheckButton.pressed.connect(SharedFunctions.run_command_in_thread.bind("systemctl", ["--user", "status", "test.service"], false))
	#%CheckButton.pressed.connect(SharedFunctions.run_command_in_thread.bind("systemctl", ["--user", "status", "test.timer"], false))
	%CheckButton.pressed.connect(_shell_run.bind("http://trailoutlaws.com"))
	%download_timer.timeout.connect(_update_progress)
	
func _on_command_finished(result) -> void:
	print("Command result:", result)
	$BACKUPS/RichTextLabel.text = "Exit Code: " + str(result["exit_code"]) + "\n"
	$BACKUPS/RichTextLabel.text += result["output"]

func _shell_run (url: String) -> void:
	OS.shell_open(url)

func download(button: Button, system_name: String) -> void:
	print (system_name)
	button.disabled = true
	%download_ProgressBar.visible = true
	%download_ProgressBar.value = 0
	button.text = "Downloading"
	http_request.download_file = "Apps/ES-DE_x64.AppImage"
	http_request.request("https://gitlab.com/es-de/emulationstation-de/-/package_files/164503027/download")
	%download_timer.start()
	emit_signal("download_status_changed", "started", 0.0)
	download_file_async(button)

func download_file_async(button: Button) -> void:
	var result = await http_request.request_completed
	%download_timer.stop()
	_handle_request_result(result)
	button.disabled = false
	button.text = "DOWNLOADED"
	if SharedFunctions.OS_TYPE == "Linux":
		SharedFunctions.execute_command("chmod", ["+x", http_request.download_file],false)

func _update_progress() -> void:
	downloaded_bytes = http_request.get_downloaded_bytes()
	total_bytes = http_request.get_body_size()
	if total_bytes > 0:
		var progress := float(downloaded_bytes) / float(total_bytes) * 100
		%download_ProgressBar.value = progress
		print("Download progress: ", progress, "%")  # Debug line
		emit_signal("download_status_changed", "downloading", progress)

func _handle_request_result(result_data: Array) -> void:
	var result: int = result_data[0]
	var response_code: int = result_data[1]
	var status: String = ""
	%download_ProgressBar.visible = false
	emit_signal("download_status_changed", status, 100.0 if status == "failed" else 100.0)

	if result == OK and response_code == 200:
		print("Request completed successfully!")
	else:
		print("Request failed with result: ", result, " and response code: ", response_code)

func show_info(button: Button) -> void:
	for vbox in vbox_list:
		var vbox_container = get_node(vbox) as VBoxContainer
		print (vbox_container.name)
		vbox_container.visible = false
	match button.name:
		"emusrus_button":
			%emusrus_vbox.visible = true
		"retroarch_button":
			if SharedFunctions.RA_PATH != "":
				%retroarch_valid.text = "Path validated"
			else:
				%retroarch_valid.text = "Path not found!"
			%retroarch_vbox.visible = true
