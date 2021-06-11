pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--variables

function _init()
	 player={
		sp=1,
		x=8,     y=16,
		h=8,      w=8, --in pixels
		flp=false,
		dx=0,     dy=0,
		max_dx=2, max_dy=3,
		acc=0.5,  boost=4,
		anim_speed=0.1,
		next_anim_time=time(),
		jumping=false,
		falling=false
 }
 
 egg={
  sp=17,
  x=player.x, y=player.y-8,
  h=8, w=8,
  dx=0, dy=0,
  max_dx=2, max_dy=3,
  anim=0
 }
 
 --physics
 friction=0.85
 gravity=0.3
 
 --meta
 carrying_egg=true
 level_num=0
 lives_left=6
 
end
-->8
--update and draw

function _update()
	player_update()
	egg_update()
end

function _draw()
 cls()
	map(0,0)
	player_draw()
	egg_draw()
	ui_draw()
end

function player_draw()
 
 if player.jumping then
 	player.sp=5
 
 elseif player.falling then
 	player.sp=6
 
 --idle no egg=head bob!
 elseif abs(player.dx)<0.1 
 and not carrying_egg then
	 if time()>player.next_anim_time then
	 	player.sp+=1
	 	if player.sp>4 then
	 	 player.sp=1
	 	end
	 	player.next_anim_time=time()+player.anim_speed
	 end 
	
	--moving (egg or no egg)
	elseif abs(player.dx)>0.1 then
	 if time()>player.next_anim_time then
	 	player.sp+=1
	 	if player.sp>3 then
	 	 player.sp=1
	 	end
	 	player.next_anim_time=time()+player.anim_speed
	 end 
	 
	--idle with egg
	else
	 player.sp=1
	end
 
 local flipped=player.dx<0
 
 spr(player.sp,player.x,
  player.y,1,1,flipped)
 
end

function egg_draw()
	spr(egg.sp,egg.x,egg.y)
end

function ui_draw()

 spr(52,75,0)

 local str_lives="x"..lives_left
 print(str_lives,66,1,0)
 print(str_lives,67,2,7)

 local str_lvl="level "..level_num
 print(str_lvl,84,1,0)
 print(str_lvl,85,2,7)
end
-->8
--player functions

function player_update()
	--physics
	player.dy+=gravity
	player.dx*=friction
 
 --⬅️➡️ controls
 if btn(⬅️) then
  player.dx-=player.acc
 elseif btn(➡️) then
  player.dx+=player.acc
 end
 
 --⬆️ jump
 if btnp(⬆️) and player.landed then
  player.landed=false
  if carrying_egg then
   player.dy-=player.boost*0.7
  else
   player.dy-=player.boost
  end
 end
 
 --🅾️ interact
 if btnp(🅾️) then
 	
 	if carrying_egg then
	 	carrying_egg=false
	 	--todo add throw
	 elseif egg_nearby() then
	 	carrying_egg=true
		end
 end
 
 --map collision below
 if player.dy>0 then 
  player.falling=true
  player.landed=false
  player.jumping=false
  
  player.dy=limit_speed(player.dy,player.max_dy)
  
  if collide_map(player,"down",0) then  
   player.landed=true
   player.falling=false  
   player.dy=0
   player.y-=(player.y+player.h)%8
  end
 end
 
 --map collision above
 if player.dy<0 then 
 	player.falling=false
 	player.jumping=true
 	
 	player.dy=limit_speed(player.dy,player.max_dy)
  
  if collide_map(player,"up",1) then    
   player.dy=0
  end
 end
 
 --map collision/friction left/right
 if player.dx<0 then 
 	player.dx=limit_speed(player.dx,player.max_dx)
  if collide_map(player,"left",0) then    
   player.x+=0
   player.dx=0
  end
 end
 
 if player.dx>0 then 
 	player.dx=limit_speed(player.dx,player.max_dx)
  if collide_map(player,"right",0) then    
   player.x-=0
   player.dx=0
  end
 end
 
 --apply
 player.x+=player.dx
 player.y+=player.dy

