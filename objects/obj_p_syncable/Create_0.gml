/// @description Insert description here
// You can write your code in this editor
entity_uuid = generate_uuid4_string()

excluded_vars = [
	"x",
	"y",
	"dir",
	"id",
	"sprite_index",
	"excluded_vars",
	"inst_vars",
	"inst_vals",
	"diff_vars_and_vals",
	"allowed_datatypes"
]

inst_vars = []
inst_vals = []
diff_vars_and_vals = []
allowed_datatypes = ["number", "string", "array", "bool"]