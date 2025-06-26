-- quid
-- Ratchanon Suwatsiriphol

--!native
--!optimize 2

--[=[
	@class quid
	A suitable uid for representing entity uniqueness. While providing version-detectability, k-sortability and human-readability
]=]

-- [Base64url](https://base64.guru/standards/base64url)
-- [RFC 4648](https://datatracker.ietf.org/doc/html/rfc4648)

-- stylua: ignore
local BASE_64_URL_CHARACTER = {
	"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
	"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
	"0","1","2","3","4","5","6","7","8","9", "-", "_"
}

-- stylua: ignore
local BASE_64_URL_VALUE_MAP = {} do
	for i, character in ipairs(BASE_64_URL_CHARACTER) do
		BASE_64_URL_VALUE_MAP[character] = i - 1
	end
end

local MAX_SAFE_INTEGER = 9007199254740991
local MASK_NORMALIZED_U32 = 4294967295 -- 2^32 - 1

--[=[
	@class Config
	A configuration object for quid generation
]=]
local DEFAULT_CONFIG = {}

--- Version state
---
--- @prop version number
--- @within Config
DEFAULT_CONFIG.version = game.PlaceVersion

--- Fingerprint state
---
--- @prop fingerprint string
--- @within Config
DEFAULT_CONFIG.fingerprint = `{game.GameId}:{game.PlaceId}:{game.JobId}`

--- Internal state used for entropy generation
---
--- @prop _counter number
--- @within Config
--- @private
DEFAULT_CONFIG._counter = 0

--- A factory function for produce unix-timestamp in milliseconds as a integer.
---
--- :::tip
--- You can overwrite this, implement your own clock function.
--- :::
---
--- @function clock
--- @within Config
--- @return number -- A unix-timestamp in milliseconds as a integer.
DEFAULT_CONFIG.clock = function()
	return (workspace:GetServerTimeNow() * 1000) // 1
end

--- A factory function for produce random number between [0, 1]
---
--- :::tip
--- You can overwrite this, implement your own entropy function.
--- :::
---
--- @function entropy
--- @within Config
--- @param version number
--- @param timestamp number
--- @param fingerprint string
--- @param counter number
--- @return number -- A random number between [0, 1]
DEFAULT_CONFIG.entropy = function(version: number, timestamp: number, fingerprint: string, counter: number)
	-- With math.random (Weak entropy)
	return math.random()

	-- -- With sha256 (Strong entropy)
	-- local sha256 = require(game.ReplicatedStorage.Packages.sha256) :: any -- [sha256](https://github.com/Dekkonot/luau-hashing/tree/main/modules/sha256)
	-- local _, digest_block = sha256(`{version}-{timestamp}-{fingerprint}-{counter}`)
	-- local noise_u32 = 0
	-- for i = 1, #digest_block do
	-- 	noise_u32 = bit32.bxor(noise_u32, digest_block[i])
	-- end
	-- return noise_u32 / MASK_NORMALIZED_U32 -- Normalized noise_u32 to be a number between [0, 1]
end

type Config = typeof(DEFAULT_CONFIG)

-- Bucket cache for generating quid improve performance
-- 4 bytes: Version (Padding: 4)
-- 8 bytes: Timestamp (Padding: 8)
-- 12 bytes: Uniqueness (Padding: 12)
local cache_quid = table.create(4 + 8 + 12)

local function decode(integer_base: string): number
	local integer = 0
	local length = #BASE_64_URL_CHARACTER
	local base = integer_base

	for i = 1, #base do
		local c = string.sub(base, i, i)
		local val = BASE_64_URL_VALUE_MAP[c]
		integer = integer * length + val
	end

	return integer
end

local function generate(config: Config, version: number?, timestamp: number?)
	local length = #BASE_64_URL_CHARACTER
	local version = version or config.version
	local timestamp = timestamp or config.clock()

	-- Version (Padding: 4)
	local version_state = version
	for i = 4, 1, -1 do
		local remainder = (version_state % length) // 1
		version_state = version_state // length
		cache_quid[i] = BASE_64_URL_CHARACTER[remainder + 1]
	end

	-- Timestamp (Padding: 8)
	local timestamp_state = timestamp
	for i = 12, 5, -1 do
		local remainder = (timestamp_state % length) // 1
		timestamp_state = timestamp_state // length
		cache_quid[i] = BASE_64_URL_CHARACTER[remainder + 1]
	end

	-- Uniqueness (Padding: 12)
	config._counter %= MAX_SAFE_INTEGER
	for i = 24, 13, -1 do
		-- pointer: [0, #BASE_64_URL_CHARACTER]
		local pointer = (
			#BASE_64_URL_CHARACTER
			* config.entropy(config.version, timestamp, config.fingerprint, config._counter) -- noise: [0, 1]
			// 1
		) + 1
		cache_quid[i] = BASE_64_URL_CHARACTER[pointer]
	end

	local quid = table.concat(cache_quid)
	table.clear(cache_quid)
	config._counter += 1

	return quid
end

local quid = { config = DEFAULT_CONFIG }
quid.__index = quid

--- Generate a new quid with global config state
---
--- @within quid
--- @param version number?
--- @param timestamp number?
--- @return string -- quid
function quid.next(version: number?, timestamp: number?)
	return generate(DEFAULT_CONFIG, version, timestamp)
end

--- Parse a quid string into its components
---
--- @within quid
--- @param quid string
--- @return number -- version
--- @return number -- timestamp
--- @return number -- uniqueness
function quid.parse(quid: string)
	local version = string.sub(quid, 1, 4)
	local timestamp = string.sub(quid, 5, 12)
	local uniqueness = string.sub(quid, 13, 28)

	-- stylua: ignore
	return
		decode(version), 
		decode(timestamp),
		decode(uniqueness)
end

--- Check if x is a valid quid
---
--- @within quid
--- @param x any | string?
--- @return boolean
function quid.is(x: any | string?): boolean
	-- stylua: ignore
	return 
		type(x) == "string" and 
		string.find(x, "^[A-Za-z0-9%-_]+$") ~= nil and
		#x == 28
end

--- Create a new quid instance with custom config state
---
--- @within quid
--- @param config_state Config?
--- @return quid
function quid.new(config_state: Config?)
	local self = setmetatable({}, quid)
	self.config = config_state or DEFAULT_CONFIG
	return self
end

--- Generate a new quid with local config state
---
--- @within quid
--- @param version number?
--- @param timestamp number?
--- @return string -- quid
function quid:Next(version: number?, timestamp: number?)
	return generate(self.config, version, timestamp)
end

return quid
