
display.setStatusBar(display.HiddenStatusBar)

_W, _H = display.contentWidth, display.contentHeight


system.activate("multitouch")

local mChar = require("mChar")
local mWorld = require("mWorld")
local mJoystick = require("mJoystick")
local hBeats = require ("heartBeats")

function main()
    game = display.newGroup()
        
    function movePlayerAndMap(e)
        local xVal = e.joyX
        local yVal = e.joyY
        local xMove
        local yMove
        xVal = xVal or 0
        xMove = xVal * game.speed
        yVal = yVal or 0
        yMove = yVal * game.speed
        
        --blocking movement past edge
        local xMin = 0
        local xMax = game.world.worldData.width
        local yMin = 0
        local yMax = game.world.worldData.height
        local xPlayer = game.char.xPosInWorld + _W * .5
        local yPlayer = game.char.yPosInWorld + _H * .5
        if (xPlayer > xMax and xMove > 0 ) or (xPlayer < xMin and xMove < 0 ) then
            xMove = 0
        end
        if (yPlayer > yMax and yMove > 0 ) or (yPlayer < yMin and yMove < 0 ) then
            yMove = 0
        end
        --print(xPlayer, yPlayer)
                
        game.char:shiftLocation({xMove, yMove})
        
        if e.joyAngle ~= false then
            
            -- rotate char
            game.char.rotation = e.joyAngle
            
            -- calculate dist from center to touch
            local dist = ((math.abs(e.joyX * 10))^2) + ((math.abs(e.joyY * 10))^2)
            
            -- make arrow to reinforce interaction
            --game.arrow.alpha = 0--.1
            --game.arrow.rotation = e.joyAngle
            --game.arrow.yScale = dist * .005
        else
            --game.arrow.alpha = 0
        end

        game.world:centerOnChar()
		
		rescueSpacemen()
        
    end
        
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
        --print ("chan: "..chan)
        --print ("vol:  "..vol)
        --print "---"
        audio.setVolume(vol, {channel = chan})
    end
    
    function game:initialize()
        
        -- game params
        self.speed = 10
        self.listenX = 0
        self.listenY = 0    
        
        
        -- game display objects
        
        --local arrow = display.newImageRect("images/arrow.png", 100, 400)
        --arrow:setReferencePoint(display.BottomCenterReferencePoint)
        --arrow.alpha = 0
        --arrow.x, arrow.y = _W * .5, _H * .5
        --self:insert(arrow)
        --self.arrow = arrow
        
        local laser = makeLaser()
        self:insert(laser)
        self.laser = laser
    
        local char = mChar.makeChar()
        self:insert(char)
        self.char = char
        
        self.musicStream= audio.loadStream("jupiter.mp3")
        
    end
    
    function game:unloadWorld()
        if self.world then
            self.world:removeSelf()
            self.world = nil
        end
        if self.UI then
            self.UI:removeSelf()
            self.UI = nil
        end
    end
    
    function game:loadWorld()
        local world = mWorld.makeWorld()
        self:insert(world)
        self.world = world
        
        local UI = makeUI()
        self:insert(UI)
        self.UI = UI
        
        local joystick = mJoystick.newJoystick(
            {
                outerImage = "images/joystickOuter.png",		
                outerAlpha = .01,
                innerImage = "images/joystickInner.png",		
                innerAlpha = .01,						
                position_x = _W * .5,						
                position_y = _H * .5,						
                onMove = movePlayerAndMap
            })
            
        joystick.xScale = 3
        joystick.yScale = 3
        joystick.x = joystick.x - joystick.contentWidth * .5
        joystick.y = joystick.y - joystick.contentWidth * .5
        self:insert(joystick)
        self.joystick = joystick
        
        self.char:setLocation({5000,5000})
        
    end
    
    function game:start()
        self:addListeners()
        self.joystick.joystickStart()
        -- start timer
        game.startTime = (system.getTimer())
        game.timeElapsed = timer.performWithDelay(1000, function() updateTime(self.UI.timeRemainingText) end, -1)
    end
    
    function game:stop(endState)
        audio.stop()
        self.joystick.joystickStop()
        self:showMenu(endState)
        timer.cancel(self.timeElapsed)
    end
    
    function game:showMenu(menuType)
        local menu = makeMenu(menuType)
        game:insert(menu)
        game.menu = menu
        audio.stop()
		audio.reserveChannels(30)
        
        --if type(musicStream) ~= "nil" then
           -- musicStream = nil
        --end
        -- audio track
        --if type(musicStream) == "nil" then
            
        --end
        audio.setVolume(.4, {channel = 32})		
        audio.play(self.musicStream, {loops = -1, fadeIn = 50000, channel = 32})
        --print("music started")
        
    end
    
    function gameLoop()
        
        -- if listening has been switched on, listen
        if game.isListening == true then
            local xDiff = game.listenX - game.char.x
            local yDiff = game.listenY - game.char.y
            game.listenAngle = math.ceil(math.atan2((yDiff), (xDiff)) * 180 / math.pi)
            game.laser.rotation = game.listenAngle
            listen(game.listenAngle + 90)
        end
        
    end
    
    function game:addListeners()
        Runtime:addEventListener("enterFrame", gameLoop)
        Runtime:addEventListener("touch", toggleListening)
    end
    
    function game:removeListeners()
        Runtime:removeEventListener("enterFrame", gameLoop)
        Runtime:removeEventListener("touch", toggleListening)
    end

	function rescueSpacemen()
		local xdiff = 0
		local ydiff = 0
		--print("spacemen: "..game.world.worldData.numSpacemen, "Rescued: "..game.world.worldData.numSpacemenCollected)
		
		for i = 1, #game.world.worldData.spacemen do
			xdiff = math.abs(game.char.xPosInWorld + (_W * .5) - game.world.worldData.spacemen[i].xVal)
			ydiff = math.abs(game.char.yPosInWorld + (_H * .5) - game.world.worldData.spacemen[i].yVal)
			if xdiff < 40 and ydiff < 40 then
				if game.world.worldData.spacemen[i].isRescued == false then
					game.world.grpSpacemen[i].isVisible = false
					game.world.worldData.spacemen[i].isRescued = true
					audio.play(game.world.worldData.sounds[2])
					game.world.worldData.numSpacemenCollected = game.world.worldData.numSpacemenCollected + 1
					game.UI.smCollectedText.text = game.world.worldData.numSpacemenCollected.."/"..game.world.worldData.numSpacemen					
					--print("Rescued: "..game.world.worldData.numSpacemenCollected)
					--print("Rescue at", xdiff, ydiff)
					
                    -- check for end condition
                    if game.world.worldData.numSpacemenCollected >= game.world.worldData.numSpacemen then
                        game:stop("success")
                    end
                    
				else
					--print("Already rescued")
				end
			else
				----print(0, 0)
			end
		end
	end
    
    game:initialize()
    game:showMenu("initial")
    
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

