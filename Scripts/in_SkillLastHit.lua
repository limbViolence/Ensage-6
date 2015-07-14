--<<Simple skill last hit icon>>

require("libs.Utils")
require("libs.ScriptConfig")
require("libs.AbilityDamage")

local config = ScriptConfig.new()
config:SetParameter("Toggle", "L", config.TYPE_HOTKEY)
config:SetParameter("ShowAutoAttackHit", true)
config:SetParameter("ShowOnCreeps", true)
config:SetParameter("ShowOnCatapults", true)
config:SetParameter("ShowOnTowers", true)
config:Load()

local toggleKey = config.Toggle
local oneHit = config.ShowAutoAttackHit
local showOnCreeps = config.ShowOnCreeps
local showOnCatapults = config.ShowOnCatapults
local showOnTowers = config.ShowOnTowers

local inGame = false
local showIcon = true

local icon = {}

local creepDamageSpells = {
	"earthshaker_fissure",
	"sven_storm_bolt",
	"tiny_toss",
	"kun_torrent",
	"beastmaster_wild_axes",
	"dragon_knight_breathe_fire",
	"rattletrap_rocket_flare",
	"omniknight_purification",
	"brewmaster_thunder_clap",
	"centaur_double_edge",
	"shredder_whirling_death",
	"tusk_ice_shards",
	"elder_titan_ancestral_spirit",
	"legion_commander_overwhelming_odds",
	"earth_spirit_boulder_smash",
	"pudge_rot",
	"sandking_burrowstrike",
	"slardar_slithereen_crush",
	"tidehunter_anchor_smash",
	"night_stalker_void",
	"undying_decay",
	"magnataur_shockwave",
	"mirana_starfall",
	"morphling_waveform",
	"phantom_lancer_spirit_lance",
	"templar_assassin_meld",
	"luna_lucent_beam",
	"bounty_hunter_shuriken_toss",
	"ursa_earthshock",
	"naga_siren_rip_tide",
	"troll_warlord_whirling_axes_melee",
	"ember_spirit_sleight_of_fist",
	"bloodseeker_blood_bath",
	"nevermore_shadowraze1",
	"razor_plasma_field",
	"phantom_assassin_stifling_dagger",
	"clinkz_searing_arrows",
	"broodmother_spawn_spiderlings",
	"weaver_shukuchi",
	"spectre_spectral_dagger",
	"meepo_poof",
	"nyx_assassin_impale",
	"slark_dark_pact",
	"medusa_mystic_snake",
	"crystal_maiden_crystal_nova",
	"puck_illusory_orb",
	"storm_spirit_static_remnant",
	"windrunner_powershot",
	"zuus_arc_lightning",
	"lina_dragon_slave",
	"shadow_shaman_ether_shock",
	"tinker_laser",
	"rubick_fade_bolt",
	"keeper_of_the_light_illuminate",
	"skywrath_mage_arcane_bolt",
	"oracle_fortunes_end",
	"techies_land_mines",
	"lich_frost_nova",
	"lion_impale",
	"necrolyte_death_pulse",
	"queenofpain_scream_of_pain",
	"death_prophet_carrion_swarm",
	"pugna_nether_blast",
	"dazzle_shadow_wave",
	"leshrac_lightning_storm",
	"winter_wyvern_splinter_blast",
}

local catapultDamageSpells = {
	"dragon_knight_breathe_fire",
	"templar_assassin_meld",
	"clinkz_searing_arrows",
	"keeper_of_the_light_illuminate",
	"techies_land_mines",
	"pugna_nether_blast"
}

local towerDamageSpells = {
	"tiny_toss",
	"clinkz_searing_arrows",
	"techies_land_mines",
	"pugna_nether_blast"
}

local shft = client.screenSize.x/1600

function Key(msg, code)

	if client.chat or msg == KEY_DOWN then
		return
	end

	if code == toggleKey then
		showIcon = not showIcon
	end

end

function Tick(tick)

	if not SleepCheck() or not inGame or client.paused then 
		return 
	end
	
	local me = entityList:GetMyHero()

	if not me then return end

	if showIcon then
	
		local enemyTeam = me:GetEnemyTeam()
		
		if showOnCreeps then calculateDamage(entityList:GetEntities({classId = CDOTA_BaseNPC_Creep_Lane, team = enemyTeam}), creepDamageSpells, me) end
		if showOnCatapults then calculateDamage(entityList:GetEntities({classId = CDOTA_BaseNPC_Creep_Siege, team = enemyTeam}), catapultDamageSpells, me) end
		if showOnTowers then calculateDamage(entityList:GetEntities({classId = CDOTA_BaseNPC_Tower, team = enemyTeam}), towerDamageSpells, me) end
		
	end

	Sleep(333)

end

