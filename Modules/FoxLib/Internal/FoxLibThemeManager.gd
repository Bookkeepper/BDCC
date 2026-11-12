const FoxThemeHelper = preload("res://FoxLib/UI/FoxThemeHelper.gd")
const FoxUIManager = preload("res://FoxLib/FoxUIManager.gd")
const Globals = preload("res://FoxLib/Globals.gd")
#nodebug
const ModThemesFolder = "res://FoxLib/Themes"
const UserThemesFolder = "user://foxlib/themes"

const THEME_DEFAULT_SECONDARY_BACKGROUND_STR = "0.207843,0.133333,0.364706,1" #35225d
const THEME_DEFAULT_OPTIONS_HEADER_BACKGROUND_STR = "0.211765,0.184314,0.372549,1" #362f5f
const THEME_DEFAULT_ADULT_ADVISORY_BACKGROUND_STR = "0.364706,0.133333,0.329412,1" #5d2254
const THEME_DEFAULT_INVENTORY_BACKGROUND_STR = "0.105882,0.058823,0.258824,1" #1b0f42
const THEME_DEFAULT_INVENTORY_ENTRY_BACKGROUND_STR = "0.290196,0.364706,0.623529,1" #4a5d9f
const THEME_DEFAULT_INVENTORY_ENTRY_ACTIVE_BACKGROUND_STR = "0.054902,0,0.301961,1" #0e004d
const THEME_DEFAULT_INVENTORY_ENTRY_INACTIVE_BACKGROUND_STR = "0.031373,0,0.172549,1" #08002c
const THEME_DEFAULT_PORTAIT_BACKGROUND_COLOR_STR = "0.247059,0.243137,0.490196,1" #3f3e7d
# Unsupported theming
const THEME_DEFAULT_BLOCK_CATCHER_BACKGROUND_STR = "0.086274,0.086274,0.086274,1" #161616

class FoxLibThemeHolder:
	var activeTheme = "default"
	var lastUsedTheme = "default"
	var themeInfos = {}
	var defaultTheme = {}

static func initListOptionWithThemes(foxLib):
	var holder = Globals.of(FoxLibThemeHolder)
	var themeList = [["default", "Default"]]
	var usedThemeIds = ["", "null"]
	initThemesFromSource(ModThemesFolder, holder, themeList, usedThemeIds)
	initThemesFromSource(UserThemesFolder, holder, themeList, usedThemeIds)
	foxLib.addListOption("currentTheme", "Current Theme", themeList,
		"Current FoxLib Theme to use for the game.").bindToField(holder, "activeTheme").enableMainMenuOnly()

static func initThemesFromSource(themeSource, holder, themeList, usedThemeIds):
	# Get all themes from folder.
	var dir = Directory.new()
	if dir.open(themeSource) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".json"):
				var defaultName = file_name.trim_suffix(".json")
				var themeId = defaultName.to_lower()
				if themeId in usedThemeIds:
					Log.print("[FoxLib] Skipping theme " + file_name + " as it is a duplicate theme")
					continue
				var themeData = null
				if themeId == "default":
					themeData = holder.defaultTheme
				else:
					themeData = readModFileAsJson(themeSource + "/" + file_name)
				if themeData == null:
					Log.print("[FoxLib] Skipping theme " + file_name + " as it is not a valid json")
					continue
				# Fill theme defaults
				fillThemeVarString(themeData, "name", defaultName)
				fillThemeVarInt(themeData, "sidePanelsCornersSize", 16)
				fillThemeVarInt(themeData, "adultAdvisoryCornersSize", 32)
				fillThemeVarColor(themeData, "primaryBackground", "#3f3e7d")
				fillThemeVarColor(themeData, "secondaryBackground", "#35225d")
				fillThemeVarColor(themeData, "optionsHeaderBackground", "#362f5f")
				fillThemeVarColor(themeData, "adultAdvisoryBackground", "#5d2254")
				fillThemeVarColor(themeData, "inventoryBackground", "#1b0f42")
				fillThemeVarColor(themeData, "inventoryEntryBackground", "#4a5d9f")
				fillThemeVarColor(themeData, "inventoryEntryActiveBackground", "#0e004d")
				fillThemeVarColor(themeData, "inventoryEntryInactiveBackground", "#08002c")
				fillThemeVarColor(themeData, "portaitBackground", "#3f3e7d")
				# Add theme to list
				themeData["id"] = themeId
				usedThemeIds.append(themeId)
				holder.themeInfos[themeId] = themeData
				if themeId != "default":
					themeList.append([themeId, themeData["name"]])
			file_name = dir.get_next()
	else:
		dir.make_dir_recursive(themeSource)