end

function limit_speed(num,maximum)
 return mid(-maximum,num,maximum)
end

function egg_nearby()
	
	local xdif=abs(egg.x-player.x)
	local ydif=abs(egg.y-player.y)
	
	if xdif<8 and ydif<8 then
		return true
	else
		return false
	end
end
-->8
--egg functions

function egg_update()
 if carrying_egg then
	 
	 --map collision/friction left/right
	 if player.dx<0 then 
	 	egg.dx=limit_speed(egg.dx,egg.max_dx)
	  egg.dx+=friction
	  if collide_map(egg,"left",0) then    	   
	   egg.dx=0
	   player.dx=0 --blocks player
	   player.x+=0.5
	  end
	 end
	 
	 if player.dx>0 then 
	 	egg.dx=limit_speed(egg.dx,egg.max_dx)
	  egg.dx-=friction
	  if collide_map(egg,"right",0) then    	   
	   egg.dx=0
	   player.dx=0 --blocks player
	   player.x-=0.5
	  end
	 end
	 
	 egg.dx=0
	 egg.dy=0
	 egg.x=player.x
	 egg.y=player.y-8 
	 
	--else not carrying egg
	else 
	 egg.dy+=gravity	
	 
		--map collision below
	 if egg.dy>0 then 
	  egg.dy=limit_speed(egg.dy,egg.max_dy)
	  if collide_map(egg,"down",0) then    
	   egg.dy=0
	   egg.y-=(egg.y+egg.h)%8
	  end
	 end
	 
	 --map collision above
	 if egg.dy<0 then 
	 	egg.dy=limit_speed(egg.dy,egg.max_dy)
	  if collide_map(egg,"up",1) then    
	   egg.dy=0
	  end
	 end
	 
	 --map collision/friction left/right
	 if egg.dx<0 then 
	 	egg.dx=limit_speed(egg.dx,egg.max_dx)
	  if collide_map(egg,"left",0) then    
	   egg.x+=0
	   egg.dx=0
	  end
	 end
	 
	 if egg.dx>0 then 
	 	egg.dx=limit_speed(egg.dx,egg.max_dx)
	  if collide_map(egg,"right",0) then    
	   egg.x-=0
	   egg.dx=0
	  end
	 end

	 --apply
	 egg.x+=egg.dx
	 egg.y+=egg.dy
	
	end
	
end

-->8
--collisions

function collide_map(obj,dir,flag)
	--obj=table needs x,y,w,h
	--dir=up,down,left,right
 
 --unpack
 local x=obj.x local y=obj.y
 local w=obj.w local h=obj.h
 
 --make hitbox on side of dir
 local x1 local x2
 local y1 local y2
 if dir=="left" then
  x1=x-1   y1=y
  x2=x     y2=y+h-1
 elseif dir=="right" then
  x1=x+w-1 y1=y
  x2=x+w   y2=y+h-1
 elseif dir=="up" then
  x1=x     y1=y-3
  x2=x+w-1 y2=y-2
 elseif dir=="down" then
  x1=x     y1=y+h-1
  x2=x+w-1 y2= y+h
 end
 
 rectfill(x1,y1,x2,y2,7)

 --pixels to tiles
 x1/=8 y1/=8
 x2/=8 y2/=8
 
 --check all 4 sides, get tile and check flag comp
 if fget(mget(x1,y1),flag)
 or fget(mget(x1,y2),flag)
 or fget(mget(x2,y1),flag)
 or fget(mget(x2,y2),flag) then
  return true
 else
   return false
 end
end

