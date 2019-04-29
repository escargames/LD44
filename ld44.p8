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
#include constants.lua

mode = {}
#include mode_test.lua
#include mode_menu.lua
#include mode_play.lua

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

__gfx__
0000000033b33b335555555133333b3333b3333355555551555555513333b3b366653333333333333333b3b333333ccccc733333ccccccccccccccccffffffff
0000000055555555555555515555333bb3335555555555515555555533333b336665366db3b3366d36653b3333ccccccccc7c733ccc7cccccc7cccccffff8fff
00000000555555555556555155555533335555555556555155565555b3b3333355d336653b333665365d33333ccccccccccc7c73ccccccccccccc6ccfff8a8ff
000000005566655555565551555555133555555556655551555566553b3333333336655d3336655d333365333cccccc6ccccc7c3ccccc6cccccc7cccfff383ff
000000005555555555565551566555515555665555555553355555553333b3b3333665333336653366d35533cc6cccccc6cccc7ccccccc7cccccccccfff3b3ff
0000000055555555555555515556555155565555555551333355555533333b333665d6633665d66366533665ccccccccccccccc7cccccccccc7cccccfff3b3ff
000000001111111155555551555555515555555511113b3b33331111b3b33333366636533666365355533665cccccc7cccc7cccccc6ccccccccc6cccfff333ff
0000000033b33333555555515555555155555551333333b33b3333333b333333355533333555333333333553ccccccccccccccccccccccccccccccccffffffff
fffffff00ffffffff000000ff000000ffff00ffff000000fffffffff94949494333336653333366566533333cccccccccc6cccccccccccccccccccccffffffff
fffff004200fffff0133d31003bbdb30ff0be0ff02222220ffffffff555555553665366533653665665366d3cccc6cccccccccccccccccccccc7ccccffffffff
fff0042428200fff03d333100bdbbb30f0ebbb0f04444420ffffff0f55555555365d355d335d355d5d336653dccccccccccccccccc7ccc6cccccccccffefffff
f00424442828200f033331d00bbbb3d00bbbb38004222420fff009b0556665553333653333336533336655d3cdccccccc7ccccccccccccccc6ccccccfe7effff
04242424282828e0033d31100bbdb3300bbeb33004444420f00ab0b05555555566d3553333335533336653333cdcccc7ccccccc3c6ccccccccccdcccf3e3ffff
04244424288828e0f043120ff04b320f0b4b3230f004200ffab0b0b09494949466533665b3b33665665d33333dcdcccccccc7c33ccccc7ccccccccccf3b3ffff
0424244428ee28e0f044420ff044420ff004400fff0420ffffb0ffffc4c4c4c4555336653b3336656663b3b333dcdcccccccc333cccccc6cccccccccf3b3ffff
04242426622e2ee0ff0000ffff0000fffff00ffffff00fffffffffffcccccccc333335533333355355533b3333333dccccc33333ccccccccccccccccf333ffff
0442266666622ee0ff0000ffff0000ffffffffffff000000000000ff45555554ff00ffffffffffffff0ffffff000000ffff0000ff0000fffffffffffffffffff
04066666666660e0f042e20ff051d10fff0000fff01111111111110f95555559f0770ffffffffffff0ba00ff01111110ff03bbb00bb330fffffffffffffff9ff
00666662262267000442eee00551ddd0f051d10ff05dddddddddd10f4556555406d770fffff000fff0b0b9ff05dddd10f03bbbb3b3b3330fffff2fffffef939f
f06666624624670f042222e0051111d00551ddd0f05dddddddddd10f955655590667770fff06770ff0b0bfff05555510f0bbabbbbbbb330ffff262fffe8e393f
f06622677677670f0666666006666660051111d0f05dddddddddd10f455655540d667770f0d66770f0b0bfff0000000003bb93bbab3b3330fff323fff3e33b3f
f07624666666670f067667600676676006766760f05dddddddddd10f955555590d666d70f0d66d70ffffffff0d7767700bbbbbbbbb3bb330fff3b3fff3b33b3f
f07724777557770f065665600656656006566560f05555555555510f45555554f0d6660fff0d660fffffffff0d5565500bbbbbb9b3b33330fff3b3fff3b3333f
ff000000000000fff000000ff000000ff000000ff00000000000000f95555559ff0000fffff000ffffffffff0d6666600babbbb23333a330fff333fff333ffff
88888888888888880d666660f0d666666666660ff0d666666666660f33b33b335555555155555551555555510d666660f0bb90b20322330f3333333322998899
88888888888888880d767670f0d677676777660ff0d677676777660f555555555556555555565551555655550d767670ff0bb20b032330ff33b333b322998899
88888888888888880d565650f0d655656555660ff0d655656555660f555555555556555555565551555655550d565650fff0bb2332200fff3333333399229988
88888888888888880d666660f0d666666666660ff0d666666666660f566566555665665556655551555566550d666660ffff0004220fffff3b333b3399229988
88888888888888880d650560f0d650505666660ff0d666666666660f555655555555555555565551555655550d666660ffffff04220fffff33b3b33388992299
88888888888888880d607060f0d607070666660ff0d776776776760f555655555555555555565551555655550d776770fffff0444220ffff333b333388992299
88888888888888880dd070d0f0dd07070ddddd0ff0d556556556560f555555511111111155555551555555510d556550fffff0444420ffff3b3333b399889922
8888888888888888f000000fff000000000000fff0d666666666660f555555513333333355555551555555510d666660ffffff00000fffff3333333399889922
55550555500555555555555555000055550000555500005555555555555555550000000000000000000000000000000000000000000000000000000000000000
55003005040555555005005550777705507777055077770555555555555555550000222000000000000000000000000000002220000000000000000000000000
50883bb009a0555508e0e70507766660067777700666667055500555555555550000288228000000000022200000000000028882280000000000222000000000
08ee8b0509aa055502888805076600050667777006000060550c7055555151550002886ff820000000008882282e00000028886ff8200000000e288228200000
08e8880509aaa005502880550600f2f000666600002ff200550dc05555151515000286fff820000000066ff8882e0000002886fff8200000000e28886fff0000
02888805509aaaa05502055550fff4f00f0000f00f4ff4f055500555515151510000286f882000000006ff8882c100000002286f880000000001128886ff1000
502280555509aa0555505555550fff0550ffff0550ffff055555555555151515000001c1ccc10000001cf2882cc10000000001ccc1c10000001cc12222c10000
55000555555000555555555555500055550000555500005555555555555151550000001111100000000110001110000000000011111000000001100011100000
50055555555005555550055555500555555005555550055555500555555055550000000000000000000000000000000000000666666000000000000000000000
06705555550aa05555028055550280555502805555028055550aa055550a05550000000000000000000000000000000000006777777600000000006666000000
0d6705005509a0555002805555028055550280055002805550499a05550905550000000000000000000000000000000000067777777760000000667777660000
50d670a0550990550f04800555008055500480f00f04800550499a05550905550000000000000000000000000000000000677777766660000006777777776000
550d6a0555049055504800f0550f00550f048005500480f0550440555504055500000000000000000000000000000000006776676fff00000067777776676000
55509c055550055550c4700550707c0550c4170550714c0555500555555055550000000000000000000000000000000000676ff6ff1f0000006776676ff60000
550900c0550490555507c05550c000555500dc0550cd00555555555555555555000000000000000000000000000000000088fff6ff15500000866ff6ff1f0000
5500550055500555555005555505555555550055550055555555555555555555000000000000000000000000000000000678ffffeefff0000088fff6ff155000
55000555000555555555555555555555dd5555555555555555555555555555555505505500000000000000000000000006776fffeeff000006776fffeefff000
50ee7050e7705555d555555d5555555500d55555555555555555555555555555506506050000000000000000000000000066000ffff0000006776fffeeff0000
5088e70288e055550d5555d055dddd55500ddd55555dddd555555555555555550644440500000000000000000000000000000000000000000066000ffff00000
0e888828888e055550dddd055d0000d5500000d555d0000500555555555555550447470500000000000000000000000000000000000000000000000000000000
02888888888e05555000000550000005550000055d00000044000055000000555047470500000000000000000000000000000000000000000000000000000000
02888888888e055555000055d050050d555000005000005550446405446464055044440500000000000000000000000000000000000000000000000000000000
5028888888805555555005550555555055550005d000055550644055544440555500005500000000000000000000000000000000000000000000000000000000
5028888888e055555550055555555555555500550005555554040545504040555555555500000000000000000000000000000000000000000000000000000000
550288888e0555555555555555555555555555555555555555555555555555550666660000666660000000000000000000100100009933330099333000000000
55502888e05555555550055555555555555005555555555555500555555555556777776006777776000000000000000001601610044493000444930300000000
5555002005555555550bb05555555555550cc05555555555550aa0555555555567f1f100067f1f10000000000000000016cccc10444549004445490000000000
555555055555555550b36b055500005550cd6c055500005550a96a055500005506ffff00006ffff011000000000000001cc7c710454444904544449000000000
555555555555555550333b0550bbbb0550dddc0550cccc0550999a0550aaaa0500dffd0000dffd00cc1111001111110001c7c710344444403444444000003300
555555555555555550133b05013336b0501ddc0501ddd6c050499a05049996a00ddddddfddddddf001cc6c10cc6c6c1001cccc10334544433345444300033530
555555555555555550113305011133305011dd050111ddd050449905044499900ffdddffffdddff0016cc1000cccc10000111100300444333004443000035300
555555555555555555000055500000055500005550000005550000555000000500c70c700c70c7000c1c10c001c1c10000000000300003300300030000003000
f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f300f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
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
0000000000000000000000101010100001010101010100000000001010101000010101010101010001010001010100000000010101010100000000010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f132c2d130713070713071307073f2c2d07101107070710110707073f070702070707070707220707073f070707070707020707070707073f07070707072526072b070707073f070707070207070707070707073f072c2d070707070707070707073f070707070b0d0d0e0c070707073f070702070707070707070707073f3f
3f073c3d141307070707070707073f3c3d07202124222320210715073f2c2d020b0d0e1e1d0d0e1e0c073f07072c2d0707020707070707073f070723070733340732230707073f070704013923070707070707073f073c3d07072c2d0707072c2d073f0707070b0e1d1c1b1c070707073f070702070707070707070707073f3f
3f071307101107070707040101013f072804010101010101010101013f3c3d0617010101010103071d073f07073c3d0707020707072c2d073f01010101010101010101032b073f072402240207070401031507073f07070707153c3d0707073c3d073f0101030d0d0d0c0401010101013f070702070707070707070707073f3f
3f131407202107071407020707073f0707022c2d072c2d0b0e0c07073f0707220e071011101102151e073f070707070707020707073c3d073f2526072b25262526252602322b3f070706010524070223020707073f07072c2d0707072c2d070707073f0707020d0d0d0d270d0e0c18073f070702070707070707070707073f3f
3f071307190808180818020707133f2324023c3d073c3d0d0d1d0a073f07070b1c142021202102070e073f010101031011020707070707073f353623323536353633340207323f070724070b0c2202223a0101013f07073c3d0707073c3d070707073f0707021b0d0d1c021b1e1c18073f070702070707070707070707073f3f
3f2c2d07070707070707390707073f01010518180a13241b1e1c08073f07071d13040101010105140d073f07070702202102072c2d0707073f353604033334333404013837033f070b0d0d0e0d230207022407073f070707072c2d070707040101013f070706011701010507070708073f070706010101010103070707073f3f
3f3c3d1407070b0c0707020707073f07070707071908180818081a073f07071b1e270e0d1d1e0e0d1c073f07070706010139073c3d0707073f333406380101010139072b06053f070d1e1e0d0e070601050707073f072c2d073c3d072c2d020707073f070b0d0d0d0c07070715081a073f070707070707070702070707073f3f
3f07071414131b1c0707020713073f070707070707070707070707073f070707070207070707070707073f070707070707020707070707073f070707070707070702233207073f071b0d0d0d1c072422220707073f073c3d070707073c3d020707073f071b0e0e0e1c070707070707073f070707070707070702070707073f3f
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f070707070707070707070707073f070707070207070707070707073f070707070707020707070707073f070707070601010307070707073f070707070707070707070707073f070707020707070707070707073f070707070707070707070707073f070702070707070707070707073f070707070707020707070707073f3f
3f070704010101010101010307073f070707070207070707070707073f070707070707020707070707073f07072c2d072c2d020707072c2d3f070707070707070707070707073f070707020707070707070707073f070704010101010101030707073f070702070707070707070707073f070707070707020707070707073f3f
3f070702070707070707070207073f070707070601010307070707073f070707070707020707070707073f07073c3d073c3d020707073c3d3f070707070707070707070707073f070707020707070707070707073f010105070707070707020707073f070702070707070707070707073f070707070707020707070707073f3f
3f070706030707070707070207073f070707070707070601010307073f070707040101380101010101013f0707072c2d07070210110707073f010101010101010101010101013f070707020707070707070707073f070707070707070707020707073f070706010101010101030707073f070707070707020707070707073f3f
3f070707020707070707070207073f070707070707070707070601013f070707020707070707070707073f0707073c3d07070220210401013f070707070707070707070707073f010101380103070707070707073f070707070401010101050707073f070707070707070707020707073f010101030707020707070707073f3f
3f010101050707070707070207073f070707070707070707070707073f070704050707070707070707073f070401010101013801010507073f070707070707070707070707073f070707070702070707070707073f070707070207070707070707073f070707070707070707060101013f070707060101050707070707073f3f
3f070707070707070707070207073f070707070707070707070707073f070702070707070707070707073f070207070707070707070707073f070707070707070707070707073f070707070706010101030707073f070707070207070707070707073f070707070707070707070707073f070707070707070707070707073f3f
3f070707070707070707070207073f070707070707070707070707073f070702070707070707070707073f070207070707070707070707073f070707070707070707070707073f070707070707070707020707073f070707070207070707070707073f070707070707070707070707073f070707070707070707070707073f3f
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f
3f2c2d073f070207073f07140207243f1011073f07022c2d3f2c2d07073f0714072224073f070702073f070707070707070207070707073f070707070707070707073e07073f07150b0c073f0728043907073f07070707073e073f0704010103073e3f07073e070707073f3f3f3f3f3f3f070707070707070707070707073f3f
3f3c3d243f070603133f01010507073f2021243f07023c3d3f3c3d2c2d3f0101010101013f072202133f070707070707070207070707073f07070707073e070707070707073f0101170d3e3f0728020207133f070403072229073f070222230207073f07040103290a283f3f3f3f3f3f3f070707070707070707070707073f3f
3f0101013f101102133f14070723073f2c2d073f070207223f07073c3d3f0707130707073f220405073f070707070707070207070707073f07073e070707070707070707073f073e1b1c073f0722060507073f0138053e0707073f070601013801013f07022802070a073f3f3f3f3f3f3f070707070707070707070707073f3f
3f242c2d3f202102073f3f3f3f3f3f3f3c3d073f070601013f070401013f3f3f3f3f3f3f3f010507243f010101010307070207070707073f070707070707040101010101013f3f3f3f3f3f3f07070707073e3f070707071407073f073e07070713073f07060139070a073f3f3f3f3f3f3f070707070707070707070707073f3f
3f073c3d3f3f3f3f3f3f07240401013f0103073f2c2d2c2d3f07022c2d3f0707020723243f071307073f070707070601013907070707073f010101010101390707070707073f070707073e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f071407073e07073f3e0707020707073f3f3f3f3f3f3f070707070707070707070707073f3f
3f3f3f3f3f070213073f0101052c2d3f0702073f3c3d3c3d3f07023c3d3f0704050707243f3f3f3f3f3f070707070707070207070707073f07070707070702073e3e3e3e073f18090a3e073f0707142c2d07073f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f070707040101010101010101013f3f
3f1313133f140207073f1307073c3d3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0702130707073f3f3f3f3f3f070707070707070601030707073f07073e070707023e3e3e0707073f1a280103073f0707133c3d01013f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f070707020707070707070707073f3f
3f0101013f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f070707070707070707020707073f070707070707020707070707073f0a190802073f101107070715073f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f070707020707070707070707073f3f
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

