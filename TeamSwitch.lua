local settings = require(script.Parent.CONFIG)
local teams = game:GetService("Teams")
local debounce = {}
local debounceCooldown = 2

local function switchTeam(player)
	
	local currentTime = tick()
	
	-- avoid running loads of times at once for efficiency
	if debounce[player] and (currentTime-debounce[player] < debounceCooldown) then
		return
	end
	
	debounce[player] = currentTime
	
	-- define the target team using the config file
	local targetTeam = teams:FindFirstChild(settings.TargetTeam)
	if not targetTeam then
		warn("Target team not found, did you set it in the CONFIG file?") -- error message
		return
	end

	-- don't bother if they're already on the right team
	if player.Team == targetTeam then
		return
	end

	if settings.BalanceTeams then
		local targetTeamPlayers = #targetTeam:GetPlayers() -- get number of players on the target team
		local smallestOtherCount = math.huge

		-- get number of players on all other teams and figure out smallest count
		for _, team in ipairs(teams:GetChildren()) do
			if team ~= targetTeam then
				local count = #team:GetPlayers()
				if count < smallestOtherCount then
					smallestOtherCount = count
				end
			end
		end

		if smallestOtherCount == math.huge then
			-- no other teams found, so let them join
			player.Team = targetTeam
		else
			-- account for the maximum inbalance set in the config
			local maxSize = settings.MaximumInbalance + smallestOtherCount
			-- if there are less players on the team than the max let them join
			if targetTeamPlayers < maxSize then
				player.Team = targetTeam
			end
		end
	else
		player.Team = targetTeam
	end
end

script.Parent.Touched:Connect(function(hit)
	local character = hit.Parent
	local player = game:GetService("Players"):GetPlayerFromCharacter(character)
	if player then -- check the object is actually a player
		switchTeam(player)
	end
end)
