pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- ld44
-- by niarkou and sam

#include escarlib/p8u.lua
--#include escarlib/logo.lua
#include escarlib/btn.lua
#include escarlib/draw.lua
--#include escarlib/print.lua
#include escarlib/random.lua
--#include escarlib/fonts/double_homicide.lua
#include escarlib/fonts/lilabit.lua
#include escarlib/font.lua
--load_font(double_homicide,14)
load_font(lilabit,14)

#include map.lua
#include collisions.lua

mode = {
    test = {},
    menu = {},
    play = {},
}

#include mode_test.lua
#include mode_menu.lua
#include mode_play.lua

g_btn_confirm = 4
g_btn_back = 5
g_btn_jump = 4
g_btn_call = 5

-- menu navigation sfx
g_sfx_navigate = 38
g_sfx_confirm = 39

-- gameplay sfx
g_sfx_death = 37
g_sfx_happy = 36
g_sfx_saved = 32
g_sfx_jump = 35
g_sfx_ladder = 34
g_sfx_footstep = 33

-- sprites
g_spr_player = 18
g_spr_follower = 20
g_spr_exit = 26
g_spr_portal = 38
g_spr_spikes = 36
g_spr_happy = 37
g_spr_count = 48

g_fill_amount = 2
g_solid_time = 80
g_win_frames = 40
g_lose_frames = 80

-- game
game = {}

function new_entity(x, y, dir)
    return {
        x = x, y = y,
        dir = dir,
        anim = rnd(128),
        walk = rnd(128),
        climbspd = 0.5,
        grounded = false,
        ladder = false,
        jumped = false,
        jump = 0, fall = 0,
        cooldown = 0,
    }
end

function new_player(x, y, dir)
    local e = new_entity(x, y, dir)
    e.can_jump = true
    e.spd = 1.0
    e.spr = g_spr_player
    e.pcolors = { 5, 6 }
    e.call = 1
    return e
end

--
-- standard pico-8 workflow
--

function _init()
    poke(0x5f34, 1)
    cartdata("ld44")
    state = "menu"
end

function _update60()
    if state != prev_state then
        mode[state].start()
        prev_state = state
    end
    mode[state].update()
end

function _draw()
    mode[prev_state].draw()
end

--
-- moving
--

function jump()
    if btn(2) or btn(g_btn_jump) then
        return true end
end

function move_x(e, dx)
    if not wall_area(e.x + dx, e.y, 4, 4) then
        e.x += dx
    end
end

function move_y(e, dy)
    while wall_area(e.x, e.y + dy, 4, 4) do
        dy *= 7 / 8
        if abs(dy) < 0.00625 then return end
    end
    e.y += dy
    -- wrap around when falling
    if e.y > (world.y + world.h) * 8 + 16 then
        e.y = world.y * 8
    end
end

function update_player()
    if world.lose then
        return -- do nothing, we died!
    end
    if not btn(g_btn_call) then
        selectcolor = 1
        update_entity(game.player, btn(0), btn(1), jump(), btn(3))
        selectcolorscreen = false
    elseif btn(g_btn_call) then
        update_entity(game.player)
        selectcolorscreen = true
        if btnp(0) and selectcolor > 1 then
            sfx(g_sfx_navigate)
            selectcolor -= 1
        elseif btnp(1) and selectcolor < #num then
            sfx(g_sfx_navigate)
            selectcolor += 1
        end
        game.player.call = num[selectcolor]
    end
    -- did we die in spikes or some other trap?
    if trap(game.player.x - 2, game.player.y) or
       trap(game.player.x + 2, game.player.y) then
        sfx(g_sfx_death)
        world.lose = g_lose_frames
        death_particles(game.player.x, game.player.y)
    end
end

