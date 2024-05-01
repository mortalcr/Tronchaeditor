extends CodeEdit

var changed := false

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
	"float": colors["type"],
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

const FUNCTION = preload("res://function.png")
const VARIABLE = preload("res://variable.png")

func code_completion():
	code_completion_enabled = true
	text_changed.connect(func():
		request_code_completion()
	)
	code_completion_requested.connect(func():
		var text_for_completion = get_text_for_code_completion()
		var completion_index = text_for_completion.find(char(0xFFFF))
		var last_space = text_for_completion.rfind(" ", completion_index)
		var word = ""
		if last_space > -1:
			word = text_for_completion.substr(last_space + 1, completion_index - last_space - 1)
			var last_newline = word.rfind("\n")
			if last_newline > -1:
				word = word.substr(last_newline + 1)
		else:
			word = text_for_completion.substr(0, completion_index)
			var last_newline = word.rfind("\n")
			if last_newline > -1:
				word = word.substr(last_newline + 1)
		word = word.strip_edges()
		var completions = {
			"func": {"kind": CodeEdit.KIND_FUNCTION, "insert": "func FuncName() {};", "image": FUNCTION},
			"return": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "return", "image": VARIABLE},
			"if": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "if {};", "image": VARIABLE},
			"else": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "else {};", "image": VARIABLE},
			"package": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "package", "image": VARIABLE},
			"var": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "var", "image": VARIABLE},
			"const": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "const", "image": VARIABLE},
			"switch": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "switch {};", "image": VARIABLE},
			"continue": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "continue", "image": VARIABLE},
			"break": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "break", "image": VARIABLE},
			"for": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "for ; ; {};", "image": VARIABLE},
			"type": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "type Name {};", "image": VARIABLE},
			"struct": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "struct {}", "image": VARIABLE},
			"default": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "default", "image": VARIABLE},
			"case": {"kind": CodeEdit.KIND_PLAIN_TEXT, "insert": "case", "image": VARIABLE},
			"print": {"kind": CodeEdit.KIND_FUNCTION, "insert": "print();", "image": FUNCTION},
			"println": {"kind": CodeEdit.KIND_FUNCTION, "insert": "println();", "image": FUNCTION},
			"append": {"kind": CodeEdit.KIND_FUNCTION, "insert": "append();", "image": FUNCTION},
			"cap": {"kind": CodeEdit.KIND_FUNCTION, "insert": "cap();", "image": FUNCTION},
			"len": {"kind": CodeEdit.KIND_FUNCTION, "insert": "len();", "image": FUNCTION},
			"panic": {"kind": CodeEdit.KIND_FUNCTION, "insert": "panic();", "image": FUNCTION},
			"int": {"kind": CodeEdit.KIND_CLASS, "insert": "int", "image": VARIABLE},
			"string": {"kind": CodeEdit.KIND_CLASS, "insert": "string", "image": VARIABLE},
			"bool": {"kind": CodeEdit.KIND_CLASS, "insert": "bool", "image": VARIABLE},
			"error": {"kind": CodeEdit.KIND_CLASS, "insert": "error", "image": VARIABLE},
		}
		
		for words in completions:
			if word.begins_with(words[0]) and word.is_subsequence_of(words): 
				if words in completions:
					add_code_completion_option(completions[words]["kind"], words, completions[words]["insert"],to_color("#dcd7ba"), completions[words]["image"])
		update_code_completion_options(false)
	)

func _ready():
	code_completion()
	var code_highlighter: CodeHighlighter = CodeHighlighter.new()
	code_highlighter.number_color = colors.number
	code_highlighter.function_color = colors.function
	code_highlighter.member_variable_color = colors.member
	syntax_highlighter = code_highlighter
	code_highlighter.symbol_color = colors.punctuation
	for keyword in keywords:
		code_highlighter.add_keyword_color(keyword,keywords[keyword])
	for region in regions:
		code_highlighter.add_color_region(region.start, region.end, region.color, region.inline)
