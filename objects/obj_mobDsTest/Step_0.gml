/// @description Insert description here
// You can write your code in this editor
if ((soundDelay > 0))
    soundDelay--
else
{
    soundDelay = 40
    mob_play_ds(48)
}
if ((len > 0))
{
    len -= 5
    x += (dir * 5)
}
else
{
    dir *= -1
    len = 1000
}
