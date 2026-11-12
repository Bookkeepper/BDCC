extends SayParser

# Should this be inspiration for Mixin like API?
const FoxFonts = preload("res://FoxLib/FoxFonts.gd")

func combineTags(tags: Array):
	var result = []
	var pos = 0
	var processThese = FoxFonts.getReservedTags()
	
	while pos < tags.size():
		var tag = tags[pos]
		if(tag[0] == TagType.Text):
			result.append(tag)
			pos += 1
			
		elif(tag[0] == TagType.CloseTag):
			result.append([TagType.Text, "[/"+tag[1]+"]"])
			pos += 1
		
		elif(tag[0] == TagType.Tag):
			if(processThese.has(tag[1])):
				var tagCommand = tag[1]
				var tagArg = tag[2]
				var tagText = ""
				pos += 1
				while pos < tags.size():
					if(tags[pos][0] == TagType.Text):
						tagText += tags[pos][1]
						pos += 1
					elif(tags[pos][0] == TagType.Tag):
						if(tags[pos][2] == ""):
							tagText += "["+tags[pos][1]+"]"
						else:
							tagText += "["+tags[pos][1]+"="+tags[pos][2]+"]"
						pos += 1
					elif(tags[pos][0] == TagType.CloseTag):
						if(tags[pos][1] == tagCommand || tags[pos][1] == ""):
							result.append([TagType.Tag, tagCommand, tagArg, tagText])
							pos += 1
							break
						else:
							tagText += "[/"+tags[pos][1]+"]"
							pos += 1
					else:
						pos += 1
			else:
				if(tag[2] == ""):
					result.append([TagType.Text, "["+tag[1]+"]"])
				else:
					result.append([TagType.Text, "["+tag[1]+"="+tag[2]+"]"])
				pos += 1
		else:
			pos += 1
	return result

func processTag(tag, arg, text, overrides: Dictionary = {}):
	var fontPath = FoxFonts.getFontPathFromTag(tag)
	if fontPath != null:
		return "[font=" + fontPath.trim_prefix("res://") + "]" + text + "[/font]"
	return .processTag(tag, arg, text, overrides)
