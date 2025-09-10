-- for whatever reason, i cant just use require for modchart scripts and be all fine and happy, so this is inserted in every modchart script (along with being wrapped around onCreate() end)

-- things that shold be percents
print('hi', players)
local modRemap = {}
local customMods = {}
local percentFriends = {'invert', 'flip', 'beatx', 'beaty', 'pulse'}

local allPlayers = {}
for i=1,(players or 2) do
	table.insert(allPlayers, i)
end

for i=0,3 do
	-- percent friends that have a data input of 0-3
	for _,v in pairs{'reverse'} do
		table.insert(percentFriends, v..i)
	end
end

local function miniScale(v)
	return 1 - (0.5*(v/100))
end

modRemap.tiny = function(percent)
	return 'mini', miniScale(percent)
end
modRemap.beatz = function(percent)
	return 'beatz', percent / 1000
end
for _,v in pairs{'X', 'Y', 'Z'} do
	modRemap['tiny'..v:lower()] = function(percent)
		return 'mini'..v, miniScale(percent)
	end
	modRemap['rotation'..v:lower()] = function(percent)
		return 'localrotate'..v, percent / 100
	end
end


for _,v in pairs(percentFriends) do
	modRemap[v] = function(percent) 
		return v, percent / 100
	end
end


function table.contains(t, v, k)
	for k,vv in pairs(t) do
		if k and v[k] == vv[k] or v == vv then
			return true
		end
	end
end

local sqrt = math.sqrt

local sin = math.sin

local asin = math.asin

local cos = math.cos

local pow = math.pow

local exp = math.exp

local pi = math.pi

local abs = math.abs



-- ===================================================================== --



-- Utility functions


--- Flip any easing function, making it go from 1 to 0

-- Example use:

-- ```lua

-- ease {0, 20, flip(outQuad), 50, 'modname'}

-- ```

flip = setmetatable({}, {

__call = function(self, fn)

	self[fn] = self[fn] or function(x)

		return 1 - fn(x)

	end

	return self[fn]

end,

})



-- Mix two easing functions together into a new ease

-- the new ease starts by acting like the first argument, and then ends like the second argument

-- Example: ease {0, 20, blendease(inQuad, outQuad), 100, 'modname'}

blendease = setmetatable({}, {

__index = function(self, key)

	self[key] = {}

	return self[key]

end,

__call = function(self, fn1, fn2)

	if not self[fn1][fn2] then

		local transient1 = fn1(1) <= 0.5

		local transient2 = fn2(1) <= 0.5

		if transient1 and not transient2 then

			error("blendease: the first argument is a transient ease, but the second argument doesn't match")

		end

		if transient2 and not transient1 then

			error("blendease: the second argument is a transient ease, but the first argument doesn't match")

		end

		self[fn1][fn2] = function(x)

			local mixFactor = 3 * x ^ 2 - 2 * x ^ 3

			return (1 - mixFactor) * fn1(x) + mixFactor * fn2(x)

		end

	end

	return self[fn1][fn2]

end,

})


-- Declare an easing function taking one custom parameter

function with1param(fn, defaultparam1)
	return function(t)
		return fn(t, defaultparam1)
	end
end

-- Declare an easing function taking two custom parameters

function with2params(fn, defaultparam1, defaultparam2)
	return function(t)
		return fn(t, defaultparam1, defaultparam2)
	end
end



-- ===================================================================== --



-- Easing functions



function bounce(t)

return 4 * t * (1 - t)

end

function tri(t)

return 1 - abs(2 * t - 1)

end

function bell(t)

return inOutQuint(tri(t))

end

function pop(t)

return 3.5 * (1 - t) * (1 - t) * sqrt(t)

end

function tap(t)

return 3.5 * t * t * sqrt(1 - t)

end

function pulse(t)

return t < 0.5 and tap(t * 2) or -pop(t * 2 - 1)

end



function spike(t)

return exp(-10 * abs(2 * t - 1))

end

function inverse(t)

return t * t * (1 - t) * (1 - t) / (0.5 - t)

