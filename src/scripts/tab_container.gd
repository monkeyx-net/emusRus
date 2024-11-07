extends TabContainer

var FIRST_RUN: bool = true


func _ready() -> void:
	_connect_signals()
	if FIRST_RUN == false:
		%TabContainer.set_tab_hidden(0,true)
	print (SharedFunctions.ESDE_ACTIVE)
	
func _connect_signals():
	$BACKUPS/backups_button.pressed.connect(SharedFunctions.button_func.bind($BACKUPS/backups_button, %backups_gc ))
	$BACKUPS/restore_button.pressed.connect(SharedFunctions.button_func.bind($BACKUPS/restore_button, %restore_gc ))
	%backup_1.pressed.connect(SharedFunctions.run_command_in_thread.bind("find", ["/home/tim/", "-name", "*.cfg", "-print"], false))
	SharedFunctions.command_finished.connect(_on_command_finished)

func _on_command_finished(result):
	print("Command result:", result)
	
