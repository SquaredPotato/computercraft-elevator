require("disk/level") -- Level class, protocol string

elActSide = "right"
elDirSide = "back"

currentLevel = 1
direction = -1 -- -1: up, 1: down

getOnTime = 3 -- seconds to get on if another floor is active

lhostname = "server"

rednet.open("top")
rednet.host(protocol, lhostname)

moveAllowed = true
timer = 0

function initialize ()
    redstone.setOutput(elActSide, true)

    for i = 1, table.getn(levels) do
        levels[i].id = rednet.lookup(protocol, levels[i].hostname)
        print("Found hostname ", levels[i].hostname, " on id ", levels[i].id)
    end
end

function waitForEvent()
    local type, a, b, c = os.pullEvent()
    
    if type == "rednet_message" and c == protocol then
        local opcode = string.sub(b, 1, 3)
        local where = tonumber(string.sub(b,4))
        print(opcode..":"..tostring(where))
        if opcode == "act" then
            levels[tonumber(string.sub(b,4))].active = true
        elseif opcode == "dct" then
            levels[tonumber(string.sub(b,4))].active = false
        elseif opcode == "pst" then
            print("new pst: "..string.sub(b,4))
            currentLevel = tonumber(string.sub(b,4))
        else
            print(opcode)
        end
    elseif type == "timer" and a == timer then
        moveAllowed = true
    end
end

function moveOrNot(direction)
    if direction > 0 then
        for i = currentLevel, table.getn(levels), 1 do
            if levels[i].active == true then
                return true
            end
        end
    else
        for i = currentLevel, 1, -1 do
            if levels[i].active == true then
                return true
            end
        end
    end
    return false 
end

function setElevator(move, direction)
    if direction < 0 then
        redstone.setOutput(elDirSide, true)
    else
        redstone.setOutput(elDirSide, false)
    end
    redstone.setOutput(elActSide, not move)
end

function elevatorUpdate()
    for i = 1, table.getn(levels) do
        -- Arrived at an active level
        if i == currentLevel and levels[i].active == true then
            levels[i].active = false
            rednet.broadcast("dct"..tostring(i), protocol)
            redstone.setOutput(elActSide, true)
            moveAllowed = false
            timer = os.startTimer(getOnTime)
        -- Checking levels in both directions
        elseif moveAllowed then
            moved = false
            if moveOrNot(direction) then
                print("Moving in "..tostring(direction))
                setElevator(true, direction)
                moved = true
            else
                if direction < 0 then
                    direction = 1
                else
                    direction = -1
                end
                if moveOrNot(direction) then
                    print("Moving in "..tostring(direction))
                    setElevator(true, direction)
                    moved = true
                end
            end
            if not moved then
                setElevator(false, 0)
            end
        end 
    end 
end

function main()
    initialize()
    while true do
        waitForEvent()
        elevatorUpdate()
    end
end

main()
