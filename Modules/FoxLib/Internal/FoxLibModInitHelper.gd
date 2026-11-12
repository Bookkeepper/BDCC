const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")
const FoxModuleAPI = preload("res://FoxLib/FoxModuleAPI.gd")

static func callOnFoxLibModInit():
	pass

static func callOnFoxLibModInitReal():
	for module in GlobalRegistry.getModules().values():
		if module == null or not module.has_method("onFoxLibModInit"):
			continue
		var moduleFoxModuleAPI = null
		if module.has_method("getFoxModuleAPI"):
			moduleFoxModuleAPI = module.getFoxModuleAPI()
		if moduleFoxModuleAPI == null:
			moduleFoxModuleAPI = FoxModuleAPI.new()
			moduleFoxModuleAPI.moduleId = module.id
			moduleFoxModuleAPI.moduleCache = weakref(module)
		module.call("onFoxLibModInit", moduleFoxModuleAPI)
		if FoxUIManager.hasFatalError():
			break