end



local function popElasticInternal(t, damp, count)

return (1000 ^ -(t ^ damp) - 0.001) * sin(count * pi * t)

end



local function tapElasticInternal(t, damp, count)

return (1000 ^ -((1 - t) ^ damp) - 0.001) * sin(count * pi * (1 - t))

end



local function pulseElasticInternal(t, damp, count)

if t < 0.5 then

	return tapElasticInternal(t * 2, damp, count)

else

	return -popElasticInternal(t * 2 - 1, damp, count)

end

end



popElastic = with2params(popElasticInternal, 1.4, 6)

tapElastic = with2params(tapElasticInternal, 1.4, 6)

pulseElastic = with2params(pulseElasticInternal, 1.4, 6)



impulse = with1param(function(t, damp)

t = t ^ damp

return t * (1000 ^ -t - 0.001) * 18.6

end, 0.9)



function instant()

return 1

end

function linear(t)

return t

end

function inQuad(t)

return t * t

end

function outQuad(t)

return -t * (t - 2)

end

function inOutQuad(t)

t = t * 2

if t < 1 then

	return 0.5 * t ^ 2

else

	return 1 - 0.5 * (2 - t) ^ 2

end

end

function outInQuad(t)
t = t * 2

if t < 1 then

	return 0.5 - 0.5 * (1 - t) ^ 2

else

	return 0.5 + 0.5 * (t - 1) ^ 2

end

end

function inCubic(t)

return t * t * t

end

function outCubic(t)

return 1 - (1 - t) ^ 3

end
function inOutCubic(t)

t = t * 2

if t < 1 then

	return 0.5 * t ^ 3

else

	return 1 - 0.5 * (2 - t) ^ 3

end

end

function outInCubic(t)

t = t * 2

if t < 1 then

	return 0.5 - 0.5 * (1 - t) ^ 3

else

	return 0.5 + 0.5 * (t - 1) ^ 3

end

end

function inQuart(t)

return t * t * t * t

end

function outQuart(t)

return 1 - (1 - t) ^ 4

end

function inOutQuart(t)

t = t * 2

if t < 1 then

	return 0.5 * t ^ 4

else

	return 1 - 0.5 * (2 - t) ^ 4

end

end

function outInQuart(t)

t = t * 2

if t < 1 then

	return 0.5 - 0.5 * (1 - t) ^ 4

else

	return 0.5 + 0.5 * (t - 1) ^ 4

end

end

function inQuint(t)

return t ^ 5

end

function outQuint(t)

return 1 - (1 - t) ^ 5

end

function inOutQuint(t)

t = t * 2

if t < 1 then

	return 0.5 * t ^ 5

else

	return 1 - 0.5 * (2 - t) ^ 5

end

end

function outInQuint(t)

t = t * 2

if t < 1 then

	return 0.5 - 0.5 * (1 - t) ^ 5

else

	return 0.5 + 0.5 * (t - 1) ^ 5

end

end

function inExpo(t)

return 1000 ^ (t - 1) - 0.001

end

function outExpo(t)

return 1.001 - 1000 ^ -t

end

function inOutExpo(t)

t = t * 2

if t < 1 then

	return 0.5 * 1000 ^ (t - 1) - 0.0005

else

	return 1.0005 - 0.5 * 1000 ^ (1 - t)

end

end

function outInExpo(t)

if t < 0.5 then

	return outExpo(t * 2) * 0.5

else

	return inExpo(t * 2 - 1) * 0.5 + 0.5

end

end

function inCirc(t)

return 1 - sqrt(1 - t * t)

end

function outCirc(t)

return sqrt(-t * t + 2 * t)

end

function inOutCirc(t)

t = t * 2

if t < 1 then

	return 0.5 - 0.5 * sqrt(1 - t * t)

else

	t = t - 2

	return 0.5 + 0.5 * sqrt(1 - t * t)

end

end

function outInCirc(t)

if t < 0.5 then

	return outCirc(t * 2) * 0.5

else

	return inCirc(t * 2 - 1) * 0.5 + 0.5

