pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- mini project one mario

t = true 
f = false

chr = { -- intialize our char

	x = 18, -- x start 
	y = 104, -- y start 
	
	dx = 0, -- velocity 
	dy = 0, -- velocity 
	
	sprt = 21, -- sprite start
	frm = 5, -- sprite frames per second
	flp = f,
	
	life = 3, -- how many lives 
	jump = 3.4, -- how much to jump 
	wlk = f, -- if walking
}

map_data = {
	offset_x = 0,
	offset_y = 0
}

flag = {
	sprt_1 = 29,
	sprt_2 = 30,
	x = 136,
	y = 32,
	dy = 0,
	pon_flag = f
}

grav = 0.2 -- gravity 


function _update()

	-- player movment
	chr.dx = 0
	
	chr.wlk = f
	
	if not flag.pon_flag then
		if (btn(0)) then
		 chr.dx=-1.8 
		 chr.flp= t 
		 
		 if on_floor then 
		 	chr.wlk = t
		 else 
		 	chr.sprt = 23
		 	chr.wlk = f
		 end 
		 
		end 
		if (btn(1)) then
		 chr.dx=1.8 
		 chr.flp = f 
		 
		 if on_floor then 
		 	chr.wlk = t
		 else 
		 	chr.sprt = 23
		 	chr.wlk = f
		 end 
		 
		end
		
		if chr.wlk then walking() else chr.sprt = 21 end
		
		chr.x+=chr.dx
		
		if in_left_wall() then
			chr.x = flr((chr.x + 7) / 8) * 8
			chr.dx = 0
		elseif in_right_wall() then
			chr.x = flr(chr.x / 8) * 8
			chr.dx = 0
		elseif in_flag() then
			-- this is where they touched the flag
			flag.pon_flag = t
			chr.x = flr(chr.x / 8) * 8
			chr.dy = 0
		end
		
		-- player jumping 
		if (btn(5) or btn(2)) and on_floor() then 
			chr.wlk = f	
			chr.dy =- chr.jump
		end
		
		-- player gravity
		if not on_floor() then
			chr.dy+=grav
			chr.sprt = 23 
		end
		
		-- player fall
		chr.y+=chr.dy
		
		chr.onground = t
		
		if in_roof() then
			chr.y = flr((chr.y + 7) / 8) * 8
			chr.dy = 0
		elseif in_floor() then
			chr.y = flr(chr.y / 8) * 8
			chr.dy = 0
		end
	end
	
	-- flag movement
	if flag.pon_flag and flag.y < chr.y then
		flag.y += 1.7
		if flag.y > chr.y then
			flag.y = chr.y
			-- this is where the level is finished
			-- the flag has been brought down
		end
	end
-- end function  
 
	camera(chr.x)
	 
end 

function _draw()

	cls()
	cls(12)
	-- 16, 00 31, 16 
	palt(0, f)
	palt(11, t)
	map(map_data.offset_x, map_data.offset_y, 0, 0, 128, 16)
	palt(0, t)
	
	-- render the flag if they are on the second part of the map
	if map_data.offset_y == 16 then
		spr(flag.sprt_1, flag.x, flag.y)
		spr(flag.sprt_2, flag.x + 8, flag.y)
	end
	
	spr(chr.sprt, chr.x, chr.y, 1,1, chr.flp)
end

function walking()

chr.frm=chr.frm-1
	if chr.frm<0 then 
		chr.sprt = chr.sprt + 1
		if chr.sprt > 22 then chr.sprt = 21 end
		chr.frm = 5
	end 

end 

function on_floor()
	local x1 = flr(chr.x / 8) + map_data.offset_x
	local x2 = flr((chr.x + 7) / 8) + map_data.offset_x
	local y = flr((chr.y + 8) / 8) + map_data.offset_y
	local map_cell1 = mget(x1, y)
	local map_cell2 = mget(x2, y)
	return fget(map_cell1, 0) or fget(map_cell2, 0)
end

function in_floor()
	local x1 = flr(chr.x / 8) + map_data.offset_x
	local x2 = flr((chr.x + 7) / 8) + map_data.offset_x
	local y = flr((chr.y + 7) / 8) + map_data.offset_y
	local map_cell1 = mget(x1, y)
	local map_cell2 = mget(x2, y)
	return fget(map_cell1, 0) or fget(map_cell2, 0)