static func readModFileAsJson(path):
	var file = File.new()
	if not file.file_exists(path):
		return null
	if file.open(path, File.READ) != OK:
		return null
	var content = file.get_as_text()
	file.close()
	if content == null:
		return null
	var jsonResult = JSON.parse(content)
	if jsonResult.error != OK:
		return null
	if not jsonResult.result is Dictionary:
		return null
	return jsonResult.result

static func fillThemeVarString(theme, key, default):
	if (not theme.has(key)) or (typeof(theme[key]) != TYPE_STRING) or (theme[key].length() == 0):
		theme[key] = default

static func fillThemeVarInt(theme, key, default):
	if theme.has(key) and typeof(theme[key]) == TYPE_REAL:
		theme[key] = int(theme[key])
	if (not theme.has(key)) or (typeof(theme[key]) != TYPE_INT):
		theme[key] = default

static func fillThemeVarColor(theme, key, default):
	if theme.has(key) and typeof(theme[key]) == TYPE_STRING and theme[key].length() != 0:
		theme[key] = Color(theme[key])
	if (not theme.has(key)) or (typeof(theme[key]) != TYPE_COLOR):
		if typeof(default) == TYPE_STRING:
			theme[key] = Color(default)
		else:
			theme[key] = default

static func applyThemeLoad(scene):
	if scene == null or not is_instance_valid(scene):
		return
	var holder = Globals.of(FoxLibThemeHolder)
	var theme = holder.themeInfos[holder.activeTheme]
	holder.lastUsedTheme = holder.activeTheme
	if theme == null or holder.activeTheme == "default":
		VisualServer.set_default_clear_color(holder.themeInfos["default"]["primaryBackground"])
		return
	VisualServer.set_default_clear_color(theme["primaryBackground"])
	applyThemeRecursive(scene)
	var tree = FoxUIManager.getSceneTree()
	yield(tree, "idle_frame")
	yield(tree, "idle_frame")
	applyThemeRecursive(scene)

static func applyTheme(rootNode):
	var holder = Globals.of(FoxLibThemeHolder)
	var theme = holder.themeInfos[holder.activeTheme]
	if theme == null or holder.activeTheme == "default":
		return
	applyThemeImpl(rootNode, theme)

static func applyThemeRecursive(rootNode):
	var holder = Globals.of(FoxLibThemeHolder)
	var theme = holder.themeInfos[holder.activeTheme]
	if theme == null or holder.activeTheme == "default":
		return
	applyThemeImplRecursive(rootNode, theme)

static func applyThemeImplRecursive(rootNode, theme):
	if theme == null or theme.id == "default" or rootNode == null or not is_instance_valid(rootNode):
		return
	# Log.print("TEST: " + str(rootNode))
	for childNode in rootNode.get_children():
		applyThemeImplRecursive(childNode, theme)
	applyThemeImpl(rootNode, theme)

static func applyThemeImpl(rootNode, theme):
	if theme == null or theme.id == "default" or rootNode == null or not is_instance_valid(rootNode):
		return
	if rootNode is Panel or rootNode is PanelContainer:
		var panelStyle = rootNode.get_stylebox("panel")
		if panelStyle is StyleBoxFlat:
			applyPanelStyleTheme(rootNode, panelStyle, theme)
	elif rootNode is ColorRect:
		var new_color = transformThemeColor(rootNode, rootNode.color, theme)
		if new_color != null:
			rootNode.color = new_color

