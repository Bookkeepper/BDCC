# This class is used by FoxLib ModHelper for debugging
const debug_tracers = {}
const fallback_null = null
const trace_mode = {}

# Backport of GD4 type_string to GD3
static func type_string(typeInt):
	return "0x" + str(typeInt)

static func trace_str(arg):
	if arg == null:
		return "<null>"
	if arg == fallback_null:
		return "<fallback null>"
	if typeof(arg) == TYPE_OBJECT and not is_instance_valid(arg):
		return "<invalid>"
	var arg_str = null
	if typeof(arg) == TYPE_DICTIONARY:
		return "<dictionary>"
	elif typeof(arg) == TYPE_ARRAY:
		return "<array>"
	else:
		arg_str = var2str(arg)
	if arg_str.length() > 512:
		arg_str = "[Object:" + str(arg.get_class()) + "]"
	return arg_str

static func enable_trace():
	if trace_mode.size() != 0:
		return
	trace_mode["trace"] = true
	provide_thread_debug_stack()
	Log.print("[FLMH] Enabling trace mode")

static func trace_lazy(trace):
	if trace_mode.size() != 0:
		Log.print("TRACE: " + str(trace))

static func trace(trace):
	if trace_mode.size() == 0:
		enable_trace()
	Log.print("TRACE: " + str(trace))

static func provide_thread_debug_stack():
	var current_thread_id = OS.get_thread_caller_id()
	var current_stack = debug_tracers.get(current_thread_id)
	if current_stack == null:
		if debug_tracers.size() == 0:
			Log.print("[FLMH] Enabling debug mode")
		current_stack = []
		debug_tracers[current_thread_id] = current_stack
	return current_stack

static func push_debug_lazy(dbg):
	if debug_tracers.size() == 0:
		return -1
	trace_lazy(dbg)
	var debug_stack = provide_thread_debug_stack()
	var debug_index = debug_stack.size()
	debug_stack.push_front(dbg)
	return debug_index

static func pop_debug_lazy(debug_index):
	if debug_index == -1:
		return
	var debug_stack = provide_thread_debug_stack()
	while debug_stack.size() > debug_index:
		debug_stack.pop_front()

static func dump_stack_error(dbg, err):
	var debug_stack = provide_thread_debug_stack()
	Log.error("FATAL ERROR: " + err)
	if debug_tracers.size() == 0:
		# If available get stack from godot itself
		var gd_debug_stack = get_stack()
		var gotDebug = false
		for gd_dbg_line in gd_debug_stack:
			Log.error(" at " + str(gd_dbg_line.source.trim_prefix("res://")) + "#" + str(gd_dbg_line.function) + "():" + str(gd_dbg_line.line))
			gotDebug = true
		if gotDebug:
			return
	Log.error(" at " + dbg)
	debug_stack.invert()
	for dbg_line in debug_stack:
		Log.error(" at " + dbg_line)
	debug_stack.invert()

static func check_non_null(dbg, instance):
	trace_lazy("check_non_null: " + str(dbg) + " -> " + trace_str(instance))
	if instance != null and instance != fallback_null:
		if typeof(instance) == TYPE_OBJECT and not is_instance_valid(instance):
			dump_stack_error(dbg, "Invalid instance")
			return fallback_null
		return instance
	dump_stack_error(dbg, "Null instance")
	if fallback_null != null:
		fallback_null.clear()
	return fallback_null

static func call_virtual_safe(dbg, instance, methodName, args):
	trace_lazy("call_virtual_safe: " + str(dbg) + " -> " + trace_str(instance) + "." + str(methodName) + "()")
	if instance == null or instance == fallback_null:
		dump_stack_error(dbg, "Cannot call " + methodName + " on null instance")
		return null
	if not is_instance_valid(instance):
		dump_stack_error(dbg, "Cannot call " + methodName + " on invalid instance")
		return null
	if not (instance is Object):
		dump_stack_error(dbg, "Cannot trace " + methodName + " on non object " + type_string(typeof(instance)))
		return null
	if not instance.has_method(methodName):
		dump_stack_error(dbg, "Cannot call " + methodName + " on " + instance.get_class() + ", method does not exists")
		return null
	# Populate stack
	var debug_stack = provide_thread_debug_stack()
	var debug_index = debug_stack.size()
	debug_stack.push_front(dbg)
	# Call method
	var ret = instance.callv(methodName, args)
	# Restore debug stack
	while debug_stack.size() > debug_index:
		debug_stack.pop_front()
	#Return value
	return ret

