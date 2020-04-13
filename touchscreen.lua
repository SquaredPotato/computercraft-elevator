require("disk/level") -- Levels, protocol string
require("here")    -- Who are we, sides

---- globals
lhostname = levels[here].hostname
hitboxHeight = 3

-- colors
bgColor = colors.black
barColor = colors.gray
textColor = colors.blue
hitColorOne = colors.cyan
hitColorTwo = colors.blue
hitActive = colors.orange

---- setup
-- rednet
rednet.open(modemSide)
rednet.host(protocol, lhostname)

-- monitor
monitor = peripheral.wrap(monitorSide)
width, height = monitor.getSize()

print("Monitor size (x,y): "..tostring(width)..","..tostring(height))

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
    monitor.setBackgroundColor(bgColor)
    for i = 1, height do
        monitor.setCursorPos(1, i)
        for j = 1, width do
            monitor.write(" ")
        end
    end
end

function fillBox(color, xMin, xMax, yMin, yMax)
    monitor.setBackgroundColor(color)
    for i = yMin, yMax do
        monitor.setCursorPos(xMin, i)
        for j = xMin, xMax do
             monitor.write(" ")
        end
    end
end

function drawBar(text)
    fillBox(barColor, 1, width, 1, 1)
    local center = math.ceil((width / 2) - (string.len(text) / 2) + 1)
    monitor.setCursorPos(center, 1)
    monitor.write(text)
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
        end
        fillBox(color, hitboxes[i].xMin,
                        hitboxes[i].xMax,
                        hitboxes[i].yMin,
                        hitboxes[i].yMax)
        
        -- Background color already correct from fillBox
        local y = hitboxes[i].yMax - ((hitboxes[i].yMax - hitboxes[i].yMin) / 2)
        monitor.setCursorPos(2,y)
        monitor.write(hitboxes[i].name)       
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
            name = levels[i].hostname
        }
        y = y + hitboxHeight
    end
end

-- Unfortunately no threads, so interrupts may be long
function waitForEvent()
    local type, a, b, c = os.pullEvent()
 
    if type == "monitor_touch" then
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
    elseif type == "redstone" then
        if redstone.getInput(contactSide) then
            print("its here")
            rednet.broadcast("pst"..tostring(here), protocol)
        end
    elseif type == "rednet_message" and c == protocol then
        opcode = string.sub(b, 1, 3)
        print(opcode)
        if opcode == "act" then
            print("act")
            levels[tonumber(string.sub(b,4))].active = true
        elseif opcode == "dct" then
            print("dct")
            levels[tonumber(string.sub(b,4))].active = false
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