end

function in_roof()
	local x1 = flr(chr.x / 8) + map_data.offset_x
	local x2 = flr((chr.x + 7) / 8) + map_data.offset_x
	local y = flr(chr.y / 8) + map_data.offset_y
	local map_cell1 = mget(x1, y)
	local map_cell2 = mget(x2, y)
	return fget(map_cell1, 0) or fget(map_cell2, 0)
end

function in_left_wall()
	local x = flr(chr.x / 8) + map_data.offset_x
	local y1 = flr(chr.y / 8) + map_data.offset_y
	local y2 = flr((chr.y + 7) / 8) + map_data.offset_y
	local map_cell1 = mget(x, y1)
	local map_cell2 = mget(x, y2)
	return fget(map_cell1, 0) or fget(map_cell2, 0)
end

function in_right_wall()
	local x = flr((chr.x + 7) / 8) + map_data.offset_x
	local y1 = flr(chr.y / 8) + map_data.offset_y
	local y2 = flr((chr.y + 7) / 8) + map_data.offset_y
	local map_cell1 = mget(x, y1)
	local map_cell2 = mget(x, y2)
	return fget(map_cell1, 0) or fget(map_cell2, 0)
end

function in_flag()
	local x = flr(chr.x / 8) + map_data.offset_x
	if chr.x >= x * 8 and chr.x <= x * 8 + 2 then
		local y = flr(chr.y / 8) + map_data.offset_y
		local map_cell = mget(x, y)
		return fget(map_cell, 2)
	end
	return false
end

