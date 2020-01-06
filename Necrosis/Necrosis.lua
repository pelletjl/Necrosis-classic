--[[
    Necrosis LdC
    Copyright (C) 2005-2008  Lom Enfroy

    This file is part of Necrosis LdC.

    Necrosis LdC is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Necrosis LdC is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Necrosis LdC; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
--]]

------------------------------------------------------------------------------------------------------
-- Necrosis LdC
-- Par Lomig (Kael'Thas EU/FR) & Tarcalion (Nagrand US/Oceanic)
-- Contributions deLiadora et Nyx (Kael'Thas et Elune EU/FR)
--
-- Skins et voix Françaises : Eliah, Ner'zhul
--
-- Version Allemande par Geschan
-- Version Espagnole par DosS (Zul’jin)
-- Version Russe par Komsomolka
--
-- Version $LastChangedDate: 2010-08-04 12:04:27 +1000 (Wed, 04 Aug 2010) $
------------------------------------------------------------------------------------------------------

-- Global variables || Variables globales
NecrosisConfig = {}

-- Local variables || Variables locales
local Local = {}
local _G = getfenv(0)

------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS || FONCTIONS LOCALES
------------------------------------------------------------------------------------------------------

-- Creating two functions, new and del || Création de deux fonctions, new et del
-- New creates a temporary array, del destroys it || new crée un tableau temporaire, del le détruit
-- These temporary tables are stored for reuse without having to recreate them. || Ces tableaux temporaires sont stockés pour être réutilisés sans être obligés de les recréer.
local new, del
do
	local cache = setmetatable({}, {__mode='k'})
	function new(populate, ...)
		local tbl
		local t = next(cache)
		if ( t ) then
			cache[t] = nil
			tbl = t
		else
			tbl = {}
		end
		if ( populate ) then
			local num = select("#", ...)
			if ( populate == "hash" ) then
				assert(math.fmod(num, 2) == 0)
				local key
				for i = 1, num do
					local v = select(i, ...)
					if not ( math.fmod(i, 2) == 0 ) then
						key = v
					else
						tbl[key] = v
						key = nil
					end
				end
			elseif ( populate == "array" ) then
				for i = 1, num do
					local v = select(i, ...)
					table.insert(tbl, i, v)
				end
			end
		end
		return tbl
	end
	function del(t)
		for k in next, t do
			t[k] = nil
		end
		cache[t] = true
	end
end

-- Define a metatable which will be applied to any table object that uses it. || Métatable permettant d'utiliser les tableaux qui l'utilisent comme des objets
-- Common functions = :insert, :remove & :sort || Je définis les opérations :insert, :remove et :sort
-- Any table declared as follows "a = setmetatable({}, metatable)" will be able to use the common functions. || Tout tableau qui aura pour déclaration a = setmetatable({}, metatable) pourra utiliser ces opérateurs
local metatable = {
	__index = {
		["insert"] = table.insert,
		["remove"] = table.remove,
		["sort"] = table.sort,
	}
}

-- Create the spell metatable. || Création de la métatable contenant les sorts de nécrosis
Necrosis.Spell = setmetatable({}, metatable)

------------------------------------------------------------------------------------------------------
-- DECLARATION OF VARIABLES || DÉCLARATION DES VARIABLES
------------------------------------------------------------------------------------------------------

-- Detection of initialisation || Détection des initialisations du mod
Local.LoggedIn = true
Local.InWorld = true

-- Events utilised by Necrosis || Events utilisés dans Necrosis
Local.Events = {
	"BAG_UPDATE",
	"PLAYER_REGEN_DISABLED",
	"PLAYER_REGEN_ENABLED",
	"PLAYER_DEAD",
	"PLAYER_ALIVE",
	"PLAYER_UNGHOST",
	"UNIT_PET",
	"UNIT_SPELLCAST_FAILED",
	"UNIT_SPELLCAST_INTERRUPTED",
	"UNIT_SPELLCAST_SUCCEEDED",
	"UNIT_SPELLCAST_SENT",
	"UNIT_MANA",
	"UNIT_HEALTH",
	"LEARNED_SPELL_IN_TAB",
	"PLAYER_TARGET_CHANGED",
	"TRADE_REQUEST",
	"TRADE_REQUEST_CANCEL",
	"TRADE_ACCEPT_UPDATE",
	"TRADE_SHOW",
	"TRADE_CLOSED",
	"COMBAT_LOG_EVENT_UNFILTERED",
	"SKILL_LINES_CHANGED"
	-- "BAG_UPDATE_DELAYED"
}

-- Configuration defaults || Configuration par défaut
-- To be used if the configuration savedvariables is missing, or if the NecrosisConfig.Version number is changed. || Se charge en cas d'absence de configuration ou de changement de version
Local.DefaultConfig = {
	SoulshardContainer = 4,
	ShadowTranceAlert = true,
	ShowSpellTimers = true,
	AntiFearAlert = true,
	CreatureAlert = true,
	NecrosisLockServ = true,
	NecrosisAngle = 180,
	StonePosition = {1, 2, 3, 4, 5, 6, 7, 8},
		-- 1 = Firestone
		-- 2 = Spellstone
		-- 3 = Healthstone
		-- 4 = Soulstone
		-- 5 = Buff menu
		-- 6 = Mounts
		-- 7 = Demon menu
		-- 8 = Curse menu
	CurseSpellPosition = {1, 2, 3, 4, 5, 6, 7},
		-- 1 = Weakness || Faiblesse
		-- 2 = Agony || Agonie
		-- 3 = Tongues || Langage
		-- 4 = Exhaustion || Fatigue
		-- 5 = Elements
		-- 6 = Doom || Funeste
		-- 7 = Corruption (not really a curse, but hey - its useful :)
	-- DemonSpellPosition = {1, 2, 3, 4, 5, 6, 8, 9, 10, -11},
        DemonSpellPosition = {1, 2, 3, 4, 5, 6, 8, 7, 9, 10, -11},
		-- 1 = Fel Domination || Domination corrompue
		-- 2 = Summon Imp
		-- 3 = Summon Voidwalker || Marcheur
		-- 4 = Summon Succubus
		-- 5 = Summon Felhunter
		-- 6 = Felguard || Gangregarde
		-- 7 = Infernal
		-- 8 = Doomguard
		-- 9 = Enslave || Asservissement
		-- 10 = Sacrifice
		-- 11 = Demonic Empowerment || Renforcement
	BuffSpellPosition = {1, 2, 3, 4, 5, 6, 7, 8, -9, 10},
		-- 1 = Demon Armor || Armure
		-- 2 = Fel Armor || Gangrarmure
		-- 3 = Unending Breath || Respiration
		-- 4 = Detect Invisibility || Invisibilité
		-- 5 = Eye of Kilrogg
		-- 6 = Ritual of Summoning || TP
		-- 7 = Soul Link || Lien Spirituel
		-- 8 = Shadow Ward || Protection contre l'ombre
		-- 9 = Demonic Empowerment || Renforcement démoniaque --
		-- 10 = Banish || Bannir
	NecrosisToolTip = true,

	MainSpell = 41,

	PetMenuPos = {x=1, y=0, direction=1},
	PetMenuDecalage = {x=1, y=26},

	BuffMenuPos = {x=1, y=0, direction=1},
	BuffMenuDecalage = {x=1, y=26},

	CurseMenuPos = {x=1, y=0, direction=1},
	CurseMenuDecalage = {x=1, y=-26},

	ChatMsg = true,
	ChatType = true,
	Language = GetLocale(),
	ShowCount = true,
	CountType = 1,
	ShadowTranceScale = 100,
	NecrosisButtonScale = 90,
	NecrosisColor = "Rose",
	Sound = true,
	SpellTimerPos = 1,
	SpellTimerJust = "LEFT",
	Circle = 1,
	TimerType = 1,
	SensListe = 1,
	PetName = {},
	DemonSummon = true,
	BanishScale = 100,
	ItemSwitchCombat = {},
	DestroyCount = 32,
	DestroyShard = false,
	SoulshardSort = true,
	SoulshardDestroy = false,
	FramePosition = {
		["NecrosisSpellTimerButton"] = {"CENTER", "UIParent", "CENTER", 100, 300},
		["NecrosisButton"] = {"CENTER", "UIParent", "CENTER", 0, -200},
		["NecrosisCreatureAlertButton"] = {"CENTER", "UIParent", "CENTER", -60, 0},
		["NecrosisAntiFearButton"] = {"CENTER", "UIParent", "CENTER", -20, 0},
		["NecrosisShadowTranceButton"] = {"CENTER", "UIParent", "CENTER", 20, 0},
		["NecrosisBacklashButton"] = {"CENTER", "UIParent", "CENTER", 60, 0},
		["NecrosisFirestoneButton"] = {"CENTER", "UIParent", "CENTER", -121,-100},
		["NecrosisSpellstoneButton"] = {"CENTER", "UIParent", "CENTER", -87,-100},
		["NecrosisHealthstoneButton"] = {"CENTER", "UIParent", "CENTER", -53,-100},
		["NecrosisSoulstoneButton"] = {"CENTER", "UIParent", "CENTER", -17,-100},
		["NecrosisBuffMenuButton"] = {"CENTER", "UIParent", "CENTER", 17,-100},
		["NecrosisMountButton"] = {"CENTER", "UIParent", "CENTER", 53,-100},
		["NecrosisPetMenuButton"] = {"CENTER", "UIParent", "CENTER", 87,-100},
		["NecrosisCurseMenuButton"] = {"CENTER", "UIParent", "CENTER", 121,-100},
	},
}

-- Casted spell variables (name, rank, target, target level) || Variables des sorts castés (nom, rang, cible, niveau de la cible)
Local.SpellCasted = {}

-- Timers variables || Variables des timers
Local.TimerManagement = {
	-- Spells to timer || Sorts à timer
	SpellTimer = setmetatable({}, metatable),
	-- Association of timers to Frames || Association des timers aux Frames
	TimerTable = setmetatable({}, metatable),
	-- Groups of timers by mobs || Groupes de timers par mobs
	SpellGroup = setmetatable(
		{
			{Name = "Rez", SubName = " ", Visible = 0},
			{Name = "Main", SubName = " ", Visible = 0},
			{Name = "Cooldown", SubName = " ", Visible = 0}
		},
		metatable
	),
	-- Last cast spell || Dernier sort casté
	LastSpell = {}
}

-- Variables of the invocation messages || Variables des messages d'invocation
Local.SpeechManagement = {
	-- Latest messages selected || Derniers messages sélectionnés
	-- Added 'RoS = 0' by Draven (April 3rd, 2008) || Added 'RoS = 0' by Draven (April 3rd, 2008)
	LastSpeech = {Pet = 0, Steed = 0, Rez = 0, TP = 0, RoS = 0},
	-- Messages to use after the spell succeeds || Messages à utiliser après la réussite du sort
	SpellSucceed = {
		-- Added 'RoS = setmetatable ({}, metatable),' by Draven (April 3rd, 2008) || Added 'RoS = setmetatable({}, metatable),' by Draven (April 3rd, 2008)
		RoS = setmetatable({}, metatable),
		Pet = setmetatable({}, metatable),
		Steed = setmetatable({}, metatable),
		Rez = setmetatable({}, metatable),
		TP = setmetatable({}, metatable),
		Sacrifice = setmetatable({}, metatable)
	},
}

-- Variables used for managing summoning and stone buttons || Variables utilisées pour la gestion des boutons d'invocation et d'utilisation des pierres
Local.Stone = {
	Soul = {Mode = 1, Location = {}},
	Health = {Mode = 1, Location = {}},
	Spell = {Mode = 1, Location = {}},
	Hearth = {Location = {}},
	Fire = {Mode = 1},
}
Local.SomethingOnHand = "Truc"

-- Component count variable || Variable de comptage des composants
Local.Reagent = {Infernal = 0, Demoniac = 0}

-- Variables used in demon management || Variables utilisées dans la gestion des démons
Local.Summon = {}

-- List of buttons available in each menu || Liste des boutons disponibles dans chaque menu
Local.Menu = {
	Pet = setmetatable({}, metatable),
	Buff = setmetatable({}, metatable),
	Curse = setmetatable({}, metatable)
}

-- Active Buffs Variable || Variable des Buffs Actifs
Local.BuffActif = {}

-- Variable of the state of the buttons (grayed or not) || Variable de l'état des boutons (grisés ou non)
Local.Desatured = {}

-- Last image used for the sphere || Dernière image utilisée pour la sphere
Local.LastSphereSkin = "Aucune"

-- Variables of care stone exchanges || Variables des échanges de pierres de soins
Local.Trade = {}

-- Variables used for the management of soul fragments || Variables utilisées pour la gestion des fragments d'âme
Local.Soulshard = {Count = 0, Move = 0}
Local.BagIsSoulPouch = {}

-- Variables used for warnings || Variables utilisées pour les avertissements
-- Antifear and Demonic or Elemental Target || Antifear et Cible démoniaque ou élémentaire
Local.Warning = {
	Antifear = {
		Toggle = 2,
		Icon = {"", "Immu", "Prot"}
	}
}

-- Time elapsed between two OnUpdate events || Temps écoulé entre deux event OnUpdate
Local.LastUpdate = {0, 0}

------------------------------------------------------------------------------------------------------
-- NECROSIS FUNCTIONS APPLIED TO ENTRY IN THE GAME || FONCTIONS NECROSIS APPLIQUEES A L'ENTREE DANS LE JEU
------------------------------------------------------------------------------------------------------

-- Function applied to loading || Fonction appliquée au chargement
function Necrosis:OnLoad(event)
	if event == "SPELLS_CHANGED" then
		local _, Class = UnitClass("player")
			if Class == "WARLOCK" then

			for index in ipairs(Necrosis.Spell) do
				Necrosis.Spell[index].ID = nil
			end
			Necrosis:SpellSetup()
			-- Necrosis:CreateMenu()
			Necrosis:ButtonSetup()
		end
	end
	if event == "PLAYER_LOGIN" then

		local _, Class = UnitClass("player")
		if Class == "WARLOCK" then
			-- Initialization of the mod || Initialisation du mod
			self:Initialize(Local.DefaultConfig)

			-- Recording of the events used || Enregistrement des events utilisés
			NecrosisButton:RegisterEvent("PLAYER_ENTERING_WORLD")
			NecrosisButton:RegisterEvent("PLAYER_LEAVING_WORLD")
			for i in ipairs(Local.Events) do
				NecrosisButton:RegisterEvent(Local.Events[i])
			end

			-- Detecting the type of demon present at the connection || Détection du Type de démon présent à la connexion
			Local.Summon.DemonType = UnitCreatureFamily("pet")
		end
	end
end

------------------------------------------------------------------------------------------------------
-- NECROSIS FUNCTIONS || FONCTIONS NECROSIS
------------------------------------------------------------------------------------------------------
-- Function started when updating the interface (main) - every 0.1 seconds || Fonction lancée à la mise à jour de l'interface (main) -- Toutes les 0,1 secondes environ
function Necrosis:OnUpdate(something, elapsed)
	Local.LastUpdate[1] = Local.LastUpdate[1] + elapsed
	Local.LastUpdate[2] = Local.LastUpdate[2] + elapsed

	-- If smooth scroll timers, we update them as soon as possible || Si défilement lisse des timers, on les met à jours le plus vite possible
	if NecrosisConfig.Smooth then
		NecrosisUpdateTimer(Local.TimerManagement.SpellTimer)
	end

	-- If timers texts, we update them very quickly also || Si timers textes, on les met à jour très vite également
	if NecrosisConfig.TimerType == 2 then
		self:TextTimerUpdate(Local.TimerManagement.SpellTimer, Local.TimerManagement.SpellGroup)
	end

	-- Every second || Toutes les secondes
	if Local.LastUpdate[1] > 1 then
	-- If configured, sorting fragments every second || Si configuré, tri des fragment toutes les secondes
		if NecrosisConfig.SoulshardSort and Local.Soulshard.Move > 0  then
			Necrosis:SoulshardSwitch("MOVE")
		end

		-- Timers Table Course || Parcours du tableau des Timers
		if Local.TimerManagement.SpellTimer[1] then
			for index = 1, #Local.TimerManagement.SpellTimer, 1 do
				if Local.TimerManagement.SpellTimer[index] then
					-- We remove the completed timers || On enlève les timers terminés
					local TimeLocal = GetTime()
					if TimeLocal >= (Local.TimerManagement.SpellTimer[index].TimeMax - 0.5) then
						local StoneFade = false
						-- If the timer was that of Soul Stone, warn the Warlock || Si le timer était celui de la Pierre d'âme, on prévient le Démoniste
						if Local.TimerManagement.SpellTimer[index].Name == self.Spell[11].Name then
							self:Msg(self.ChatMessage.Information.SoulstoneEnd)
							if NecrosisConfig.Sound then PlaySoundFile(self.Sound.SoulstoneEnd) end
							StoneFade = true
						elseif Local.TimerManagement.SpellTimer[index].Name == self.Spell[9].Name then
							Local.TimerManagement.Banish = false
						end
						-- Otherwise we remove the timer silently (but not in case of enslave) || Sinon on enlève le timer silencieusement (mais pas en cas d'enslave)
						if not (Local.TimerManagement.SpellTimer[index].Name == self.Spell[10].Name) then
							Local.TimerManagement = self:RetraitTimerParIndex(index, Local.TimerManagement)
							index = 0
							if StoneFade then
								-- We update the appearance of the button of the soul stone || On met à jour l'apparence du bouton de la pierre d'âme
								self:UpdateIcons()
							end
							break
						end
					end
				end
			end
		end
		Local.LastUpdate[1] = 0
	-- Every half second || Toutes les demies secondes
	elseif Local.LastUpdate[2] > 0.5 then
		-- If normal graphical timers scroll, then we update every 0.5 seconds || Si défilement normal des timers graphiques, alors on met à jour toutes les 0.5 secondes
		if not NecrosisConfig.Smooth then
			NecrosisUpdateTimer(Local.TimerManagement.SpellTimer)
		end
		-- If configured, display warnings from Antifear || Si configuré, affichage des avertissements d'Antifear
		if NecrosisConfig.AntiFearAlert then
			Necrosis:ShowAntiFearWarning()
		end
		-- If configured, the Sphere is transfected into a Ground Chrono || Si configuré, on transfome la Sphere en Chrono de Rez
		if (NecrosisConfig.CountType == 3 or NecrosisConfig.Circle == 2)
			and (Local.Stone.Soul.Mode == 3 or Local.Stone.Soul.Mode == 4)
			then
				Local.LastSphereSkin = self:RezTimerUpdate(
					Local.TimerManagement.SpellTimer, Local.LastSphereSkin
				)
		end
		Local.LastUpdate[2] = 0
	end
end


-- Function started according to the intercepted event || Fonction lancée selon l'événement intercepté
function Necrosis:OnEvent(self, event,...)
	local arg1,arg2,arg3,arg4,arg5,arg6 = ...

	if (event == "PLAYER_ENTERING_WORLD") then
		Local.InWorld = true
	elseif (event == "PLAYER_LEAVING_WORLD") then
		Local.InWorld = false
	end

	-- Is the game well loaded? || Le jeu est-il bien chargé ?
	if not Local.InWorld then
		return
	end

	-- If the contents of the bags have changed, we check that Soul Fragments are always in the right bag || Si le contenu des sacs a changé, on vérifie que les Fragments d'âme sont toujours dans le bon sac
	if (event == "BAG_UPDATE") then
		Necrosis:BagExplore(arg1)
		if (NecrosisConfig.SoulshardSort) then
			Necrosis:SoulshardSwitch("CHECK")
		end
	-- If the player wins or loses mana || Si le joueur gagne ou perd de la mana
	elseif (event == "UNIT_MANA") and arg1 == "player" then
		Necrosis:UpdateMana()
	-- If the player wins or loses his life || Si le joueur gagneou perd de la vie
	elseif (event == "UNIT_HEALTH") and arg1 == "player" then
		Necrosis:UpdateHealth()
	-- If the player dies || Si le joueur meurt
	elseif (event == "PLAYER_DEAD") then
		-- It may hide the Twilight or Backlit buttons. || On cache éventuellement les boutons de Crépuscule ou Contrecoup.
		Local.Dead = true
		NecrosisShadowTranceButton:Hide()
		NecrosisBacklashButton:Hide()
		-- We gray all the spell buttons || On grise tous les boutons de sort
		if _G["NecrosisMountButton"] then
			NecrosisMountButton:GetNormalTexture():SetDesaturated(1)
		end
		for i = 1, 15, 1 do
			if _G["NecrosisBuffMenu"..i] then
				_G["NecrosisBuffMenu"..i]:GetNormalTexture():SetDesaturated(1)
			end
			if _G["NecrosisPetMenu"..i] then
				_G["NecrosisPetMenu"..i]:GetNormalTexture():SetDesaturated(1)
			end
			if _G["NecrosisCurseMenu"..i] then
				_G["NecrosisCurseMenu"..i]:GetNormalTexture():SetDesaturated(1)
			end
		end
	-- If the player resurrects || Si le joueur ressucite
	elseif 	(event == "PLAYER_ALIVE" or event == "PLAYER_UNGHOST") then
		-- We are sobering all the spell buttons || On dégrise tous les boutons de sort
		if _G["NecrosisMountButton"] then
			NecrosisMountButton:GetNormalTexture():SetDesaturated(nil)
		end
		for i = 1, 15, 1 do
			if _G["NecrosisBuffMenu"..i] then
				_G["NecrosisBuffMenu"..i]:GetNormalTexture():SetDesaturated(nil)
			end
			if _G["NecrosisPetMenu"..i] then
				_G["NecrosisPetMenu"..i]:GetNormalTexture():SetDesaturated(nil)
			end
			if _G["NecrosisCurseMenu"..i] then
				_G["NecrosisCurseMenu"..i]:GetNormalTexture():SetDesaturated(nil)
			end
		end
		-- We reset the gray button list || On réinitialise la liste des boutons grisés
		Local.Desatured = {}
		Local.Dead = false
	-- Successful spell casting management || Gestion de l'incantation des sorts réussie
	elseif (event == "UNIT_SPELLCAST_SUCCEEDED") and arg1 == "player" then
		_, Local.SpellCasted.Name = arg1, arg3
		Local.SpellCasted.Name = GetSpellInfo(arg3)
		-- print ('GUUUID'..Local.SpellCasted.TargetGUID)
		Necrosis:SpellManagement()
	-- When the warlock begins to cast a spell, we intercept the spell's name || Quand le démoniste commence à incanter un sort, on intercepte le nom de celui-ci
	-- We also save the name of the target of the spell as well as its level || On sauve également le nom de la cible du sort ainsi que son niveau
	elseif (event == "UNIT_SPELLCAST_SENT") then

		-- print('spellcast send : arg 1 =   ' .. arg1 )
		-- print('spellcast send : arg 2 =   ' .. arg2 )
		-- print('spellcast send : arg 3 =   ' .. arg3 )
		-- print('spellcast send : arg 4 =   ' .. arg4 )
		-- print('spellcast send : arg 5 =   ' .. arg5 )
		-- print('spellcast send : arg 6 =   ' .. arg6 )
		_, Local.SpellCasted.Name, Local.SpellCasted.Rank, Local.SpellCasted.TargetName = arg1, arg2, arg3, arg4
		-- local castedSpellName, castedSpellRank = GetSpellInfo(696)
		Local.SpellCasted.TargetName = arg2
		Local.SpellCasted.TargetGUID = UnitGUID("target")
		Local.SpellCasted.Name = GetSpellInfo(arg4)
		Local.SpellCasted.Rank = GetSpellSubtext(Local.SpellCasted.Name)
		-- print(Local.SpellCasted)

		if not Local.SpellCasted.TargetGUID then
			Local.SpellCasted.TargetGUID = ""

		end

		if (not Local.SpellCasted.TargetName or Local.SpellCasted.TargetName == "") and UnitName("target") then
			Local.SpellCasted.TargetGUID = UnitGUID("target")
			Local.SpellCasted.TargetName = UnitName("target")
		elseif not Local.SpellCasted.TargetName then
			Local.SpellCasted.TargetName = ""
		end
		Local.SpellCasted.TargetLevel = UnitLevel("target")
		if not Local.SpellCasted.TargetLevel then
			Local.SpellCasted.TargetLevel = ""
		end
		Local.SpeechManagement = Necrosis:Speech_It(Local.SpellCasted, Local.SpeechManagement, metatable)

	-- When the warlock stops his incantation, we release the name of it || Quand le démoniste stoppe son incantation, on relache le nom de celui-ci
	elseif (event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED") and arg1 == player then
		Local.SpellCasted = {}
	-- Flag if a Trade window is open, so you can automatically trade the healing stones || Flag si une fenetre de Trade est ouverte, afin de pouvoir trader automatiquement les pierres de soin
	elseif event == "TRADE_REQUEST" or event == "TRADE_SHOW" then
		Local.Trade.Request = true
	elseif event == "TRADE_REQUEST_CANCEL" or event == "TRADE_CLOSED" then
		Local.Trade.Request = false
	elseif event=="TRADE_ACCEPT_UPDATE" then
		if Local.Trade.Request and Local.Trade.Complete then
			AcceptTrade()
			Local.Trade.Request = false
			Local.Trade.Complete = false
		end
	-- AntiFear button hide on target change || AntiFear button hide on target change
	elseif event == "PLAYER_TARGET_CHANGED" then
		if NecrosisConfig.AntiFearAlert and Local.Warning.Antifear.Immune then
			Local.Warning.Antifear.Immune = false
		end
		if NecrosisConfig.CreatureAlert
			and UnitCanAttack("player", "target")
			and not UnitIsDead("target") then
				Local.Warning.Banishable = true
				if UnitCreatureType("target") == Necrosis.Unit.Demon then
					NecrosisCreatureAlertButton:Show()
					NecrosisCreatureAlertButton:SetNormalTexture("Interface\\Addons\\Necrosis\\UI\\DemonAlert")
				elseif UnitCreatureType("target") == Necrosis.Unit.Elemental then
					NecrosisCreatureAlertButton:Show()
					NecrosisCreatureAlertButton:SetNormalTexture("Interface\\Addons\\Necrosis\\UI\\ElemAlert")
				end
		elseif Local.Warning.Banishable then
			Local.Warning.Banishable = false
			NecrosisCreatureAlertButton:Hide()
		end

	-- If the Warlock learns a new spell / spell, we get the new spells list || Si le Démoniste apprend un nouveau sort / rang de sort, on récupère la nouvelle liste des sorts
	-- If the Warlock learns a new buff or summon spell, the buttons are recreated || Si le Démoniste apprend un nouveau sort de buff ou d'invocation, on recrée les boutons
	elseif (event == "LEARNED_SPELL_IN_TAB") then
		for index in ipairs(Necrosis.Spell) do
			Necrosis.Spell[index].ID = nil
		end
		Necrosis:SpellSetup()
		Necrosis:CreateMenu()
		Necrosis:ButtonSetup()

	-- At the end of the fight, we stop reporting Twilight || A la fin du combat, on arrête de signaler le Crépuscule
	-- We remove the spell timers and the names of mobs || On enlève les timers de sorts ainsi que les noms des mobs
	elseif (event == "PLAYER_REGEN_ENABLED") then
		Local.PlayerInCombat = false
		Local.TimerManagement = Necrosis:RetraitTimerCombat(Local.TimerManagement)

		-- We are redefining the attributes of spell buttons in a situational way || On redéfinit les attributs des boutons de sorts de manière situationnelle
		Necrosis:NoCombatAttribute(Local.Stone.Soul.Mode, Local.Stone.Fire.Mode, Local.Stone.Spell.Mode, Local.Menu.Pet, Local.Menu.Buff, Local.Menu.Curse)
		Necrosis:UpdateIcons()

	-- When the warlock changes demon || Quand le démoniste change de démon
	elseif (event == "UNIT_PET" and arg1 == "player") then
		Necrosis:ChangeDemon()

	-- Reading the combat log || Lecture du journal de combat
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags , noidea, Effect = CombatLogGetCurrentEventInfo()
		-- Detection of Shadow Trance and Contrecoup || Détection de la transe de l'ombre et de  Contrecoup
		if subevent == "SPELL_AURA_APPLIED" and destGUID == UnitGUID("player") then
			Necrosis:SelfEffect("BUFF", Effect)
		-- Detection of the end of Shadow Trance and Contrecoup || Détection de la fin de la transe de l'ombre et de Contrecoup
		elseif subevent == "SPELL_AURA_REMOVED" and destGUID == UnitGUID("player") then
			Necrosis:SelfEffect("DEBUFF", Effect)
		-- Debian Detection || Détection du Déban
		elseif subevent == "SPELL_AURA_REMOVED" and destGUID == UnitGUID("focus") and Local.TimerManagement.Banish and Effect == Necrosis.Spell[9].Name then
			Necrosis:Msg("BAN ! BAN ! BAN !")
			Necrosis:RetraitTimerParNom(Necrosis.Spell[9], Local.TimerManagement)
				Local.TimerManagement.Banish = false
		-- Resist / immune detection || Détection des résists / immunes
		elseif subevent == "SPELL_MISSED" and sourceGUID == UnitGUID("player") and destGUID == UnitGUID("target") then
			if NecrosisConfig.AntiFearAlert
				and (Effect == Necrosis.Spell[13].Name or Effect == Necrosis.Spell[19].Name)
				and arg12 == "IMMUNE"
				then
					Local.Warning.Antifear.Immune = true
			end
			if Effect == Local.TimerManagement.LastSpell.Name
				and GetTime() <= (Local.TimerManagement.LastSpell.Time + 1.5)
				then
					Necrosis:RetraitTimerParIndex(Local.TimerManagement.LastSpell.Index, Local.TimerManagement)
			end
		-- Detection application of a spell / fire stone on a weapon || Détection application d'une pierre de sort/feu sur une arme
		elseif subevent == "ENCHANT_APPLIED"
			and destGUID == UnitGUID("player")
			and (arg9 == NecrosisConfig.ItemSwitchCombat[1] or NecrosisConfig.ItemSwitchCombat[2])
			then
				Local.SomethingOnHand = arg9
				Necrosis:UpdateIcons()
		-- End of enchantment detection || Détection fin d'enchant
		elseif subevent == "ENCHANT_REMOVE"
			and destGUID == UnitGUID("player")
			and (arg9 == NecrosisConfig.ItemSwitchCombat[1] or NecrosisConfig.ItemSwitchCombat[2])
			then
				Local.SomethingOnHand = "Rien"
				Necrosis:UpdateIcons()
		elseif subevent == "UNIT_DIED"
			then
				Necrosis:RetraitTimerParGuid(sourceGUID,Local.TimerManagement)
		end

	-- If we change weapons, we look at whether a spell / fire enchantment is on the new || Si on change d'arme, on regarde si un enchantement de sort / feu est sur la nouvelle
	elseif event == "SKILL_LINES_CHANGED" then
		local hasMainHandEnchant = GetWeaponEnchantInfo()
		if hasMainHandEnchant then
			Local.SomethingOnHand = "Truc"
		else
			Local.SomethingOnHand = "Rien"
		end
		Necrosis:UpdateIcons()

	-- If we come back into combat || Si on rentre en combat
	elseif event == "PLAYER_REGEN_DISABLED" then
		Local.PlayerInCombat = true
		-- Close the options menu || On ferme le menu des options
		if _G["NecrosisGeneralFrame"] and NecrosisGeneralFrame:IsVisible() then
			NecrosisGeneralFrame:Hide()
		end
		-- Spell button attributes are negated situational || On annule les attributs des boutons de sorts de manière situationnelle
		Necrosis:InCombatAttribute(Local.Menu.Pet, Local.Menu.Buff, Local.Menu.Curse)
	end
	return
end

------------------------------------------------------------------------------------------------------
-- FUNCTIONS NECROSIS "ON EVENT" || FONCTIONS NECROSIS "ON EVENT"
------------------------------------------------------------------------------------------------------

-- Events: PLAYER_ENTERING_WORLD and PLAYER_LEAVING_WORLD || Events : PLAYER_ENTERING_WORLD et PLAYER_LEAVING_WORLD
-- Function applied to each loading screen || Fonction appliquée à chaque écran de chargement
-- When you leave an area, you stop watching the surroundings || Quand on sort d'une zone, on arrête de surveiller les envents
-- When we enter an area, we resume surveillance || Quand on rentre dans une zone, on reprend la surveillance
-- This makes it possible to avoid a loading time that is too long for the mod || Cela permet d'éviter un temps de chargement trop long du mod
function Necrosis:RegisterManagement(RegistrationType)
	if RegistrationType == "IN" then
		for i in ipairs(Local.Events) do
			NecrosisButton:RegisterEvent(Local.Events[i])
		end
	else
		for i in ipairs(Local.Events) do
			NecrosisButton:UnregisterEvent(Local.Events[i])
		end
	end
	return
end

-- Event : UNIT_PET
-- Allows the servo to be timed, as well as to prevent for servo breaks || Permet de timer les asservissements, ainsi que de prévenir pour les ruptures d'asservissement
-- Also change the name of the pet to the replacement of it || Change également le nom du pet au remplacement de celui-ci
function Necrosis:ChangeDemon()
	-- If the new demon is a slave demon, we put a 5 minute timer || Si le nouveau démon est un démon asservi, on place un timer de 5 minutes
	if (self:UnitHasEffect("pet", self.Spell[10].Name)) then
		if (not Local.Summon.DemonEnslaved) then
			Local.Summon.DemonEnslaved = true
			Local.TimerManagement = Necrosis:InsertTimerParTable(10, "","", Local.TimerManagement)
		end
	else
		-- When the enslaved demon is lost, remove the timer and warn the warlock || Quand le démon asservi est perdu, on retire le Timer et on prévient le Démoniste
		if (Local.Summon.DemonEnslaved) then
			Local.Summon.DemonEnslaved = false
			Local.TimerManagement = self:RetraitTimerParNom(self.Spell[10].Name, Local.TimerManagement)
			if NecrosisConfig.Sound then PlaySoundFile(self.Sound.EnslaveEnd) end
			self:Msg(self.ChatMessage.Information.EnslaveBreak, "USER")
		end
	end

	-- If the demon is not enslaved we define its title, and we update its name in Necrosis || Si le démon n'est pas asservi on définit son titre, et on met à jour son nom dans Necrosis
	Local.Summon.LastDemonType = Local.Summon.DemonType
	Local.Summon.DemonType = UnitCreatureFamily("pet")
	for i = 1, #self.Translation.DemonName, 1 do
		if Local.Summon.DemonType == self.Translation.DemonName[i] and not (NecrosisConfig.PetName[i] or (UnitName("pet") == UNKNOWNOBJECT)) then
			NecrosisConfig.PetName[i] = UnitName("pet")
			self:Localization()
			break
		end
	end
	self:UpdateMana()

	return
end

-- Events : CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS, CHAT_MSG_SPELL_AURA_GONE_SELF et CHAT_MSG_SPELL_BREAK_AURA
-- Manage the appearing and disappearing effects on the warlock || Permet de gérer les effets apparaissants et disparaissants sur le démoniste
-- Based on CombatLog || Basé sur le CombatLog
function Necrosis:SelfEffect(action, nom)
	if NecrosisConfig.LeftMount then
		local NomCheval1 = GetSpellInfo(NecrosisConfig.LeftMount)
	else
		local NomCheval1 = Necrosis.Spell[2].Name
	end
	if NecrosisConfig.RightMount then
		local NomCheval2 = GetSpellInfo(NecrosisConfig.RightMount)
	else
		local NomCheval2 = Necrosis.Spell[1].Name
	end

	if action == "BUFF" then
		-- Changing the mount button when the Warlock is disassembled || Changement du bouton de monture quand le Démoniste est démonté
		if nom == Necrosis.Spell[1].Name or  nom == Necrosis.Spell[2].Name or nom == "NomCheval1" or nom == "NomCheval2" then
			Local.BuffActif.Mount = true
			if _G["NecrosisMountButton"] then
				NecrosisMountButton:SetNormalTexture("Interface\\Addons\\Necrosis\\UI\\MountButton-02")
				NecrosisMountButton:GetNormalTexture():SetDesaturated(nil)
			end
		-- Change Dominated Domination Button if Enabled + Cooldown Timer || Changement du bouton de la domination corrompue si celle-ci est activée + Timer de cooldown
		elseif  nom == Necrosis.Spell[15].Name then
			Local.BuffActif.Domination = true
			if _G["NecrosisPetMenu1"] then
				NecrosisPetMenu1:SetNormalTexture("Interface\\Addons\\Necrosis\\UI\\Domination-02")
				NecrosisPetMenu1:GetNormalTexture():SetDesaturated(nil)
			end
		-- Change the spiritual link button if it is enabled || Changement du bouton du lien spirituel si celui-ci est activé
		elseif nom == Necrosis.Spell[38].Name then
			Local.BuffActif.SoulLink = true
			if _G["NecrosisBuffMenu7"] then
				NecrosisBuffMenu7:SetNormalTexture("Interface\\Addons\\Necrosis\\UI\\SoulLink-02")
				NecrosisBuffMenu7:GetNormalTexture():SetDesaturated(nil)
			end
		-- If Backlash, to display the icon and we proc the sound || si Contrecoup, pouf on affiche l'icone et on proc le son
		-- If By-effect, one-on-one icon and one proc the sound || if By-effect, pouf one posts the icon and one proc the sound
		elseif nom == Necrosis.Translation.Proc.Backlash and NecrosisConfig.ShadowTranceAlert then
			self:Msg(self.ProcText.Backlash, "USER")
			if NecrosisConfig.Sound then PlaySoundFile(Necrosis.Sound.Backlash) end
			NecrosisBacklashButton:Show()
		-- If Twilight, to display the icon and sound || si Crépuscule, pouf on affiche l'icone et on proc le son
		-- If Twilight / Nightfall, puff one posts the icon and one proc the sound || if Twilight/Nightfall, pouf one posts the icon and one proc the sound
		elseif nom == Necrosis.Translation.Proc.ShadowTrance and NecrosisConfig.ShadowTranceAlert then
			self:Msg(self.ProcText.ShadowTrance, "USER")
			if NecrosisConfig.Sound then PlaySoundFile(Necrosis.Sound.ShadowTrance) end
			NecrosisShadowTranceButton:Show()
		end
	else
		-- Changing the mount button when the Warlock is disassembled || Changement du bouton de monture quand le Démoniste est démonté
		if nom == Necrosis.Spell[1].Name or  nom == Necrosis.Spell[2].Name or nom == "NomCheval1" or nom == "NomCheval2" then
			Local.BuffActif.Mount = false
			if _G["NecrosisMountButton"] then
				NecrosisMountButton:SetNormalTexture("Interface\\Addons\\Necrosis\\UI\\MountButton-01")
			end
		-- Domination button change when Warlock is no longer under control || Changement du bouton de Domination quand le Démoniste n'est plus sous son emprise
		elseif  nom == Necrosis.Spell[15].Name then
			Local.BuffActif.Domination = false
			if _G["NecrosisPetMenu1"] then
				NecrosisPetMenu1:SetNormalTexture("Interface\\Addons\\Necrosis\\UI\\Domination-01")
			end
		-- Changing the Spiritual Link button when the Warlock is no longer under control || Changement du bouton du Lien Spirituel quand le Démoniste n'est plus sous son emprise
		elseif nom == Necrosis.Spell[38].Name then
			Local.BuffActif.SoulLink = false
			if _G["NecrosisBuffMenu7"] then
				NecrosisBuffMenu7:SetNormalTexture("Interface\\Addons\\Necrosis\\UI\\SoulLink-01")
			end
		-- Hide the shadowtrance (nightfall) or backlash buttons when the state is ended
		elseif nom == Necrosis.Translation.Proc.ShadowTrance or nom == Necrosis.Translation.Proc.Backlash then
			NecrosisShadowTranceButton:Hide()
			NecrosisBacklashButton:Hide()
		end
	end
	Necrosis:UpdateMana()
	return
end

-- Event : UNIT_SPELLCAST_SUCCEEDED
-- Manages everything related to successful spell casts || Permet de gérer tout ce qui touche aux sorts une fois leur incantation réussie
function Necrosis:SpellManagement()
	-- print (Local.SpellCasted.Name)
	local SortActif = false
	if (Local.SpellCasted.Name) then
		-- print ('casting on target '..Local.SpellCasted.TargetName)
		-- Messages Posts Cast (Démons et TP)
		Local.SpeechManagement.SpellSucceed = self:Speech_Then(Local.SpellCasted, Local.SpeechManagement.DemonName, Local.SpeechManagement.SpellSucceed)

		-- Special case: Haunt refreshes Corruption (if present) on a target
		-- if (Local.SpellCasted.Name == self.Spell[42].Name) then
		-- 	-- Check if the target is afflicted with Corruption
		-- 	if (self:UnitHasEffect("target", self.Spell[14].Name)) then
		-- 	  Local.TimerManagement.LastSpell.Time = GetTime()

		-- 		-- Remove the old corruption timer
		-- 		Local.TimerManagement = self:RetraitTimerParNom(self.Spell[14].Name, Local.TimerManagement)

		-- 		-- Insert a new Corruption timer
		-- 		Local.TimerManagement = self:InsertTimerParTable(14, Local.SpellCasted.TargetName, Local.SpellCasted.TargetLevel, Local.TimerManagement)
		-- 	end
		-- end


		-- Create a timer when a soulstone has been used || Si le sort lancé à été une Résurrection de Pierre d'âme, on place un timer
		if (Local.SpellCasted.Name == self.Spell[11].Name) then
			if Local.SpellCasted.TargetName == UnitName("player") then
				Local.SpellCasted.TargetName = ""
				Local.SpellCasted.TargetGUID = ""
			end
			Local.TimerManagement = Necrosis:InsertTimerParTable(11, Local.SpellCasted.TargetName, "", Local.TimerManagement)
		-- Create a timer if a healthstone was used || Si le sort était une pierre de soin
		elseif Local.SpellCasted.Name:find(self.Translation.Item.Healthstone) and not Local.SpellCasted.Name:find(self.Translation.Misc.Create) then
			Local.TimerManagement = self:InsertTimerStone("Healthstone", nil, nil, Local.TimerManagement)
		-- Create a timer for any other spell cast (if valid) || Pour les autres sorts castés, tentative de timer si valable
		else
			for spell=1, #self.Spell, 1 do
				if Local.SpellCasted.Name == self.Spell[spell].Name and not (spell == 10) then
					-- Update the timer if it already exists || Si le timer existe déjà sur la cible, on le met à jour
					if Local.TimerManagement.SpellTimer[1] then
						for thisspell=1, #Local.TimerManagement.SpellTimer, 1 do
							if Local.TimerManagement.SpellTimer[thisspell].Name == Local.SpellCasted.Name
								and Local.TimerManagement.SpellTimer[thisspell].TargetGUID == Local.SpellCasted.TargetGUID
								and not (self.Spell[spell].Type == 4)	-- not a curse
								and not (self.Spell[spell].Type == 5) -- not corruption
								and not (spell == 16)
								and not (spell == 41)
								then
								-- If it is spell launched already present on a mob, we put the timer back to the bottom ||Si c'est sort lancé déjà présent sur un mob, on remet le timer à fond
								if not (spell == 9) or (spell == 9 and not self:UnitHasEffect("focus", Local.SpellCasted.Name)) then
									Local.TimerManagement.SpellTimer[thisspell].Time = self.Spell[spell].Length
									Local.TimerManagement.SpellTimer[thisspell].TimeMax = floor(GetTime() + self.Spell[spell].Length)
									if (spell == 9) and (Local.SpellCasted.Rank:find("1")) then
										Local.TimerManagement.SpellTimer[thisspell].Time = 20
										Local.TimerManagement.SpellTimer[thisspell].TimeMax = floor(GetTime() + 20)
									end
								end
								SortActif = true
								break
							end


							-- If we have banished a new target, then remove the previous timer. || Si c'est un banish sur une nouvelle cible, on supprime le timer précédent
							if Local.TimerManagement.SpellTimer[thisspell].Name == Local.SpellCasted.Name and spell == 9
								and not
									(Local.TimerManagement.SpellTimer[thisspell].TargetGUID == Local.SpellCasted.TargetGUID)
								then
								Local.TimerManagement = self:RetraitTimerParIndex(thisspell, Local.TimerManagement)
								SortActif = false
								break
							end

							-- If we have cast fear, then remove the previous timer || Si c'est un fear, on supprime le timer du fear précédent
							if Local.TimerManagement.SpellTimer[thisspell].Name == Local.SpellCasted.Name and spell == 13 then
								Local.TimerManagement = self:RetraitTimerParIndex(thisspell, Local.TimerManagement)
								SortActif = false
								break
							end

							if SortActif then
								break
							end
						end
						-- If the timer is a curse, one removes the preceding curse on the target || Si le timer est une malédiction, on enlève la précédente malédiction sur la cible
						if (self.Spell[spell].Type == 4) or (spell == 16) then
							for thisspell=1, #Local.TimerManagement.SpellTimer, 1 do
								-- But we keep the cooldown of the evil curse || Mais on garde le cooldown de la malédiction funeste
								if Local.TimerManagement.SpellTimer[thisspell].Name == self.Spell[16].Name then
									Local.TimerManagement.SpellTimer[thisspell].TargetGUID = Local.SpellCasted.TargetGUID
									Local.TimerManagement.SpellTimer[thisspell].TargetLevel = Local.SpellCasted.TargetLevel
								end
								if Local.TimerManagement.SpellTimer[thisspell].Type == 4
									and Local.TimerManagement.SpellTimer[thisspell].TargetGUID == Local.SpellCasted.TargetGUID
									then
									Local.TimerManagement = self:RetraitTimerParIndex(thisspell, Local.TimerManagement)
									break
								end
							end
							SortActif = false
						-- If its a corruption timer, remove the previous one || Si le timer est une corruption, on enlève la précédente corruption sur la cible
						elseif (self.Spell[spell].Type == 5) then
							for thisspell=1, #Local.TimerManagement.SpellTimer, 1 do
								if Local.TimerManagement.SpellTimer[thisspell].Type == 5
									and Local.TimerManagement.SpellTimer[thisspell].TargetGUID == Local.SpellCasted.TargetGUID
									then
									Local.TimerManagement = self:RetraitTimerParIndex(thisspell, Local.TimerManagement)
									break
								end
							end
							SortActif = false
						end
					end
					if not SortActif
						and not (self.Spell[spell].Type == 0)
						and not (spell == 10)
						and not (spell == 1)
						and not (spell == 2)
						then

						if (spell == 9) then

							if Necrosis.Spell[9].Rank:find("(%d+)") then
								self.Spell[spell].Length = 20
							else
								self.Spell[spell].Length = 30
							end
							Local.TimerManagement.Banish = true
						end

						-- now insert a timer for the spell that has been casted
						Local.TimerManagement = Necrosis:InsertTimerParTable(spell, Local.SpellCasted.TargetName, Local.SpellCasted.TargetLevel, Local.TimerManagement,Local.SpellCasted.TargetGUID)
						break
					end
				end
			end
		end
	end
	Local.SpellCasted = {}
	return
end

------------------------------------------------------------------------------------------------------
-- INTERFACE FUNCTIONS - XML ​​LINKS || FONCTIONS DE L'INTERFACE -- LIENS XML
------------------------------------------------------------------------------------------------------

-- Function to move Necrosis elements on the screen ||Fonction permettant le déplacement d'éléments de Necrosis sur l'écran
function Necrosis:OnDragStart(button)
	button:StartMoving()
end

-- Function stopping the movement of Necrosis elements on the screen ||Fonction arrêtant le déplacement d'éléments de Necrosis sur l'écran
function Necrosis:OnDragStop(button)
	-- We stop the movement effectively ||On arrête le déplacement de manière effective
	button:StopMovingOrSizing()
	-- We save the location of the button ||On sauvegarde l'emplacement du bouton
	local NomBouton = button:GetName()
	local AncreBouton, BoutonParent, AncreParent, BoutonX, BoutonY = button:GetPoint()
	if not BoutonParent then
		BoutonParent = "UIParent"
	else
		BoutonParent = BoutonParent:GetName()
	end
	NecrosisConfig.FramePosition[NomBouton] = {AncreBouton, BoutonParent, AncreParent, BoutonX, BoutonY}
end

-- Function managing the help bubbles ||Fonction gérant les bulles d'aide
function Necrosis:BuildTooltip(button, Type, anchor, sens)
	-- If the display of help bubbles is disabled, Bye bye! ||Si l'affichage des bulles d'aide est désactivé, Bye bye !
	if not NecrosisConfig.NecrosisToolTip then
		return
	end

	-- If the tooltip is associated with a menu button, we change the anchoring of the tooltip according to its meaning ||Si la bulle d'aide est associée à un bouton de menu, on change l'ancrage de la tooltip suivant son sens
	if sens then
		if (sens == "Pet" and NecrosisConfig.PetMenuPos.direction < 0)
			or
				(sens == "Buff" and NecrosisConfig.BuffMenuPos.direction < 0)
			or
				(sens == "Curse" and NecrosisConfig.CurseMenuPos.direction < 0)
			or
				(sens == "Timer" and NecrosisConfig.SpellTimerJust == "RIGHT")
			then
				anchor = "ANCHOR_LEFT"
		end
	end

	-- We look at whether corrupt domination, shadow guard or curse amplification are up (for tooltips) ||On regarde si la domination corrompue, le gardien de l'ombre ou l'amplification de malédiction sont up (pour tooltips)
	local start, duration, start2, duration2, start3, duration3
	if self.Spell[15].ID then
		start, duration = GetSpellCooldown(self.Spell[15].ID, BOOKTYPE_SPELL)
	else
		start = 1
		duration = 1
	end
	if self.Spell[43].ID then
		start2, duration2 = GetSpellCooldown(self.Spell[43].ID, BOOKTYPE_SPELL)
		if not start2 then start2 = 1 end
		if not duration2 then duration2 = 1 end
	else
		start2 = 1
		duration2 = 1
	end
	if self.Spell[50].ID then
		start3, duration3 = GetSpellCooldown(self.Spell[50].ID, BOOKTYPE_SPELL)
	else
		start3 = 1
		duration3 = 1
	end

	-- Creating help bubbles .... ||Création des bulles d'aides....
	GameTooltip:SetOwner(button, anchor)
	GameTooltip:SetText(self.TooltipData[Type].Label)
	-- ..... for the main button ||..... pour le bouton principal
	if (Type == "Main") then
		GameTooltip:AddLine(self.TooltipData.Main.Soulshard..Local.Soulshard.Count)
		GameTooltip:AddLine(self.TooltipData.Main.InfernalStone..Local.Reagent.Infernal)
		GameTooltip:AddLine(self.TooltipData.Main.DemoniacStone..Local.Reagent.Demoniac)
		local SoulOnHand = false
		local HealthOnHand = false
		local SpellOnHand = false
		local FireOnHand = false
		if Local.Stone.Soul.OnHand then SoulOnHand = true end
		if Local.Stone.Health.OnHand then HealthOnHand = true end
		if Local.Stone.Spell.OnHand then SpellOnHand = true end
		if Local.Stone.Fire.OnHand then FireOnHand = true end
		GameTooltip:AddLine(self.TooltipData.Main.Soulstone..self.TooltipData[Type].Stone[SoulOnHand])
		GameTooltip:AddLine(self.TooltipData.Main.Healthstone..self.TooltipData[Type].Stone[HealthOnHand])
		GameTooltip:AddLine(self.TooltipData.Main.Spellstone..self.TooltipData[Type].Stone[SpellOnHand])
		GameTooltip:AddLine(self.TooltipData.Main.Firestone..self.TooltipData[Type].Stone[FireOnHand])
		-- View the name of the daemon, or if it is slave, or "None" if no daemon is present ||Affichage du nom du démon, ou s'il est asservi, ou "Aucun" si aucun démon n'est présent
		if (Local.Summon.DemonType) then
			GameTooltip:AddLine(self.TooltipData.Main.CurrentDemon..Local.Summon.DemonType)
		elseif Local.Summon.DemonEnslaved then
			GameTooltip:AddLine(self.TooltipData.Main.EnslavedDemon)
		else
			GameTooltip:AddLine(self.TooltipData.Main.NoCurrentDemon)
		end
	-- ..... for stone buttons ||..... pour les boutons de pierre
	elseif Type:find("stone") then
		-- Soul Stone ||Pierre d'âme
		if (Type == "Soulstone") then
			-- We display the name of the stone and the action that will produce the click on the button ||On affiche le nom de la pierre et l'action que produira le clic sur le bouton
			-- And also the cooldown ||Et aussi le Temps de recharge
			if Local.Stone.Soul.Mode == 1 or Local.Stone.Soul.Mode == 3 then
				Necrosis:ManaCostLocalize(51)
			end
			self:MoneyToggle()
			NecrosisTooltip:SetBagItem(Local.Stone.Soul.Location[1], Local.Stone.Soul.Location[2])
			local itemName = tostring(NecrosisTooltipTextLeft6:GetText())
			GameTooltip:AddLine(self.TooltipData[Type].Text[Local.Stone.Soul.Mode])
			GameTooltip:AddLine(self.TooltipData[Type].Ritual)
			if itemName:find(self.Translation.Misc.Cooldown) then
				GameTooltip:AddLine(itemName)
			end
		-- Healthstone | Stone of life ||Healthstone | Pierre de vie
		elseif (Type == "Healthstone") then
			-- Idem ||Idem
			if Local.Stone.Health.Mode == 1 then
				Necrosis:ManaCostLocalize(52)
			end
			self:MoneyToggle()
			NecrosisTooltip:SetBagItem(Local.Stone.Health.Location[1], Local.Stone.Health.Location[2])
			local itemName = tostring(NecrosisTooltipTextLeft6:GetText())
			GameTooltip:AddLine(self.TooltipData[Type].Text[Local.Stone.Health.Mode])
			if Local.Stone.Health.Mode == 2 then
				GameTooltip:AddLine(self.TooltipData[Type].Text2)
			end
			if itemName:find(self.Translation.Misc.Cooldown) then
				GameTooltip:AddLine(itemName)
			end
			if  Local.Soulshard.Count > 0 and not (start3 > 0 and duration3 > 0) then
				GameTooltip:AddLine(self.TooltipData[Type].Ritual)
			end
		-- Stone of spell ||Pierre de sort
		elseif (Type == "Spellstone") then
			-- Eadem ||Eadem
			if Local.Stone.Spell.Mode == 1 then
				Necrosis:ManaCostLocalize(53)
			end
			GameTooltip:AddLine(self.TooltipData[Type].Text[Local.Stone.Spell.Mode])
		-- Fire stone ||Pierre de feu
		elseif (Type == "Firestone") then
			-- Idem ||Idem
			if Local.Stone.Fire.Mode == 1 then
				Necrosis:ManaCostLocalize(54)
			end
			GameTooltip:AddLine(self.TooltipData[Type].Text[Local.Stone.Fire.Mode])
		end
	-- ..... for the Timers button ||..... pour le bouton des Timers
	elseif (Type == "SpellTimer") then
		self:MoneyToggle()
		NecrosisTooltip:SetBagItem(Local.Stone.Hearth.Location[1], Local.Stone.Hearth.Location[2])
		local itemName = tostring(NecrosisTooltipTextLeft5:GetText())
		GameTooltip:AddLine(self.TooltipData[Type].Text)
		if itemName:find(self.Translation.Misc.Cooldown) then
			GameTooltip:AddLine(self.Translation.Item.Hearthstone.." - "..itemName)
		else
			GameTooltip:AddLine(self.TooltipData[Type].Right..GetBindLocation())
		end

	-- ..... for the shadow trance button ||..... pour le bouton de la Transe de l'ombre
	elseif (Type == "ShadowTrance") or (Type == "Backlash") then
		GameTooltip:SetText(self.TooltipData[Type].Label.."          |CFF808080"..self.Spell[45].Rank.."|r")
	-- ..... for other buffs and demons, the mana cost ... ||..... pour les autres buffs et démons, le coût en mana...
	elseif (Type == "Enslave") then
		Necrosis:ManaCostLocalize(35)
		if Local.Soulshard.Count == 0 then
			GameTooltip:AddLine("|c00FF4444"..self.TooltipData.Main.Soulshard..Local.Soulshard.Count.."|r")
		end
	elseif (Type == "Mount") and self.Spell[2].ID then
		if (NecrosisConfig.LeftMount) then
			local leftMountName = GetSpellInfo(NecrosisConfig.LeftMount);
			GameTooltip:AddLine(leftMountName);
		else
			--use tooltip for default mounts
			GameTooltip:AddLine(self.TooltipData[Type].Text);
		end
		if (NecrosisConfig.RightMount) then
			local rightMountName = GetSpellInfo(NecrosisConfig.RightMount)
			GameTooltip:AddLine(rightMountName);
		end

	elseif (Type == "Armor") then
		if self.Spell[31].ID then
			Necrosis:ManaCostLocalize(31)
		else
			Necrosis:ManaCostLocalize(36)
		end
	elseif (Type == "FelArmor") then
		Necrosis:ManaCostLocalize(47)
	elseif (Type == "Invisible") then
		Necrosis:ManaCostLocalize(33)
	elseif (Type == "Aqua") then
		Necrosis:ManaCostLocalize(32)
	elseif (Type == "Kilrogg") then
		Necrosis:ManaCostLocalize(34)
	elseif (Type == "Banish") then
		Necrosis:ManaCostLocalize(9)
		if self.Spell[9].Rank:find("2") then
		GameTooltip:AddLine(self.TooltipData[Type].Text)
		end
	elseif (Type == "Weakness") then
		Necrosis:ManaCostLocalize(23)
	elseif (Type == "Agony") then
		Necrosis:ManaCostLocalize(22)
	elseif (Type == "Tongues") then
		Necrosis:ManaCostLocalize(25)
	elseif (Type == "Exhaust") then
		Necrosis:ManaCostLocalize(40)
	elseif (Type == "Elements") then
		Necrosis:ManaCostLocalize(26)
	elseif (Type == "Doom") then
		Necrosis:ManaCostLocalize(16)
	elseif (Type == "Corruption") then
		Necrosis:ManaCostLocalize(14)
	elseif (Type == "TP") then
		Necrosis:ManaCostLocalize(37)
		if Local.Soulshard.Count == 0 then
			GameTooltip:AddLine("|c00FF4444"..self.TooltipData.Main.Soulshard..Local.Soulshard.Count.."|r")
		end
	elseif (Type == "SoulLink") then
		Necrosis:ManaCostLocalize(38)
	elseif (Type == "ShadowProtection") then
		Necrosis:ManaCostLocalize(43)
		if start2 > 0 and duration2 > 0 then
			local seconde = duration2 - ( GetTime() - start2)
			local affiche
			affiche = tostring(floor(seconde)).." "..self.Translation.Misc.Sec
			GameTooltip:AddLine(self.Translation.Misc.Cooldown..": "..affiche)
		end
	elseif (Type == "Domination") then
		if start > 0 and duration > 0 then
			local seconde = duration - ( GetTime() - start)
			local affiche, minute, time
			if seconde <= 59 then
				affiche = tostring(floor(seconde)).." "..self.Translation.Misc.Sec
			else
				minute = tostring(floor(seconde/60))
				seconde = mod(seconde, 60)
				if seconde <= 9 then
					time = "0"..tostring(floor(seconde))
				else
					time = tostring(floor(seconde))
				end
				affiche = minute..":"..time
			end
			GameTooltip:AddLine(self.Translation.Misc.Cooldown..": "..affiche)
		end
	elseif (Type == "Imp") then
		Necrosis:ManaCostLocalize(3)
		if not (start > 0 and duration > 0) then
			GameTooltip:AddLine(self.TooltipData.DominationCooldown)
		end
	elseif (Type == "Voidwalker") then
		Necrosis:ManaCostLocalize(4)
		if Local.Soulshard.Count == 0 then
			GameTooltip:AddLine("|c00FF4444"..self.TooltipData.Main.Soulshard..Local.Soulshard.Count.."|r")
		elseif not (start > 0 and duration > 0) then
			GameTooltip:AddLine(self.TooltipData.DominationCooldown)
		end
	elseif (Type == "Succubus") then
		Necrosis:ManaCostLocalize(5)
		if Local.Soulshard.Count == 0 then
			GameTooltip:AddLine("|c00FF4444"..self.TooltipData.Main.Soulshard..Local.Soulshard.Count.."|r")
		elseif not (start > 0 and duration > 0) then
			GameTooltip:AddLine(self.TooltipData.DominationCooldown)
		end
	elseif (Type == "Felhunter") then
		Necrosis:ManaCostLocalize(6)
		if Local.Soulshard.Count == 0 then
			GameTooltip:AddLine("|c00FF4444"..self.TooltipData.Main.Soulshard..Local.Soulshard.Count.."|r")
		elseif not (start > 0 and duration > 0) then
			GameTooltip:AddLine(self.TooltipData.DominationCooldown)
		end
	elseif (Type == "Felguard") then
		Necrosis:ManaCostLocalize(7)
		if Local.Soulshard.Count == 0 then
			GameTooltip:AddLine("|c00FF4444"..self.TooltipData.Main.Soulshard..Local.Soulshard.Count.."|r")
		elseif not (start > 0 and duration > 0) then
			GameTooltip:AddLine(self.TooltipData.DominationCooldown)
		end
	elseif (Type == "Infernal") then
		Necrosis:ManaCostLocalize(8)
		if Local.Reagent.Infernal == 0 then
			GameTooltip:AddLine("|c00FF4444"..self.TooltipData.Main.InfernalStone..Local.Reagent.Infernal.."|r")
		else
			GameTooltip:AddLine(self.TooltipData.Main.InfernalStone..Local.Reagent.Infernal)
		end
	elseif (Type == "Doomguard") then
		Necrosis:ManaCostLocalize(30)
		if DemoniacStone == 0 then
			GameTooltip:AddLine("|c00FF4444"..self.TooltipData.Main.DemoniacStone..Local.Reagent.Demoniac.."|r")
		else
			GameTooltip:AddLine(self.TooltipData.Main.DemoniacStone..Local.Reagent.Demoniac)
		end
	elseif (Type == "BuffMenu") then
		if Local.PlayerInCombat and NecrosisConfig.AutomaticMenu then
			GameTooltip:AddLine(self.TooltipData[Type].Text2)
		else
			GameTooltip:AddLine(self.TooltipData[Type].Text)
		end
	elseif (Type == "CurseMenu") then
		if Local.PlayerInCombat and NecrosisConfig.AutomaticMenu then
			GameTooltip:AddLine(self.TooltipData[Type].Text2)
		else
			GameTooltip:AddLine(self.TooltipData[Type].Text)
		end
	elseif (Type == "PetMenu") then
		if Local.PlayerInCombat and NecrosisConfig.AutomaticMenu then
			GameTooltip:AddLine(self.TooltipData[Type].Text2)
		else
			GameTooltip:AddLine(self.TooltipData[Type].Text)
		end
	end
	-- And hop, posting! || Et hop, affichage !
	GameTooltip:Show()
end

-- Function updating the buttons Necrosis and giving the state of the button of the soul stone || Fonction mettant à jour les boutons Necrosis et donnant l'état du bouton de la pierre d'âme
function Necrosis:UpdateIcons()

	-- If the function was called to detect an enchantment, it is detected! || Si la fonction a été appelée pour détecter un enchantement, on le détecte !
	if Local.SomethingOnHand == "Truc" then
		self:MoneyToggle()
		NecrosisTooltip:SetInventoryItem("player", 16)
		local itemName = tostring(NecrosisTooltipTextLeft8:GetText())
		if itemName and NecrosisConfig.ItemSwitchCombat[1] then
			if itemName:find(NecrosisConfig.ItemSwitchCombat[1]) then
				Local.SomethingOnHand = NecrosisConfig.ItemSwitchCombat[1]
			end
		end
		if itemName and NecrosisConfig.ItemSwitchCombat[2] then
			if itemName:find(NecrosisConfig.ItemSwitchCombat[2]) then
				Local.SomethingOnHand = NecrosisConfig.ItemSwitchCombat[2]
			end
		end
	end

	-- Soul Stone || Pierre d'âme
	-----------------------------------------------

	-- We inquire to know if a stone of soul was used -> verification in the timers || On se renseigne pour savoir si une pierre d'âme a été utilisée --> vérification dans les timers
	local SoulstoneInUse = false
	if Local.TimerManagement.SpellTimer then
		for index = 1, #Local.TimerManagement.SpellTimer, 1 do
			if (Local.TimerManagement.SpellTimer[index].Name == self.Spell[11].Name)  and Local.TimerManagement.SpellTimer[index].TimeMax > 0 then
				SoulstoneInUse = true
				break
			end
		end
	end

	-- If the stone was not used, and there is no stone in inventory -> Mode 1 || Si la Pierre n'a pas été utilisée, et qu'il n'y a pas de pierre en inventaire -> Mode 1
	if not (Local.Stone.Soul.OnHand or SoulstoneInUse) then
		Local.Stone.Soul.Mode = 1
	end

	-- If the stone was not used, but there is a stone in inventory || Si la Pierre n'a pas été utilisée, mais qu'il y a une pierre en inventaire
	if Local.Stone.Soul.OnHand and (not SoulstoneInUse) then
		-- If the stone in inventory contains a timer, and we leave a RL -> Mode 4 || Si la pierre en inventaire contient un timer, et qu'on sort d'un RL --> Mode 4
		local start, duration = GetContainerItemCooldown(Local.Stone.Soul.Location[1],Local.Stone.Soul.Location[2])
		if Local.LoggedIn and start > 0 and duration > 0 then
			Local.TimerManagement = self:InsertTimerStone("Soulstone", start, duration, Local.TimerManagement)
			Local.Stone.Soul.Mode = 4
			Local.LoggedIn = false
		-- If the stone does not contain a timer, or you do not leave an RL -> Mode 2 || Si la pierre ne contient pas de timer, ou qu'on ne sort pas d'un RL --> Mode 2
		else
			Local.Stone.Soul.Mode = 2
			Local.LoggedIn = false
		end
	end

	-- If the stone was used but there is no stone in inventory -> Mode 3 || Si la Pierre a été utilisée mais qu'il n'y a pas de pierre en inventaire --> Mode 3
	if (not Local.Stone.Soul.OnHand) and SoulstoneInUse then
		Local.Stone.Soul.Mode = 3
	end

	-- If the stone was used and there is a stone in inventory || Si la Pierre a été utilisée et qu'il y a une pierre en inventaire
	if Local.Stone.Soul.OnHand and SoulstoneInUse then
			Local.Stone.Soul.Mode = 4
	end

	-- If out of combat and we can create a stone, we associate the left button to create a stone. || Si hors combat et qu'on peut créer une pierre, on associe le bouton gauche à créer une pierre.
	if self.Spell[51].ID and NecrosisConfig.ItemSwitchCombat[4] and (Local.Stone.Soul.Mode == 1 or Local.Stone.Soul.Mode == 3) then
		self:SoulstoneUpdateAttribute("NoStone")
	end

	-- Display of the mode icon || Affichage de l'icone liée au mode
	if _G["NecrosisSoulstoneButton"] then
		NecrosisSoulstoneButton:SetNormalTexture("Interface\\AddOns\\Necrosis\\UI\\SoulstoneButton-0"..Local.Stone.Soul.Mode)
	end

	-- Stone of life || Pierre de vie
	-----------------------------------------------

	-- Mode "I have one" (2) / "I have none" (1) || Mode "j'en ai une" (2) / "j'en ai pas" (1)
	if (Local.Stone.Health.OnHand) then
		Local.Stone.Health.Mode = 2
	else
		Local.Stone.Health.Mode = 1
		-- If out of combat and we can create a stone, we associate the left button to create a stone. || Si hors combat et qu'on peut créer une pierre, on associe le bouton gauche à créer une pierre.
		if self.Spell[52].ID and NecrosisConfig.ItemSwitchCombat[3] then
			self:HealthstoneUpdateAttribute("NoStone")
		end
	end

	--Display of the mode icon || Affichage de l'icone liée au mode
	if _G["NecrosisHealthstoneButton"] then
		NecrosisHealthstoneButton:SetNormalTexture("Interface\\AddOns\\Necrosis\\UI\\HealthstoneButton-0"..Local.Stone.Health.Mode)
	end

	-- Stone of spell || Pierre de sort
	-----------------------------------------------

	-- Stone in the inventory ... || Pierre dans l'inventaire...
	if Local.Stone.Spell.OnHand then
		-- ... and on the weapon = mode 3, otherwise = mode 2 || ... et sur l'arme = mode 3, sinon = mode 2
		if Local.SomethingOnHand == NecrosisConfig.ItemSwitchCombat[1] then
			Local.Stone.Spell.Mode = 3
		else
			Local.Stone.Spell.Mode = 2
		end
	-- Stone nonexistent ... || Pierre inexistante...
	else
		-- ... but on the weapon = mode 4, otherwise = mode 1 || ... mais sur l'arme = mode 4, sinon = mode 1
		if Local.SomethingOnHand == NecrosisConfig.ItemSwitchCombat[1] then
			Local.Stone.Spell.Mode = 4
		else
			Local.Stone.Spell.Mode = 1
		end
		-- If out of combat and we can create a stone, we associate the left button to create a stone. || Si hors combat et qu'on peut créer une pierre, on associe le bouton gauche à créer une pierre.
		if self.Spell[53].ID and NecrosisConfig.ItemSwitchCombat[3] then
			self:SpellstoneUpdateAttribute("NoStone")
		end
	end

	-- Display of the mode icon || Affichage de l'icone liée au mode
	if _G["NecrosisSpellstoneButton"] then
		NecrosisSpellstoneButton:SetNormalTexture("Interface\\AddOns\\Necrosis\\UI\\SpellstoneButton-0"..Local.Stone.Spell.Mode)
	end

	-- Fire stone || Pierre de feu
	-----------------------------------------------

	-- Stone in the inventory ... || Pierre dans l'inventaire...
	if Local.Stone.Fire.OnHand then
		-- ... and on the weapon = mode 3, otherwise = mode 2 || ... et sur l'arme = mode 3, sinon = mode 2
		if Local.SomethingOnHand == NecrosisConfig.ItemSwitchCombat[2] then
			Local.Stone.Fire.Mode = 3
		else
			Local.Stone.Fire.Mode = 2
		end
	-- Stone nonexistent ... || Pierre inexistante...
	else
		-- ... but on the weapon = mode 4, otherwise = mode 1 || ... mais sur l'arme = mode 4, sinon = mode 1
		if Local.SomethingOnHand == NecrosisConfig.ItemSwitchCombat[2] then
			Local.Stone.Fire.Mode = 4
		else
			Local.Stone.Fire.Mode = 1
		end
		-- If out of combat and we can create a stone, we associate the left button to create a stone. || Si hors combat et qu'on peut créer une pierre, on associe le bouton gauche à créer une pierre.
		if self.Spell[54].ID and NecrosisConfig.ItemSwitchCombat[2] then
			self:FirestoneUpdateAttribute("NoStone")
		end
	end

	-- Display of the mode icon || Affichage de l'icone liée au mode
	if _G["NecrosisFirestoneButton"] then
		NecrosisFirestoneButton:SetNormalTexture("Interface\\AddOns\\Necrosis\\UI\\FirestoneButton-0"..Local.Stone.Fire.Mode)
	end
end

-- Update the sphere according to life || Update de la sphere en fonction de la vie
function Necrosis:UpdateHealth()
	local health = UnitHealth("player")
	if NecrosisConfig.Circle == 4 then
		local healthMax = UnitHealthMax("player")
		if health == healthMax then
			if not (Local.LastSphereSkin == NecrosisConfig.NecrosisColor.."\\Shard32") then
				Local.LastSphereSkin = NecrosisConfig.NecrosisColor.."\\Shard32"
				NecrosisButton:SetNormalTexture("Interface\\AddOns\\Necrosis\\UI\\"..Local.LastSphereSkin)
			end
		else
			local taux = math.floor(health / (healthMax / 16))
			if not (Local.LastSphereSkin == NecrosisConfig.NecrosisColor.."\\Shard"..taux) then
				Local.LastSphereSkin = NecrosisConfig.NecrosisColor.."\\Shard"..taux
				NecrosisButton:SetNormalTexture("Interface\\AddOns\\Necrosis\\UI\\"..Local.LastSphereSkin)
			end
		end
	end
	-- If the inside of the stone shows life || Si l'intérieur de la pierre affiche la vie
	if NecrosisConfig.CountType == 5 then
		NecrosisShardCount:SetText(health)
	end
end

-- Update buttons according to mana || Update des boutons en fonction de la mana
function Necrosis:UpdateMana()
	if Local.Dead then return end
  local ptype = UnitPowerType("player")
	local mana = UnitPower("player",ptype)
	local manaMax = UnitPowerMax("player", ptype)

	-- If the perimeter of the stone shows the mana || Si le pourtour de la pierre affiche la mana
	if NecrosisConfig.Circle == 3 then
		if mana == manaMax then
			if not (Local.LastSphereSkin == NecrosisConfig.NecrosisColor.."\\Shard32") then
				Local.LastSphereSkin = NecrosisConfig.NecrosisColor.."\\Shard32"
				NecrosisButton:SetNormalTexture("Interface\\AddOns\\Necrosis\\UI\\"..Local.LastSphereSkin)
			end
		else
			local taux = math.floor(mana / (manaMax / 16))
			if not (Local.LastSphereSkin == NecrosisConfig.NecrosisColor.."\\Shard"..taux) then
				Local.LastSphereSkin = NecrosisConfig.NecrosisColor.."\\Shard"..taux
				NecrosisButton:SetNormalTexture("Interface\\AddOns\\Necrosis\\UI\\"..Local.LastSphereSkin)
			end
		end
	end

	-- If the inside of the stone shows mana || Si l'intérieur de la pierre affiche la mana
	if NecrosisConfig.CountType == 4 then
		NecrosisShardCount:SetText(mana)
	end
	-- If corrupt domination cooldown is gray || Si cooldown de domination corrompue on grise
	if _G["NecrosisPetMenu1"] and self.Spell[15].ID and not Local.BuffActif.Domination then
		local start, duration = GetSpellCooldown(self.Spell[15].ID, "spell")
		if start > 0 and duration > 0 then
			if not Local.Desatured["Domination"] then
				NecrosisPetMenu1:GetNormalTexture():SetDesaturated(1)
				Local.Desatured["Domination"] = true
			end
		else
			if Local.Desatured["Domination"] then
				NecrosisPetMenu1:GetNormalTexture():SetDesaturated(nil)
				Local.Desatured["Domination"] = false
			end
		end
	end

	-- If shadow guardian cooldown we gray || Si cooldown de gardien de l'ombre on grise
	if _G["NecrosisBuffMenu8"] and self.Spell[43].ID then
		local start, duration = GetSpellCooldown(self.Spell[43].ID, "spell")
		if self.Spell[43].Mana > mana and start > 0 and duration > 0 then
			if not Local.Desatured["Gardien"] then
				NecrosisBuffMenu8:GetNormalTexture():SetDesaturated(1)
				Local.Desatured["Gardien"] = true
			end
		else
			if Local.Desatured["Gardien"] then
				NecrosisBuffMenu8:GetNormalTexture():SetDesaturated(nil)
				Local.Desatured["Gardien"] = false
			end
		end
	end


	-- Demon button || Bouton des démons
	-----------------------------------------------
	local ManaPet = new("array",
		true, true, true, true, true, true, true
	)

	if mana then
	-- Coloring the button in gray if not enough mana || Coloration du bouton en grisé si pas assez de mana
		if self.Spell[3].ID then

			if self.Spell[3].Mana > mana then
				for i = 1, 7, 1 do
					ManaPet[i] = false
				end
			elseif self.Spell[4].ID then
				if self.Spell[4].Mana > mana then
					for i = 2, 7, 1 do
						ManaPet[i] = false
					end
				elseif self.Spell[8].ID then
					if self.Spell[8].Mana > mana then
							ManaPet[7] = false
							ManaPet[8] = false
					elseif self.Spell[30].ID then
						if self.Spell[30].Mana > mana then
							ManaPet[8] = false
						end
					end
				end
			end
		end
	end
	-- Coloring of the button in gray if no stone for the invocation || Coloration du bouton en grisé si pas de pierre pour l'invocation
	if Local.Soulshard.Count == 0 then
		for i = 2, 5, 1 do
			ManaPet[i] = false
		end
	end
	if Local.Reagent.Infernal == 0 then
		ManaPet[6] = false
	end
	if Local.Reagent.Demoniac == 0 then
		ManaPet[7] = false
	end

	-- Texturing of pet buttons || Texturage des boutons de pet
	local PetNameHere = new("array",
		"Imp-0", "Voidwalker-0", "Succubus-0", "Felhunter-0", "Felguard-0", "Infernal-0", "Doomguard-0"
	)
	for i = 1, #PetNameHere, 1 do
		local PetManaButton = _G["NecrosisPetMenu"..(i + 1)]
		if PetManaButton
			and Local.Summon.LastDemonType
			and Local.Summon.LastDemonType == self.Translation.DemonName[i]
			and not (Local.Summon.LastDemonType == Local.Summon.DemonType)
			then
				PetManaButton:SetNormalTexture("Interface\\Addons\\Necrosis\\UI\\"..PetNameHere[i].."1")
				Local.Summon.LastDemonType = nil
		end
		if PetManaButton
			and Local.Summon.DemonType
			and Local.Summon.DemonType == self.Translation.DemonName[i]
			then
				PetManaButton:SetNormalTexture("Interface\\Addons\\Necrosis\\UI\\"..PetNameHere[i].."2")
		elseif PetManaButton and ManaPet[i] then
			if Local.Desatured["NecrosisPetMenu"..(i + 1)] then
				PetManaButton:GetNormalTexture():SetDesaturated(nil)
				Local.Desatured["NecrosisPetMenu"..(i + 1)] = false
			end
		elseif PetManaButton then
			if not Local.Desatured["NecrosisPetMenu"..(i + 1)] then
				PetManaButton:GetNormalTexture():SetDesaturated(1)
				Local.Desatured["NecrosisPetMenu"..(i + 1)] = true
			end
		end
	end
	del(PetNameHere)
	del(ManaPet)


	-- Buffs button || Bouton des buffs
	-----------------------------------------------

	if mana then
	-- Coloring the button in gray if not enough mana || Coloration du bouton en grisé si pas assez de mana
		if self.Spell[35].ID then
			if self.Spell[35].Mana > mana or Local.Soulshard.Count == 0 then
				if not Local.Desatured["Enslave"] then
					if _G["NecrosisPetMenu9"] then
						NecrosisPetMenu9:GetNormalTexture():SetDesaturated(1)
					end
					Local.Desatured["Enslave"] = true
				end
			else
				if Local.Desatured["Enslave"]then
					if _G["NecrosisPetMenu9"] then
						NecrosisPetMenu9:GetNormalTexture():SetDesaturated(nil)
					end
					Local.Desatured["Enslave"] = false
				end
			end
		end
		if _G["NecrosisBuffMenu1"] and self.Spell[31].ID then
			if self.Spell[31].Mana > mana then
				if  not Local.Desatured["Armor"] then
					NecrosisBuffMenu1:GetNormalTexture():SetDesaturated(1)
					Local.Desatured["Armor"] = true
				end
			else
				if Local.Desatured["Armor"] then
					NecrosisBuffMenu1:GetNormalTexture():SetDesaturated(nil)
					Local.Desatured["Armor"] = false
				end
			end
		elseif _G["NecrosisBuffMenu1"] and self.Spell[36].ID then
			if self.Spell[36].Mana > mana then
				if not Local.Desatured["Armor"] then
					NecrosisBuffMenu1:GetNormalTexture():SetDesaturated(1)
					Local.Desatured["Armor"] = true
				end
			else
				if Local.Desatured["Armor"] then
					NecrosisBuffMenu1:GetNormalTexture():SetDesaturated(nil)
					Local.Desatured["Armor"] = false
				end
			end
		elseif _G["NecrosisBuffMenu7"] and self.Spell[38].ID and not Local.BuffActif.SoulLink then
			if self.Spell[38].Mana > mana then
				if not Local.Desatured["SoulLink"] then
					NecrosisBuffMenu7:GetNormalTexture():SetDesaturated(1)
					Local.Desatured["SoulLink"] = true
				end
			else
				if Local.Desatured["SoulLink"] then
					NecrosisBuffMenu7:GetNormalTexture():SetDesaturated(nil)
					Local.Desatured["SoulLink"] = false
				end
			end
		end

		local BoutonNumber = new("array",
			2, 3, 4, 5, 6, 11
		)
		local SortNumber = new("array",
			47, 32, 33, 34, 37, 9
		)
		for i = 1, #SortNumber, 1 do
			local f = _G["NecrosisBuffMenu"..BoutonNumber[i]]
			if f and self.Spell[SortNumber[i]].ID then
				if self.Spell[SortNumber[i]].Mana > mana then
					if not Local.Desatured["NecrosisBuffMenu"..BoutonNumber[i]] then
						f:GetNormalTexture():SetDesaturated(1)
						Local.Desatured["NecrosisBuffMenu"..BoutonNumber[i]] = true
					end
				else
					if Local.Desatured["NecrosisBuffMenu"..BoutonNumber[i]] then
						f:GetNormalTexture():SetDesaturated(nil)
						Local.Desatured["NecrosisBuffMenu"..BoutonNumber[i]] = false
					end
				end
			end
		end
		del(BoutonNumber)
		del(SortNumber)

		if _G["NecrosisPetMenu10"] and self.Spell[44].ID then
			if not UnitExists("pet") then
				if not Local.Desatured["Sacrifice"] then
					NecrosisPetMenu10:GetNormalTexture():SetDesaturated(1)
					Local.Desatured["Sacrifice"] = true
				end
			else
				if Local.Desatured["Sacrifice"] then
					NecrosisPetMenu10:GetNormalTexture():SetDesaturated(nil)
					Local.Desatured["Sacrifice"] = false
				end
			end
		end

	end

	-- Curses button || Bouton des curses
	-----------------------------------------------

	if mana then
		local SpellMana = new("array",
													 23, -- Curse of weakness
													 22, -- Curse of agony
													 25, -- Curse of tongues
													 40, -- Curse of exhaustion
													 26, -- Curse of the elements
													 16, -- Curse of doom
													 14  -- Corruption
													)

		-- Coloring the button in gray if not enough mana || Coloration du bouton en grisé si pas assez de mana
		for i = 1, #SpellMana, 1 do
			local f = _G["NecrosisCurseMenu"..i+1]
			if f and self.Spell[SpellMana[i]].ID then
				if self.Spell[SpellMana[i]].Mana > mana then
					if not Local.Desatured["NecrosisCurseMenu"..i+1] then
						f:GetNormalTexture():SetDesaturated(1)
						Local.Desatured["NecrosisCurseMenu"..i+1] = true
					end
				else
					if Local.Desatured["NecrosisCurseMenu"..i+1] then
						f:GetNormalTexture():SetDesaturated(nil)
						Local.Desatured["NecrosisCurseMenu"..i+1] = false
					end
				end
			end
		end
		del(SpellMana)
	end


	-- Timers button || Bouton des Timers
	-----------------------------------------------
	if Local.Stone.Hearth.Location[1] then
		local start, duration, enable = GetContainerItemCooldown(Local.Stone.Hearth.Location[1], Local.Stone.Hearth.Location[2])
		if duration > 20 and start > 0 then
			if not Local.Stone.Hearth.Cooldown then
				NecrosisSpellTimerButton:GetNormalTexture():SetDesaturated(1)
				Local.Stone.Hearth.Cooldown = true
			end
		else
			if Local.Stone.Hearth.Cooldown then
				NecrosisSpellTimerButton:GetNormalTexture():SetDesaturated(nil)
				Local.Stone.Hearth.Cooldown = false
			end
		end
	end
end


------------------------------------------------------------------------------------------------------
-- FUNCTIONS MANAGING STONES & SHARDS || FONCTIONS DES PIERRES ET DES FRAGMENTS
------------------------------------------------------------------------------------------------------

-- Explore bags for stones & shards || Fonction qui fait l'inventaire des éléments utilisés en démonologie : Pierres, Fragments, Composants d'invocation
function Necrosis:BagExplore(arg)
	for container = 0, 4, 1 do
		for i = 1, 3, 1 do
			if GetBagName(container) == self.Translation.Item.SoulPouch[i] then
				Local.BagIsSoulPouch[container + 1] = true
				break
			else
				Local.BagIsSoulPouch[container + 1] = false
			end
		end
	end
	local AncienCompte = Local.Soulshard.Count

	if not arg then
		Local.Stone.Soul.OnHand = nil
		Local.Stone.Health.OnHand = nil
		Local.Stone.Fire.OnHand = nil
		Local.Stone.Spell.OnHand = nil
		Local.Stone.Hearth.OnHand = nil
		-- Search all bags || Parcours des sacs
		for container = 0, 4, 1 do
			-- Exit if its a known soul bag (which can only store shards) || Parcours des emplacements des sacs
			if Local.BagIsSoulPouch[container + 1] then break end
			for slot=1, GetContainerNumSlots(container), 1 do
				self:MoneyToggle()
				NecrosisTooltip:SetBagItem(container, slot)
				local itemName = tostring(NecrosisTooltipTextLeft1:GetText())
				-- If there is an item located in that bag slot || Dans le cas d'un emplacement non vide
				if itemName then
					-- Check if its a soulstone || Si c'est une pierre d'âme, on note son existence et son emplacement
					if itemName:find(self.Translation.Item.Soulstone) then
						Local.Stone.Soul.OnHand = container
						Local.Stone.Soul.Location = {container,slot}
						NecrosisConfig.ItemSwitchCombat[4] = itemName

						-- Update its button attributes on the sphere || On attache des actions au bouton de la pierre
						self:SoulstoneUpdateAttribute()
					-- Check if its a healthstone || Même chose pour une pierre de soin
					elseif itemName:find(self.Translation.Item.Healthstone) then
						Local.Stone.Health.OnHand = container
						Local.Stone.Health.Location = {container,slot}
						NecrosisConfig.ItemSwitchCombat[3] = itemName

						-- Update its button attributes on the sphere || On attache des actions au bouton de la pierre
						self:HealthstoneUpdateAttribute()
					-- Check if its a spellstone || Et encore pour la pierre de sort
					elseif itemName:find(self.Translation.Item.Spellstone) then
						Local.Stone.Spell.OnHand = container
						Local.Stone.Spell.Location = {container,slot}
						NecrosisConfig.ItemSwitchCombat[1] = itemName

						-- Update its button attributes on the sphere || On attache des actions au bouton de la pierre
						self:SpellstoneUpdateAttribute()
					-- Check if its a firestone || La pierre de feu maintenant
					elseif itemName:find(self.Translation.Item.Firestone) then
						Local.Stone.Fire.OnHand = container
						NecrosisConfig.ItemSwitchCombat[2] = itemName

						-- Update its button attributes on the sphere || On attache des actions au bouton de la pierre
						self:FirestoneUpdateAttribute()
					-- Check if its a hearthstone || et enfin la pierre de foyer
					elseif itemName:find(self.Translation.Item.Hearthstone) then
						Local.Stone.Hearth.OnHand = container
						Local.Stone.Hearth.Location = {container,slot}
					end
				end
			end
		end
	else
		if Local.Stone.Soul.OnHand == arg then Local.Stone.Soul.OnHand = nil end
		if Local.Stone.Health.OnHand == arg then Local.Stone.Health.OnHand = nil end
		if Local.Stone.Fire.OnHand == arg then Local.Stone.Fire.OnHand = nil end
		if Local.Stone.Spell.OnHand == arg then Local.Stone.Spell.OnHand = nil end
		if Local.Stone.Hearth.OnHand == arg then Local.Stone.Hearth.OnHand = nil end
		for slot=1, GetContainerNumSlots(arg), 1 do
			self:MoneyToggle()
			NecrosisTooltip:SetBagItem(arg, slot)
			local itemName = tostring(NecrosisTooltipTextLeft1:GetText())
			-- If there is an item located in that bag slot || Dans le cas d'un emplacement non vide
			if itemName then
				-- Check if its a soulstone || Si c'est une pierre d'âme, on note son existence et son emplacement
				if itemName:find(self.Translation.Item.Soulstone) then
					Local.Stone.Soul.OnHand = arg
					Local.Stone.Soul.Location = {arg,slot}
					NecrosisConfig.ItemSwitchCombat[4] = itemName

					-- Update its button attributes on the sphere || On attache des actions au bouton de la pierre
					self:SoulstoneUpdateAttribute()
				-- Check if its a healthstone || Même chose pour une pierre de soin
				elseif itemName:find(self.Translation.Item.Healthstone) then
					Local.Stone.Health.OnHand = arg
					Local.Stone.Health.Location = {arg,slot}
					NecrosisConfig.ItemSwitchCombat[3] = itemName

					-- Update its button attributes on the sphere || On attache des actions au bouton de la pierre
					self:HealthstoneUpdateAttribute()
				-- Check if its a spellstone || Et encore pour la pierre de sort
				elseif itemName:find(self.Translation.Item.Spellstone) then
					Local.Stone.Spell.OnHand = arg
					Local.Stone.Spell.Location = {arg,slot}
					NecrosisConfig.ItemSwitchCombat[1] = itemName

					-- Update its button attributes on the sphere || On attache des actions au bouton de la pierre
					self:SpellstoneUpdateAttribute()
				-- Check if its a firestone || La pierre de feu maintenant
				elseif itemName:find(self.Translation.Item.Firestone) then
					Local.Stone.Fire.OnHand = arg
					NecrosisConfig.ItemSwitchCombat[2] = itemName

					-- Update its button attributes on the sphere || On attache des actions au bouton de la pierre
					self:FirestoneUpdateAttribute()
				-- Check if its a hearthstone || et enfin la pierre de foyer
				elseif itemName:find(self.Translation.Item.Hearthstone) then
					Local.Stone.Hearth.OnHand = arg
					Local.Stone.Hearth.Location = {arg,slot}
				end
			end
		end
	end

	-- Update stone / reagent counters
	Local.Soulshard.Count = GetItemCount(6265)
	Local.Reagent.Infernal = GetItemCount(5565)
	Local.Reagent.Demoniac = GetItemCount(16583)
	-- Destroy extra shards (if enabled) || Si il y a un nombre maximum de fragments à conserver, on enlève les supplémentaires
	if NecrosisConfig.DestroyShard
		and NecrosisConfig.DestroyCount
		and NecrosisConfig.DestroyCount > 0
		then
			for container = 0, 4, 1 do
				if Local.BagIsSoulPouch[container + 1] then break end
				for slot=1, GetContainerNumSlots(container), 1 do
					local itemLink = GetContainerItemLink(container, slot)
					if (itemLink) then
						local _, itemID = strsplit(":", itemLink)
						itemID = tonumber(itemID)
						if (itemID == 6265) then
							if (math.floor(NecrosisConfig.DestroyCount) < GetItemCount(6265)) then
								PickupContainerItem(container, slot)
								if (CursorHasItem()) then
									DeleteCursorItem()
									Local.Soulshard.Count = GetItemCount(6265)
								end
							end
							break
						end
					end
				end
				if math.floor(NecrosisConfig.DestroyCount) >= Local.Soulshard.Count then break end
			end
	end

	-- Updtae the main (sphere) button display || Affichage du bouton principal de Necrosis
	if NecrosisConfig.Circle == 1 then
		if (Local.Soulshard.Count <= 32) then
			if not (Local.LastSphereSkin == NecrosisConfig.NecrosisColor.."\\Shard"..Local.Soulshard.Count) then
				Local.LastSphereSkin = NecrosisConfig.NecrosisColor.."\\Shard"..Local.Soulshard.Count
				NecrosisButton:SetNormalTexture("Interface\\AddOns\\Necrosis\\UI\\"..Local.LastSphereSkin)
			end
		elseif not (Local.LastSphereSkin == NecrosisConfig.NecrosisColor.."\\Shard32") then
			Local.LastSphereSkin = NecrosisConfig.NecrosisColor.."\\Shard32"
			NecrosisButton:SetNormalTexture("Interface\\AddOns\\Necrosis\\UI\\"..Local.LastSphereSkin)
		end
	elseif NecrosisConfig.Circle == 2 and (Local.Stone.Soul.Mode == 1 or Local.Stone.Soul.Mode == 2) then

		if (Local.Soulshard.Count <= 32) then
			if not (Local.LastSphereSkin == NecrosisConfig.NecrosisColor:gsub("Turquoise", "Bleu"):gsub("Rose", "Bleu"):gsub("Orange", "Bleu").."\\Shard"..Local.Soulshard.Count) then
				Local.LastSphereSkin = NecrosisConfig.NecrosisColor:gsub("Turquoise", "Bleu"):gsub("Rose", "Bleu"):gsub("Orange", "Bleu").."\\Shard"..Local.Soulshard.Count
				NecrosisButton:SetNormalTexture("Interface\\AddOns\\Necrosis\\UI\\"..Local.LastSphereSkin)
			end
		elseif not (Local.LastSphereSkin == NecrosisConfig.NecrosisColor:gsub("Turquoise", "Bleu"):gsub("Rose", "Bleu"):gsub("Orange", "Bleu").."\\Shard32") then
			Local.LastSphereSkin = NecrosisConfig.NecrosisColor:gsub("Turquoise", "Bleu"):gsub("Rose", "Bleu"):gsub("Orange", "Bleu").."\\Shard32"
			NecrosisButton:SetNormalTexture("Interface\\AddOns\\Necrosis\\UI\\"..Local.LastSphereSkin)
		end
	end
	if NecrosisConfig.ShowCount then
		if NecrosisConfig.CountType == 2 then
			NecrosisShardCount:SetText(Local.Reagent.Infernal.." / "..Local.Reagent.Demoniac)
		elseif NecrosisConfig.CountType == 1 then
			if Local.Soulshard.Count < 10 then
				NecrosisShardCount:SetText("0"..Local.Soulshard.Count)
			else
				NecrosisShardCount:SetText(Local.Soulshard.Count)
			end
		end
	else
		NecrosisShardCount:SetText("")
	end
	-- Update icons and we're done || Et on met le tout à jour !
	self:UpdateIcons()

	-- If bags are full (or if we have reached the limit) then display a notification message || S'il y a plus de fragment que d'emplacements dans le sac défini, on affiche un message d'avertissement
	if NecrosisConfig.SoulshardSort then
		local CompteMax = GetContainerNumSlots(NecrosisConfig.SoulshardContainer)
		for i = 1, 5, 1 do
			if Local.BagIsSoulPouch[i] and (not NecrosisConfig.SoulshardContainer == i - 1) then
				CompteMax = CompteMax + GetContainerNumSlots(i-1)
			end
		end
		if Local.Soulshard.Count > AncienCompte and Local.Soulshard.Count == CompteMax then
			if (NecrosisConfig.SoulshardDestroy) then
				self:Msg(self.ChatMessage.Bag.FullPrefix..GetBagName(NecrosisConfig.SoulshardContainer)..self.ChatMessage.Bag.FullDestroySuffix)
			else
				self:Msg(self.ChatMessage.Bag.FullPrefix..GetBagName(NecrosisConfig.SoulshardContainer)..self.ChatMessage.Bag.FullSuffix)
			end
		end
	end
end

-- Allows you to find / arrange shards in bags || Fonction qui permet de trouver / ranger les fragments dans les sacs
function Necrosis:SoulshardSwitch(Type)
	-- print (TYPE .. "SS type check".. Local.Soulshard.Move)
	if (Type == "CHECK") then Local.Soulshard.Move = 0 end
	for container = 0, 4, 1 do
		if Local.BagIsSoulPouch[container+1] then break end
		if not (container == NecrosisConfig.SoulshardContainer) then
			for slot = 1, GetContainerNumSlots(container), 1 do
				local itemLink = GetContainerItemLink(container, slot)
				if (itemLink) then
					local _, itemID = strsplit(":", itemLink)
					itemID = tonumber(itemID)
					if (itemID == 6265) then
						if (Type == "CHECK") then
							Local.Soulshard.Move = Local.Soulshard.Move + 1
						elseif (Type == "MOVE") then
							self:FindSlot(container, slot)
							Local.Soulshard.Move = Local.Soulshard.Move - 1
						end
					end
				end
			end
		end
	end
end

-- Finds a new bag / slot when moving shards || Pendant le déplacement des fragments, il faut trouver un nouvel emplacement aux objets déplacés :)
function Necrosis:FindSlot(shardIndex, shardSlot)
	local full = true
	for slot=1, GetContainerNumSlots(NecrosisConfig.SoulshardContainer), 1 do
		self:MoneyToggle()
 		NecrosisTooltip:SetBagItem(NecrosisConfig.SoulshardContainer, slot)
 		local itemInfo = tostring(NecrosisTooltipTextLeft1:GetText())
		if not itemInfo:find(self.Translation.Item.Soulshard) then
			PickupContainerItem(shardIndex, shardSlot)
			PickupContainerItem(NecrosisConfig.SoulshardContainer, slot)
			if (CursorHasItem()) then
				if shardIndex == 0 then
					PutItemInBackpack()
				else
					PutItemInBag(19 + shardIndex)
				end
			end
			full = false
			break
		end
	end
	-- Destory extra shards if the option is enabled || Destruction des fragments en sur-nombre si l'option est activée
	if (full and NecrosisConfig.SoulshardDestroy) then

		if (math.floor(NecrosisConfig.DestroyCount) < Local.Soulshard.Count) then
			PickupContainerItem(shardIndex, shardSlot)
			if (CursorHasItem()) then
				DeleteCursorItem()
				Local.Soulshard.Count = GetItemCount(6265)
			end
		end
	end
end

------------------------------------------------------------------------------------------------------
-- VARIOUS FUNCTIONS || FONCTIONS DES SORTS
------------------------------------------------------------------------------------------------------

-- Display or Hide buttons depending on spell availability || Affiche ou masque les boutons de sort à chaque nouveau sort appris
function Necrosis:ButtonSetup()

	local NBRScale = (100 + (NecrosisConfig.NecrosisButtonScale - 85)) / 100
	if NecrosisConfig.NecrosisButtonScale <= 95 then
		NBRScale = 1.1
	end

	local ButtonName = new("array",
		"NecrosisFirestoneButton",
		"NecrosisSpellstoneButton",
		"NecrosisHealthstoneButton",
		"NecrosisSoulstoneButton",
		"NecrosisBuffMenuButton",
		"NecrosisMountButton",
		"NecrosisPetMenuButton",
		"NecrosisCurseMenuButton"
	)

	for index, valeur in ipairs(ButtonName) do
		local f = _G[valeur]
		if f then f:Hide() end
	end

	local SpellExist = new("array",
		self.Spell[54].ID,
		self.Spell[53].ID,
		self.Spell[52].ID,
		self.Spell[51].ID,
		Local.Menu.Buff[1],
		Local.Summon.SteedAvailable,
		Local.Menu.Pet[1],
		Local.Menu.Curse[1]
		-- self.Spell[27].ID  Not in classic //TODO clear up
	)
	if NecrosisConfig.NecrosisLockServ then

		local indexScale = -36
		for index=1, #NecrosisConfig.StonePosition, 1 do
			for button = 1, #NecrosisConfig.StonePosition, 1 do
				if math.abs(NecrosisConfig.StonePosition[index]) == button
					and NecrosisConfig.StonePosition[button] > 0
					and SpellExist[button] then
						local f = _G[ButtonName[button]]

						if not f then
							f = self:CreateSphereButtons(ButtonName[button])
							self:StoneAttribute(Local.Summon.SteedAvailable)
						end
						f:ClearAllPoints()
						f:SetPoint(
							"CENTER", "NecrosisButton", "CENTER",
							((40 * NBRScale) * cos(NecrosisConfig.NecrosisAngle - indexScale)),
							((40 * NBRScale) * sin(NecrosisConfig.NecrosisAngle - indexScale))
						)
						f:Show()
						indexScale = indexScale + 36
						break
				end
			end
		end
	else
		for index=1, #NecrosisConfig.StonePosition, 1 do
			for button = 1, #NecrosisConfig.StonePosition, 1 do
				if math.abs(NecrosisConfig.StonePosition[index]) == button
					and NecrosisConfig.StonePosition[button] > 0
					and SpellExist[button] then
						local f = _G[ButtonName[button]]
						if not f then
							f = self:CreateSphereButtons(ButtonName[button])
							self:StoneAttribute(Local.Summon.SteedAvailable)
						end
						f:ClearAllPoints()
						f:SetPoint(
							NecrosisConfig.FramePosition[ButtonName[button]][1],
							NecrosisConfig.FramePosition[ButtonName[button]][2],
							NecrosisConfig.FramePosition[ButtonName[button]][3],
							NecrosisConfig.FramePosition[ButtonName[button]][4],
							NecrosisConfig.FramePosition[ButtonName[button]][5]
						)
						f:Show()
						break
				end
			end
		end
	end
	del(ButtonName)
	del(SpellExist)
end

-- Input a spell check on Minor Major Lesser Greater and turn it into a rank
function Necrosis:StoneToRank(spellName)
	if (spellName:find(self.Translation.StoneRank.Minor))  then
		return self.Translation.Misc.Rank .. " 1"
	end
	if (spellName:find(self.Translation.StoneRank.Major)) then
		return self.Translation.Misc.Rank .. " 5"
	end
	if (spellName:find(self.Translation.StoneRank.Lesser)) then
		return self.Translation.Misc.Rank .. " 2"
	end
	if (spellName:find(self.Translation.StoneRank.Greater)) then
		return self.Translation.Misc.Rank .. " 4"
	end
	return self.Translation.Misc.Rank .. " 3"
end
-- Inputa rank and convert it to major lesser greater etc
function Necrosis:RankToStone(rank)
	if (rank == self.Translation.Misc.Rank .. " 1" )  then
		return " ("..self.Translation.StoneRank.Minor..")"
	end
	if (rank == self.Translation.Misc.Rank .. " 2" )  then
		return " ("..self.Translation.StoneRank.Lesser..")"
	end
	if (rank == self.Translation.Misc.Rank .. " 4" )  then
		return " ("..self.Translation.StoneRank.Greater..")"
	end
	if (rank == self.Translation.Misc.Rank .. " 5" )  then
		return " ("..self.Translation.StoneRank.Major..")"
	end
	return ""
end
-- My favourite feature! Create a list of spells known by the warlock sorted by name & rank || Ma fonction préférée ! Elle fait la liste des sorts connus par le démo, et les classe par rang.
-- Select the highest available spell in the case of stones. || Pour les pierres, elle sélectionne le plus haut rang connu
function Necrosis:SpellSetup()
--    print("SpellSetup")
	local CurrentSpells = new("hash",
		"ID", {},
		"Name", {},
		"subName", {}
	)

	local spellID = 1
	local Invisible = 0
	local InvisibleID = 0
	-- local totalSpellTabs = GetNumSpellTabs();

	-- Search for all spells known by the warlock || On va parcourir tous les sorts possedés par le Démoniste
	while true do

		local spellName, subSpellName = GetSpellBookItemName(spellID, BOOKTYPE_SPELL)

		if not spellName then
			do break end
		end
		if(spellName:find(self.Translation.Misc.Create .. " " .. self.Translation.Item.Healthstone) )then
			subSpellName= Necrosis:StoneToRank(spellName)
			spellName = self.Translation.Misc.Create .. " " .. self.Translation.Item.Healthstone
		end
		if(spellName:find(self.Translation.Misc.Create .. " " .. self.Translation.Item.Soulstone) )then
			subSpellName= Necrosis:StoneToRank(spellName)
			spellName = self.Translation.Misc.Create .. " " .. self.Translation.Item.Soulstone
		end
		if(spellName:find(self.Translation.Misc.Create .. " " .. self.Translation.Item.Firestone) )then
			subSpellName= Necrosis:StoneToRank(spellName)
			spellName = self.Translation.Misc.Create .. " " .. self.Translation.Item.Firestone
		end
		if(spellName:find(self.Translation.Misc.Create .. " " .. self.Translation.Item.Spellstone) )then
			subSpellName= Necrosis:StoneToRank(spellName)
			spellName = self.Translation.Misc.Create .. " " .. self.Translation.Item.Spellstone
		end
		-- Print(subSpellName)
		-- Print(spellName.."   -   "..subSpellName.."----"..spellID)
		-- For spells with numbered ranks, compare each one || Pour les sorts avec des rangs numérotés, on compare pour chaque sort les rangs 1 à 1
		-- And preserve the highest rank || Le rang supérieur est conservé
		if (subSpellName and not (subSpellName == " " or subSpellName == "")) then
			local _, _, spellRank = subSpellName:find("(%d+)")
			spellRank = tonumber(spellRank)

			if (spellRank ~= nil) then
				local found = false
				for index=1, #CurrentSpells.Name, 1 do
					--  a version of the spell is already in our table
					if (CurrentSpells.Name[index] == spellName) then
						found = true
						local _, _, CurrentRank = CurrentSpells.subName[index]:find("(%d+)")
						CurrentRank = tonumber(CurrentRank)
						if (CurrentRank ~= nil) then
							-- Higher rank spell? Update the table
							if (CurrentRank < spellRank) then
								CurrentSpells.ID[index] = spellID
								CurrentSpells.subName[index] = subSpellName
							end
						end
						break
					end
				end
				-- The highest rank of each spell is inserted into the table || Les plus grands rangs de chacun des sorts à rang numérotés sont insérés dans la table
				if (not found) then
					table.insert(CurrentSpells.ID, spellID)
					table.insert(CurrentSpells.Name, spellName)
					table.insert(CurrentSpells.subName, subSpellName)
				end
			end
		end
		spellID = spellID + 1
	end

	-- Update the list of spells with the new ranks || On met à jour la liste des sorts avec les nouveaux rangs
	for spell=1, #self.Spell, 1 do
		for index = 1, #CurrentSpells.Name, 1 do
			if (self.Spell[spell].Name == CurrentSpells.Name[index]) then
				self.Spell[spell].ID = CurrentSpells.ID[index]
				self.Spell[spell].Rank = CurrentSpells.subName[index]
			end
		end
	end
	del(CurrentSpells)

	for spellID = 1, MAX_SPELLS, 1 do
		local spellName, subSpellName = GetSpellBookItemName(spellID, BOOKTYPE_SPELL)
		if (spellName) then
			for index = 1, #self.Spell, 1 do
				if self.Spell[index].Name == spellName then
					self:MoneyToggle()
					if not self.Spell[index].ID then
						self.Spell[index].ID = spellID
					end
					self.Spell[index].Mana = getManaCostForSpell(spellName) or 100
				end
			end
		end
	end

	-- Update the spell durations according to their rank || On met à jour la durée de chaque sort en fonction de son rang
	-- Fear || Peur
	if self.Spell[13] and self.Spell[13].ID then
		local _, _, lengtH = self.Spell[13].Rank:find("(%d+)")
		if lengtH then
			lengtH = tonumber(lengtH)
			self.Spell[13].Length = tonumber(lengtH) * 5 + 5
		end
	end
	-- Corruption
	if self.Spell[14] and self.Spell[14].ID then
		local _, _, ranK = self.Spell[14].Rank:find("(%d+)")
		if ranK then
			ranK = tonumber(ranK)
			if self.Spell[14].ID and ranK <= 2 then
				self.Spell[14].Length = ranK * 3 + 9
			end
		end
	end

	-- WoW 3.0 :  Les montures se retrouvent dans une interface à part
	-- if GetNumCompanions("MOUNT") > 0 then
	-- 	for i = 1, GetNumCompanions("MOUNT"), 1 do
	-- 		local _, NomCheval, SpellCheval = Necrosis:GetCompanionInfo("MOUNT", i)
	-- 		if NomCheval == self.Spell[1].Name then
	-- 			self.Spell[1].ID = SpellCheval
	-- 		end
	-- 		if NomCheval == self.Spell[2].Name then
	-- 			self.Spell[2].ID = SpellCheval
	-- 		end
	-- 	end
	-- end

	-- associate the mounts to the sphere button || Association du sort de monture correct au bouton

	if (self.Spell[1] and self.Spell[1].ID) or (self.Spell[2] and self.Spell[2].ID) then
		Local.Summon.SteedAvailable = true
	else
		Local.Summon.SteedAvailable = false
	end

	if not InCombatLockdown() then
		self:MainButtonAttribute()
		self:BuffSpellAttribute()
		self:PetSpellAttribute()
		self:CurseSpellAttribute()
		self:StoneAttribute(Local.Summon.SteedAvailable)
	end

	Necrosis:BindName()
end

-- Extract an attribute from a spell || Fonction d'extraction d'attribut de sort
-- F(Type=string, string, int) -> Spell=table
function Necrosis:FindSpellAttribute(Type, attribute, array)
	for index=1, #self.Spell, 1 do
		if self.Spell[index][Type]:find(attribute) then return self.Spell[index][array] end
	end
	return nil
end

------------------------------------------------------------------------------------------------------
-- MISCELLANEOUS FUNCTIONS || FONCTIONS DIVERSES
------------------------------------------------------------------------------------------------------

-- Function to check the presence of a debuff on the unit || Fonction pour savoir si une unité subit un effet
-- F(string, string)->bool
function Necrosis:UnitHasEffect(unit, effect)
	local index = 1
	while UnitDebuff(unit, index) do
		self:MoneyToggle()
		NecrosisTooltip:SetUnitDebuff(unit, index)
		local DebuffName = tostring(NecrosisTooltipTextLeft1:GetText())
   		if DebuffName:find(effect) then
			return true
		end
		index = index + 1
	end
	return false
end

-- Function to check the presence of a buff on the unit.
-- Strictly identical to UnitHasEffect, but as WoW distinguishes Buff and DeBuff, so we have to.
function Necrosis:UnitHasBuff(unit, effect)
	local index = 1
	while UnitBuff(unit, index) do
	-- Here we'll cheat a little. checking a buff or debuff return the internal spell name, and not the name we give at start
		-- So we use an API widget that will use the internal name to return the known name.
		-- For example, the "Curse of Agony" spell is internaly known as "Spell_Shadow_CurseOfSargeras". Much easier to use the first one than the internal one.
		self:MoneyToggle()
		NecrosisTooltip:SetUnitBuff(unit, index)
		local BuffName = tostring(NecrosisTooltipTextLeft1:GetText())
   		if BuffName:find(effect) then
			return true
		end
		index = index + 1
	end
	return false
end


-- Display the antifear button / warning || Affiche ou cache le bouton de détection de la peur suivant la cible.
function Necrosis:ShowAntiFearWarning()
	local Actif = false -- Must be False, or a number from 1 to Local.Warning.Antifear.Icon[] max element.

	-- Checking if we have a target. Any fear need a target to be casted on
	if UnitExists("target") and UnitCanAttack("player", "target") and not UnitIsDead("target") then
		-- Checking if the target has natural immunity (only NPC target)
		if not UnitIsPlayer("target") and ( UnitCreatureType("target") == self.Unit.Undead or UnitCreatureType("target") == "Mechanical" ) then
			Actif = 2 -- Immun
		end
		-- We'll start to parse the target buffs, as his class doesn't give him natural permanent immunity
		if not Actif then
			for index=1, #self.AntiFear.Buff, 1 do
				if self:UnitHasBuff("target",self.AntiFear.Buff[index]) then
					Actif = 3 -- Prot
					break
				end
			end

			-- No buff found, let's try the debuffs
			for index=1, #self.AntiFear.Debuff, 1 do
				if self:UnitHasEffect("target",self.AntiFear.Debuff[index]) then
					Actif = 3 -- Prot
					break
				end
			end
		end

		-- An immunity has been detected before, but we still don't know why => show the button anyway
		if Local.Warning.Antifear.Immune and not Actif then
			Actif = 1
		end
	end

	if Actif then
		-- Antifear button is currently not visible, we have to change that
		if not Local.Warning.Antifear.Actif then
			Local.Warning.Antifear.Actif = true
			self:Msg(self.ChatMessage.Information.FearProtect, "USER")
			NecrosisAntiFearButton:SetNormalTexture("Interface\\Addons\\Necrosis\\UI\\AntiFear"..Local.Warning.Antifear.Icon[Actif].."-02")
			if NecrosisConfig.Sound then PlaySoundFile(self.Sound.Fear) end
			ShowUIPanel(NecrosisAntiFearButton)
			Local.Warning.Antifear.Blink = GetTime() + 0.6
			Local.Warning.Antifear.Toggle = 2

		-- Timer to make the button blink
		elseif GetTime() >= Local.Warning.Antifear.Blink then
			if Local.Warning.Antifear.Toggle == 1 then
				Local.Warning.Antifear.Toggle = 2
			else
				Local.Warning.Antifear.Toggle = 1
			end
			Local.Warning.Antifear.Blink = GetTime() + 0.4
			NecrosisAntiFearButton:SetNormalTexture("Interface\\Addons\\Necrosis\\UI\\AntiFear"..Local.Warning.Antifear.Icon[Actif].."-0"..Local.Warning.Antifear.Toggle)
		end

	elseif Local.Warning.Antifear.Actif then	-- No antifear on target, but the button is still visible => gonna hide it
		Local.Warning.Antifear.Actif = false
		HideUIPanel(NecrosisAntiFearButton)
	end
end

-- Trade healthstone (out of combat) || Fonction pour gérer l'échange de pierre (hors combat)
function Necrosis:TradeStone()
		-- If a friendly target is selected then trade the stone || Dans ce cas si un pj allié est sélectionné, on lui donne la pierre
		-- Else use it || Sinon, on l'utilise
		if Local.Trade.Request and Local.Stone.Health.OnHand and not Local.Trade.Complete then
			PickupContainerItem(Local.Stone.Health.Location[1], Local.Stone.Health.Location[2])
			ClickTradeButton(1)
			Local.Trade.Complete = true
			return
		elseif UnitExists("target") and UnitIsPlayer("target")
		and not (UnitCanAttack("player", "target") or UnitName("target") == UnitName("player")) then
				PickupContainerItem(Local.Stone.Health.Location[1], Local.Stone.Health.Location[2])
				if CursorHasItem() then
					DropItemOnUnit("target")
					Local.Trade.Complete = true
				end
				return
		end
end

function Necrosis:MoneyToggle()
	for index=1, 10 do
		local text = _G["NecrosisTooltipTextLeft"..index]
			if text then text:SetText(nil) end
			text = _G["NecrosisTooltipTextRight"..index]
			if text then text:SetText(nil) end
	end
	NecrosisTooltip:Hide()
	NecrosisTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
end

function Necrosis:GameTooltip_ClearMoney()
    -- Intentionally empty don't clear money while we use hidden tooltips
end


-- Function (XML) to restore the default attachment points of the buttons || Fonction (XML) pour rétablir les points d'attache par défaut des boutons
function Necrosis:ClearAllPoints()
	if  _G["NecrosisFirestoneButton"] then NecrosisFirestoneButton:ClearAllPoints() end
	if  _G["NecrosisSpellstoneButton"] then NecrosisSpellstoneButton:ClearAllPoints() end
	if  _G["NecrosisHealthstoneButton"] then NecrosisHealthstoneButton:ClearAllPoints() end
	if  _G["NecrosisSoulstoneButton"] then NecrosisSoulstoneButton:ClearAllPoints() end
	if  _G["NecrosisMountButton"] then NecrosisMountButton:ClearAllPoints() end
	if  _G["NecrosisPetMenuButton"] then NecrosisPetMenuButton:ClearAllPoints() end
	if  _G["NecrosisBuffMenuButton"] then NecrosisBuffMenuButton:ClearAllPoints() end
	if  _G["NecrosisCurseMenuButton"] then NecrosisCurseMenuButton:ClearAllPoints() end
end

-- Disable drag functionality || Fonction (XML) pour étendre la propriété NoDrag() du bouton principal de Necrosis sur tout ses boutons
function Necrosis:NoDrag()
	if  _G["NecrosisFirestoneButton"] then NecrosisFirestoneButton:RegisterForDrag("") end
	if  _G["NecrosisSpellstoneButton"] then NecrosisSpellstoneButton:RegisterForDrag("") end
	if  _G["NecrosisHealthstoneButton"] then NecrosisHealthstoneButton:RegisterForDrag("") end
	if  _G["NecrosisSoulstoneButton"] then NecrosisSoulstoneButton:RegisterForDrag("")end
	if  _G["NecrosisMountButton"] then NecrosisMountButton:RegisterForDrag("") end
	if  _G["NecrosisPetMenuButton"] then NecrosisPetMenuButton:RegisterForDrag("") end
	if  _G["NecrosisBuffMenuButton"] then NecrosisBuffMenuButton:RegisterForDrag("") end
	if  _G["NecrosisCurseMenuButton"] then NecrosisCurseMenuButton:RegisterForDrag("") end
end

-- Enable drag functionality || Fonction (XML) inverse de celle du dessus
function Necrosis:Drag()
	if  _G["NecrosisFirestoneButton"] then NecrosisFirestoneButton:RegisterForDrag("LeftButton") end
	if  _G["NecrosisSpellstoneButton"] then NecrosisSpellstoneButton:RegisterForDrag("LeftButton") end
	if  _G["NecrosisHealthstoneButton"] then NecrosisHealthstoneButton:RegisterForDrag("LeftButton") end
	if  _G["NecrosisSoulstoneButton"] then NecrosisSoulstoneButton:RegisterForDrag("LeftButton") end
	if  _G["NecrosisMountButton"] then NecrosisMountButton:RegisterForDrag("LeftButton") end
	if  _G["NecrosisPetMenuButton"] then NecrosisPetMenuButton:RegisterForDrag("LeftButton") end
	if  _G["NecrosisBuffMenuButton"] then NecrosisBuffMenuButton:RegisterForDrag("LeftButton") end
	if  _G["NecrosisCurseMenuButton"] then NecrosisCurseMenuButton:RegisterForDrag("LeftButton") end
end


-- Rebuild the menus at mod startup or when the spellbook changes || A chaque changement du livre des sorts, au démarrage du mod, ainsi qu'au changement de sens du menu on reconstruit les menus des sorts
function Necrosis:CreateMenu()
	Local.Menu.Pet = setmetatable({}, metatable)
	Local.Menu.Curse = setmetatable({}, metatable)
	Local.Menu.Buff = setmetatable({}, metatable)
	local menuVariable = nil
	local PetButtonPosition = "Button"
	local BuffButtonPosition = "Button"
	local CurseButtonPosition = "Button"

	-- Hide all the pet demon buttons || On cache toutes les icones des démons
	for i = 1, #NecrosisConfig.DemonSpellPosition, 1 do
		menuVariable = _G["NecrosisPetMenu"..i]
		if menuVariable then
			menuVariable:Hide()
			menuVariable:ClearAllPoints()
			menuVariable:SetPoint("CENTER", "NecrosisButton", "CENTER", 3000, 3000)
		end
	end
	-- Hide the general buff spell buttons || On cache toutes les icones des sorts
	for i = 1, #NecrosisConfig.BuffSpellPosition, 1 do
		menuVariable = _G["NecrosisBuffMenu"..i]
		if menuVariable then
			menuVariable:Hide()
			menuVariable:ClearAllPoints()
			menuVariable:SetPoint("CENTER", "NecrosisButton", "CENTER", 3000, 3000)
		end
	end
	-- Hide the curse buttons || On cache toutes les icones des curses
	for i = 1, #NecrosisConfig.CurseSpellPosition, 1 do
		menuVariable = _G["NecrosisCurseMenu"..i]
		if menuVariable then
			menuVariable:Hide()
			menuVariable:ClearAllPoints()
			menuVariable:SetPoint("CENTER", "NecrosisButton", "CENTER", 3000, 3000)
		end
	end
	if NecrosisConfig.StonePosition[7] > 0 then
		local MenuID = new("array",
			15, 3, 4, 5, 6, 8, 30, 35, 44, 59
		)
		-- We order and display the buttons in the demon menu || On ordonne et on affiche les boutons dans le menu des démons
		for index = 1, #NecrosisConfig.DemonSpellPosition, 1 do
			-- If the summoning spell exists, the button is displayed in the pets menu || Si le sort d'invocation existe, on affiche le bouton dans le menu des pets
			for spell = 1, #NecrosisConfig.DemonSpellPosition, 1 do
				if math.abs(NecrosisConfig.DemonSpellPosition[index]) == spell
					and NecrosisConfig.DemonSpellPosition[spell] > 0
					and self.Spell[ MenuID[spell] ].ID then
						-- On-Demand Creation of the Demon Menu Button || Création à la demande du bouton du menu des démons
						if not _G["NecrosisPetMenuButton"] then
							_ = self:CreateSphereButtons("PetMenu")
						end
						menuVariable = self:CreateMenuPet(spell)
						menuVariable:ClearAllPoints()
						menuVariable:SetPoint(
							"CENTER", "NecrosisPetMenu"..PetButtonPosition, "CENTER",
							NecrosisConfig.PetMenuPos.direction * NecrosisConfig.PetMenuPos.x * 32,
							NecrosisConfig.PetMenuPos.y * 32
						)
						PetButtonPosition = spell
						Local.Menu.Pet:insert(menuVariable)
						break
				end
			end
		end
		del(MenuID)

		-- Display the pets menu button || Maintenant que tous les boutons de pet sont placés les uns à côté des autres, on affiche les disponibles
		if Local.Menu.Pet[1] then
			Local.Menu.Pet[1]:ClearAllPoints()
			Local.Menu.Pet[1]:SetPoint(
				"CENTER", "NecrosisPetMenuButton", "CENTER",
				NecrosisConfig.PetMenuPos.direction * NecrosisConfig.PetMenuPos.x * 32 + NecrosisConfig.PetMenuDecalage.x,
				NecrosisConfig.PetMenuPos.y * 32 + NecrosisConfig.PetMenuDecalage.y
			)
			-- Secure the menu || Maintenant on sécurise le menu, et on y associe nos nouveaux boutons
			for i = 1, #Local.Menu.Pet, 1 do
				Local.Menu.Pet[i]:SetParent(NecrosisPetMenuButton)
				-- Close the menu when a child button is clicked || Si le menu se ferme à l'appui d'un bouton, alors il se ferme à l'appui d'un bouton !
				NecrosisPetMenuButton:WrapScript(Local.Menu.Pet[i], "OnClick", [[
					if self:GetParent():GetAttribute("state") == "Ouvert" then
						self:GetParent():SetAttribute("state", "Ferme")
					end
				]])
				NecrosisPetMenuButton:WrapScript(Local.Menu.Pet[i], "OnEnter", [[
					self:GetParent():SetAttribute("mousehere", true)
				]])
				NecrosisPetMenuButton:WrapScript(Local.Menu.Pet[i], "OnLeave", [[
					self:GetParent():SetAttribute("mousehere", false)
					local stateMenu = self:GetParent():GetAttribute("state")
					if not (stateMenu == "Bloque" or stateMenu == "Combat" or stateMenu == "ClicDroit") then
						self:GetParent():SetAttribute("state", "Refresh")
					end
				]])
				if NecrosisConfig.BlockedMenu or not NecrosisConfig.ClosingMenu then
					NecrosisPetMenuButton:UnwrapScript(Local.Menu.Pet[i], "OnClick")
				end
			end
			self:MenuAttribute("NecrosisPetMenuButton")
			self:PetSpellAttribute()
		end
	end

	if NecrosisConfig.StonePosition[5] > 0 then
		-- Setup the buttons available on the buffs menu || On ordonne et on affiche les boutons dans le menu des buffs
		local MenuID = new("array",
			31, 47, 32, 33, 34, 37, 38, 43, 59, 9
		)
		for index = 1, #NecrosisConfig.BuffSpellPosition, 1 do
			-- Display the button if the spell is known || Si le buff existe, on affiche le bouton dans le menu des buffs
			if math.abs(NecrosisConfig.BuffSpellPosition[index]) == 1
				and NecrosisConfig.BuffSpellPosition[1] > 0
				and (self.Spell[31].ID or self.Spell[36].ID) then
					-- Create on demand || Création à la demande du bouton du menu des Buffs
					if not _G["NecrosisBuffMenuButton"] then
						_ = self:CreateSphereButtons("BuffMenu")
					end
					menuVariable = self:CreateMenuBuff(1)
					menuVariable:ClearAllPoints()
					menuVariable:SetPoint(
						"CENTER", "NecrosisBuffMenu"..BuffButtonPosition, "CENTER",
						NecrosisConfig.BuffMenuPos.direction * NecrosisConfig.BuffMenuPos.x * 32,
						NecrosisConfig.BuffMenuPos.y * 32
					)
					BuffButtonPosition = 1
					Local.Menu.Buff:insert(menuVariable)
			else
				for spell = 2, #NecrosisConfig.BuffSpellPosition, 1 do
					if math.abs(NecrosisConfig.BuffSpellPosition[index]) == spell
						and NecrosisConfig.BuffSpellPosition[spell] > 0
						and self.Spell[ MenuID[spell] ].ID then
							-- Create on demand || Création à la demande du bouton du menu des Buffs
							if not _G["NecrosisBuffMenuButton"] then
								_ = self:CreateSphereButtons("BuffMenu")
							end
							menuVariable = self:CreateMenuBuff(spell)
							menuVariable:ClearAllPoints()
							menuVariable:SetPoint(
								"CENTER", "NecrosisBuffMenu"..BuffButtonPosition, "CENTER",
								NecrosisConfig.BuffMenuPos.direction * NecrosisConfig.BuffMenuPos.x * 32,
								NecrosisConfig.BuffMenuPos.y * 32
							)
							BuffButtonPosition = spell
							Local.Menu.Buff:insert(menuVariable)
							break
					end
				end
			end
		end
		del(MenuID)

		-- Display the buffs menu button on the sphere || Maintenant que tous les boutons de buff sont placés les uns à côté des autres, on affiche les disponibles
		if Local.Menu.Buff[1] then
			Local.Menu.Buff[1]:ClearAllPoints()
			Local.Menu.Buff[1]:SetPoint(
				"CENTER", "NecrosisBuffMenuButton", "CENTER",
				NecrosisConfig.BuffMenuPos.direction * NecrosisConfig.BuffMenuPos.x * 32 + NecrosisConfig.BuffMenuDecalage.x,
				NecrosisConfig.BuffMenuPos.y * 32 + NecrosisConfig.BuffMenuDecalage.y
			)
			-- Secure the menu || Maintenant on sécurise le menu, et on y associe nos nouveaux boutons
			for i = 1, #Local.Menu.Buff, 1 do
				Local.Menu.Buff[i]:SetParent(NecrosisBuffMenuButton)
				-- Close the menu upon button Click || Si le menu se ferme à l'appui d'un bouton, alors il se ferme à l'appui d'un bouton !
				NecrosisBuffMenuButton:WrapScript(Local.Menu.Buff[i], "OnClick", [[
					if self:GetParent():GetAttribute("state") == "Ouvert" then
						self:GetParent():SetAttribute("state", "Ferme")
					end
				]])
				NecrosisBuffMenuButton:WrapScript(Local.Menu.Buff[i], "OnEnter", [[
					self:GetParent():SetAttribute("mousehere", true)
				]])
				NecrosisBuffMenuButton:WrapScript(Local.Menu.Buff[i], "OnLeave", [[
					self:GetParent():SetAttribute("mousehere", false)
					local stateMenu = self:GetParent():GetAttribute("state")
					if not (stateMenu == "Bloque" or stateMenu == "Combat" or stateMenu == "ClicDroit") then
						self:GetParent():SetAttribute("state", "Refresh")
					end
				]])
				if NecrosisConfig.BlockedMenu or not NecrosisConfig.ClosingMenu then
					NecrosisBuffMenuButton:UnwrapScript(Local.Menu.Buff[i], "OnClick")
				end
			end
			self:MenuAttribute("NecrosisBuffMenuButton")
			self:BuffSpellAttribute()
		end
	end


	if NecrosisConfig.StonePosition[8] > 0 then
		-- Setup the buttons to be displayed on the curse menu || On ordonne et on affiche les boutons dans le menu des malédictions
		-- MenuID contient l'emplacement des sorts en question dans la table des sorts de Necrosis.
		local MenuID = new("array",
												23, -- Curse of weakness
												22, -- Curse of agony
												25, -- Curse of tongues
												40, -- Curse of exhaustion
												26, -- Curse of the elements
												16, -- Curse of doom
												14 -- Corruption
											 )
		for index = 1, #NecrosisConfig.CurseSpellPosition, 1 do
			for sort = 1, #NecrosisConfig.CurseSpellPosition, 1 do
				-- Si la Malédiction existe, on affiche le bouton dans le menu des curses
				if math.abs(NecrosisConfig.CurseSpellPosition[index]) == sort
					and NecrosisConfig.CurseSpellPosition[sort] > 0
					and self.Spell[MenuID[sort]].ID then
						-- Création à la demande du bouton du menu des malédictions
						if not _G["NecrosisCurseMenuButton"] then
							_ = self:CreateSphereButtons("CurseMenu")
						end
						menuVariable = self:CreateMenuCurse(sort)
						menuVariable:ClearAllPoints()
						menuVariable:SetPoint(
							"CENTER", "NecrosisCurseMenu"..CurseButtonPosition, "CENTER",
							NecrosisConfig.CurseMenuPos.direction * NecrosisConfig.CurseMenuPos.x * 32,
							NecrosisConfig.CurseMenuPos.y * 32
						)
						CurseButtonPosition = sort
						Local.Menu.Curse:insert(menuVariable)
						break
				end
			end
		end
		del(MenuID)

		-- Display the curse menu button on the sphere || Maintenant que tous les boutons de curse sont placés les uns à côté des autres, on affiche les disponibles
		if Local.Menu.Curse[1] then
			Local.Menu.Curse[1]:ClearAllPoints()
			Local.Menu.Curse[1]:SetPoint(
				"CENTER", "NecrosisCurseMenuButton", "CENTER",
				NecrosisConfig.CurseMenuPos.direction * NecrosisConfig.CurseMenuPos.x * 32 + NecrosisConfig.CurseMenuDecalage.x,
				NecrosisConfig.CurseMenuPos.y * 32 + NecrosisConfig.CurseMenuDecalage.y
			)
			-- Secure the menu || Maintenant on sécurise le menu, et on y associe nos nouveaux boutons
			for i = 1, #Local.Menu.Curse, 1 do
				Local.Menu.Curse[i]:SetParent(NecrosisCurseMenuButton)
				-- Respond to clicks || Si le menu se ferme à l'appui d'un bouton, alors il se ferme à l'appui d'un bouton !
				NecrosisCurseMenuButton:WrapScript(Local.Menu.Curse[i], "OnClick", [[
					if self:GetParent():GetAttribute("state") == "Ouvert" then
						self:GetParent():SetAttribute("state","Ferme")
					end
				]])
				NecrosisCurseMenuButton:WrapScript(Local.Menu.Curse[i], "OnEnter", [[
					self:GetParent():SetAttribute("mousehere", true)
				]])
				NecrosisCurseMenuButton:WrapScript(Local.Menu.Curse[i], "OnLeave", [[
					self:GetParent():SetAttribute("mousehere", false)
					local stateMenu = self:GetParent():GetAttribute("state")
					if not (stateMenu == "Bloque" or stateMenu == "Combat" or stateMenu == "ClicDroit") then
						self:GetParent():SetAttribute("state", "Refresh")
					end
				]])
				if NecrosisConfig.BlockedMenu or not NecrosisConfig.ClosingMenu then
					NecrosisCurseMenuButton:UnwrapScript(Local.Menu.Curse[i], "OnClick")
				end
			end
			self:MenuAttribute("NecrosisCurseMenuButton")
			self:CurseSpellAttribute()
		end
	end

	-- Always keep menus Open (if enabled) || On bloque le menu en position ouverte si configuré
	if NecrosisConfig.BlockedMenu then
		if _G["NecrosisBuffMenuButton"] then NecrosisBuffMenuButton:SetAttribute("state", "Bloque") end
		if _G["NecrosisPetMenuButton"] then NecrosisPetMenuButton:SetAttribute("state", "Bloque") end
		if _G["NecrosisCurseMenuButton"] then NecrosisCurseMenuButton:SetAttribute("state", "Bloque") end
	end
end

-- Reset Necrosis to default position || Fonction pour ramener tout au centre de l'écran
function Necrosis:Recall()
	local ui = new("array",
		"NecrosisButton",
		"NecrosisSpellTimerButton",
		"NecrosisAntiFearButton",
		"NecrosisCreatureAlertButton",
		"NecrosisBacklashButton",
		"NecrosisShadowTranceButton"
	)
	local pos = new("array",
		{0, -100},
		{0, 100},
		{20, 0},
		{60, 0},
		{-60, 0},
		{-20, 0}
	)
	for i = 1, #ui, 1 do
		local f = _G[ui[i]]
		f:ClearAllPoints()
		f:SetPoint("CENTER", "UIParent", "CENTER", pos[i][1], pos[i][2])
		f:Show()
		self:OnDragStop(f)
	end
	del(ui)
	del(pos)
end

-- Display the timers on the left or right || Fonction permettant le renversement des timers sur la gauche / la droite
function Necrosis:SymetrieTimer(bool)
	local num
	if bool then
		NecrosisConfig.SpellTimerPos = -1
		NecrosisConfig.SpellTimerJust = "RIGHT"
		num = 1
		while _G["NecrosisTimerFrame"..num.."OutText"] do
			_G["NecrosisTimerFrame"..num.."OutText"]:ClearAllPoints()
			_G["NecrosisTimerFrame"..num.."OutText"]:SetPoint(
				"RIGHT",
				_G["NecrosisTimerFrame"..num],
				"LEFT",
				-5, 1
			)
			_G["NecrosisTimerFrame"..num.."OutText"]:SetJustifyH("RIGHT")
			num = num + 1
		end
	else
		NecrosisConfig.SpellTimerPos = 1
		NecrosisConfig.SpellTimerJust = "LEFT"
		num = 1
		while _G["NecrosisTimerFrame"..num.."OutText"] do
			_G["NecrosisTimerFrame"..num.."OutText"]:ClearAllPoints()
			_G["NecrosisTimerFrame"..num.."OutText"]:SetPoint(
				"LEFT",
				_G["NecrosisTimerFrame"..num],
				"RIGHT",
				5, 1
			)
			_G["NecrosisTimerFrame"..num.."OutText"]:SetJustifyH("LEFT")
			num = num + 1
		end
	end
	if _G["NecrosisTimerFrame0"] then
		NecrosisTimerFrame0:ClearAllPoints()
		NecrosisTimerFrame0:SetPoint(
			NecrosisConfig.SpellTimerJust,
			NecrosisSpellTimerButton,
			"CENTER",
			NecrosisConfig.SpellTimerPos * 20, 0
		)
	end
	if _G["NecrosisListSpells"] then
		NecrosisListSpells:ClearAllPoints()
		NecrosisListSpells:SetJustifyH(NecrosisConfig.SpellTimerJust)
		NecrosisListSpells:SetPoint(
			"TOP"..NecrosisConfig.SpellTimerJust,
			NecrosisSpellTimerButton,
			"CENTER",
			NecrosisConfig.SpellTimerPos * 23, 10
		)
	end
end

function NecrosisTimer(nom, duree)
	local Cible = UnitName("target")
	local Niveau = UnitLevel("target")
	local Guid = UnitGUID("target")
	local truc = 6
	if not Cible then
		Cible = ""
		truc = 2
	end
	if not Niveau then
		Niveau = ""
	end

	Local.TimerManagement = NecrosisTimerX(nom, duree, truc, Cible, Niveau, Local.TimerManagement,Guid)
end

function Necrosis:SetOfxy(menu)
	if menu == "Buff" and _G["NecrosisBuffMenuButton"] then
		Local.Menu.Buff[1]:ClearAllPoints()
		Local.Menu.Buff[1]:SetPoint(
			"CENTER", "NecrosisBuffMenuButton", "CENTER",
			NecrosisConfig.BuffMenuPos.direction * NecrosisConfig.BuffMenuPos.x * 32 + NecrosisConfig.BuffMenuDecalage.x,
			NecrosisConfig.BuffMenuPos.y * 32 + NecrosisConfig.BuffMenuDecalage.y
		)
	elseif menu == "Pet" and _G["NecrosisPetMenuButton"] then
		Local.Menu.Pet[1]:ClearAllPoints()
		Local.Menu.Pet[1]:SetPoint(
			"CENTER", "NecrosisPetMenuButton", "CENTER",
			NecrosisConfig.PetMenuPos.direction * NecrosisConfig.PetMenuPos.x * 32 + NecrosisConfig.PetMenuDecalage.x,
			NecrosisConfig.PetMenuPos.y * 32 + NecrosisConfig.PetMenuDecalage.y
		)
	elseif menu == "Curse" and _G["NecrosisCurseMenuButton"] then
		Local.Menu.Curse[1]:ClearAllPoints()
		Local.Menu.Curse[1]:SetPoint(
			"CENTER", "NecrosisCurseMenuButton", "CENTER",
			NecrosisConfig.CurseMenuPos.direction * NecrosisConfig.CurseMenuPos.x * 32 + NecrosisConfig.CurseMenuDecalage.x,
			NecrosisConfig.CurseMenuPos.y * 32 + NecrosisConfig.CurseMenuDecalage.y
		)
	end
end

-- This function fixes a problem with the Blizzard API "GetCompanionInfo", which will return a different name for some mounts in the game.
-- Example: the bronze drake (spell 59569)
--      -> GetCompanionInfo will return this as "Bronze Drake Mount" (wrong)
--      -> GetSpellInfo will return this as "Bronze Drake" (correct)
function Necrosis:GetCompanionInfo(type, id)
	local creatureID, creatureName, creatureSpellID, icon, issummoned = GetCompanionInfo(type, id)

	if creatureSpellID then
		-- Get the correct (localised) name
		creatureName = GetSpellInfo(creatureSpellID)
	end

	return creatureID, creatureName, creatureSpellID, icon, issummoned
end
