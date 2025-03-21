function item_add(argument0) //gml_Script_item_add
{
    if ((global.itemSlot[0] == 0))
    {
        global.itemSlot[0] = argument0
        obj_sys.itemScale[0] = 0
    }
    else if ((global.itemSlot[1] == 0))
    {
        global.itemSlot[1] = argument0
        obj_sys.itemScale[1] = 0
    }
    else
    {
        item_drop(global.itemSlot[0])
        global.itemSlot[0] = argument0
        obj_sys.itemScale[0] = 0
    }
    obj_sys.itemDescI = argument0
    obj_sys.itemDescA = 120
}

function item_drop(argument0) //gml_Script_item_drop
{
    var drop = instance_create_depth(x, y, 0, obj_intr_item)
    drop.itemid = argument0
}

function item_swap() //gml_Script_item_swap
{
    var temp = 0
    if ((global.itemSlot[0] != 0) && (global.itemSlot[1] != 0))
    {
        temp = global.itemSlot[0]
        global.itemSlot[0] = global.itemSlot[1]
        global.itemSlot[1] = temp
        global.itemSwap = 100
        obj_sys.itemDescI = global.itemSlot[0]
        obj_sys.itemDescA = 120
    }
}

function item_use() //gml_Script_item_use
{
    var use = 1
    if ((global.itemSlot[0] == 1))
    {
        play_se(se_drink, 1)
        obj_pkun.stmRegen = 100
    }
    else if ((global.itemSlot[0] == 2))
    {
        global.flashPow = 100
        play_se(se_batterychange, 1)
    }
    else if ((global.itemSlot[0] == 3))
    {
        if ((global.lifeCur < global.lifeMax))
        {
            play_se(se_drink, 1)
            global.lifeCur++
        }
        else
            use = 0
    }
    else if ((global.itemSlot[0] == 4))
    {
        global.trans_col = 16777215
        global.trans_alp = 1
        timeStop = 300
        play_se(se_tiktok, 1)
    }
    else if ((global.itemSlot[0] == 5))
    {
        intrTarget = instance_create_depth(x, y, 0, obj_intr_hidebox)
        play_se(intrTarget.se_in, 1)
        intrTarget.shake = 20
        x = intrTarget.x
        hiding = 1
        with (obj_p_mob)
        {
            if ((!target_is_near()) || (distance_to_object(obj_pkun) > 700))
                lostTarget = 1
        }
    }
    else if ((global.itemSlot[0] == 6))
    {
        play_se(se_seal, 1)
        if ((distance_to_object(obj_jianshi) <= 500))
            obj_jianshi.sealed = 1
        else
            use = 0
    }
    if use
    {
        global.itemSlot[0] = 0
        if ((global.itemSlot[1] != 0))
        {
            global.itemSlot[0] = global.itemSlot[1]
            global.itemSlot[1] = 0
        }
    }
}

function item_spawn_at(argument0, argument1) 
{
//    show_debug_message("Spawning item " + string(argument1) + " at spawner position: " + string(argument0.x) + "," + string(argument0.y));
    with (argument0) {
        item_drop(argument1)
        instance_destroy()
    }
}