__gfx__
00000000bb9992bbbbfffffffffffbbbffffffffbbbbbbfb00000000fbbbbbbbccccccccaaaaaaaab444444b4fff0ff044404440ffbbbfffff404fff00004440
00000000b994992bbf444bbbbb444fbbbbbbbbbbbbbbbbfb00000000fbbbbbbbcccccccc8888888849999992f4440440000000004fbbbf444f000f4400000000
00700700b949292bf44044bbb44044fbbbbbbbbbbbbbbbfb00000000fbbbbbbbcccccccc9bb99bb949444992f4440004404440444fbbbf444f444f4400004044
00077000b949292bf40004bbb40004fbbbbbbbbbbbbbbbfb00000000fbbbbbbbcccccccc9999999949999292f4440440000000000fffff000fffff0000000000
00077000b949292bf44044bbb44044fbbbbbbbbbbbbbbbfb00000000fbbbbbbbcccccccc88888888499229920444044044404440444044404440444000004440
00700700b992992bfb444bbbbb444bfbbbbbbbbbbbbbbbfb00000000fbbbbbbbccccccccbbbbbbbb49999992f004044000000000000000000000000000000000
00000000bb9992bbfbbbbbbbbbbbbbfbbbbbbbbbbbbbbbfb00000000fbbbbbbbccccccccbbbbbbbb49929992f440444040444044404440444044404400004044
00000000bb222bbbfbbbbbbbbbbbbbfbbbbbbbbbbbbbbbfb00000000fbbbbbbbccccccccbbbbbbbb422222220004000400000000000000000000000000000000
0000000000000000c0000000000000000000000c088888800000000008888880cccccccc000ccccc444000004ffffff0bbb99bbbbbbb777777779bbbbbbbbbbb
0000000000000000088899999889999998888990888f1fff08888880888f1fffccccc0007770cccc00000000f4ffff00bbb99bbbbbbbb77733379bbbbbbbbbbb
00000000000000000888988999998899998899804f4ff440888f1fff4f4ff440cccc077777770ccc40440000ff444400bbb99bbbbbbbbb7773779bbbbbbbbbbb
000000000000000008899889999888899999988044ff44004f4ff4404dff44d0ccc0077776770ccc00000000ff444400bbb99bbbbbbbbbb733379bbbbbbbbbbb
00000000000000000999999999988889999998800d8dd8d044ff44000d8dd8d0cc077777776770cc44400000ff444400bbb99bbbbbbbbbbb77779bbbbbb88bbb
00000000000000000998999999988889999998800d8888d00d8dd8d000888800c07766777777770c00000000ff444400bbb99bbbbbbbbbbbb7779bbbbbb88bbb
0000000000000000099999999999889998899980008888000d8888d004888840c07677777777777040440000f0000040bbb99bbbbbbbbbbbbb779bbbbbb00bbb
0000000000000000c0000000000000000000000c00400400008888000000000007777777777777700000000000000004bbb99bbbbbbbbbbbbbb79bbbbbb99bbb
0000000000000000000000000ffffff00ffffff00000000000000000000000007777777777777777000000000000000000000000000000000000000000000000
0000000000000000000000000ffffff00ffffff00000000000000000000000000767776677777677000000000000000000000000000000000000000000000000
0000000000000000000000000ffffff00ffffff00000000000000000000000000776767666766670000000000000000000000000000000000000000000000000
0000000000000000000000000ff44ff00ffffff0000000000000000000000000c077677776667770000000000000000000000000000000000000000000000000
00000000000000000000000004f4f4f00ffffff0000000000000000000000000c07777707777700c000000000000000000000000000000000000000000000000
0000000000000000000000000f4fff400ffffff0000000000000000000000000cc07770c07770ccc000000000000000000000000000000000000000000000000
0000000000000000000000000ffffff00ffffff0000000000000000000000000ccc000ccc000cccc000000000000000000000000000000000000000000000000
0000000000000000000000000ffffff00ffffff0000000000000000000000000cccccccccccccccc000000000000000000000000000000000000000000000000
__label__
ccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaccccccccccccccccaaaaaaaacccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc88888888888888888888888888888888cccccccccccccccc88888888cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc90099009900990099009900990099009cccccccccccccccc90099009cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc99999999999999999999999999999999cccccccccccccccc99999999cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc88888888888888888888888888888888cccccccccccccccc88888888cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000cccccccccccccccc00000000cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000cccccccccccccccc00000000cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000cccccccccccccccc00000000cccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaacccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc88888888cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc90099009cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc99999999cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc88888888cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc66fffffffffffffffffff600cccccccccccccccccccccccccccccccc66fffffffffffffffffff660cccccccccccccccccccccccccccccccc
cccccccccccccccc0f4440600600606000444f00cccccccccccccccccccccccccccccccc6f4440006000600000444f00cccccccccccccccccccccccccccccccc
ccccccccccccccccf440446006006660644044f0ccccccccccccccccccccccccccccccccf440440060006600044044f0cccccccccccccccccccccccccccccccc
ccccccccccccccccf400646006000060040004f0ccccccccccccccccccccccccccccccccf400640060006000040064f0cccccccccccccccccccccccccccccccc
ccccccccccccccccf440446066600060044044f0ccccccccccccccccccccccccccccccccf440440066606660044044f0cccccccccccccccccccccccccccccccc
ccccccccccccccccf044400000000000004440f0ccccccccccccccccccccccccccccccccf044400000000000004440f0cccccccccccccccccccccccccccccccc
ccccccccccccccccf000000000000000000000f0ccccccccccccccccccccccccccccccccf000000000000000000000f0cccccccccccccccccccccccccccccccc
ccccccccccccccccf000000000000000000000f0ccccccccccccccccccccccccccccccccf000000000000000000000f0cccccccccccccccccccccccccccccccc
ccccccccccccccccf0000000cccccccc000000f0cccccccccccccccc00999200ccccccccaaaaaaaaaaaaaaaaaaaaaaaacccccccccccccccccccccccccccccccc
ccccccccccccccccf0000000cccccccc000000f0cccccccccccccccc09949920cccccccc888888888888888888888888cccccccccccccccccccccccccccccccc
ccccccccccccccccf0000000cccccccc000000f0cccccccccccccccc09492920cccccccc900990099009900990099009cccccccccccccccccccccccccccccccc
ccccccccccccccccf0000000cccccccc000000f0cccccccccccccccc09492920cccccccc999999999999999999999999cccccccccccccccccccccccccccccccc
ccccccccccccccccf0006060cccccccc666000f0cccccccccccccccc69492920cccccccc888888888888888888888888cccccccccccccccccccccccccccccccc
ccccccccccccccccf0006060cccccccc606000f0cccccccccccccccc69929920cccccccc000000000000000000000000cccccccccccccccccccccccccccccccc
ccccccccccccccccf0006660cccccccc666000f0cccccccccccccccc66999200cccccccc000000000000000000000000cccccccccccccccccccccccccccccccc
ccccccccccccccccf0006060cccccccc600000f0cccccccccccccccc60222000cccccccc000000000000000000000000cccccccccccccccccccccccccccccccc
ccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaacccccccccccccccccccccccc66999200cccccccc00999200cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc888888888888888888888888cccccccccccccccccccccccc09949920cccccccc09949920cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc900990099009900990099009cccccccccccccccccccccccc09492920cccccccc09492920cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc999999999999999999999999cccccccccccccccccccccccc09492920cccccccc09492920cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc888888888888888888888888cccccccccccccccccccccccc09492920cccccccc09492920cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc000000000000000000000000cccccccccccccccccccccccc09929920cccccccc09929920cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc000000000000000000000000cccccccccccccccccccccccc00999200cccccccc00999200cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc000000000000000000000000cccccccccccccccccccccccc00222000cccccccc00222000cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaa8888888ccccccccccccccccaaaaaaaacccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc888888888888888888888888888f1fffcccccccccccccccc88888888cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc9999999999999009900999994f4ff449cccccccccccccccc90999009cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc99999999999999999999999944ff4499cccccccccccccccc99999999cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc8888888888888888888888888d8dd8d8cccccccccccccccc88888888cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc9090909090009000000009000d8888d0cccccccccccccccc90900000cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc90909990999099900000999099888800cccccccccccccccc90900000cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccc00000000000000000000000000400400cccccccccccccccc00000000cccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaacccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc88888888cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc90099a09cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc99999999cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc88888888cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66000660cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc60606000cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc70fffffffffffffffffff000cccccccccccccccccccccccccccccccc00fffffffffffffffffff000cccccccccccccccccccccccccccccccc
cccccccccccccccc0f4440000000000000444f00cccccccccccccccccccccccccccccccc0f4440000000000000444f00cccccccccccccccccccccccccccccccc
ccccccccccccccccf440440000000000044044f0ccccccccccccccccccccccccccccccccf440440000000000044044f0cccccccccccccccccccccccccccccccc
ccccccccccccccccf400040000000000040004f0ccccccccccccccccccccccccccccccccf400040000000000040004f0cccccccccccccccccccccccccccccccc
ccccccccccccccccf440440000000000044044f0ccccccccccccccccccccccccccccccccf440440000000000044044f0cccccccccccccccccccccccccccccccc
ccccccccccccccccf044400000000000004440f0ccccccccccccccccccccccccccccccccf044400000000000004440f0cccccccccccccccccccccccccccccccc
ccccccccccccccccf000000000000000000000f0ccccccccccccccccccccccccccccccccf000000000000000000000f0cccccccccccccccccccccccccccccccc
ccccccccccccccccf000000000000000000000f0ccccccccccccccccccccccccccccccccf000000000000000000000f0cccccccccccccccccccccccccccccccc
ccccccccccccccccf0000000cccccccc000000f0cccccccccccccccc00999200ccccccccaaaaaaaaaaaaaaaaaaaaaaaacccccccccccccccccccccccccccccccc
ccccccccccccccccf0000000cccccccc000000f0cccccccccccccccc09949920cccccccc888888888888888888888888cccccccccccccccccccccccccccccccc
ccccccccccccccccf0000000cccccccc000000f0cccccccccccccccc09492920cccccccc900990099009900990099009cccccccccccccccccccccccccccccccc
ccccccccccccccccf0000000cccccccc000000f0cccccccccccccccc09492920cccccccc999999999999999999999999cccccccccccccccccccccccccccccccc
ccccccccccccccccf0000000cccccccc000000f0cccccccccccccccc09492920cccccccc888888888888888888888888cccccccccccccccccccccccccccccccc
ccccccccccccccccf0000000cccccccc000000f0cccccccccccccccc09929920cccccccc000000000000000000000000cccccccccccccccccccccccccccccccc
ccccccccccccccccf0000000cccccccc000000f0cccccccccccccccc00999200cccccccc000000000000000000000000cccccccccccccccccccccccccccccccc
ccccccccccccccccf0000000cccccccc000000f0cccccccccccccccc00222000cccccccc000000000000000000000000cccccccccccccccccccccccccccccccc
ccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaacccccccccccccccccccccccc00999200cccccccc00999200cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc888888888888888888888888cccccccccccccccccccccccc09949920cccccccc09949920cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc900990099009900990099009cccccccccccccccccccccccc09492920cccccccc09492920cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc999999999999999999999999cccccccccccccccccccccccc09492920cccccccc09492920cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc888888888888888888888888cccccccccccccccccccccccc09492920cccccccc09492920cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc000000000000000000000000cccccccccccccccccccccccc09929920cccccccc09929920cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc000000000000000000000000cccccccccccccccccccccccc00999200cccccccc00999200cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc000000000000000000000000cccccccccccccccccccccccc00222000cccccccc00222000cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