--todo: remove??
function collide_object(obj,others)
  
 for o in all(others) do
 	--get bounding box of other obj
 	local oth_x=o.x   local oth_y=o.y
 	--local o_x2=o.x+w local o_y2=o.y+y
 	local oth_w=o.w    local oth_h=o.h
 	
 	--get obj values
  local x1=obj.x local y1=obj.y
  local x2=obj.x+obj.w
  local y2=obj.y+obj.h
 	local w=abs(x1-x2)
 	local h=abs(y1-y2)
 	
 	--calc collision vals
 	local xs=w/2+oth_w/2
 	local ys=h/2+oth_h/2
 	local xd=abs((x1+w/2)-(oth_x+oth_w/2))
 	local yd=abs((y1+h/2)-(oth_y+oth_h/2))
 	
 	--check collision
 	if xd<xs and yd<ys then
 	 return true
 	else
 	 return false
 	end
 	
 end
end
__gfx__
00000000000087000008700000080000000000000000070000087000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000075990007599000077000000087000008759900075990000000000000000000000000000000000000000000000000000000000000000000000000
00700700000077800007780000075990000075990000778000077800000000000000000000000000000000000000000000000000000000000000000000000000
00077000700777707007777070077800700777800007777070077770000000000000000000000000000000000000000000000000000000000000000000000000
00077000077776700777767007777670077776700777767007777670000000000000000000000000000000000000000000000000000000000000000000000000
00700700076667000766670007666770076667007766670007666700000000000000000000000000000000000000000000000000000000000000000000000000
00000000007770000077700000777700007770000077700000777000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000900000009000000090000000900000090000000090000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000f7000000f7000000f7000000f7000000f700000a00000000000000000000000000000000777600000000000000000000000000000000000000000
0000000000ff770000ff770000ff770000ff7700009f77000a00f0a0a0a0000a0000000000000000007aa7700000000000000000000000000000000000000000
0000000000fff700005ff700005ff700005ff700005ff7000059f700005af00000a0f0000000f00007aaa9760000000000000000000000000000000000000000
0000000004ff7f7004ff7f7004f5757004f5757004f5757004f5a57000f9af0000faff0a00faff0007aaa9760000000000000000000000000000000000000000
000000000ffff7700ffff7700ffff7700f5f57700f5f57700f5f57f00f5af7f0a059a7f0005aa7f0077997760000000000000000000000000000000000000000
0000000004ffff7004ffff7004ffff7004ffff7004fff57004fff57744ff5f770ffaaf700ff9af70077777600000000000000000000000000000000000000000
00000000004fff00004fff00004fff00004fff00004fff00004fff77004ff5774f4fa5774f4fa577006666000000000000000000000000000000000000000000
00000000044444400444444000000000000f70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000004000040040f70400000000000ff77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000004000000440ff77040000808000fff7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000004000000440fff7040000080004ff7f700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555555555555555558085555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000454545454545454545454545454545450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000045454500454545004545450045454500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004545000045450000454500004545000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055555555555555555555550000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055555555555555555555555500f770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055555555555555555555555500ff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005555555555555555555555550fff77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055555555555555555555555504fff7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055555555555555555555550004ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005555555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000cccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000
000000000cc6ccccccc6ccc6cc66ccccc6ccccccccccccccc6ccccc0000000000000000000000000000000000000000000000000000000000000000000000000
00000000cc676c6666676c6766776c66676c66cccc6666cc676c66cc000000000000000000000000000000000000000000000000000000000000000000000000
00000000c6777677777776717717767777767766667777667776776c000000000000000000000000000000000000000000000000000000000000000000000000
00000000667117111111171111111771111771777711176711177176000000000000000000000000000000000000000000000000000000000000000000000000
0000000067111711d11117111d1117111d171111111111711d111176000000000000000000000000000000000000000000000000000000000000000000000000
00000000671111d11111d111111111d111111d111111d17111111d76000000000000000000000000000000000000000000000000000000000000000000000000
00000000671d111111111111111d1111111111111111111111111176000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001111111111111111777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000111d11111d111111777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001111111111111511777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001111111111111111777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000111111d111111111777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001511111111111111777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000011111111111d1111777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001111111111111111777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030303030303000000000000000000000003030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4100000000000000313232323232330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0041000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0042424200000000000000000042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004200000000000000420042420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0042000000420000004200420042420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0042004200000042004200420042420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424243434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000005300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000001105000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