static func applyPanelStyleTheme(panel, panelStyle, theme):
	var bg_color_str = FoxThemeHelper.get_og_bg_color(panelStyle)
	var border_color_str = FoxThemeHelper.get_og_border_color(panelStyle)
	if bg_color_str == THEME_DEFAULT_SECONDARY_BACKGROUND_STR:
		panelStyle.set_bg_color(theme["secondaryBackground"])
		var corner_tl = panelStyle.get_corner_radius(CORNER_TOP_LEFT)
		var corner_tr = panelStyle.get_corner_radius(CORNER_TOP_RIGHT)
		var corner_br = panelStyle.get_corner_radius(CORNER_BOTTOM_RIGHT)
		var corner_bl = panelStyle.get_corner_radius(CORNER_BOTTOM_LEFT)
		if corner_tl == 0 and corner_bl == 0 and corner_tr == 16 and corner_br == 16:
			var corner_new_value = theme["sidePanelsCornersSize"]
			panelStyle.set_corner_radius(CORNER_TOP_RIGHT, corner_new_value)
			panelStyle.set_corner_radius(CORNER_BOTTOM_RIGHT, corner_new_value)
		if corner_tl == 16 and corner_bl == 16 and corner_tr == 0 and corner_br == 0:
			var corner_new_value = theme["sidePanelsCornersSize"]
			panelStyle.set_corner_radius(CORNER_TOP_LEFT, corner_new_value)
			panelStyle.set_corner_radius(CORNER_BOTTOM_LEFT, corner_new_value)
	elif bg_color_str == THEME_DEFAULT_ADULT_ADVISORY_BACKGROUND_STR:
		panelStyle.set_bg_color(theme["adultAdvisoryBackground"])
		if bg_color_str == border_color_str:
			panelStyle.set_border_color(theme["adultAdvisoryBackground"])
		var corner_tl = panelStyle.get_corner_radius(CORNER_TOP_LEFT)
		var corner_tr = panelStyle.get_corner_radius(CORNER_TOP_RIGHT)
		var corner_br = panelStyle.get_corner_radius(CORNER_BOTTOM_RIGHT)
		var corner_bl = panelStyle.get_corner_radius(CORNER_BOTTOM_LEFT)
		if corner_tl == 32 and corner_bl == 32 and corner_tr == 32 and corner_br == 32:
			var corner_new_value = theme["adultAdvisoryCornersSize"]
			panelStyle.set_corner_radius(CORNER_TOP_LEFT, corner_new_value)
			panelStyle.set_corner_radius(CORNER_TOP_RIGHT, corner_new_value)
			panelStyle.set_corner_radius(CORNER_BOTTOM_RIGHT, corner_new_value)
			panelStyle.set_corner_radius(CORNER_BOTTOM_LEFT, corner_new_value)
	else:
		var bg_color = transformThemeColor(panel, FoxThemeHelper.get_og_bg_color(panelStyle), theme)
		if bg_color != null:
			panelStyle.set_bg_color(bg_color)
			if bg_color_str == border_color_str:
				panelStyle.set_border_color(bg_color)

static func transformThemeColor(debug_obj, color, theme):
	if color == null:
		return null
	var elementStr = str(debug_obj)
	if elementStr.begins_with("CrotchBlock:[PanelContainer:"):
		return null # Skip crotch blocks when theming
	var color_str = str(color)
	if color_str == THEME_DEFAULT_SECONDARY_BACKGROUND_STR:
		return theme["secondaryBackground"]
	elif color_str == THEME_DEFAULT_OPTIONS_HEADER_BACKGROUND_STR:
		return theme["optionsHeaderBackground"]
	elif color_str == THEME_DEFAULT_ADULT_ADVISORY_BACKGROUND_STR:
		return theme["adultAdvisoryBackground"]
	elif color_str == THEME_DEFAULT_INVENTORY_BACKGROUND_STR:
		return theme["inventoryBackground"]
	elif color_str == THEME_DEFAULT_INVENTORY_ENTRY_BACKGROUND_STR:
		return theme["inventoryEntryBackground"]
	elif color_str == THEME_DEFAULT_INVENTORY_ENTRY_ACTIVE_BACKGROUND_STR:
		return theme["inventoryEntryActiveBackground"]
	elif color_str == THEME_DEFAULT_INVENTORY_ENTRY_INACTIVE_BACKGROUND_STR:
		return theme["inventoryEntryInactiveBackground"]
	elif color_str == THEME_DEFAULT_PORTAIT_BACKGROUND_COLOR_STR:
		return theme["portaitBackground"]
	elif color_str == THEME_DEFAULT_BLOCK_CATCHER_BACKGROUND_STR:
		return null # Theming of block catcher is not supported yet.
	else:
		if not color_str.begins_with("1,1,1,") and not color_str.begins_with("0,0,0,"):
			Log.print("[FoxLib] Missing themable color for: " + elementStr + " (Color: " + color_str + ")")
		return null

static func needSceneReload():
	var holder = Globals.of(FoxLibThemeHolder)
	return holder.lastUsedTheme != holder.activeTheme

static func reloadMainMenuScene():
	var holder = Globals.of(FoxLibThemeHolder)
	var sceneTree = FoxUIManager.getSceneTree()
	if holder.lastUsedTheme != "default":
		sceneTree.change_scene("res://Modules/FoxLib/UI/FoxLibThemeReload.tres")
		yield(sceneTree, "idle_frame")
		yield(sceneTree, "idle_frame")
	sceneTree.change_scene("res://UI/MainMenu/MainMenu.tscn")

static func getPrimaryBackgroundColor():
	var holder = Globals.of(FoxLibThemeHolder)
	if holder.defaultTheme.empty():
		return Color("#3f3e7d")
	var theme = holder.themeInfos[holder.activeTheme]
	if theme == null:
		theme = holder.defaultTheme
	return theme["primaryBackground"]