function makeUI()
    local UI = display.newGroup()
    
    local smCollected = display.newImageRect("images/spaceman.png", 44, 64)
    UI:insert(smCollected)
    UI.smCollected = smCollected
    smCollected.x, smCollected.y = _W - 120, 150
    
    local numSmCollected = game.world.worldData.numSpacemenCollected
    local numSmTotal = game.world.worldData.numSpacemen
    local smCollectedText = display.newText(numSmCollected.."/"..numSmTotal, 0, 0, nil, 24)
	smCollectedText.x, smCollectedText.y = smCollected.x + 60, smCollected.y - 20
    UI:insert(smCollectedText)
    UI.smCollectedText = smCollectedText
    
    local timeRemaining = getFormattedTime(math.floor(game.world.worldData.timeLimit/1000))
    local timeRemainingText = display.newText(timeRemaining, 0, 0, nil, 24)
    timeRemainingText.x, timeRemainingText.y = smCollected.x + 60, smCollected.y + 20
    UI:insert(timeRemainingText)
    UI.timeRemainingText = timeRemainingText
        
    return UI
end


function updateTime(txtObj)
    local timeInSeconds = getTimeInSeconds()
    txtObj.text = getFormattedTime(timeInSeconds)
    if game.world.worldData.timeLimit > 0 then
        if timeInSeconds <= 0 then
            game:stop("failure")
        elseif timeInSeconds < math.floor(game.world.worldData.timeLimit / 1000) then
            --check if pitch needs to be raised
            if( timeInSeconds % game.world.worldData.timeCheckFrequency == 0) then
                raiseSpacemenPitches()
            end
        end
        
        if timeInSeconds == game.world.worldData.ambientFadeout then
            --fixme: breaks music after 1st play
            audio.fadeOut({time = game.world.worldData.ambientFadeout * 1000, channel = 32})
        end
    end
