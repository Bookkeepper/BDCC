#class_name FoxFonts
#public_api

const Globals = preload("res://FoxLib/Globals.gd")

const MainGameFonts = [
	"res://UI/FontResources/GlobalDefaultFont.tres",
	"res://UI/FontResources/Normal/NormalFont.tres",
]
const AllGameFonts = [
	"res://UI/FontResources/GlobalDefaultFont.tres",
	"res://UI/FontResources/Normal/NormalFont.tres",
	"res://UI/FontResources/Normal/BoldItalicsFont.tres",
	"res://UI/FontResources/Normal/ItalicsFont.tres",
	"res://UI/FontResources/Normal/BoldFont.tres",
	"res://Fonts/normalconsolefont.tres",
	"res://Fonts/smallconsolefont.tres",
]
const reservedTags = {
	"say": true,
	"sayShowName": true,
	"sayMale": true,
	"sayFemale": true,
	"sayAndro": true,
	"sayOther": true,
}

class FoxFontsHolder:
	var fontTagMap = {}
	var reservedTags = {
		"say": true,
		"sayShowName": true,
		"sayMale": true,
		"sayFemale": true,
		"sayAndro": true,
		"sayOther": true,
	}


# RichTextBox may ignore fallback fonts.
static func internalAppendFallbackFont(resourcePath, loadedFallbackFont):
	if not ResourceLoader.exists(resourcePath):
		return
	var loadedFont = ResourceLoader.load(resourcePath)
	loadedFont.add_fallback(loadedFallbackFont)
	# ResourceLoader.save(resourcePath, loadedFont)

# Doesn't apply on say box panel by default sadly, use tagName argument for use in say box.
static func addFallbackFont(fallbackFont, applyOnAllFonts=false, tagName=null):
	if not ResourceLoader.exists(fallbackFont):
		return
	var holder = Globals.of(FoxFontsHolder)
	if tagName != null and holder.reservedTags.get(tagName) == true:
		tagName = null
	var loadedFallbackFont = load(fallbackFont)
	if loadedFallbackFont == null:
		return
	var applyOn = MainGameFonts
	if applyOnAllFonts:
		applyOn = AllGameFonts
	for gameFontPath in applyOn:
		internalAppendFallbackFont(gameFontPath, loadedFallbackFont)
	if tagName != null:
		var fallbackFontRes = fallbackFont + ".tres"
		if ResourceLoader.exists(fallbackFontRes):
			holder.fontTagMap[tagName] = fallbackFontRes
			holder.reservedTags[tagName] = true

static func getFontPathFromTag(tagName=null):
	if tagName == null:
		return null
	var holder = Globals.of(FoxFontsHolder)
	return holder.fontTagMap.get(tagName)

static func getReservedTags():
	var holder = Globals.of(FoxFontsHolder)
	return holder.reservedTags
