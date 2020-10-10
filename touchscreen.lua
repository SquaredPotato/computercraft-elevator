require("disk/level") -- Levels, protocol string
require("here")    -- Who are we, sides

---- globals
lhostname = levels[here].name
hitboxHeight = 3
currentLevel = here
contacterPositive = false -- If signal from contactor is inverted

-- colors
bgColor = colors.black
barColor = colors.gray
textColor = colors.blue
currentColor = colors.green
hitColorOne = colors.cyan
hitColorTwo = colors.blue
hitActive = colors.orange

---- setup
-- rednet
rednet.open(modemSide)

-- monitor
-- http://www.computercraft.info/forums2/index.php?/topic/21363-multiple-monitors-one-computer/
monitors = {peripheral.find("monitor")}  -- "find" needs CC 1.6 or later

local multiTerm = {}
for funcName,_ in pairs(monitors[1]) do
    multiTerm[funcName] = function(...)
        for i=1,#monitors-1 do monitors[i][funcName](unpack(arg)) end
        return monitors[#monitors][funcName](unpack(arg))
    end
end

term.redirect(multiTerm)
term.clear()
term.setCursorPos(1,1)

width, height = term.getSize()

-- hitbox
hitbox = {
    xMin = 1,
    xMax = 1,
    yMin = 1,
    yMax = 1,
    name = ""
}

function hitbox:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function hitbox:hit(x, y)
    if x >= self.xMin and x <= self.xMax then
        if y >= self.yMin and y <= self.yMax then
            return true
        end
    end
    return false
end

hitboxes = {}

-- utilities
function clearScreen()
    term.setBackgroundColor(bgColor)
    for i = 1, height do
        term.setCursorPos(1, i)
        for j = 1, width do
            term.write(" ")
        end
    end
end

function fillBox(color, xMin, xMax, yMin, yMax)
    term.setBackgroundColor(color)
    for i = yMin, yMax do
        term.setCursorPos(xMin, i)
        for j = xMin, xMax do
             term.write(" ")
        end
    end
end

function drawBar(text)
    fillBox(barColor, 1, width, 1, 1)
    local center = math.ceil((width / 2) - (string.len(text) / 2) + 1)
    term.setCursorPos(center, 1)
    term.write(text)
end

function drawHitboxes()
    for i = 1, table.getn(hitboxes) do
        color = colors.black
        if math.floor(i % 2) > 0 then
            color = hitColorOne
        else
            color = hitColorTwo
        end
        if levels[i].active then
            color = hitActive
        elseif i == currentLevel then
            color = currentColor
        end
        fillBox(color, hitboxes[i].xMin,
                        hitboxes[i].xMax,
                        hitboxes[i].yMin,
                        hitboxes[i].yMax)
        
        -- Background color already correct from fillBox
        local y = hitboxes[i].yMax - ((hitboxes[i].yMax - hitboxes[i].yMin) / 2)
        term.setCursorPos(2,y)
        term.write(hitboxes[i].name)       
    end
end

function generateHitboxes()
    local y = 2
    for i = 1, table.getn(levels) do
        hitboxes[i] = hitbox:new{
            xMin = 1,
            xMax = width,
            yMin = y,
            yMax = y + hitboxHeight - 1,
            name = levels[i].name
        }
        y = y + hitboxHeight
    end
end

-- Unfortunately no threads, so interrupts may be long
function waitForEvent()
    local type, a, b, c = os.pullEvent()
	
	if type == "redstone" then
		rednet.broadcast("pst"..tostring(here), protocol)
		currentLevel = here
    elseif type == "monitor_touch" then
        for i = 1, table.getn(hitboxes) do
            if hitboxes[i]:hit(b, c) then
                levels[i].active = not levels[i].active
                local opcode = ""
                if levels[i].active == true then
                    opcode = "act"
                else
                    opcode = "dct"
                end
                rednet.broadcast(opcode..tostring(i),protocol)
            end
        end
    elseif type == "rednet_message" and c == protocol then
        opcode = string.sub(b, 1, 3)
        if opcode == "act" then
            levels[tonumber(string.sub(b,4))].active = true
        elseif opcode == "dct" then
            levels[tonumber(string.sub(b,4))].active = false
        elseif opcode == "pst" then
            currentLevel = tonumber(string.sub(b, 4))
        end
    end
end

-- main
function main()
    clearScreen()
    drawBar(lhostname)
    generateHitboxes()
    drawHitboxes()
    while true do
        waitForEvent()
        drawHitboxes()
    end 
end

main()