function calculateDamage(units, spells, me)

	local spell
		
	for _, skill in ipairs(spells) do
		spell = me:FindSpell(skill)
		if spell and spell.level > 0 then break end
	end
	
	if not spell then return end
	
	for _, unit in ipairs(units) do
		
		local offset = unit.healthbarOffset
	
		if offset ~= -1 then
			
			local hand = unit.handle
			
			if not icon[hand] then
				icon[hand] = drawMgr:CreateRect(-35 * shft, -32  * shft, 0, 0, 0xFF8AB160)
				icon[hand].entity = unit 
				icon[hand].entityPosition =  Vector(0, 0, offset)
				icon[hand].w = 20 * shft
				icon[hand].h = 20 * shft
				icon[hand].visible = false
			end
			
			if unit.visible and unit.alive then
				
				local aDamage = AbilityDamage.GetDamage(spell)
				local aType = abilityType(spell.dmgType)
				local myDamage = me.dmgMin + me.dmgBonus
				
				---- spell corrections
				if spell.name == "earthshaker_fissure" then
					if GetDistance2D(me, unit) <= 325 then
						local aftershock = me:GetAbility(3)
						if aftershock and aftershock.level > 0 then
							aDamage = aDamage + AbilityDamage.GetDamage(aftershock)
						end
					end
				elseif spell.name == "pugna_nether_blast" then
					if unit.classId == CDOTA_BaseNPC_Tower then
						aType = DAMAGE_PURE
						aDamage = aDamage / 2
					end
				elseif spell.name == "tiny_toss" then
					if unit.classId == CDOTA_BaseNPC_Tower then
						aType = DAMAGE_PURE
						aDamage = aDamage  / 3
					end
				elseif spell.name == "undying_decay" then
					local damage = {20, 60, 100, 140}
					aDamage = damage[spell.level]
				elseif spell.name == "templar_assassin_meld" then
					if unit.classId ~= CDOTA_BaseNPC_Creep_Lane then
						aDamage = myDamage / 2 + aDamage
					else
						aDamage = myDamage + aDamage
					end
				elseif spell.name == "ember_spirit_sleight_of_fist" then
					aDamage = myDamage / 2
				elseif spell.name == "razor_plasma_field" then
					local damageMin = {30, 50, 70, 90}
					local damageMax = {160, 230, 300, 370}
					local plasmaLevel = me:GetAbility(1).level
					local distance = GetDistance2D(me, unit)
					if distance <= 725 then
						aDamage = distance / 725 * damageMax[plasmaLevel]
						if aDamage < damageMin[plasmaLevel] then
							aDamage = damageMin[plasmaLevel]
						end
					end
				elseif spell.name == "clinkz_searing_arrows" then
					if unit.classId ~= CDOTA_BaseNPC_Creep_Lane then
						aDamage = myDamage / 2 + aDamage
					else
						aDamage = myDamage + aDamage
					end
				elseif spell.name == "keeper_of_the_light_illuminate" then
					aDamage = aDamage + 100
				elseif spell.name == "techies_land_mines" then
					local damage = {300, 375, 450, 525}
					aDamage = damage[spell.level]
				elseif spell.name == "lich_frost_nova" then
					local damage = {75, 100, 125, 150}
					aDamage = aDamage + damage[spell.level]
				elseif spell.name == "zuus_arc_lightning" then
					if GetDistance2D(me, unit) <= 1225  then
						local static = me:GetAbility(3)
						if static and static.level > 0 then
							local damage = {0.05, 0.07, 0.09, 0.11}
							aDamage = aDamage + unit.health * damage[spell.level]
						end
					end
				end
				----
				
				local spellDamageTaken = math.floor(unit:DamageTaken(aDamage, aType, me))
				local autoAttackDamageTaken = math.floor(unit:DamageTaken(myDamage, DAMAGE_PHYS, me))

				if unit.health <= spellDamageTaken then
					icon[hand].visible = true
					icon[hand].textureId = drawMgr:GetTextureId("NyanUI/spellicons/" .. spell.name)
				elseif unit.health - spellDamageTaken <= autoAttackDamageTaken and oneHit then
					icon[hand].visible = true
					icon[hand].textureId = drawMgr:GetTextureId("NyanUI/spellicons/translucent/" .. spell.name .. "_t50")
				elseif icon[hand].visible then
					icon[hand].visible = false
				end

			elseif icon[hand].visible then
				icon[hand].visible = false
			end
		
		end
	end
end

function abilityType(ability)
	if ability == LuaEntityAbility.DAMAGE_TYPE_MAGICAL then
		return DAMAGE_MAGC	
	elseif ability == LuaEntityAbility.DAMAGE_TYPE_PURE then
		return DAMAGE_PURE
	else
		return DAMAGE_PHYS
	end
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me then
			script:Disable()
		else
			inGame = true
			showIcon = true
			icon = {}
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
	collectgarbage("collect")
end

script:RegisterEvent(EVENT_TICK, Load)
script:RegisterEvent(EVENT_CLOSE, GameClose)