--<<Simple courier bottle abuse>>

require("libs.Utils")
require("libs.ScriptConfig")

local config = ScriptConfig.new()
config:SetParameter("Abuse", "Z", config.TYPE_HOTKEY)
config:SetParameter("ItemsFromStash", true)
config:Load()

local abuseCour = config.Abuse
local itemsFromStash = config.ItemsFromStash

local inGame = false
local abusing = false
local courFollowing = false
local courBottle = false

function Key(msg, code)

	if client.chat or not inGame or msg == KEY_DOWN then
		return
	end

	if code == abuseCour then
		courFollowing = false
		courBottle = false
		abusing = true
	end

end

function Tick(tick)

	if not SleepCheck() or not inGame or client.paused then 
		return 
	end
	
	local me = entityList:GetMyHero()

	if not me then
		return
	end

	if abusing then
	
		local cour = entityList:FindEntities({classId = CDOTA_Unit_Courier, team = me.team, alive = true})[1]
		local bottle = me:FindItem("item_bottle")

		if cour then
			
			if not courFollowing and bottle then
				if GetDistance2D(me, cour) > 250 then
					cour:Follow(me)
				end
				courFollowing = true
			end
			
			if courFollowing and GetDistance2D(me, cour) <= 250 then
				if bottle and bottle.charges == 0 then
					entityList:GetMyPlayer():GiveItem(cour, bottle)
				end
				
				local cbottle = cour:FindItem("item_bottle")
				
				if cbottle and cbottle.purchaser == me then
					courFollowing = false
					courBottle = true
				end
			end

			if courBottle then
				cour:CastAbility(cour:GetAbility(1))
				if itemsFromStash then cour:CastAbility(cour:GetAbility(4), true) end
				cour:CastAbility(cour:GetAbility(5), true)
				
				cour:SafeCastAbility(cour:GetAbility(6))
				
				courBottle = false
				abusing = false
			end
			
		else
			abusing = false
		end

	end
	
	Sleep(750)

end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then
			script:Disable()
		else
			inGame = true
			courFollowing = false
			courBottle = false
			abusing = false
			script:RegisterEvent(EVENT_TICK, Tick)
			script:RegisterEvent(EVENT_KEY, Key)
			script:UnregisterEvent(Load)
		end
	end
end

function GameClose()
	if inGame then
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK, Load)
		inGame = false
	end
end

script:RegisterEvent(EVENT_TICK, Load)
script:RegisterEvent(EVENT_CLOSE, GameClose)