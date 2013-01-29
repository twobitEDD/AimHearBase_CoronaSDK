

display.setStatusBar(display.HiddenStatusBar)

_W, _H = display.contentWidth, display.contentHeight


system.activate("multitouch")

local mChar = require("mChar")
local mWorld = require("mWorld")
local mJoystick = require("mJoystick")
local hBeats = require ("heartBeats")

function main()
    game = display.newGroup()
        
    -- game params
    game.speed = 20
    game.listenX = 0
    game.listenY = 0    
    
    -- game display objects
    local world = mWorld.makeWorld()
    game:insert(world)
    game.world = world
    
    local arrow = display.newImageRect("images/arrow.png", 100, 400)
    arrow:setReferencePoint(display.BottomCenterReferencePoint)
    arrow.alpha = 0
    arrow.x, arrow.y = _W * .5, _H * .5
    game:insert(arrow)
    game.arrow = arrow
    
    local laser = makeLaser()
    game:insert(laser)
    game.laser = laser

    local char = mChar.makeChar()
    game:insert(char)
    game.char = char
    
    -- text terminal
    local grpTerminal = display.newGroup()
    game:insert(grpTerminal)
    game.grpTerminal = grpTerminal
    local termA = display.newText("x", 200, 50, nil, 24)
    local termB = display.newText("x", 200, 80, nil, 24)
    local termC = display.newText("x", 200, 110, nil, 24)
    local termD = display.newText("x", 200, 140, nil, 24)
    grpTerminal:insert(termA)
    grpTerminal:insert(termB)
    grpTerminal:insert(termC)
    grpTerminal:insert(termD)
    grpTerminal.termA = termA
    grpTerminal.termB = termB
    grpTerminal.termC = termC
    grpTerminal.termD = termD
    
    function movePlayerAndMap(e)
        local xVal = e.joyX
        local yVal = e.joyY
        local xMove
        local yMove
        if type(xVal) == "number" then
            xMove = xVal * game.speed
        else
            xMove = 0
        end
        if type(yVal) == "number" then
            yMove = yVal * game.speed
        else
            yMove = 0
        end
        
        game.char:moveTo({xMove, yMove})
        
        if e.joyAngle ~= false then
            
            -- rotate char
            game.char.rotation = e.joyAngle
            
            -- calculate dist from center to touch
            local dist = ((math.abs(e.joyX * 10))^2) + ((math.abs(e.joyY * 10))^2)
            
            -- make arrow to reinforce interaction
            game.arrow.alpha = 0--.1
            game.arrow.rotation = e.joyAngle
            game.arrow.yScale = dist * .005
        else
            game.arrow.alpha = 0
        end

        game.world:centerOnChar()
		
		rescueSpacemen()
        
    end
    
    local joystick = mJoystick.newJoystick(
        {
            outerImage = "images/joystickOuter.png",		
            outerAlpha = 0.01,
            innerImage = "images/joystickInner.png",		
            innerAlpha = 0.01,						
            position_x = _W * .5,						
            position_y = _H * .5,						
            onMove = movePlayerAndMap
        })
        
    joystick.xScale = 3
    joystick.yScale = 3
    joystick.x = joystick.x - joystick.contentWidth * .5
    joystick.y = joystick.y - joystick.contentWidth * .5
    
    --joystick.joystickStop()
    --joystick.joystickStart()
    
    game:insert(joystick)
    game.joystick = joystick
    
    function toggleListening(e)
        
        -- toggle listening so game loop knows whether to listen
        if e.phase == "began" then
            game.isListening = true
            game.laser.isVisible = true
            
            -- turn on listenable channels
            
        elseif e.phase == "ended" then
            game.isListening = false
            game.laser.isVisible = false
            
            -- turn off listenable channels
            for i = 1, 30 do
                audio.setVolume(0, {channel = i})
            end
        end
        
        -- give the game an x and y value to calculate listening angle
        game.listenX = e.x
        game.listenY = e.y
        
    end
    
    
    function listen(angle)
        
        -- display and blink laser
        game.laser:blink()
        
        -- compare that angle to the angles of other objects in the world to determine which objects are in range.
       hBeats.checkHB(game.world.worldData.spacemen, game.char.xPosInWorld + _W * .5,game.char.yPosInWorld + _H * .5, game.listenX, game.listenY )
         
        -- insert in-range objects (and their corresponding angle differences) into a table
        
        
        -- crawl the table, setting the channel volume for each channel to correspond to the angle differences
        
        
        -- play all sounds in the table on their respective channels
        
    end
    
    function game:setChannelVolume(chan, vol)
        print ("chan: "..chan)
        print ("vol:  "..vol)
        print "---"
        audio.setVolume(vol, {channel = chan})
    end
    
    function gameLoop()
        game.grpTerminal.termA.text = ""--"x pos of char in world: "..math.floor(game.char.xPosInWorld)
        game.grpTerminal.termB.text = ""--"y pos of char in world: "..math.floor(game.char.yPosInWorld)
        game.grpTerminal.termC.text = ""--"listening at angle to "..game.listenX..", "..game.listenY
        game.grpTerminal.termD.text = ""--math.floor(game.world.y)
        
        -- if listening has been switched on, listen
        if game.isListening == true then
            local xDiff = game.listenX - game.char.x
            local yDiff = game.listenY - game.char.y
            game.listenAngle = math.ceil(math.atan2((yDiff), (xDiff)) * 180 / math.pi)
            game.laser.rotation = game.listenAngle
            listen(game.listenAngle + 90)
        end
        
    end
    
    Runtime:addEventListener("enterFrame", gameLoop)
    Runtime:addEventListener("touch", toggleListening)

	function rescueSpacemen()
		local xdiff = 0
		local ydiff = 0
		print("spacemen: "..#game.world.worldData.spacemen, "Rescued: "..game.world.worldData.numSpacemenCollected)
		
		for i = 1, #game.world.worldData.spacemen do
			xdiff = math.abs(game.char.xPosInWorld + (_W * .5) - game.world.worldData.spacemen[i].xVal)
			ydiff = math.abs(game.char.yPosInWorld + (_H * .5) - game.world.worldData.spacemen[i].yVal)
			if xdiff < 40 and ydiff < 40 then
				if game.world.worldData.spacemen[i].isRescued == false then
					game.world.grpSpacemen[i].isVisible = false
					game.world.worldData.spacemen[i].isRescued = true
					audio.play(game.world.worldData.sounds[2])
					game.world.worldData.numSpacemenCollected = game.world.worldData.numSpacemenCollected + 1
					print("Rescued: "..game.world.worldData.numSpacemenCollected)
					--update interface?
					print("Rescue at", xdiff, ydiff)
				else
					print("Already rescued")
				end
			else
				--print(0, 0)
			end
		end
	end

    
end

function makeLaser()
    local LSR = display.newGroup()
    
    for i = 1, 40 do
        local line = display.newLine(15 * (i - 1), 0, 15 * i, 0)
        LSR:insert(line)
        line:setColor(math.random(255), 0, 0)
        line.width = 2
    end
        
    function LSR:blink()
        for i = 1, self.numChildren do
            LSR[i]:setColor(math.random(255), 0, 0)
        end
    end
    
    LSR.x, LSR.y = _W * .5, _H * .5
    LSR.isVisible = false
    
    return LSR
end

main()