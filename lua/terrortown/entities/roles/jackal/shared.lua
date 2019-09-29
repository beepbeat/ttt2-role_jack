if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_jack.vmt")
end

JACKAL_EQUIPMENT = {
	"weapon_ttt_flaregun",
	"weapon_ttt_knife",
	"weapon_ttt_phammer",
	"weapon_ttt_push",
	"weapon_ttt_sipistol",
	"weapon_ttt_decoy",
	"weapon_ttt2_sidekickdeagle",
	EQUIP_ARMOR,
	EQUIP_DISGUISE
}

-- creates global var "TEAM_JACKAL" and other required things
-- TEAM_[name], data: e.g. icon, color, ...
roles.InitCustomTeam(ROLE.name, { -- this creates the var "TEAM_JACKAL"
	icon = "vgui/ttt/dynamic/roles/icon_jack",
	color = Color(100, 190, 205, 255)
})

ROLE.Base = "ttt_role_base"

ROLE.color = Color(100, 190, 205, 255) -- ...
ROLE.dkcolor = Color(36, 134, 152, 255) -- ...
ROLE.bgcolor = Color(255, 188, 121, 255) -- ...
ROLE.abbr = "jack" -- abbreviation
ROLE.defaultTeam = TEAM_JACKAL -- the team name: roles with same team name are working together
ROLE.defaultEquipment = JACKAL_EQUIPMENT -- here you can set up your own default equipment
ROLE.surviveBonus = 0 -- bonus multiplier for every survive while another player was killed
ROLE.scoreKillsMultiplier = 1 -- multiplier for kill of player of another team
ROLE.scoreTeamKillsMultiplier = -8 -- multiplier for teamkill
ROLE.fallbackTable = {}
ROLE.traitorCreditAward = true -- will receive credits on kill like a traitor

ROLE.conVarData = {
	pct = 0.14, -- necessary: percentage of getting this role selected (per player)
	maximum = 1, -- maximum amount of roles in a round
	minPlayers = 7, -- minimum amount of players until this role is able to get selected
	credits = 3, -- the starting credits of a specific role
	togglable = true, -- option to toggle a role for a client if possible (F1 menu)
	random = 50
}

-- init jackal fallback table
hook.Add("InitFallbackShops", "JackInitFallback", function()
	-- init fallback shop
	InitFallbackShop(JACKAL, table.Merge(JACKAL.fallbackTable, TRAITOR.fallbackTable)) -- merge jackal equipment with traitor equipment
end)

hook.Add("TTT2FinishedLoading", "JackInitT", function()
	if SERVER and JESTER then
		-- add a easy role filtering to receive all jesters
		-- but just do it, when the role was created, then update it with recommended function
		-- theoretically this function is not necessary to call, but maybe there are some modifications
		-- of other addons. So it's better to use this function
		-- because it calls hooks and is doing some networking
		JACKAL.networkRoles = {JESTER}
	end

	if CLIENT then
		-- setup here is not necessary but if you want to access the role data, you need to start here
		-- setup basic translation !
		LANG.AddToLanguage("English", JACKAL.name, "Jackal")
		LANG.AddToLanguage("English", TEAM_JACKAL, "TEAM Jackal")
		LANG.AddToLanguage("English", "info_popup_" .. JACKAL.name,
			[[You are the Jackal!
			Try to kill each other role! It's hard, so maybe you need a Sidekick...]])
		LANG.AddToLanguage("English", "body_found_" .. JACKAL.abbr, "This was a Jackal...")
		LANG.AddToLanguage("English", "search_role_" .. JACKAL.abbr, "This person was a Jackal!")
		LANG.AddToLanguage("English", "target_" .. JACKAL.name, "Jackal")
		LANG.AddToLanguage("English", "ttt2_desc_" .. JACKAL.name, [[The Jackal needs to win alone or with his sidekick!]])
		LANG.AddToLanguage("English", "hilite_win_" .. TEAM_JACKAL, "THE JACK WON") -- name of base role of a team -> maybe access with GetTeamRoles(ROLES.SERIALKILLER.team)[1].name
		LANG.AddToLanguage("English", "win_" .. TEAM_JACKAL, "The Jackal has won!") -- teamname
		LANG.AddToLanguage("English", "ev_win_" .. TEAM_JACKAL, "The evil Jackal won the round!")
		LANG.AddToLanguage("English", "credit_" .. JACKAL.abbr .. "_all", "Jackals, you have been awarded {num} equipment credit(s) for your performance.")

		LANG.AddToLanguage("Deutsch", JACKAL.name, "Jackal")
		LANG.AddToLanguage("Deutsch", TEAM_JACKAL, "TEAM Jackal")
		LANG.AddToLanguage("Deutsch", "info_popup_" .. JACKAL.name,
			[[Du bist ein Jackal!
			Versuche jede andere Rolle zu töten! Es ist schwer, also brauchst du vielleicht einen Sidekick]])
		LANG.AddToLanguage("Deutsch", "body_found_" .. JACKAL.abbr, "Er war ein Jackal...")
		LANG.AddToLanguage("Deutsch", "search_role_" .. JACKAL.abbr, "Diese Person war ein Jackal!")
		LANG.AddToLanguage("Deutsch", "target_" .. JACKAL.name, "Jackal")
		LANG.AddToLanguage("Deutsch", "ttt2_desc_" .. JACKAL.name, [[Der Jackal muss alleine oder mit seinem Sidekick gewinnen!]])
		LANG.AddToLanguage("Deutsch", "hilite_win_" .. TEAM_JACKAL, "THE JACK WON") -- name of base role of a team -> maybe access with TEAM_JACKAL
		LANG.AddToLanguage("Deutsch", "win_" .. TEAM_JACKAL, "Der Jackal hat gewonnen!") -- teamname
		LANG.AddToLanguage("Deutsch", "ev_win_" .. TEAM_JACKAL, "Der böse Jackal hat die Runde gewonnen!")
		LANG.AddToLanguage("Deutsch", "credit_" .. JACKAL.abbr .. "_all", "Jackale, euch wurde(n) {num} Ausrüstungs-Credit(s) für eure Leistung gegeben.")
	end
end)

if SERVER then	
	-- modify roles table of rolesetup addon
	hook.Add("TTTAModifyRolesTable", "ModifyRoleJackToInno", function(rolesTable)
		local jackals = rolesTable[ROLE_JACKAL]

		if not jackals then return end

		rolesTable[ROLE_INNOCENT] = rolesTable[ROLE_INNOCENT] + jackals
		rolesTable[ROLE_JACKAL] = 0
	end)

	-- Give Loadout on respawn and rolechange	
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		if isRoleChange then -- TODO: maybe give SiKi deagle if not used before
			ply:GiveEquipmentWeapon("weapon_ttt2_sidekickdeagle")
		end
		ply:GiveEquipmentItem("item_ttt_armor")
	end

	-- Remove Loadout on death and rolechange
	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
		ply:StripWeapon("weapon_ttt2_sidekickdeagle")
		ply:RemoveEquipmentItem("item_ttt_armor")
	end
end
