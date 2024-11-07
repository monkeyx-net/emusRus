extends Node

# make json config for these? 
const ESDE_ACTIVE := true
const RA_ACTIVE := true
var result = {}

signal command_finished(result: String)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
	var exit_code = OS.execute(command, parameters, output, console) ## add if exit == 0 etc
	result["output"] = array_to_string(output)
	result["exit_code"] = exit_code	
	return result

func run_command_in_thread(command: String, paramaters: Array, console: bool) -> Dictionary:
	var thread = Thread.new()
	var bob = thread.start(execute_command.bind(command,paramaters,console))
	while thread.is_alive():
		await get_tree().process_frame
	emit_signal("command_finished", result)
	return thread.wait_to_finish()
