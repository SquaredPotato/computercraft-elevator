local monitors = {peripheral.find("monitor")}

local multiTerm = {}
for funcName,_ in pairs(monitors[1]) do
    multiTerm[funcName] = function(...)
        for i=1,#monitors-1 do monitors[i][funcName](unpack(arg)) end
        return monitors[#monitors][funcName](unpack(arg))
    end
end

term.redirect(multiTerm)

x, y = term.getSize()

while true do
    event, side, xPos, yPos = os.pullEvent("monitor_touch")
    print(event .. " => Side: " .. tostring(side) .. ", " ..
    "X: " .. tostring(xPos) .. ", " ..
    "Y: " .. tostring(yPos) .. ", " .. 
    "Xs: " .. tostring(x) .. ", " ..
    "Ys: " .. tostring(y)
    )
end

print("Hello world!")
