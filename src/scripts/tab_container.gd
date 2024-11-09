extends TabContainer

var FIRST_RUN: bool = true
var vbox_list: Array = ["%emusrus_vbox","%retroarch_vbox"]


func _ready() -> void:
	_connect_signals()
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
	SharedFunctions.command_finished.connect(_on_command_finished)
	%emusrus_button.pressed.connect(show_info.bind(%emusrus_button))
	%retroarch_button.pressed.connect(show_info.bind(%retroarch_button))

func _on_command_finished(result) -> void:
	#print("Command result:", result)
	$BACKUPS/RichTextLabel.text = "Exit Code: " + str(result["exit_code"]) + "\n"
	$BACKUPS/RichTextLabel.text += result["output"]

func show_info(button: Button) -> void:
	for vbox in vbox_list:
		var vbox_container = get_node(vbox) as VBoxContainer
		print (vbox_container.name)
		vbox_container.visible = false
	match button.name:
		"emusrus_button":
			%emusrus_vbox.visible = true
		"retroarch_button":
			%retroarch_vbox.visible = true
			
