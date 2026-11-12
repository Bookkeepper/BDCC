#class_name FoxThemeHelper

const FoxLibOriginalBackground = "FLOBG"
const FoxLibOriginalBorder = "FLOB"

static func get_og_bg_color(themableNode):
	if themableNode.has_meta(FoxLibOriginalBackground):
		return themableNode.get_meta(FoxLibOriginalBackground)
	var bg_color = str(themableNode.get_bg_color())
	themableNode.set_meta(FoxLibOriginalBackground, bg_color)
	return bg_color

static func get_og_border_color(themableNode):
	if themableNode.has_meta(FoxLibOriginalBorder):
		return themableNode.get_meta(FoxLibOriginalBorder)
	var border_color = str(themableNode.get_border_color())
	themableNode.set_meta(FoxLibOriginalBorder, border_color)
	return border_color
