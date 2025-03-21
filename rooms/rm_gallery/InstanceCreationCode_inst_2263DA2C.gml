var arr = [10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12]
for (var i = 0; i < array_length(arr); i++)
{
    var hf = instance_create_depth((x + 500 * (i + 1)), y, -1, obj_h_figure)
    hf.mob_id = arr[i]
}
