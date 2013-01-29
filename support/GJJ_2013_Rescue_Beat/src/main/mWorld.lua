module(...,package.seeall)

--local _W, _H = display

function makeWorld()
    local WLD = display.newGroup()
    WLD.x, WLD.y = _W * .5, _H * .5
    
    --local bg = display.newRect(0, 0, _W, _H)
    --bg:setFillColor(100,200,100)
    --WLD:insert(bg)
    --WLD.bg = bg
    
    WLD.worldData = {
        bricks = {}
    }
    
    function WLD:generateNewWorldData()
        local worldData = {
            width = 10000,
            height = 10000,
            --xRef = 10000,
            --yRef = 10000,
            numBricks = 2000,
            numSpacemen = 10,
            numSpacemenCollected = 0,
            bricks = {},
            spacemen = {},
            timeLimit = 90000, --ms
            timeCheckFrequency = 1, --s
            initialPitch = 0.8,
            maxPitchRaise = 1.0,
            ambientFadeout = 5, --s
            
            -- load audio system
            sounds = {audio.loadSound("spaceman.wav"), audio.loadSound("collect.wav")}
        }
        
        -- generate random block positions throughout the world
        for i = 1, worldData.numBricks do
            worldData.bricks[i] = {}
            worldData.bricks[i].xVal = math.random(worldData.width)
            worldData.bricks[i].yVal = math.random(worldData.height)
        end
        for i = 1, worldData.numSpacemen do
            local sm = {}
            sm.xVal = math.random(worldData.width)
            sm.yVal = math.random(worldData.height)
            sm.timeRemaining = 100 --note: in future, vary lifespans?
            --playtesting case below
            --[[
            if i == 1 then
                sm.xVal, sm.yVal = 5000, 5000
            end
            --]]
            
            sm.isRescued = false
            timer.performWithDelay(math.random(2000), function()
                sm.soundChannel, sm.soundSource = audio.play(worldData.sounds[1], {channel = i, loops = -1})
                --print("soundSource type: "..type(sm.soundSource))
                if type(sm.soundSource) ~= nil then
                    al.Source(sm.soundSource, al.PITCH, worldData.initialPitch ) --note: make this pitch variation function more elegant
                end
                audio.setVolume(0, {channel = i})
            end)
            
            worldData.spacemen[i] = sm

            --print (i.." Spaceman X Y "..sm.xVal.."  "..sm.yVal)
            
            
        end
        
        self.worldData = worldData
        
    end
    
    local grpSpacemen = display.newGroup()
    WLD:insert(grpSpacemen)
    WLD.grpSpacemen = grpSpacemen
    
    function WLD:display()
        for i = 1, self.worldData.numBricks do
            local bData = self.worldData.bricks[i]
            local brick = display.newImageRect("images/stars_"..math.random(9)..".png", 32, 32)
            --local brick = display.newCircle(0, 0, math.random(10))
            brick.id = "brick"
            --brick:setFillColor(math.random(200,255), math.random(200,255), math.random(200,255))
            brick.alpha = .7
            self:insert(brick)
            brick.x, brick.y = bData.xVal, bData.yVal
        end
        for i = 1, self.worldData.numSpacemen do
            local sData = self.worldData.spacemen[i]
            local spaceman = display.newImageRect("images/spaceman.png", 44, 64)
            spaceman.id = "spaceman"
            self.grpSpacemen:insert(spaceman)
            spaceman.x, spaceman.y = sData.xVal, sData.yVal
        end
    end

    
    function WLD:centerOnChar()
        self.x = self.parent.char.xPosInWorld * -1
        self.y = self.parent.char.yPosInWorld * -1
    end
    
    WLD:generateNewWorldData()
    WLD:display()
    
    return WLD
end