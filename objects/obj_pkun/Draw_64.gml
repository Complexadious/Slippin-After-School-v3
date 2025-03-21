/// @description Insert description here
// You can write your code in this editor
if global.shaderOn
{
    shader_set(shd_bloom)
    shader_set_uniform_f(shader_get_uniform(shd_bloom, "intensity"), 0.3)
    draw_surface(application_surface, 0, 0)
    shader_reset()
}
