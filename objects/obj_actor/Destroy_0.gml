show_debug_message("Actor destroyed in room: " + string(room));

if (role == "item") {
    play_se(se_pickup, 1);
}
else if (role == "custom" && make_pkun_hide) {
    with (obj_pkun) {
        hiding = 0;
        if (intrTarget != -4) {
            intrTarget.shake = other.shake_amount_out;
            if (other.hide_se_out != -4) {
                play_se(other.hide_se_out, 1);
            }
            if (intrTarget.object_index == obj_intr_hidebox) {
                with (intrTarget)
                    instance_destroy();
                intrTarget = -4;
            }
        }
    }
}
else if (role == "redmask") {
    with (obj_pkun) {
        hiding = 0;
        intrTarget.shake = 20;
        play_se(intrTarget.se_out, 1);
        if (intrTarget.object_index == obj_intr_hidebox) {
            with (intrTarget)
                instance_destroy();
            intrTarget = -4;
        }
    }
}
else if (role == "hanako") {
    global.trans_alp = 1;
    global.trans_col = 0;
}