function update_entity(e, go_left, go_right, go_up, go_down)
    -- portals
    local portal
    foreach(world.portals, function(p)
        if abs(p.x - e.x) < 6 and abs(p.y - e.y) < 2 then
            portal = p
        end
    end)

    -- update some variables
    e.anim += 1

    local old_x, old_y = e.x, e.y

    -- check x movement (easy)
    if go_left then
        e.dir = true
        e.walk += 1
        move_x(e, -e.spd)
    elseif go_right then
        e.dir = false
        e.walk += 1
        move_x(e, e.spd)
    end

    -- check for ladders and ground below
    local ladder = ladder_area(e.x, e.y, 0, 4)
    local ladder_below = ladder_area_down(e.x, e.y + 0.0125, 4)
    local ground_below = wall_area(e.x, e.y + 0.0125, 4, 4)
    local grounded = ladder or ladder_below or ground_below

    -- if inside a ladder, stop jumping
    if ladder then
        e.jump = 0
    end

    -- if grounded, stop falling
    if grounded then
        e.fall = 0
    end

    -- allow jumping again
    if e.jumped and not go_up then
        e.jumped = false
    end

    if go_up then
        -- up/jump button
        if ladder then
            move_y(e, -e.climbspd)
            ladder_middle(e)
        elseif grounded and e.can_jump and not e.jumped then
            e.jump = 20
            e.jumped = true
            e.walk = 8
            if state == "play" then
                sfx(g_sfx_jump)
            end
        end
    elseif go_down then
        -- down button
        if ladder or ladder_below then
            move_y(e, e.climbspd)
            ladder_middle(e)
        end
    end

    if e.jump > 0 then
        move_y(e, -mid(1, e.jump / 5, 2) * jump_speed)
        e.jump -= 1
        if old_y == e.y then
            e.jump = 0 -- bumped into something!
        end
    elseif not grounded then
        move_y(e, mid(1, e.fall / 5, 2) * fall_speed)
        e.fall += 1
    end

    if grounded and old_x != e.x then
        if last_move == nil or time() > last_move + 0.25 then
            last_move = time()
            sfx(g_sfx_footstep)
        end
    end

    if ladder and old_y != e.y then
        if last_move == nil or time() > last_move + 0.25 then
            last_move = time()
            sfx(g_sfx_ladder)
        end
    end

    e.grounded = grounded
    e.ladder = ladder

    -- footstep particles
    if (old_x != e.x or old_y != e.y) and rnd() > 0.5 then
        add(particles, { x = e.x + crnd(-3, 3),
                         y = e.y + crnd(2, 4),
                         vx = rnd(0.5) * (old_x - e.x),
                         vy = rnd(0.5) * (old_y - e.y) - 0.125,
                         age = 20 + rnd(5), color = e.pcolors,
                         r = { 0.5, 1, 0.5 } })
    end

    -- handle portals
    if portal and ((e.y < portal.y and old_y >= portal.y) or
                   (e.y > portal.y and old_y <= portal.y)) then
        e.x = portal.other.x
        e.y += portal.other.y - portal.y
    end
end

