pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- deep asleep
-- by sestrenexsis
--  & equalenergy
-- https://github.com/sestrenexsis/ld48_deeper_and_deeper

--[[
 you are a powerful warrior that
 has been put to sleep by a
 wizard. you must wake yourself
 up by finding and defeating
 your subconscious.
--]]

--[[
game states
    t <--> w <--> f
 t: title screen
 w: world
 f: fight
--]]

-- change keypress delays
poke(0x5f5c,6)
poke(0x5f5d,6)

--globals
_me="sestrenexsis"
_cart="ldjam48"
--cartdata(_me.."_".._cart.."_1")
--_version=1
_herox=0  -- hero tile x
_heroy=0  -- hero tile y
_herof="" -- hero facing dir
_camx=0 -- camera target x
_camy=0 -- camera target y
-- door triggers
-- from_x,from_y,to_x,to_y
_doors={
-- blue single-door house
	{9,14,31,55},{31,56,9,15},
-- blue double-door house
	{22,14,8,55},{8,56,22,15},
	{23,14,9,55},{9,56,23,15},
-- white single-door house
	{12,4,87,55},{87,56,12,5},
-- white double-door house
	{32,21,57,55},{57,56,32,22},
	{33,21,58,55},{58,56,33,22},
-- 
}
-- dialogue triggers
-- x,y,portrait,name,quote
_chats={
-- john
	{11,53,98,"john",{
		"hi, i'm john, your \nneighbor. i'll give you \nthe goods but let's see \n10 gold coins first.",
	}},
-- scientist
	{59,53,93,"scientist",{
		"yes! it's alive! \nit's alive!",
		"... oh, sorry, just \ntesting m'freakystein.",
		"want one of my spare \ngadgets?",
	}},
-- bedkeeper
	{83,52,91,"bedkeeper",{
		"zzz ...",
		"huh, hello? sorry, \nbut would you like t- \nzzz ...",
		"what, oh yes, would \nyou like to use my beds?",
	}},
}
_world={x1=0,y1=0,x2=128,y2=128}
_bound=_world
_rooms={
	{x1=1,y1=55,x2=13,y2=62},
	{x1=15,y1=54,x2=30,y2=62},
}
_act=1
_acts={
	"slash",
	"curse",
	"heal",
	"retreat",
}
_mobs={
	{name="slime",anim=36,hp=5,dmg=1},
	{name="rocket pig",anim=25,hp=25,dmg=5},
	{name="subcon",anim=68,hp=100,dmg=10},
}
_mob={}

function _init()
	_herox=37
	_heroy=50
	_heron="hero"
	_herol=1
	_herof="dn"
	initworld()
end

function _update()
	updatefn()
end

function _draw()
	drawfn()
end

function initworld()
	initfn=initworld
	updatefn=updateworld
	drawfn=drawworld
end

function updateworld()
	local mov=false
	local tx=_herox
	local ty=_heroy
	if btnp(⬆️) then
		mov=true
		ty-=1
		_herof="up"
	elseif btnp(⬇️) then
		mov=true
		ty+=1
		_herof="dn"
	elseif btnp(⬅️) then
		mov=true
		tx-=1
		_herof="lf"
	elseif btnp(➡️) then
		mov=true
		tx+=1
		_herof="rt"
	end
	if mov then
		local wlk=fget(mget(tx,ty),0)
		if wlk then
			_herox=tx
			_heroy=ty
		end
		-- check if entering a door
		for door in all(_doors) do
			if (
				door[1]==_herox and
				door[2]==_heroy
			) then
				_herox=door[3]
				_heroy=door[4]
				break
			end
		end
	end
	_bound=_world
	for i=1,#_rooms do
		local room=_rooms[i]
		if (
			room.x1<=_herox and
			room.x2>=_herox and
			room.y1<=_heroy and
			room.y2>=_heroy
		) then
			_bound=room
			break
		end
	end
	_camx=8*_herox-64
	_camy=8*_heroy-64
	if btnp(❎) then
		local chatfnd=false
		for chat in all(_chats) do
			if (
				_herox==chat[1] and
				_heroy==chat[2]
			) then
				initchat(chat)
				chatfnd=true
				break
			end
		end
		if not chatfnd then
			initfight()
		end
	end
end