static func call_virtual_simple(dbg, instance, methodName):
	trace_lazy("call_virtual_simple: " + str(dbg) + " -> " + trace_str(instance) + "." + str(methodName) + "()")
	if instance == null or instance == fallback_null:
		dump_stack_error(dbg, "Cannot call " + methodName + " on null instance")
		return null
	if not is_instance_valid(instance):
		dump_stack_error(dbg, "Cannot call " + methodName + " on invalid instance")
		return null
	if not (instance is Object):
		dump_stack_error(dbg, "Cannot trace " + methodName + " on non object " + type_string(typeof(instance)))
		return null
	if not instance.has_method(methodName):
		dump_stack_error(dbg, "Cannot call " + methodName + " on " + instance.get_class() + ", method does not exists")
		return null
	# Populate stack
	var debug_stack = provide_thread_debug_stack()
	var debug_index = debug_stack.size()
	debug_stack.push_front(dbg)
	# Call method
	var ret = instance.call(methodName)
	# Restore debug stack
	while debug_stack.size() > debug_index:
		debug_stack.pop_front()
	#Return value
	return ret

static func call_virtual_single(dbg, instance, methodName, arg):
	trace_lazy("call_virtual_single: " + str(dbg) + " -> " + trace_str(instance) + "." + str(methodName) + "()")
	if instance == null or instance == fallback_null:
		dump_stack_error(dbg, "Cannot call " + methodName + " on null instance")
		return null
	if not is_instance_valid(instance):
		dump_stack_error(dbg, "Cannot call " + methodName + " on invalid instance")
		return null
	if not (instance is Object):
		dump_stack_error(dbg, "Cannot trace " + methodName + " on non object " + type_string(typeof(instance)))
		return null
	if not instance.has_method(methodName):
		dump_stack_error(dbg, "Cannot call " + methodName + " on " + instance.get_class() + ", method does not exists")
		return null
	# Populate stack
	var debug_stack = provide_thread_debug_stack()
	var debug_index = debug_stack.size()
	debug_stack.push_front(dbg)
	# Call method
	var ret = instance.call(methodName, arg)
	# Restore debug stack
	while debug_stack.size() > debug_index:
		debug_stack.pop_front()
	#Return value
	return ret

static func call_virtual_unsafe(dbg, instance, methodName, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null, arg6 = null, arg7 = null, arg8 = null):
	trace_lazy("call_virtual_unsafe: " + str(dbg) + " -> " + trace_str(instance) + "." + str(methodName) + "()")
	if instance == null or instance == fallback_null:
		dump_stack_error(dbg, "Cannot call " + methodName + " on null instance")
		return null
	if not is_instance_valid(instance):
		dump_stack_error(dbg, "Cannot call " + methodName + " on invalid instance")
		return null
	if not (instance is Object):
		dump_stack_error(dbg, "Cannot trace " + methodName + " on non object " + type_string(typeof(instance)))
		return null
	if not instance.has_method(methodName):
		dump_stack_error(dbg, "Cannot call " + methodName + " on " + instance.get_class() + ", method does not exists")
		return null
	# Populate stack
	var debug_stack = provide_thread_debug_stack()
	var debug_index = debug_stack.size()
	debug_stack.push_front(dbg)
	# Call method
	var ret = null
	# Getting around GDScript jank, very annoying!
	if arg8 != null:
		ret = instance.call(methodName, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
	elif arg7 != null:
		ret = instance.call(methodName, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
	elif arg6 != null:
		ret = instance.call(methodName, arg1, arg2, arg3, arg4, arg5, arg6)
	elif arg5 != null:
		ret = instance.call(methodName, arg1, arg2, arg3, arg4, arg5)
	elif arg4 != null:
		ret = instance.call(methodName, arg1, arg2, arg3, arg4)
	elif arg3 != null:
		ret = instance.call(methodName, arg1, arg2, arg3)
	elif arg2 != null:
		ret = instance.call(methodName, arg1, arg2)
	elif arg1 != null:
		ret = instance.call(methodName, arg1)
	else:
		ret = instance.call(methodName)
	# Restore debug stack
	while debug_stack.size() > debug_index:
		debug_stack.pop_front()
	#Return value
	return ret