end

end

function outBounce(t)

if t < 1 / 2.75 then

	return 7.5625 * t * t

elseif t < 2 / 2.75 then

	t = t - 1.5 / 2.75

	return 7.5625 * t * t + 0.75

elseif t < 2.5 / 2.75 then

	t = t - 2.25 / 2.75

	return 7.5625 * t * t + 0.9375

else

	t = t - 2.625 / 2.75

	return 7.5625 * t * t + 0.984375

end

end

function inBounce(t)

return 1 - outBounce(1 - t)

end

function inOutBounce(t)

if t < 0.5 then

	return inBounce(t * 2) * 0.5

else

	return outBounce(t * 2 - 1) * 0.5 + 0.5

end

end

function outInBounce(t)

if t < 0.5 then

	return outBounce(t * 2) * 0.5

else

	return inBounce(t * 2 - 1) * 0.5 + 0.5

end

end

function inSine(x)

return 1 - cos(x * (pi * 0.5))

end

function outSine(x)

return sin(x * (pi * 0.5))

end

function inOutSine(x)

return 0.5 - 0.5 * cos(x * pi)

end

function outInSine(t)

if t < 0.5 then

	return outSine(t * 2) * 0.5

else

	return inSine(t * 2 - 1) * 0.5 + 0.5

end

end



function outElasticInternal(t, a, p)

return a * pow(2, -10 * t) * sin((t - p / (2 * pi) * asin(1 / a)) * 2 * pi / p) + 1

end

local function inElasticInternal(t, a, p)

return 1 - outElasticInternal(1 - t, a, p)

end

function inOutElasticInternal(t, a, p)

return t < 0.5 and 0.5 * inElasticInternal(t * 2, a, p) or 0.5 + 0.5 * outElasticInternal(t * 2 - 1, a, p)

end

function outInElasticInternal(t, a, p)

return t < 0.5 and 0.5 * outElasticInternal(t * 2, a, p) or 0.5 + 0.5 * inElasticInternal(t * 2 - 1, a, p)

end



inElastic = with2params(inElasticInternal, 1, 0.3)

outElastic = with2params(outElasticInternal, 1, 0.3)

inOutElastic = with2params(inOutElasticInternal, 1, 0.3)

outInElastic = with2params(outInElasticInternal, 1, 0.3)



function inBackInternal(t, a)

return t * t * (a * t + t - a)

end

function outBackInternal(t, a)

t = t - 1

return t * t * ((a + 1) * t + a) + 1

end

function inOutBackInternal(t, a)

return t < 0.5 and 0.5 * inBackInternal(t * 2, a) or 0.5 + 0.5 * outBackInternal(t * 2 - 1, a)

end

function outInBackInternal(t, a)

return t < 0.5 and 0.5 * outBackInternal(t * 2, a) or 0.5 + 0.5 * inBackInternal(t * 2 - 1, a)

end



inBack = with1param(inBackInternal, 1.70158)

outBack = with1param(outBackInternal, 1.70158)

inOutBack = with1param(inOutBackInternal, 1.70158)

outInBack = with1param(outInBackInternal, 1.70158)

local default_mods = {}

-- converts: nil to {1, 2}, number to {number} ({1, 2} if number is less than 1), and {...} to {...}
local function getPlayers(players)
	local players = players or allPlayers

	if type(players) == 'number' then
		if players <= 0 then
			players = allPlayers
		else
			players = {players}
		end
	end

	return players
end

-- runs a func for each remapped (or not) mod for each player

local function queueFunc(mods, func, players, mult)
	players = getPlayers(players)
	mult = mult or 1

	for i=1,#mods,2 do
		local percent = mods[i]
		local mod = mods[i + 1]
		if type(percent) ~= 'number' or type(mod) ~= 'string' then
			error ('Mixed up bitch? '..tostring(percent)..', '..tostring(mod))
		end
		if modRemap[mod] then
			mod, percent = modRemap[mod](percent)
		end
		for _,player in pairs(players) do
			if not default_mods[player] then
				default_mods[player] = {}
			end
			if not default_mods[player][mod] then
				default_mods[player][mod] = 0
			end
			if customMods[mod] then
				customMods[mod](func, player, percent * mult)
			else
				func(mod, percent * mult, player)
			end
		end
	end

