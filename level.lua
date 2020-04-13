protocol = "elevator"

level = {
    hostname = "",
    y = 1,
    id = 1,
    active = false
}

function level:new(o)
    o = o or {}
    setmetatable(o, __self)
    self.__index = self
    return o
end

levels = {
    level:new{
        hostname="Ground Floor",
        y=71,
        id=0,
    },
    level:new{
        hostname="Basement",
        y=61,
        id=0
    },
    level:new{
        hostname="Mines",
        y=10,
        id=0
    }
    
}    
