
local statelist = {
    ["left"] = rs.getInput("left"),
    ["right"] = rs.getInput("right")
}

while true do
    print("waiting for button")
    os.pullEvent("redstone")
    
    for side, state in pairs(statelist) do
        currentState = rs.getInput(side)
        if currentState ~= state then
            if currentState then
                print(side.." is detected")
            end
            statelist[side] = rs.getInput(side)
        end
    end
end   
