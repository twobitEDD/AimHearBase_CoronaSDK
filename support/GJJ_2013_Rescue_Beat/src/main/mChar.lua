module(...,package.seeall)

--local _W, _H = display

function makeChar()
    local CHR = display.newImageRect("images/ship.png", 350 * .25, 393 * .25)
    CHR.id = "char"
    CHR.x, CHR.y = _W * .5, _H * .5
        
    function CHR:shiftLocation(params)
        
        self.xPosInWorld = self.xPosInWorld + params[1]
        self.yPosInWorld = self.yPosInWorld + params[2]
        
    end
    
    function CHR:setLocation(params)
        self.xPosInWorld = params[1]
        self.yPosInWorld = params[2]
    end
    
    CHR:setLocation({5000,5000})
    
    return CHR
end