module(..., package.seeall)

 _W, _H = display.contentWidth, display.contentHeight 
 function checkHB(spacemen,worldX,worldY,touchX,touchY)

local function getAngle(newX,newY,oldX,oldY)
     deltax= newX-oldX
       deltay= newY-(oldY)
       angle= math.ceil(math.atan2( (deltay), (deltax) ) * 180 / math.pi) + 90
    if (angle<0) then angle =360+angle end
   
return angle
end

local touchAngle= getAngle(touchX,touchY,_W/2,_H/2)


for i = 1, (#spacemen) do

    local angle= getAngle(spacemen[i].xVal,spacemen[i].yVal,worldX,worldY)
    local deltaA = math.abs(angle-touchAngle)
    local tWorldX=spacemen[i].xVal-worldX
    local tWorldY= spacemen[i].yVal-worldY
  local distance= math.ceil(math.sqrt((tWorldX*tWorldX )+(tWorldY*tWorldY)))
   local v = (math.ceil(100*((1/(distance/1000)) * ( (1/ (deltaA/4) )))))/100
    if (v>1) then v=1 end
    if (v<.1) then v=0 end
    --print (i.." angle  "..angle.." distance "..distance)
  if (spacemen[i].isRescued ) then  spacemen[i].volume=0 else  spacemen[i].volume=v  end
  
     --print (i.." Volume "..spacemen[i].volume)
     game:setChannelVolume(i, spacemen[i].volume)


end



end

