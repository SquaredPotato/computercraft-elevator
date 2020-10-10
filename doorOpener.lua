require("level") -- Levels, protocol string
require("../here")    -- Who are we, sides

---- globals
currentLevel = here
gearShiftSide = doorGearshiftSignalSide -- From here.lua
-- invertedGearshiftSignal imported from here.lua 

---- setup
-- rednet
rednet.open(modemSide)

---- Functional part
-- listen for elevator level updates
function waitForEvent()
	local type, a, b, c = os.pullEvent()
	
	if type == "rednet_message" and c == protocol then
		opcode = string.sub(b, 1, 3)
		local l = tonumber(string.sub(b,4))
		
		print(opcode)
		if opcode == "dop" and l == here then
			if invertedGearshiftSignal then
				redstone.setOutput(gearShiftSide, false)
			else
				redstone.setOutput(gearShiftSide, true)
			end
		elseif opcode == "dcl" and l == here then
			if invertedGearshiftSignal then
				redstone.setOutput(gearShiftSide, true)
			else
				redstone.setOutput(gearShiftSide, false)
			end
		end
	end
end

function main()
	while true do
		waitForEvent()
	end
end

main()
