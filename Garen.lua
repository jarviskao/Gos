--[[
This script have not published on GOS.

This is not my work and i make a little change
It made by BluePrinceEB
origninal source: https://github.com/BluePrinceEB/GoS/blob/master/Garen.lua

It modified by Jarviskao 
-add missing skin
-add auto Level Up Spell
-add the function to get current target depending on different orb walking script
-modify the range of spell and drawing as well as the damage output
-remove the hp and damage drawing
-etc...
-support the lastest version
source: https://github.com/jarviskao/Gos/blob/master/Garen.lua


]]

--Hero
if GetObjectName(GetMyHero()) ~= "Garen" then return end

--Load Libs
require "DamageLib"

--Auto Update
local ver = "1.5"


function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("<font color=\"#0099FF\"><b>[Garen]: </b></font><font color=\"#FFFFFF\"> New version found!</font>")
        print("<font color=\"#0099FF\"><b>[Garen]: </b></font><font color=\"#FFFFFF\"> Downloading update, please wait...</font>")
        DownloadFileAsync("https://raw.githubusercontent.com/jarviskao/Gos/master/Garen.lua", SCRIPT_PATH .. "Garen.lua", function() print("<font color=\"#0099FF\"><b>[Garen]:</b></font><font color=\"#FFFFFF\"> Update Complete, please 2x F6!</font>") return end)
    else
       print("<font color=\"#0099FF\"><b>[Garen]: </b></font><font color=\"#FFFFFF\">No Updates found")
    end
end


GetWebResultAsync("https://raw.githubusercontent.com/jarviskao/Gos/master/Garen.version", AutoUpdate)

--Main Menu
GMenu = Menu("G", "Garen")

--Combo Menu
GMenu:SubMenu("c", "Combo")
GMenu.c:Boolean("Q", "Use Q", true)
GMenu.c:Slider("Qrange", "Min. range for use Q", 300, 0, 1000, 10)
GMenu.c:Boolean("E", "Use E", true)

--LastHit Menu
GMenu:SubMenu("LastHit", "Last Hit")
GMenu.LastHit:Boolean("Q", "Use Q", true)

--Harass Menu
GMenu:SubMenu("Harass", "Harass")
GMenu.Harass:Boolean("Q", "Use Q", true)
GMenu.Harass:Slider("Qrange", "Min. range for use Q", 300, 0, 1000, 10)
GMenu.Harass:Boolean("E", "Use E", true)

--Clear Menu
GMenu:SubMenu("Clear", "Clear")
GMenu.Clear:SubMenu("LaneClear", "Lane Clear")
GMenu.Clear.LaneClear:Boolean("Q", "Use Q", false)
GMenu.Clear.LaneClear:Boolean("E", "Use E", false)
GMenu.Clear:SubMenu("JungleClear", "Jungle Clear")
GMenu.Clear.JungleClear:Boolean("Q", "Use Q", true)
GMenu.Clear.JungleClear:Boolean("E", "Use E", true)

--KillSteal Menu
GMenu:SubMenu("KillSteal", "KillSteal")
GMenu.KillSteal:Boolean("R", "Use R", true)
GMenu.KillSteal:SubMenu("black", "KillSteal White List")
DelayAction(function()
    for _, unit in pairs(GetEnemyHeroes()) do
        GMenu.KillSteal.black:Boolean(unit.name, "Use R On: "..unit.charName, true)
    end
end, 0.5)

--Auto Menu
GMenu:SubMenu("Auto", "Auto Spell")
GMenu.Auto:Boolean("W", "Use W", true)
GMenu.Auto:Slider("Whp", "Use W if HP(%) <= X", 80, 0, 100, 5)
GMenu.Auto:Slider("Wlim", "Use W if Enemy Count >= X", 1, 1, 5, 1)

--Miscellaneous  (Auto Level Up Spell Menu)
GMenu:SubMenu("Misc", "Miscellaneous")
GMenu.Misc:SubMenu("LvUpSpell", "Auto Level Spell")
GMenu.Misc.LvUpSpell:Info("AutoLvSpellInfo", "Order: Max Q -> E -> W")
GMenu.Misc.LvUpSpell:Boolean("UseAutoLvSpell", "Use Auto Level Spell", false)

--Miscellaneous  (Skin Menu) 
GMenu.Misc:SubMenu("Skin", "Skin Changer")
  skinMeta = {["Garen"] = {"Classic", "Sanguine Garen", "Desert Trooper Garen", "Commando Garen", "Dreadknight Garen", "Rugged Garen", "Steel Legion Garen", "Garnet Chroma", "Plum Chroma", "Ivory Chroma", "Rogue Admiral Garen", "Warring Kingdoms Garen"}}