__gff__
0000000000000000000101010000000000000101010000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808
0808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808
08080818190808080808080808080808080808080808080808080808080808080808080808080a0808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808
0808082829080808080808080808080808080808080808080808080808080808080808080808080808080808020404040404040308080808080808080818190808080808080808080808080802040404040404040308080802040404040308080808080204040404040403080808080808080808080808080808080808080808
0808080808080808080808080808080808080808080808080808080808080808080808080808080808080808070818190808080501080808080808080828290808121314080808080808080807080808080808080508080807080808080508080808080708080808080805080808080808080808080808080808080808080808
0808080808080808080808080808080808080808080808080808121314080808080808080808080808080808070828290808080508080808080808080808080808082308080808080808080807080808080808080508080807080808080508080808080708080808080805080808080808080808080808080808080808080808
0808080808080808080808080808010101080808080808080808082308080808080812131313140808080809090908080808080508080808080909090808080808082408081213131314080909090808080808080508080909090808080508080808090909080808080805080808080808080808080808080808080808080808
0808080808080808080808080812131313140808080808080808082408080808080818192408080808080808080808080808080508090909080808080808010101082408080808230808080808080808080808080508080808080808080508080808080808080808080805080808080808080808080808080808080808080808
0808080808080818190808080808082308080808080808080808082408080808080828292408080808080801080808080808080508080808080808080808121314082408080808240808080808080808080808080508080808080808080508080808080808080808080805080808080808121314080808080808080808080818
0808080808080828290808080808082408080808080808080808082408081819080808082408080808080808080812131408090909080808080808080808082308082408080808240808080808081819080808080508080808080808080508080808080808080808080805080808080808082308080808080808080808080828
0d0d0d0d08080808080808080808082408080101010101080808082408082829080808082408081213140808080808230808080808080808080808080808082408082408010808240808080808082829080808080508080808080808080508080808080808080808080805080801010101012408080808080808080808080808
0c0c0c0c08080808080808080808082408121313131313140808082408080808080808082408080823080808080808240808080808080808080808080808082408082412131408240808080808080812131408090909080808080808090909080808080808080808090909090812131313142408080808080808080808081213
0c1a0f0c08080808080808080808082408080808230808080808082408080808080101012408080824080808080808240808080808080808080808080808082408082408240808241908080808080808230808080808080808080808080808080808080808121314080808080808082308082408080808080808080808080808
0c1a0f0c08080808080808080808082408080808240808181908082408080812131313131314080824080808080808240808080808080808080808080808082408082408240808242908080808080808240808080808080808080808080808121314080808082308080808080808082408082408081213131313131408080808
0b0b0b0b0b0b0b0b080812131313142408080808240808282908082408080808080823082408080824080808080808240808080808080808080808081213131314082408240808240808080808080808240808080808080808080808080808082308080808082408080808080808082408082408080808082308080808080808
0b0b0b0b0b0b0b0b080808082308082408080808240808080808082408080808080824082408080824080808080808240808080808080808080808080808232408082408240808240808080808080808240808080808080808080808080808082408080808082408080808080808082408082408080808082408080808080808
0808080808080808080808080808080808080808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002222222222220000000000000000000000
0808080808080808080808080808080808080808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808080808080808080808080808080808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808080808080808080808080808081f08080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08080808080808080808080808080808081d1e08080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808080808080808080808080808081c08080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808080808080808080909090808081c08080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808080808080808181908080808081c08080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808080818190808282908080808081c08080d0d0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808080828290808080808080808081c080d0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808080808080808080808080808081c080c0c0c0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808081213131314080808080808081c080c1a2b0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808080808230808080808080808081c080c1a2b0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1313131408080808240808080808080808081b080c1a2b0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
23080808080808082408080808080808080b0b0b0b0b0b0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
24080808080808082408080808080808080b0b0b0b0b0b0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
