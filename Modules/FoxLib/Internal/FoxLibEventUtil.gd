#nodebug
const FLMHDebug = preload("res://FoxLib/ModHelper/FLMHDebug.gd")
const DebugMode = false

static func internalCallModuleHandler(module, methodName, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null, arg6 = null, arg7 = null, arg8 = null):
	if module != null && module.has_method(methodName):
		# Getting around GDScript jank, very annoying!
		if arg8 != null:
			return module.call(methodName, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
		if arg7 != null:
			return module.call(methodName, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
		if arg6 != null:
			return module.call(methodName, arg1, arg2, arg3, arg4, arg5, arg6)
		if arg5 != null:
			return module.call(methodName, arg1, arg2, arg3, arg4, arg5)
		if arg4 != null:
			return module.call(methodName, arg1, arg2, arg3, arg4)
		if arg3 != null:
			return module.call(methodName, arg1, arg2, arg3)
		if arg2 != null:
			return module.call(methodName, arg1, arg2)
		if arg1 != null:
			return module.call(methodName, arg1)
		return module.call(methodName)
	return null

static func internalCallModulesHandlers(methodName, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null, arg6 = null, arg7 = null, arg8 = null):
	if DebugMode:
		Log.print("[FoxLib] Calling handler event: " + methodName)
	# Debug info for ya.
	var debug_index = FLMHDebug.push_debug_lazy("FoxLib/Modules/FoxLib/Internal/FoxLibEventUtil.gd:" + methodName)
	for module in GlobalRegistry.getModules().values():
		internalCallModuleHandler(module, methodName, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
	FLMHDebug.pop_debug_lazy(debug_index)

static func internalCallPlayerModulesHandlers(methodName, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null, arg6 = null, arg7 = null, arg8 = null):
	if arg1 != null && arg1.isPlayer():
		internalCallModulesHandlers(methodName, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
	else:
		if DebugMode:
			Log.print("[FoxLib] Skipping player handler call on non player: " + methodName)

