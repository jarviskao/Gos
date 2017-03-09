--[[
made by Jarviskao 
source: https://github.com/jarviskao/Gos/blob/master/Darius.lua
]]

--Hero
if GetObjectName(GetMyHero()) ~= "Darius" then return end

--Load Libs
require "DamageLib"

--Auto Update
local ver = "1.2"


function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("<font color=\"#0099FF\"><b>[Darius]: </b></font><font color=\"#FFFFFF\"> New version found!</font>")
        print("<font color=\"#0099FF\"><b>[Darius]: </b></font><font color=\"#FFFFFF\"> Downloading update, please wait...</font>")
        DownloadFileAsync("https://raw.githubusercontent.com/jarviskao/Gos/master/Darius.lua", SCRIPT_PATH .. "Darius.lua", function() print("<font color=\"#0099FF\"><b>[Darius]:</b></font><font color=\"#FFFFFF\"> Update Complete, please 2x F6!</font>") return end)
    else
       print("<font color=\"#0099FF\"><b>[Darius]: </b></font><font color=\"#FFFFFF\">No Updates found")
    end
end


GetWebResultAsync("https://raw.githubusercontent.com/jarviskao/Gos/master/Darius.version", AutoUpdate)

--Main Menu
DMenu = Menu("D", "Darius")

--Combo Menu
DMenu:SubMenu("Combo", "Combo")
DMenu.Combo:Boolean("Q", "Use Q", true)
DMenu.Combo:Boolean("W", "Use W", true)
DMenu.Combo:Slider("Wrange", "Min. range for use W", 350, 0, 500, 10)
--DMenu.Combo:Boolean("E", "Use E", true)

-- Clear Menu (Lane Clear)
DMenu:SubMenu("Clear", "Clear")
DMenu.Clear:SubMenu("LaneClear", "Lane Clear")
DMenu.Clear.LaneClear:Boolean("Q", "Use Q", false)
DMenu.Clear.LaneClear:Slider("QMana", "use Q if Mana % >", 80, 0, 100, 1)
DMenu.Clear.LaneClear:Boolean("W", "Use W", false)
DMenu.Clear.LaneClear:Slider("WMana", "use W if Mana % >", 80, 0, 100, 1)
-- Clear Menu (Jungle Clear)
DMenu.Clear:SubMenu("JungleClear", "Jungle Clear")
DMenu.Clear.JungleClear:Boolean("Q", "Use Q", true)
DMenu.Clear.JungleClear:Slider("QMana", "use Q if Mana % >", 30, 0, 100, 1)
DMenu.Clear.JungleClear:Boolean("W", "Use W", true)
DMenu.Clear.JungleClear:Slider("WMana", "use W if Mana % >", 30, 0, 100, 1)

--KillSteal Menu
DMenu:SubMenu("KillSteal", "KillSteal")
DMenu.KillSteal:Boolean("R", "Use R", true)
DMenu.KillSteal:SubMenu("black", "KillSteal White List")
DelayAction(function()
    for _, unit in pairs(GetEnemyHeroes()) do
        DMenu.KillSteal.black:Boolean(unit.name, "Use R On: "..unit.charName, true)
    end
end, 0.01)

--Miscellaneous  (Auto Level Up Spell Menu)
DMenu:SubMenu("Misc", "Miscellaneous")
DMenu.Misc:SubMenu("LvUpSpell", "Auto Level Spell")
DMenu.Misc.LvUpSpell:Info("AutoLvSpellInfo", "Order: Max Q -> W -> E")
DMenu.Misc.LvUpSpell:Boolean("UseAutoLvSpell", "Use Auto Level Spell", false)

--Miscellaneous  (Skin Menu) 
DMenu.Misc:SubMenu("Skin", "Skin Changer")
  skinMeta = {["Garen"] = { "Classic", "Lord", "BioForge", "Woad King", "DunkMaster", "Black Iron Chroma", "Bronze Chroma", "Copper Chroma", "Academy", "Amethyst", "Aquamarine", "Catseye", "Citrine", "Emerald" }}
