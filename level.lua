protocol = "elevator"

level = {
    name="",
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

-------- WARNING ------
-- These are order sensitive, floors are drawn
-- on the touchscreens as they are in this list.
-- Not only that, but it is also used to 
-- determine the elevator direction.
-------- WARNING ------
levels = {
    level:new{
        name="Sea Level",
        y=72,
        id=0,
    },
    level:new{
        name="Floor 1",
        y=48,
        id=0
    }
}