end


function ease(params)
	-- get those vars
	local beat, len, ease_fn = unpack(params)
	if type(beat) ~= 'number' then
		error('[ease] Beat ['..tostring(beat)..'] not a number value')
	elseif type(len) ~= 'number' then
		error('[ease] Length ['..tostring(len)..'] not a numerb value')
	elseif type(ease_fn) ~= 'function' then
		error('[ease] Ease ['..tostring(ease_fn)..'] not a function value')
	end
	-- remove them from the table
	for i=1,3 do table.remove(params, 1) end
	queueFunc(params, function(mod, percent, player)
		queueEase(beat, beat + len, mod, percent, player, ease_fn)
	end, params.plr)
end



function set(params)
	-- get the beat from the table and also remove it
	local beat = table.remove(params, 1)
	if type(beat) ~= 'number' then
		error('[set] Beat ['..tostring(beat)..'] not a number value')
	end
	queueFunc(params, function(mod, percent, player)
		queueSet(beat, mod, percent, player)
	end, params.plr)
end



function add(params)
	-- get the beat from the table and also remove it
	local beat = table.remove(params, 1)
	queueFunc(params, function(mod, percent, player)
		queueAdd(beat, mod, percent, player)
	end, params.plr)
end



function func(params)
	queueFuncEvent(params[1], params[2])
end



function lerp(from,to,i)return from+(to-from)*i end
function func_ease(params)
	error 'i didnt finish this yet'
	--local func = table.remove(params)
	--queueFuncEase(params[1], params[1] + params[2], function(p)
	--	func(lerp((params[3] and params[4]) and params[3] or 0, (params[3] and not params[4]) and params[3] or params[4] or 1, p))
	--end)
end



-- currently doesnt have multiple mods and stuff
function definemod(params)
	local mod = table.remove(params, 1)
	customMods[mod] = function(func, players, percent)
		queueFunc(params, func, players, percent / 100)
	end
	--if type(params[#params]) == 'string' then
	--	--local modFunc = table.remove(params, 1)
	--	--customMods[mod] = function(func, player)
	--	--	local results = modFunc()
	--	--end
	--end
end



function alias(mod1, mod2)
	modRemap[mod1] = function(p)
		return mod2, p
	end
end



function setdefault(params)
	for i=1,#params,2 do
		default_mods[params[i + 1]] = params[i]
	end
end


--local function spew(t)
--	local str = '['
--	for k,v in pairs(t) do
--		str = str..', '..tostring(k)..' => '..tostring(v)
--	end
--	return str..']'
--end

function reset(params)
	local players = getPlayers(params.plr)

	for _,player in pairs(players) do
		for mod,percent in pairs(default_mods[player]) do
			if not params.exclude or not table.contains(params.exclude, mod) then
				set {params[1], percent, mod, plr = player}
			end
		end
	end
end

function makeType(args, defaults)
	return function(...)
		local t = {}
		local a = {...}
		for i,v in pairs(args) do
			t[v] = a[i] or defaults and defaults[i] or nil
		end
		return t
	end
end

local swagWidth = 160 * 0.7
local THIRD = 1/3

local offsetMult = {-1.5, -.5, .5, 1.5}
local function centerOffset(i, offset)
	return offset * offsetMult[i + 1]
end

local function splitOffset(i, offset)
	return i > 1 and offset or -offset
end

local reverseOffsetMult = {-.5, -1.5, 1.5, .5}
local function reverseCenterOffset(i, offset)
	return offset * reverseOffsetMult[i + 1]
end

local function stepped(steps)
	return function(t)
		return math.floor(t * steps) / steps
	end
end

local function steppedEase(ease, steps)
	local stepped = stepped(steps)
	return function(t)
		return stepped(ease(t))
	end
end