function drawworld()
	cls()
	camera(_camx,_camy)
	map(0,0,0,0,128,128)
	local frm=2
	local flp=false
	if _herof=="dn" then
		frm=1
	elseif _herof=="lf" then
		frm=3
		flp=true
	elseif _herof=="rt" then
		frm=3
	end
	local x=8*_herox
	local y=8*(_heroy-1)
	spr(frm,x,y,1,2,flp)
end

function initfight()
	initfn=initfight
	updatefn=updatefight
	drawfn=drawfight
	_act=1
	local mob=rnd(_mobs)
	_mob={
		name=mob.name,
		anim=mob.anim,
		hp=mob.hp,
		dmg=mob.dmg,
	}
end

function updatefight()
	if btnp(🅾️) then
		initworld()
	end
	if btnp(⬆️) then
		_act=max(1,_act-1)
	elseif btnp(⬇️) then
		_act=min(#_acts,_act+1)
	end
	if btnp(❎) then
		act(_acts[_act])
	end
end

function act(action)
	local camx=_camx
	local camy=_camy
	camera(0,0)
	local colr=8
	if action=="curse" then
		colr=3
	elseif action=="heal" then
		colr=14
	elseif action=="retreat" then
		colr=10
	end
	print(action,64,64,colr)
	for i=1,30 do
		flip()
	end
	camera(camx,camy)
	if action=="retreat" then
		initworld()
	end
end

function drawfight()
	local camx=_camx
	local camy=_camy
	local x1=4
	local y1=16
	local x2=x1+120
	local y2=y1+96
	camera(0,0)
	rectfill(x1+0,y1+0,x2-0,y2-0,0)
	rectfill(x1+1,y1+1,x2-1,y2-1,7)
	rectfill(x1+2,y1+2,x2-2,y2-2,1)
	rectfill(x1+3,y1+3,x2-3,y2-3,0)
	spr(3,x1+20,y1+8,1,2)
	spr(_mob.anim,x2-24,y1+16,1,1)
	local name=_heron..", level "
	name=name..tostr(_herol)
	print(name,x1+8,y2-32-6,6)
	print(_mob.name,x1+64,y2-32-6,8)
	for i=1,#_acts do
		local txt=_acts[i]
		local colr=5
		if _act==i then
			colr=7
			txt=">"..txt
		else
			txt=" "..txt
		end
		print(txt,x1+8,y2-32+6*i,colr)
	end
	camera(camx,camy)
end

function initchat(chat)
	initfn=initchat
	updatefn=updatechat
	drawfn=drawchat
	_portrait=chat[3]
	_name=chat[4]
	_phrases=chat[5]
	_phrase=1
	_talking=true
end

function updatechat()
	if btnp(❎) then
		_phrase+=1
		_talking=true
		if _phrase>#_phrases then
			initworld()
		end
	end
end

function quote(q)
	local res=""
	local snds={"a1","e1","b1"}
	local snd=""
	for c in all(split(q,"")) do
		snd=rnd(snds)
		res..="\as1i0"..snd.." \^1"..c
	end
	return res
end

function drawchat()
	local camx=_camx
	local camy=_camy
	local x1=4
	local y1=96
	local x2=x1+120
	local y2=y1+32
	camera(0,0)
	rectfill(x1+0,y1+0,x2-0,y2-0,0)
	rectfill(x1+1,y1+1,x2-1,y2-1,7)
	rectfill(x1+2,y1+2,x2-2,y2-2,1)
	rectfill(x1+3,y1+3,x2-3,y2-3,0)
	spr(_portrait,x1+4,y1+4,2,2)
	print(_name,x1+4,y1+22,13)
	local text=_phrases[_phrase]
	if _talking then
		text=quote(text)
		_talking=false
	end
	print(text,x1+23,y1+4,7)
	camera(camx,camy)
end
__gfx__
00000000000000000000000000000000000000000000000000000000228888820000000000000000000000000000000000000000000775750000000000066161
00000000000000000000000000000000000000000000000000444200888828880088800000000000000000000000000000000000000557570000000000011616
0070070009900a000000000099900a00004442224444400044444444888288280717000002440442000870005050005000000000000ccc770000000000006661
00077000009999a009990aa0099990000444424444422400444444442288882807170000044404240088860015100005000000000ccccc570000000000044406
0007700007999a0000999a000999aa7002240470470244000470047088888888997700702422244400888800161000050000000000012170000000000001d160
007007000791d1a00099990009dd1a70024404604602440004600460422442040006767044444424004444007e7555500000000000014100000000000001f100
000000000601f100006999a000ff10600244044044044400044004404224420400076700024404220042040000577750000000000004440000000000000fff00
00000000070fff200079999000fff07004440440440444000440044042244204000909000f990f9f00420400007000700000000000084200000000000007f700
10000000070752800078880008857070022400000002240004470000166161660000000000000000cccc7c7cb3bbbb3bbbbbb3bb000288005777757700076700
12000000555d1880055828208821d55502440000000244000446000016116616000515c000000000ccc77c7cbbb33bbccbb3bbbb45082854777777779f0776f9
41100000f90d11890f9882898881df9002444222444244000224000061661661e0e515dce0e00000ccccccccbbbbbbc7ccbb3b335408884557777757f907779f
442200009f01158f09f2888f828159f0004442444444440002440000161661161e1515c01e100000c77cc7cc33bbb7ccc77bbbbb000228007777575700077700
55411000000155000008282082855000004704700470470002440000616111611e1e1ee01e1eeee0cc7cc7ccbb3bc7cccc7cbbbb0008820075575777000ddd00
44542200000ddd00000dd82088ddd00000460460046046000444000061616166eeee1eeeeeeeeeeeccccc7ccbbbcc7cccccccbb30001110077777775000d0d00
54541120000d0d00000d0d8080d0d00000440440044044000444000016161616000e1ee0000eeee07cccccccbbcccccc7cccccbb000101007757575700040400
5445541100040400000404000040400000440440044044000444000066616161000e00e0000e00e07cccccccbcc7cccc7ccccccb000101007757577700000000
515515550000000044445444000000000000000000000000000222000000000000000776eeeeeeee6cccccccdddddddd00000000000000007771111751551151
51551555033000004544544400000000001115d0000000000027c7200000000000000766e11bbbbecc7cc7ccd6a6111d00000000444444241111616151551555
111111110dd0d3004545445500000000011bb7dd000000000276c7720000000000000766e55b44becc6cc7ccda95156d0000000022444444dd1dd1dd51511555
1555515500000000445444540000000001bbb67d0000000002cc77c20000000000000666ea9ac44ec77cc6ccdf16615d00000000444442225515515151555155
1555515503d0d0335444444400011000013bbbb50000000002c77cc20000000000000666e1f1a71ec76cccc7d824561d42244222442442445515515515111511
111111110330d0d344445544002552000133bbb1000000000277cc721666677700000666e25ba61ec6ccc7c7d286111d44442444242244441151551555155151
55555155004424004454444401444410013333b100442400027cc7c21666666700000666e8dbb88ecccc77c6d882656d42442424444244225551111155155151
111111110442242044545544245455410111111104422420022222221666666600000111eeeeeeee7ccc66ccdddddddd24422422000000001112222115515515
00000001044224203bbbbbbb002552202112121100cc7cc0555155151555551500000000000000000a0009004442242244422422000000000000000004249200
0000002104422420bbb3bbbb0251f1504524542209c777c9eeeeeeeedddddddd000000000000000099a099a02442242424422424000000000000000002299400
0000011404224420b3bb3bb355f1f1f0254544550fcccccfea11108edacccccd000000000000000009d00a0d2422442424224424768288882888000002924900
0000224504422120bbbbbb3b05ffff004454445400111110e9a3782ed9aceecd3bbbbb3b3bd770009a0600602442212424122424768882828828000004999200
00011445044221203bb33bbb00c777c05444444400511550ef16b79edf1c1fed3bb33bb33b7650009a0076002442212424122424d52882888828000002442400
0022554402422420b3bb3bbb00cc7cc04444554405511150e8df94ded8dfc8edb3bbbb3bbb675000000067004242242442422424578888888888000004222900
0114445502442220bbbbbbbb00cc7cc04454444401100442e85aa2ded85c882d4402204400220000aa0600604244222442442224440220442200000009242900
1244554402222420bbbb33b300c777c04454554424400000eeeeeeeedddddddd44022044002200009ad0000d4222242442222424440220442200000009444200
00000000000000003b33333300000000030000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000003b3bb3b300000000330000000000003003000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000333bb3b30000000008800e0088800e0338800e00000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000003bb3333300000000338888e00888e330b388e000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000003bb33bb3000000000b888e0008888eb3b3888e00000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000033333bb3000000003b8797e008dd7eb3b87dde00000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000033bb3333000000003b379700009973b0b3799300000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000033333333000000000b399920009990b3b0999000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000003b3452d00d2273b33b227d00ccccccccccccccccaaaaaaaaaaaaaaaa4444444444444444111111111111111100000000
0000000000000000000000000000000055524dd0dd24655335246d50cc700000000000ccaab33000000000aa4400000000000044110000000000001100000000
00000000000000000000000000000000f93244d9dd442990f9442d50c0779990009aa00ca0bb8880008ee00a4000000000007d74100000000000000100000000
00000000000000000000000000000000990442d9d54229f099422dd0c07699990990000ca3b338880880000a4000011110045664100024442205005100000000
0000000000000000000000000000000000042200d5444000004445d0c0760099999a000ca0b3308888ee000a40001111110488841000442444452d5100000000
00000000000000000000000000000000000ccc00ddccc00000cccdd0c07609999999a00ca3bb0888888ee00a400151ffff028884100041141105525100000000
00000000000000000000000000000000000c0c00d0c0c00000c0c0d0c0770099999a0a0ca03b33888eeede0a401515f4f402888410000dcddc00550100000000
00000000000000000000000000000000000505000050500000505000c555559555ac0a0ca555538999e76e0a401150f2f204888410000fcffc00550100000000
0000000000000000dddddddddddddddd0000000055aaa55711717111c052000dddd2000ca05800099d67600a405100ffff04888410000fffff00000100000000
0000000000000000dd020000000000dd000000005aaaaa5511171111c025000fffff000ca085000999960d0a40050ccffcc00004100007ff7700000100000000
0000000000000000d02220000000000d00000000aaaaaaa571111111c00208888155100ca0080dddd12d100a4010cc7767cc00041000077f7700000100000000
0000000000000000d22442000000000d00000000aaaaaaa511111171c00088828511500ca000ddd5d411200a4000ccc76ccc0004100007777700000100000000
0000000000000000d51515888880000d00000000aaaaaaa571111171c00828281555500ca00d5d5814d2200a4000ccc77ccc0004100007777700000100000000
0000000000000000d51441889a88800d00000000aaaaaaa517117111c00828851111100ca00d5dd41111100a4000ccc67ccc0004100007777700000100000000
0000000000000000d15425d3dd30000d0000000055aaaa5571111111cc088855155550ccaa0ddd44144440aa4400ccc76ccc0044110007777700001100000000
0000000000000000db3bbb232230000d000000007555555111171171ccccccccccccccccaaaaaaaaaaaaaaaa4444444444444444111111111111111100000000
0000000000000000d3b33b444440000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000db7bbb444440000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d46b43888280000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d0047b888280000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d00006888820000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d00000888880000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000dd000088888000dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000dddddddddddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a2a2a2a2a2a2a2a2a2a2a2a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1
a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1
a2a2a2a2a2a2a2a2a2a2a2a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1
a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1
a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1
a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1
a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1
a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1
a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1
a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1
a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1
a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1
a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1
a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000202029202b202630273020202020202000000000000000000000000000000000000000000000000
00000000000000000000000000000000e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e10000000000000000666666666666666666666666666666660000000000000000
000002020202020202020202020202000000000000000000027171717171717171717171718393020000000000000000000000e1e1e1e1e1e1e1e1e1e1e1e1e1
e1000000000000000000000000000000e1717133710271717171717171d3e3e10000000000000000665656565656565656565656565656660000000000000000
0000027171717171717171d07171020000000000000000000271a071a071717171717171717171020000000000000000000000e1e2e2e2e2e2e2e2f0e2e2e2e2
e1000000000000000000000000000000e171d353e302717171a0a0a0718393e10000000000000000665656565656565656565656565656660000000000000000
0000027171717171717171d1717102000000000000000000027070707071717171717171717171020000000000000000000000e1e2e2e2e2e2e2e2f1e2e2e2e2
e1000000000000000000000000000000e1020202020271717170707071d3e3e10000000000000000665656565656565656565656565656660000000000000000
000002d2d2d2d2d2d2d2d2d2d2d20200000000000000000002a071a0717171b071717171717171020000000000000000000000e1d2d2d2d2d2d2d2d2d2d2d2d2
e1000000000000000000000000000000e1d3e3718393717171a0a0a0718393e10000000000000000665656563056565656645656565656660000000000000000
000002717171717171717171717102000000000000000000027171717171717171717171717171020000000000000000000000e1e2e2e2e2e2e2e2e2e2e2e2e2
e1000000000000000000000000000000e1839371717171717171717171d3e3e10000000000000000665656563156565656655656565656660000000000000000
000002717171717171717171717102000000000000000000027171717171717171717171717171020000000000000000000000e1e2e2e2e2e2e2e2e2e2e2e2e2
e1000000000000000000000000000000e1d3e3718393717171717171718393e10000000000000000665656565656565656565656565656660000000000000000
0000027171717171c2c27171717102000000000000000000020202620202625262020262020202020000000000000000000000e162e1e1e162c2c262e1e1e162
e1000000000000000000000000000000e1e1e1e1e1e1e152e1e1e1e1e1e1e1e10000000000000000665656565656565656565656565656660000000000000000
0000020202020202b3c30202020202000000000000000000020202020202021302020202020202020000000000000000000000e1e1e1e1e1e1b3c3e1e1e1e1e1
e1000000000000000000000000000000e1e1e1e1e1e1e113e1e1e1e1e1e1e1e10000000000000000666666666666666666666666666666660000000000000000
__gff__
0000000000000000000101010001000101000000000000010000000101010001000000010001000000000000010001000101010100010000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3232424242323232323034343434341032323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323200000000000000000000000000000000000032323232323232323232323232323232323232323232
3232424242323232302222222222222210323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323200000000000000000000000000000000000032323232323232323232323232323232323232323232
32324242423232321e1e1e1e1e1e1e1e1e323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
3232323f323232321e1e1e1e211e1e1e1e323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
3232323f323232321e1e1e1e311e1e1e1e323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
3232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
3232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
3232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
3232323232323232323232323232323232323232323230103232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
3232323232323232322332323232323232323232323022221032323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
3232323232323232302210323232323232323232302222222210323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
3232320406060630222222101a1a1a1a1a1a3232202020202020323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
3232321632083220202020201a1a1a1a1a1c3232202020202020323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
3232321632193226262126261a1a1a1a1a32323220202c2c2020323232323232301032323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
3232321619323220203120201a1a1a1a1a1b323220203b3c2020323232323230222210323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
3232321406060615323232321a2a2a1a2a2a3232272732322727323232323022222222103232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
3232323232323232323232090909090909093232323232323232323232302222222222221032323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
1a1a2a1a1a2a1c2a1a1c1b2a1a2a1a2a2a1a1a32323232323232323230222222222222222210323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a1a3232323232323232321e1e1e1e1e1e1e1e1e1e323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a1a3232323232323232321e1e1e1e1e1e1e1e1e1e323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a323232323232323232321e261e262c2c261e261e323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a323232323232323232321e1e1e1e3b3c1e1e1e1e323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a3232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
3232323232322a2a2a2a2a323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
3232323232322a2a2a2a2a323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
3232323232322a2a2a2a2a323232323224323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
3232323232322a2a2a2a2a323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
1a2a2a3232322a2a2a2a2a323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
2a2a2a2a2a2a2a2a2a2a2a1a1a1a1a1a1a1a1c32323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
2a2a2a2a2a2a2a2a2a2a2a1a1a1a1a1a1a1a1a1c323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
2a2a2a2a2a2a2a2a2a2a2a1a1a1a1a1a1a1a1a1a1c3232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
2a2a2a2a2a2a2a2a2a2a2a1a1a1a1a1a1a1a1a1a1a1c32323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232
__sfx__
000200002c0512b054280552705524051210521f05300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
471200200e07510064100310e07710022100520f0430f0360f0640f0470f0310c0520d02516073160441705217023160750e04614057130270f037120710f044140510f0620f027170350f0510e047150220e053
3e100020130211302113021130210f0210f0210f0210f0210f02118021180211802118021180211202112021120211202114021140211402114021140211402118021180210f0210f0210f021120211202112021
0e080000100510e053100551f0041e0051a0041800500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
461000002522224222212221e2221b222192221722216222132220f2220d2220f22216222162220f2220f225162250f225162250f225162250f225162250f225162250f225162250f225162250f2250f2200d220
461000000f22216222162220f2250d222162250f2220f2250f2250f2220f2220f22216225162250d2250f222162220d2220f227162220d22516225112220f2220e2221622214222162220f2250f222162220d222
__music__
03 02020202
03 01010141
00 41040444
03 41054544

