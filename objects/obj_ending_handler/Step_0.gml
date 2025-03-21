/// @description Insert description here
// You can write your code in this editor
if (global.dialog_mode && (global.dialog_choice_out != ""))
{
    out = global.dialog_choice_out
    global.dialog_choice_out = ""
    if ((step == 1))
    {
        if ((out == "LEAVE"))
            ending = 1
        else if ((out == "STAY"))
            ending = 2
        dialog_give_choice(getText("hanako"), getText("ending_0_2"), "YES", "NO")
        step = 2
    }
    else if ((step == 2))
    {
        if ((out == "YES"))
        {
            step = 3
            if ((ending == 1))
            {
                dialog_add_line(getText("hanako"), getText("ending_1_1"))
                dialog_add_act(new Act("hanako", -1, 0, 0))
                dialog_add_line("", " ")
                dialog_add_act(new Act("shota", 12, -1, 650))
                dialog_add_line("", "...")
                dialog_set_trans(1)
                dialog_add_line(getText("shotakun"), getText("ending_1_2"))
                dialog_add_line(getText("shotakun"), getText("ending_1_3"))
                dialog_add_line(getText("shotakun"), getText("ending_1_4"))
                dialog_add_line(getText("shotakun"), getText("ending_1_5"))
                dialog_add_line(getText("shotakun"), getText("ending_1_6"))
                dialog_add_line("", getText("ending_1_7"))
                global.end_leave = 1
            }
            else
            {
                dialog_add_line(getText("hanako"), getText("ending_2_1"))
                dialog_add_act(new Act("shota", 4, -1, 350))
                dialog_add_line("", "")
                dialog_hscene(12, 0)
                dialog_add_line("", "")
                dialog_hscene(12, 1)
                dialog_add_line("", "")
                dialog_hscene(12, 1)
                dialog_add_line("", "")
                dialog_hscene(12, 1)
                dialog_add_line("", "")
                dialog_hscene(12, 1)
                dialog_add_line("", "")
                dialog_hscene(12, 1)
                dialog_add_line("", "...")
                dialog_set_trans(1)
                dialog_add_line("", getText("ending_2_2"))
                dialog_add_line("", getText("ending_2_3"))
                dialog_add_line("", getText("ending_2_4"))
                dialog_add_line("", getText("ending_2_5"))
                dialog_add_line("", getText("ending_2_6"))
                dialog_add_line("", getText("ending_2_7"))
                global.end_stay = 1
            }
            if global.gallery_lock
            {
                dialog_add_line("", getText("ending_0_3"))
                global.gallery_lock = 0
            }
            var fn = (global.game_dir + "Stage.sav")
            if file_exists(fn)
                file_delete(fn)
            sys_save_player()
            global.trans_goto = 1
            instance_destroy()
        }
        else if ((out == "NO"))
        {
            step = 1
            dialog_give_choice(getText("hanako"), getText("ending_0_1"), "LEAVE", "STAY")
        }
    }
    if next
    {
        global.dialog_num_curr++
        next = 0
    }
}
