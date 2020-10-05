rednet.open("back")
rednet.host("elevator", "Ground Floor")

local mon = peripheral.wrap("top")
mon.write("hello")

while (true) do
    id,message = rednet.receive("elevator", 200)
    print(message)
    rednet.send(id, "reply", "elevator")
end
