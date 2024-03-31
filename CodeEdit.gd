extends CodeEdit

var colors = {
	"keyword": to_color("#957FB8"),
	"special_keyword": to_color("#FF5D62"),
	"builtin": to_color("#7FB4CA"),
	"type": to_color("#7AA89F"),
	"punctuation": to_color("#9CABCA"),
	"function": to_color("#7E9CD8"),
	"member": to_color("#E6C384"),
	"error": to_color("#E82424"),
	"number": to_color("#D27E99"),
}
var keywords = {
	"func": colors["keyword"],
	"return": colors["special_keyword"],
	"if": colors["keyword"],
	"else": colors["keyword"],
	"package": colors["keyword"],
	"var": colors["keyword"],
	"const": colors["keyword"],
	"switch": colors["keyword"],
	"continue": colors["keyword"],
	"break": colors["keyword"],
	"for": colors["keyword"],
	"type": colors["keyword"],
	"struct": colors["keyword"],
	"default": colors["keyword"],
	"case": colors["keyword"],
	"print": colors["builtin"],
	"println": colors["builtin"],
	"append": colors["builtin"],
	"cap": colors["builtin"],
	"len": colors["builtin"],
	"panic": colors["builtin"],
	"int": colors["type"],
	"int8": colors["type"],
	"int16": colors["type"],
	"int32": colors["type"],
	"int64": colors["type"],
	"uint": colors["type"],
	"uint8": colors["type"],
	"uint16": colors["type"],
	"uint32": colors["type"],
	"uint64": colors["type"],
	"complex64": colors["type"],
	"complex128": colors["type"],
	"float32": colors["type"],
	"float64": colors["type"],
	"string": colors["type"],
	"bool": colors["type"],
	"error": colors["type"],
}

var regions = [{
	"start": '"',
	"end": '"',
	"color": to_color("#98BB6C"),
	"inline": false
},{
	"start": '//',
	"end": '',
	"color": to_color("#727169"),
	"inline": true
},{
	"start": '/*',
	"end": '*/',
	"color": to_color("#727169"),
	"inline": false
}]

func to_color(color: String) -> Color:
	return Color.from_string(color, "#ff0000");

func _ready():
	var code_highlighter: CodeHighlighter = CodeHighlighter.new()
	code_highlighter.number_color = colors.number
	code_highlighter.function_color = colors.function
	syntax_highlighter = code_highlighter
	code_highlighter.symbol_color = colors.punctuation
	for keyword in keywords:
		code_highlighter.add_keyword_color(keyword,keywords[keyword])
	for region in regions:
		code_highlighter.add_color_region(region.start,region.end, region.color, region.inline)
