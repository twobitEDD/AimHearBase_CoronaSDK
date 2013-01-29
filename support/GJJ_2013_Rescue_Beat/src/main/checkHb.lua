module(..., package.seeall)

 _W, _H = display.contentWidth, display.contentHeight 
 function checkHB(worldX,worldY,touchX,touchY)
  
local function getAngle(newX,newY,oldX,oldY)
     deltax= newX-oldX
       deltay= newY-(oldY)
       angle= math.ceil(math.atan2( (deltay), (deltax) ) * 180 / math.pi) + 90
    if (angle<0) then angle =360+angle end
   
return angle
end

local touchAngle= getAngle(touchX,touchY,_W/2,_H/2)


for i = 1, (#game.world.worldData.spacemen) do

    local angle= getAngle(game.world.worldData.spacemen[i].xVal,game.world.worldData.spacemen[i].yVal,worldX,worldY)
    local deltaA = math.abs(game.world.worldData.spacemen[i].angle-touchAngle)
    local tWorldX=game.world.worldData.spacemen[i].xVal-worldX
    local tWorldY= game.world.worldData.spacemen[i].yVal-worldY
  local distance= math.ceil(math.sqrt((tWorldX*tWorldX )+(tWorldY*tWorldY)))
   local v = (math.ceil(100*((1/(distance/1000)) * ( (1/ (deltaA/4) )))))/100
    if (v>1) then v=1 end
    if (v<.1) then v=0 end
    game.world.worldData.spacemen[i].volume= v
     if game.world.worldData.spacemen[i].volume>0.09 then
     --if loud enough to be heard
     --print (i.." Volume "..game.world.worldData.spacemen[i].volume)
     print "yo"
     print (i)
     print (v)
     game:setVolume(i, v)
     end

end



end