DMenu.Misc.Skin:DropDown('skin', myHero.charName.. " Skins", 1, skinMeta[myHero.charName],function(model)
						  HeroSkinChanger(myHero, model - 1) print("<font color=\"#0099FF\"><b>[Skin]</b></font> ".. skinMeta[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") 
    end,true)
--Miscellaneous  (Draw Spells Menu)  
DMenu.Misc:SubMenu("DrawSpells", "Draw Spells")
DMenu.Misc.DrawSpells:Boolean("Q", "Draw Q Range", false)
DMenu.Misc.DrawSpells:Boolean("E", "Draw E Range", false)
DMenu.Misc.DrawSpells:Boolean("R", "Draw R Range", false)
    
--Locals
local LoL = "7.5"

--Spells
local DariusQ = { range = 425 }
local DariusE = { range = GetCastRange(myHero, _E) }
local DariusR = { range = GetCastRange(myHero, _R) }
local SkillOrders = {_Q, _E, _Q, _W, _Q, _R, _Q, _W, _Q, _W, _R, _W, _E, _W, _E, _R, _E, _E}

--Mode
function Mode() --Deftsu
    if IOW_Loaded then
		BlockF7OrbWalk(true)
        return IOW:Mode()
    elseif DAC_Loaded then
		BlockF7OrbWalk(true)
        return DAC:Mode()
    elseif PW_Loaded then
		BlockF7OrbWalk(true)
        return PW:Mode()
    elseif GoSWalkLoaded and GoSWalk.CurrentMode then
		BlockF7OrbWalk(true)
        return ({"Combo", "Harass", "LaneClear", "LastHit"})[GoSWalk.CurrentMode+1]
    elseif AutoCarry_Loaded then
		BlockF7OrbWalk(true)
        return DACR:Mode()
    elseif _G.SLW_Loaded then
		BlockF7OrbWalk(true)
        return SLW:Mode()
    elseif EOW_Loaded then
		BlockF7OrbWalk(true)
        return EOW:Mode()
    end
    return ""
end

OnDraw(function()
    --Range
    if not IsDead(myHero) then
		if DMenu.Misc.DrawSpells.Q:Value() then 
			DrawCircle(myHero,205+GetHitBox(myHero),0,50,ARGB(255, 0, 255, 0))
			DrawCircle(myHero,DariusQ.range,0,50,ARGB(255, 0, 255, 0))
		end
        if DMenu.Misc.DrawSpells.E:Value() then 
			DrawCircle(myHero, DariusE.range,0,50,ARGB(255, 173, 255, 47)) 
		end
        if DMenu.Misc.DrawSpells.R:Value() then 
			DrawCircle(myHero, DariusR.range,0,50, ARGB(255, 255, 165, 0)) 
        end
    end 
end)

local rBuffTable = {}

OnUpdateBuff (function(unit, buff)
  if not unit or not buff then return end
  	if buff.Name:lower() == "dariushemo" and GetTeam(buff) ~= (GetTeam(myHero)) and myHero.type == unit.type then
		rBuffTable[unit.networkID] = buff.Count
	end
end)

OnRemoveBuff (function(unit, buff)
  if not unit or not buff then return end
	if buff.Name:lower() == "dariushemo" and GetTeam(buff) ~= (GetTeam(myHero)) and myHero.type == unit.type then
		rBuffTable[unit.networkID] = 0
	end
end)

OnProcessSpellComplete(function(unit, spell)
	if not unit or not spell then return end
	--Locals
	local target = CurrentTarget()
	if Mode() == "Combo" then
		--W
		if Ready(_W) and DMenu.Combo.W:Value() and ValidTarget(target, DMenu.Combo.Wrange:Value()) and unit == myHero and spell.name:lower():find("attack") then
			CastSpell(_W)
		end
	end
end)

--Start
OnTick(function ()
	if not IsDead(myHero) then
		--Functions
		Combo()
		Clear()
        KillSteal()
	end
end)

--Functions
function CurrentTarget()
	if GoSWalkLoaded then
		return GoSWalk.CurrentTarget
	elseif AutoCarry_Loaded then
		return DACR:GetTarget()
	else
		return GetCurrentTarget()
	end
end

function Combo()
	if Mode() == "Combo" then
		--Locals
		local target = CurrentTarget()
		--Q
		if Ready(_Q) and DMenu.Combo.Q:Value() and ValidTarget(target,DariusQ.range) then
			CastSpell(_Q)
		end
	end
end

function Clear()
    if Mode() == "LaneClear" then
        for _, unit in pairs(minionManager.objects) do
			--Lane Clear
            if GetTeam(unit) == MINION_ENEMY then
                --Q
                if Ready(_Q) and DMenu.Clear.LaneClear.Q:Value() and ValidTarget(unit, DariusQ.range) and GetPercentMP(myHero) >= DMenu.Clear.LaneClear.QMana:Value() then
                    CastSpell(_Q)
                end 
            end
			--Jungle Clear
            if GetTeam(unit) == MINION_JUNGLE then
                --Q
                if Ready(_Q) and DMenu.Clear.JungleClear.Q:Value() and ValidTarget(unit, DariusQ.range) and GetPercentMP(myHero) >= DMenu.Clear.JungleClear.QMana:Value() then
                    CastSpell(_Q)
                end
                --W
                if Ready(_W) and  DMenu.Clear.JungleClear.W:Value() and ValidTarget(unit, DMenu.Combo.Wrange:Value()) and GetPercentMP(myHero) >= DMenu.Clear.JungleClear.WMana:Value() then
                    CastSpell(_W)
                end
            end
        end
    end
end

function KillSteal()
	for _, unit in pairs(GetEnemyHeroes()) do
		if rBuffTable ~= nil then
			local rStacks = rBuffTable[unit.networkID] or 0
			local rStacksDamage = (rStacks * ((GetSpellData(myHero, _R).level * 20) ))
			local rDamage = getdmg("R",unit,myHero)
			local targetHP = GetCurrentHP(unit) + GetDmgShield(unit) + GetHPRegen(unit) * 0.25
			if DMenu.KillSteal.R:Value() and Ready(_R) and ValidTarget(unit,DariusR.range) and targetHP  < rDamage + rStacksDamage then
				if DMenu.KillSteal.black[unit.name]:Value() then
					CastTargetSpell(unit, _R)
				end
			end
		end
	end
end

print("<font color=\"#0099FF\"><b>[Darius]: Loaded</b></font> || Version: "..ver," ", "|| LoL Support : "..LoL)
