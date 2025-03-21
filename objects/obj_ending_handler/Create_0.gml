/// @description Insert description here
// You can write your code in this editor
step = 1
next = 0
ending = 0
out = ""
dialog_add_line("", " ")
dialog_add_act(new Act("shota", -4, 10200, 560))
dialog_add_act(new Act("shota", 12, -1, 1300))
dialog_add_line(getText("hanako"), "...")
dialog_add_act(new Act("hanako", -4, 8490, 560))
dialog_add_act(new Act("hanako", 0, 1, 0))
dialog_set_view("hanako")
dialog_give_choice(getText("hanako"), getText("ending_0_1"), "LEAVE", "STAY")
global.dialog_mode = 1
global.dialog_do_fskip = 0
global.dialog_show_box = 1
obj_dialog.hide_fl = 1
