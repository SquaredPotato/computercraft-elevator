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
        hostname="Sea Level",
        y=72,
        id=0,
    },
    level:new{
        hostname="Floor 1",
        y=61,
        id=0
    }    
}    