__gfx__
0000000033b33b335555555133333b3333b3333355555551555555513333b3b366653333333333333333b3b333333ccccc733333ccccccccccccccccffffffff
0000000055555555555555515555333bb3335555555555515555555533333b336665366db3b3366d36653b3333ccccccccc7c733ccc7cccccc7cccccffff8fff
00000000555555555556555155555533335555555556555155565555b3b3333355d336653b333665365d33333ccccccccccc7c73ccccccccccccc6ccfff8f8ff
000000005566655555565551555555133555555556655551555566553b3333333336655d3336655d333365333cccccc6ccccc7c3ccccc6cccccc7cccffff8fff
000000005555555555565551566555515555665555555553355555553333b3b3333665333336653366d35533cc6cccccc6cccc7ccccccc7cccccccccffffffff
0000000055555555555555515556555155565555555551333355555533333b333665d6633665d66366533665ccccccccccccccc7cccccccccc7cccccffffffff
000000001111111155555551555555515555555511113b3b33331111b3b33333366636533666365355533665cccccc7cccc7cccccc6ccccccccc6cccffffffff
0000000033b33333555555515555555155555551333333b33b3333333b333333355533333555333333333553ccccccccccccccccccccccccccccccccffffffff
fffffff00fffffff06666600f000000ffff00ffff000000f0110000094949494333336653333366566533333cccccccccc6cccccccccccccccccccccffffffff
fffff004200fffff6777776003bbdb30ff0be0ff0222222014100000555555553665366533653665665366d3cccc6cccccccccccccccccccccc7ccccffffffff
fff0042428200fff67f1f1000bdbbb30f0ebbb0f0444442019a1000055555555365d355d335d355d5d336653dccccccccccccccccc7ccc6cccccccccffffffff
f00424442828200f06ffff000bbbb3d00bbbb3800422242019aa1000556665553333653333336533336655d3cdccccccc7ccccccccccccccc6ccccccffefffff
04242424282828e0008ff8000bbdb3300bbeb3300444442019aaa1105555555566d3553333335533336653333cdcccc7ccccccc3c6ccccccccccdcccfe7effff
04244424288828e00888888ff04b320f0b4b3230f004200f019aaaa19494949466533665b3b33665665d33333dcdcccccccc7c33ccccc7ccccccccccffefffff
0424244428ee28e00ff888fff044420ff004400fff0420ff0019aa10c4c4c4c4555336653b3336656663b3b333dcdcccccccc333cccccc6cccccccccffffffff
04242426622e2ee000cc0cc0ff0000fffff00ffffff00fff00011100cccccccc333335533333355355533b3333333dccccc33333ccccccccccccccccffffffff
0442266666622ee0ff0000ffff0000ffffffffffff000000000000ff45555554ff00ffffffffffff00001000f000000ffff0000ff0000fffffffffffffffffff
04066666666660e0f042e20ff051d10fff0000fff01111111111110f95555559f0770fffffffffff0011311001111110ff03bbb00bb330fffffffffffffff9ff
00666662262267000442eee00551ddd0f051d10ff05dddddddddd10f4556555406d770fffff000ff01883bb105dddd10f03bbbb3b3b3330fffff2fffffff939f
f06666624624670f042222e0051111d00551ddd0f05dddddddddd10f955655590667770fff06770f18ee8b1005555510f0bbabbbbbbb330ffff262fffffff9ff
f06622677677670f0666666006666660051111d0f05dddddddddd10f455655540d667770f0d6677018e888100000000003bb93bbab3b3330ffff2ffffffbffff
f07624666666670f067667600676676006766760f05dddddddddd10f955555590d666d70f0d66d70128888100d7767700bbbbbbbbb3bb330ffffffffffb3bfff
f07724777557770f065665600656656006566560f05555555555510f45555554f0d6660fff0d660f012281000d5565500bbbbbb9b3b33330fffffffffffbffff
ff000000000000fff000000ff000000ff000000ff00000000000000f95555559ff0000fffff000ff001110000d6666600babbbb23333a330ffffffffffffffff
06666600006666600d666660f0d666666666660ff0d666666666660f33b33b335555555155555551555555510d666660f0bb90b20322330f3333333322998899
67777760067777760d767670f0d677676777660ff0d677676777660f555555555556555555565551555655550d767670ff0bb20b032330ff33b333b322998899
67f1f100067f1f100d565650f0d655656555660ff0d655656555660f555555555556555555565551555655550d565650fff0bb2332200fff3333333399229988
06ffff00006ffff00d666660f0d666666666660ff0d666666666660f566566555665665556655551555566550d666660ffff0004220fffff3b333b3399229988
00dffd0000dffd000d650560f0d650505666660ff0d666666666660f555655555555555555565551555655550d666660ffffff04220fffff33b3b33388992299
0ddddddfddddddf00d607060f0d607070666660ff0d776776776760f555655555555555555565551555655550d776770fffff0444220ffff333b333388992299
0ffdddffffdddff00dd070d0f0dd07070ddddd0ff0d556556556560f555555511111111155555551555555510d556550fffff0444420ffff3b3333b399889922
00c70c700c70c700f000000fff000000000000fff0d666666666660f555555513333333355555551555555510d666660ffffff00000fffff3333333399889922
ffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffff1fffff000000000000000000000000000000000000222000000000000000000000000000002220000000000000000000000000
ffffffffffffffffffffffff11311fff000000000000000000000000000000000000288228000000000022200000000000028882280000000000222000000000
fffffffffffffffffffffff1883bb1ff000000000000000000000000000000000002886ff820000000008882282e00000028886ff8200000000e288228200000
ffffffff1fffffffffffff18ee8b1fff00000000000000000000000000000000000286fff820000000066ff8882e0000002886fff8200000000e28886fff0000
ffffff11311fffffffffff18e8881fff000000000000000000000000000000000000286f882000000006ff8882c100000002286f880000000001128886ff1000
fffff1883bb1fffffffff11288881fff00000000000000000000000000000000000001c1ccc10000001cf2882cc10000000001ccc1c10000001cc12222c10000
ffff18ee8b1ffffffff113112281ffff000000000000000000000000000000000000001111100000000110001110000000000011111000000001100011100000
ffff18e8881fffffff1883bb1111ffff000000000000000000000000000000000000000000000000000000000000000000000666666000000000000000000000
ffff1288881ffffff18ee8b1f11311ff000000000000000000000000000000000000000000000000000000000000000000006777777600000000006666000000
fffff12281fffffff18e88811883bb1f000000000000000000000000000000000000000000000000000000000000000000067777777760000000667777660000
ffffff111ffffffff12888818ee8b1ff000000000000000000000000000000000000000000000000000000000000000000677777766660000006777777776000
ffffffffffffffffff1228118e8881ff0000000000000000000000000000000000000000000000000000000000000000006776676fff00000067777776676000
fffffffffffffffffff111f1288881ff000000000000000000000000000000000000000000000000000000000000000000676ff6ff1f0000006776676ff60000
ffffffffffffffffffffffff12281fff00000000000000000000000000000000000000000000000000000000000000000088fff6ff15500000866ff6ff1f0000
fffffffffffffffffffffffff111ffff00000000000000000000000000000000000000000000000000000000000000000678ffffeefff0000088fff6ff155000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006776fffeeff000006776fffeefff000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066000ffff0000006776fffeeff0000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066000ffff00000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100100009933330099333000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001601610044493000444930300000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000016cccc10444549004445490000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000011000000000000001cc7c710454444904544449000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000cc1111001111110001c7c710344444403444444000003300
0000000000000000000000000000000000000000000000000000000000000000000000000000000001cc6c10cc6c6c1001cccc10334544433345444300033530
00000000000000000000000000000000000000000000000000000000000000000000000000000000016cc1000cccc10000111100300444333004443000035300
000000000000000000000000000000000000000000000000000000000000000000000000000000000c1c10c001c1c10000000000300003300300030000003000
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
70707070707070707070707070707070f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
70e370e3707070e3707070707070e370f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
70707070707070707070707070707070f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
70707070707070707070e37070707070f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
10101010101030e37070707070707070f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
707070707070207070e3707070707070f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
70707070e3702070707070707070e370f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
707070e370702070707070e370707070f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
e3707070707020707070e37070707070f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
707070707070207070e3707070707070f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
70e37070707020707070707070707070f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
7070e37070702070707070e37070e370f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
7070707070702070e370707070707070f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
7070401010105070707070707070e370f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
e370207070e37070e3e37070e3707070f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
70702070707070707070707070707070f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
__gff__
0000000000000000000000101010100001010001010100000000001010101000010101010101010001010001010100000000010101010100000000010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f2c2d07101107070710110707073f070702070707070707220707073f070707070707020707070707073f07070707072526072b070707073f070707070207070707070707073f072c2d070707070707070707073f070707070b0d0d0e0c070707073f070702070707070707070707073f070707070707020707070707073f3f
3f3c3d07202124222320210715073f2c2d020b0d0e1e1d0d0e1e0c073f07072c2d0707020707070707073f070723070733340732230707073f070704013923070707070707073f073c3d07072c2d0707072c2d073f0707070b0e1d1c1b1c070707073f073f02070707070707070707073f073f07070707020707070707073f3f
3f072804010101010101010101013f3c3d0617010101010103071d073f07073c3d0707020707072c2d073f01010101010101010101032b073f072402240207070401031507073f07070707153c3d0707073c3d073f0101030d0d0d0c0401010101013f070702070707070707070707073f070707070707020707070707073f3f
3f0707022c2d072c2d0b0e0c07073f0707220e071011101102151e073f070707070707020707073c3d073f2526072b25262526252602322b3f070706010524070223020707073f07072c2d0707072c2d070707073f0707020d0d0d0d270d0e0c18073f070702070707070707070707073f070707070707020707070707073f3f
3f2324023c3d073c3d0d0d1d0a073f07070b1c142021202102070e073f010101031011020707070707073f353623323536353633340207323f070724070b0c2202223a0101013f07073c3d0707073c3d070707073f0707021b0d0d1c021b1e1c18073f070702070707070707070707073f010101030707020707070707073f3f
3f01010518180a13241b1e1c08073f07071d13040101010105140d073f07070702202102072c2d0707073f353604033334333404013837033f070b0d0d0e0d230207022407073f070707072c2d070707040101013f070706011701010507070708073f070706010101010103070707073f070707060101050707070707073f3f
3f07070707071908180818081a073f07071b1e270e0d1d1e0e0d1c073f07070706010139073c3d0707073f333406380101010139072b06053f070d1e1e0d0e070601050707073f072c2d073c3d072c2d020707073f070b0d0d0d0c07070715081a073f070707070707070702070707073f070707070707070707070707073f3f
3f070707070707070707070707073f070707070207070707070707073f070707070707020707070707073f070707070707070702233207073f071b0d0d0d1c072422220707073f073c3d070707073c3d020707073f071b0e0e0e1c070707070707073f070707070707070702070707073f070707070707070707070707073f3f
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f070707070707070707070707073f070707070207070707070707073f070707070707020707070707073f070707070601010307070707073f070707070707070707070707073f070707020707070707070707073f070707070707070707070707073f070702070707070707070707073f070707070707070707070707073f3f
3f073f04010101010101010307073f073f07070207070707070707073f073f07070707020707070707073f07072c2d072c2d020707072c2d3f073f07070707070707070707073f073f07020707070707070707073f073f04010101010101030707073f073f02070707070707070707073f073f07070707070707070707073f3f
3f070702070707070707070207073f070707070601010307070707073f070707070707020707070707073f07073c3d073c3d020707073c3d3f070707070707070707070707073f070707020707070707070707073f010105070707070707020707073f070702070707070707070707073f070707070707070707070707073f3f
3f070706030707070707070207073f070707070707070601010307073f070707040101380101010101013f0707072c2d07070210110707073f010101010101010101010101013f070707020707070707070707073f070707070707070707020707073f070706010101010101030707073f070707070707070707070707073f3f
3f070707020707070707070207073f070707070707070707070601013f070707020707070707070707073f0707073c3d07070220210401013f070707070707070707070707073f010101380103070707070707073f070707070401010101050707073f070707070707070707020707073f070707070707070707070707073f3f
3f010101050707070707070207073f070707070707070707070707073f070704050707070707070707073f070401010101013801010507073f070707070707070707070707073f070707070702070707070707073f070707070207070707070707073f070707070707070707060101013f070707040101010101010101013f3f
3f070707070707070707070207073f070707070707070707070707073f070702070707070707070707073f070207070707070707070707073f070707070707070707070707073f070707070706010101030707073f070707070207070707070707073f070707070707070707070707073f070707020707070707070707073f3f
3f070707070707070707070207073f070707070707070707070707073f070702070707070707070707073f070207070707070707070707073f070707070707070707070707073f070707070707070707020707073f070707070207070707070707073f070707070707070707070707073f070707020707070707070707073f3f
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f2c2d073f070207073f07140207243f1011073f07022c2d3f2c2d07073f0714072224073f070702073f070707070707070207070707073f070707070707070707073e07073f07150b0c073f0728043907073f07070707073e073f0704010103073e3f07073e070707073f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f3c3d243f070603133f01010507073f2021243f07023c3d3f3c3d2c2d3f0101010101013f072202133f070707070707070207070707073f07070707073e070707070707073f0101170d3e3f0728020207133f070403072229073f070222230207073f07040103290a283f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f0101013f101102133f14070723073f2c2d073f070207223f07073c3d3f0707130707073f220405073f070707070707070207070707073f07073e070707070707070707073f073e1b1c073f0722060507073f0138053e0707073f070601013801013f07022802070a073f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f242c2d3f202102073f3f3f3f3f3f3f3c3d073f070601013f070401013f3f3f3f3f3f3f3f010507243f010101010307070207070707073f070707070707040101010101013f3f3f3f3f3f3f07070707073e3f070707071407073f073e07070713073f07060139070a073f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f073c3d3f3f3f3f3f3f07240401013f0103073f2c2d2c2d3f07022c2d3f0707020723243f071307073f070707070601013907070707073f010101010101390707070707073f070707073e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f071407073e07073f3e0707020707073f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f3f3f3f3f070213073f0101052c2d3f0702073f3c3d3c3d3f07023c3d3f0704050707243f3f3f3f3f3f070707070707070207070707073f07070707070702073e3e3e3e073f18090a3e073f0707142c2d07073f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f1313133f140207073f1307073c3d3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0702130707073f3f3f3f3f3f070707070707070601030707073f07073e070707023e3e3e0707073f1a280103073f0707133c3d01013f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f0101013f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f070707070707070707020707073f070707070707020707070707073f0a190802073f101107070715073f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f1314133f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f202107070707073f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000275002b500275001b5001f5001a5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000f0000f0001800018000180000e0000e00018000180000d0000d0000b0000b0000e0000e0000e00000000130001300018000180001200012000100001000013000130001300012000120001200012000
01140000000000000014000140000c00015000150001400014000177001770012000120001500015000150000c0001a0001a0001900019000177001770017000170001a0001a0001a00019000190001900019000
011600000e54415540005021a5401d54015540215401c502225401a54022540165400e54015540005001a5401d54015540215401c500225401a5402254016540135401a5401f5001f540225401a5402654000500
01160000275402b540275401b5401f5401a540265001b5401f5401b540275402b540265401c5000e54015540005001a5401d540155402154000500225401a5402254016540155401354011540105400e5400e545
011600000252002520025200000000000000000000000000000000000000000000000252002520025200000000000000000000000000000000000000000000000752007520075200000000000000000000000000
011600000000000000000000000007500075000750000000000000000000000135001350013500000000000000000000000000000000000000000000000000000000000000000000000000000000000252002520
011600002254000000225401a5402254021540195001f540000001f540185401f5401d540000001b540000001b540155401b5401a540225401a54022540215401a5001f540000001f540185401f5401d5401a500
011600000252002520025200000000000000000000000000000000000000000000000252002520025200000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 0c0e4c4d
02 0d0f4344
00 4c4e4344
02 4d4f4344

