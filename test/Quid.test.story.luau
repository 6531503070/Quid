local Quid = require(game.ReplicatedStorage.Packages.Quid)
local sha256 = require(game.ReplicatedStorage.Packages.sha256) -- [sha256](https://github.com/Dekkonot/luau-hashing/tree/main/modules/sha256)

local sample = "AAPRAZevi03RU3c8oVW2ScKSK-Uh"
assert(Quid.is(sample) == true, "Quid.is(sample), sample is a valid quid, base64url and 28 characters")

local version, timestamp, uniqueness = Quid.parse(sample)
assert(version == 977, "Version of sample quid does not match (should be 977)")
assert(timestamp == 1750996831697, "Timestamp of sample quid does not match (should be 1750996831697)")

local MASK_NORMALIZED_U32 = 4294967295 -- 2^32 - 1
local get_server_time_now = workspace.GetServerTimeNow

-- Immutable config (Simulate)
local quid_object = Quid.new({
	version = 0,
	fingerprint = `test1234567890`,

	clock = function()
		-- return get_server_time_now(workspace) * 1000 // 1
		return 1750996831697
	end,

	-- NOTE: It can be impure function
	entropy = function(version: number, timestamp: number, fingerprint: string, counter: number)
		-- Implement randomness with using `sha256` algorithm (Strong Entropy)
		local _, digest_block = sha256(`{version}-{timestamp}-{fingerprint}-{counter}`)
		local noise_u32 = 0
		for i = 1, #digest_block do
			noise_u32 = bit32.bxor(noise_u32, digest_block[i])
		end
		return noise_u32 / MASK_NORMALIZED_U32 -- Normalized noise_u32 to be a number between [0, 1]
	end,
})

-- Check if entropy is pure
assert(quid_object.config._counter == 467629496183118, "Entropy is impure (but it won't be a problem)")
