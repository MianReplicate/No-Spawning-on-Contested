-- Register the behaviour
behaviour("NoSpawningOnContested")

function NoSpawningOnContested:Awake()
	self.Flags = ActorManager.capturePoints
	self.JustTeleported = {}
	self.WatchDeactivated = {}
	self.Deactivated = {}
	self.TeamToNames = {
		[Team.Blue] = "BLUE",
		[Team.Red] = "RED",
		[Team.Neutral] = "NEUTRAL"
	}
	self.SpawnAnywaysIfAllContested = self.script.mutator.GetConfigurationBool("SpawnAnywaysIfContested")
end

function NoSpawningOnContested:Start()
	GameEvents.onActorSpawn.addListener(self, "onActorSpawn")
	GameEvents.onCapturePointCaptured.addListener(self, "onCapturePointCaptured")

	self:log("FUCK THEM ENEMIES!!")
end

function NoSpawningOnContested:onActorSpawn(actor)
	if(actor.isPlayer) then return end

	local closestFlag = nil
	local closestMagnitude = math.huge
	for _, flag in pairs(self.Flags) do
		if(flag.owner == actor.team) then
			local magnitude = (flag.transform.position - actor.position).magnitude
			if(magnitude < closestMagnitude) then
				closestFlag = flag
				closestMagnitude = magnitude
			end
		end
	end

	if(closestFlag and self:isTeamLosingPoint(closestFlag, actor)) then
		local nonContested = {}
		for _, flag in pairs(self.Flags) do
			if(flag ~= closestFlag and flag.owner == actor.team and not self:isTeamLosingPoint(flag, actor)) then
				table.insert(nonContested, flag)
			end
		end
		local nonContestedFlag = nonContested[math.random(1, #nonContested)]

		if(nonContestedFlag) then
			self:debug(closestFlag.name.." is currently being contested"..". Moving "..actor.name.." to "..nonContestedFlag.name..".")
			self.JustTeleported[actor]=0.5
			actor:TeleportTo(nonContestedFlag.spawnPosition, nonContestedFlag.transform.rotation)
		elseif(not self.SpawnAnywaysIfAllContested) then
			self:debug("No non-contested flags could be found for "..self.TeamToNames[actor.team]..". Disabling "..actor.name)
			actor:Deactivate()
			self.Deactivated[actor] = actor
			self.WatchDeactivated[closestFlag] = closestFlag
		end
	elseif(not closestFlag) then
		self:debug("Could not find the flag responsible for spawning "..actor.name)
	end
end

function NoSpawningOnContested:Update()
	for point, _ in pairs(self.WatchDeactivated) do
		if(not self:isTeamLosingPoint(point)) then
			self.WatchDeactivated[point] = nil

			for actor, _ in pairs(self.Deactivated) do
				if(actor.team == point.owner) then
					self:debug("Flag available for "..self.TeamToNames[actor.team]..". Reenabling "..actor.name)
					self.Deactivated[actor] = nil
					actor:Activate()
					actor:TeleportTo(point.spawnPosition, point.transform.rotation)
				end
			end
		end
	end

	for actor, time in pairs(self.JustTeleported) do
		local newTime = time - Time.deltaTime
		if(newTime <= 0) then
			self.JustTeleported[actor] = nil
		else
			self.JustTeleported[actor] = newTime
		end
	end
end

function NoSpawningOnContested:onCapturePointCaptured(capturePoint, newTeam)
	for actor, _ in pairs(self.Deactivated) do
		if(actor.team == newTeam) then
			self:debug("Flag available for "..self.TeamToNames[newTeam]..". Reenabling "..actor.name)
			self.Deactivated[actor] = nil
			actor:Activate()
			actor:TeleportTo(capturePoint.spawnPosition, capturePoint.transform.rotation)
		end
	end
end

function NoSpawningOnContested:getActorsWithinCaptureRange(capturePoint)
	return ActorManager.AliveActorsInRange(capturePoint.transform.position, capturePoint.captureRange)
end

function NoSpawningOnContested:isTeamLosingPoint(capturePoint, excludeActor)
	local enemyActors = {}
	local friendlyActors = {}
	for _, actor in ipairs(self:getActorsWithinCaptureRange(capturePoint)) do
		if(actor.team ~= Team.Neutral and not self.JustTeleported[actor] and actor ~= excludeActor) then
			if(actor.team == capturePoint.owner) then
				table.insert(friendlyActors, actor)
			else
				table.insert(enemyActors, actor)
			end
		end
	end
	local string = "\nCapture Point: "..capturePoint.name.."\nFriendly Actors: "
	for _, actor in ipairs(friendlyActors) do
		string = string..actor.name..", "
	end
	string = string.."\nEnemy Actors: "
	for _, actor in ipairs(enemyActors) do
		string = string..actor.name..", "
	end
	self:debug(string)

	return #friendlyActors < #enemyActors
end

function NoSpawningOnContested:debug(...)
	if(GameManager.isTestingContentMod) then
		self:log(...)
	end
end

function NoSpawningOnContested:log(...)
	local string = "<color=#ADD8E6>[No Spawning on Contested]:</color> "
	for _, extraArg in ipairs({...}) do
		string = string..extraArg
	end
	print(string)
end