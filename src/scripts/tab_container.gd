extends TabContainer

var FIRST_RUN: bool = true


func _ready() -> void:
	_connect_signals()
	if FIRST_RUN == false:
		%TabContainer.set_tab_hidden(0,true)

func _connect_signals():
	$BACKUPS/backups_button.pressed.connect(SharedFunctions.button_func.bind($BACKUPS/backups_button, %backups_gc ))
	$BACKUPS/restore_button.pressed.connect(SharedFunctions.button_func.bind($BACKUPS/restore_button, %restore_gc ))
	#%backup_1.pressed.connect(SharedFunctions.run_command_in_thread.bind("find", ["/home/tim/", "-name", "*.xcf", "-print"], false))
	%backup_1.pressed.connect(SharedFunctions.run_command_in_thread.bind("rclone", ["config", "--config=../data/rclone_emu.conf", "update", "emusRus_GoogleDrive"], false))
	%backup_2.pressed.connect(SharedFunctions.run_command_in_thread.bind("rclone", ["--config=../data/rclone_emu.conf", "ls", "emusRus_GoogleDrive:emusRus"], false))
	SharedFunctions.command_finished.connect(_on_command_finished)

func _on_command_finished(result):
	#print("Command result:", result)
	$BACKUPS/RichTextLabel.text = "Exit Code: " + str(result["exit_code"]) + "\n"
	$BACKUPS/RichTextLabel.text += result["output"]
	
