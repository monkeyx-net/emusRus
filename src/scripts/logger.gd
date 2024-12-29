var emurus_log : String = "emurus.log"

func logger(log_type: String, log_text: String) -> void:
	var log_dir: DirAccess = DirAccess.open(emurus_log)
	var log_file: FileAccess
	var log_header: String = "[GODOT] "
	var datetime: Dictionary = Time.get_datetime_dict_from_system()
	var unixtime: float = Time.get_unix_time_from_system()
	var msec: int = (unixtime - floor(unixtime)) * 1000 # finally, real ms! Thanks, monkeyx
	var timestamp: String = "[%d-%02d-%02d %02d:%02d:%02d.%03d]" % [
	datetime.year, datetime.month, datetime.day,
	datetime.hour, datetime.minute, datetime.second, msec] # real ms!!
	var log_line: String = timestamp

	match log_type:
		'w':
			log_line += " [WARNING] " + log_header
		'e':
			log_line += " [ERROR] " + log_header
		'i':
			log_line += " [INFO] " + log_header
		'd':
			log_line += " [DEBUG] " + log_header
		_:
			log_line += " " + log_header
			print("guru meditation error with logging")
	log_line += log_text
	# print(log_line)
#
	#if not log_dir:
		#log_dir = DirAccess.open("res://")
		#if log_dir.make_dir_recursive(emurus_log_folder) != OK:
			#print("Something wrong with log directory - ", emurus_log_folder)
			#return

	if not FileAccess.open(emurus_log, FileAccess.READ):
		log_file = FileAccess.open(emurus_log, FileAccess.WRITE_READ)
	else:
		log_file = FileAccess.open(emurus_log, FileAccess.READ_WRITE)
	if log_file:
		log_file.seek_end()
		log_file.store_line(log_line)
		log_file.close()
	else:
		print("Something wrong with log file - ", emurus_log)