end

function getTimeInSeconds()
    local timeElapsed = 0
    local timeLimit = 0
    timeElapsed = math.floor((system.getTimer() - game.startTime)/1000)
    timeLimit = math.floor(game.world.worldData.timeLimit / 1000)
    if timeLimit > 0 then
        timeElapsed = timeLimit - timeElapsed
    end
    return(timeElapsed)    
end

function getFormattedTime(numSeconds)
    local numMins = math.floor(numSeconds / 60)
    local rSec = numSeconds % 60
    if rSec <= 9 then
        rSec = "0"..rSec
    end
    return numMins..":"..rSec    
end


function raiseSpacemenPitches()
    local timePercent = (getTimeInSeconds() * 1000) / game.world.worldData.timeLimit
    local newPitch = game.world.worldData.initialPitch + (game.world.worldData.maxPitchRaise * (1 - timePercent))
    --print(timePercent)
    --print(newPitch)
    setSpacemenPitches(newPitch)
end

function setSpacemenPitches(newPitch)
    for i=1,game.world.worldData.numSpacemen do
        if type(game.world.worldData.spacemen[i].soundSource) ~= nil then
            al.Source(game.world.worldData.spacemen[i].soundSource, al.PITCH, newPitch )
        else
            --print("NIL SOUND SOURCE")
        end
    end
end

function makeMenu(menuType)
    local MEN = display.newGroup()
    local endText = ""
    local startText = ""
    
    
    local bg = display.newRect(0,0,_W,_H)
    MEN:insert(bg)
    MEN.bg = bg
    bg:setFillColor(250,250,250)
    bg.alpha = .5
    
    function bg:touch(e)
        return true
    end
    
    bg:addEventListener("touch", bg)
    
    if menuType == "initial" then
        startText = "START >"
        endText = "SAVE US!"
        
    elseif menuType == "success" then
        startText = "AGAIN? >"
        endText = "SUCCESS!"
        
    elseif menuType == "failure" then
        startText = "RETRY? >"
        endText = "OUT OF TIME!"
    end


    local txtBegin = display.newText(startText, 0, 0, native.systemFontBold, 120)
    MEN:insert(txtBegin)
    MEN.txtBegin = txtBegin
    txtBegin.x, txtBegin.y = _W * .75 - 50, 600
    
    function txtBegin:touch(e)
        if e.phase == "began" then
            e.target.parent.parent:unloadWorld()
            e.target.parent.parent:loadWorld()
            e.target.parent.parent:start()
            e.target.parent:removeSelf()
        end
        return true
    end
    
    txtBegin:addEventListener("touch", txtBegin)
    
    local txtGameOver = display.newText(endText, 0, 0, native.systemFontBold, 120)
    MEN:insert(txtGameOver)
    MEN.txtGameOver = txtGameOver
    txtGameOver.x, txtGameOver.y = _W * .5, 200
    
    return MEN
end

main()