GMenu.Misc.Skin:DropDown('skin', myHero.charName.. " Skins", 1, skinMeta[myHero.charName],function(model)
						  HeroSkinChanger(myHero, model - 1) print("<font color=\"#0099FF\"><b>[Skin]</b></font> ".. skinMeta[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") 
    end,true)
--Miscellaneous  (Draw Spells Menu)
GMenu.Misc:SubMenu("DrawSpells", "Draw Spells")
GMenu.Misc.DrawSpells:Boolean("E", "Draw E Range", false)
GMenu.Misc.DrawSpells:Boolean("R", "Draw R Range", false)

--Locals
local LoL = "7.5"

--Spells
local GarenE = { range = GetCastRange(myHero, _E) }
local GarenR = { range = GetCastRange(myHero, _R) }
local SkillOrders = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}

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
        if GMenu.Misc.DrawSpells.E:Value() then DrawCircle(myHero, GarenE.range, 1, 50, GoS.Red) end
        if GMenu.Misc.DrawSpells.R:Value() then DrawCircle(myHero, GarenR.range, 1, 50, GoS.Green) end
    end 
end)

OnProcessSpell(function(unit,spell)    
    if unit.isMe and spell.name:lower():find("attack") and EnemiesAround(myHero, 950) >= GMenu.Auto.Wlim:Value() then     
        if GMenu.Auto.W:Value() and Ready(_W) and GetPercentHP(myHero) < GMenu.Auto.Whp:Value() then 
            CastSpell(_W)   
        end
    end
end)


--Start
OnTick(function ()
	if not IsDead(myHero) then
	--Functions
	Combo()
        LastHit()
        Harass()
        Clear()
        KillSteal()
        AutoLvSpell()
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
		local target = CurrentTarget()
		--Q
		if Ready(_Q) and GMenu.c.Q:Value() and ValidTarget(target, GMenu.c.Qrange:Value()) then
			CastSpell(_Q)
		end
		--E
		if Ready(_E) and GMenu.c.E:Value() and ValidTarget(target, GarenE.range) and GetCastName(myHero, _E) == "GarenE" then
			CastSpell(_E)
		end
	end
end

function LastHit()
    if Mode() == "LastHit" then
        for _, minion in pairs(minionManager.objects) do
            if GetTeam(minion) == MINION_ENEMY then
                if GMenu.LastHit.Q:Value() and Ready(_Q) and ValidTarget(minion, 400) then
                    if getdmg("Q",minion,myHero) > GetCurrentHP(minion) then
                        CastSpell(_Q)
                        AttackUnit(minion)
                    end
                end
            end
        end
    end
end

function Harass()
    if Mode() == "Harass" then
	local target = CurrentTarget()
        --Q
        if Ready(_Q) and GMenu.Harass.Q:Value() and ValidTarget(target, GMenu.Harass.Qrange:Value()) then
            CastSpell(_Q)
        end
        --E
        if Ready(_E) and GMenu.Harass.E:Value() and ValidTarget(target, GarenE.range) and GetCastName(myHero, _E) == "GarenE" then
            CastSpell(_E)
        end
    end
end

function Clear()
	--LaneClear
    if Mode() == "LaneClear" then
        for _, minion in pairs(minionManager.objects) do
			
            if GetTeam(minion) == MINION_ENEMY then
                --Q
                if Ready(_Q) and GMenu.Clear.LaneClear.Q:Value() and ValidTarget(minion, 300) then
                    CastSpell(_Q)
                end
                --E
                if Ready(_E) and GMenu.Clear.LaneClear.E:Value() and ValidTarget(minion, GarenE.range) and GetCastName(myHero, _E) == "GarenE" and MinionsAround(minion, 950) >= 3 then
                    CastSpell(_E)
                end
            end
        end
    end
    --JungleClear
    if Mode() == "LaneClear" then 
        for _, mob in pairs(minionManager.objects) do
            if GetTeam(mob) == MINION_JUNGLE then
                --Q
                if Ready(_Q) and GMenu.Clear.JungleClear.Q:Value() and ValidTarget(mob, 300) then
                    CastSpell(_Q)
                end
                --E
                if Ready(_E) and GMenu.Clear.JungleClear.E:Value() and ValidTarget(mob, GarenE.range) and GetCastName(myHero, _E) == "GarenE" then
                    CastSpell(_E)
                end
            end
        end
    end
end

function KillSteal()
    for _,unit in pairs(GetEnemyHeroes()) do
        if GMenu.KillSteal.R:Value() and Ready(_R) and ValidTarget(unit, GarenR.range) and GetCurrentHP(unit) + GetDmgShield(unit) <  getdmg("R",unit,myHero) then
            if GMenu.KillSteal.black[unit.name]:Value() then
                CastTargetSpell(unit,_R)
            end
        end
    end
end

function AutoLvSpell()
	if GetLevelPoints(myHero) > 0 and GMenu.Misc.LvUpSpell.UseAutoLvSpell:Value() then
		if (myHero.level + 1 - GetLevelPoints(myHero)) then
			DelayAction(function() 
			LevelSpell(SkillOrders[myHero.level + 1 - GetLevelPoints(myHero)]) 
			end, 1)
		end
	end
end

print("<font color=\"#0099FF\"><b>[Garen]: Loaded</b></font> || Version: "..ver," ", "|| LoL Support : "..LoL)
