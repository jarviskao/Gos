--[[
This is not my work and i make a little change
It made by BluePrinceEB
origninal source: https://github.com/BluePrinceEB/GoS/blob/master/Garen.lua

It modified by Jarviskao 
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
GMenu:SubMenu("l", "Last Hit")
GMenu.l:Boolean("Q", "Use Q", true)

--Harass Menu
GMenu:SubMenu("h", "Harass")
GMenu.h:Boolean("Q", "Use Q", true)
GMenu.h:Slider("Qrange", "Min. range for use Q", 300, 0, 1000, 10)
GMenu.h:Boolean("E", "Use E", true)

--Clear Menu
GMenu:SubMenu("cl", "Clear")
GMenu.cl:SubMenu("l", "Lane Clear")
GMenu.cl.l:Boolean("Q", "Use Q", false)
GMenu.cl.l:Boolean("E", "Use E", false)
GMenu.cl:SubMenu("j", "Jungle Clear")
GMenu.cl.j:Boolean("Q", "Use Q", true)
GMenu.cl.j:Boolean("E", "Use E", true)

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
						  HeroSkinChanger(myHero, model - 1) print(skinMeta[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") 
    end,true)
--Draw Menu
GMenu.Misc:SubMenu("DrawSpells", "Draw Spells")
GMenu.Misc.DrawSpells:Boolean("E", "Draw E Range", false)
GMenu.Misc.DrawSpells:Boolean("R", "Draw R Range", false)

--Locals
local LoL = "7.5"

--Spells
local GarenE = { range = GetCastRange(myHero, _E) }
local GarenR = { range = GetCastRange(myHero, _R) }
local SkillOrders = { {_Q, _E, _W, _Q, _Q, _R, _Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W} }

--Mode
function Mode() --Deftsu
    if IOW_Loaded then
        return IOW:Mode()
    elseif DAC_Loaded then
        return DAC:Mode()
    elseif PW_Loaded then
        return PW:Mode()
    elseif GoSWalkLoaded and GoSWalk.CurrentMode then
        return ({"Combo", "Harass", "LaneClear", "LastHit"})[GoSWalk.CurrentMode+1]
    elseif AutoCarry_Loaded then
        return DACR:Mode()
    elseif _G.SLW_Loaded then
        return SLW:Mode()
    elseif EOW_Loaded then
        return EOW:Mode()
    end
    return ""
end

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

OnDraw(function()
    --Range
    if not IsDead(myHero) then
        if GMenu.Misc.DrawSpells.E:Value() then DrawCircle(myHero, GarenE.range, 1, 15, GoS.Red) end
        if GMenu.Misc.DrawSpells.R:Value() then DrawCircle(myHero, GarenR.range, 1, 15, GoS.Green) end
    end 
end)

--Functions
function AutoLvSpell()
	if GetLevelPoints(myHero) > 0 and GMenu.Misc.LvUpSpell.UseAutoLvSpell:Value() then
		if (myHero.level + 1 - GetLevelPoints(myHero)) then
			DelayAction(function() 
			LevelSpell(SkillOrders[1][myHero.level + 1 - GetLevelPoints(myHero)]) 
			end, 1)
		end
	end
end


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
                if GMenu.l.Q:Value() and Ready(_Q) and ValidTarget(minion, 400) then
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
        if Ready(_Q) and GMenu.h.Q:Value() and ValidTarget(target, GMenu.h.Qrange:Value()) then
            CastSpell(_Q)
        end
        --E
        if Ready(_E) and GMenu.h.E:Value() and ValidTarget(target, GarenE.range) and GetCastName(myHero, _E) == "GarenE" then
            CastSpell(_E)
        end
    end
end

function Clear()
    if Mode() == "LaneClear" then
        for _, minion in pairs(minionManager.objects) do
            if GetTeam(minion) == MINION_ENEMY then
                --Q
                if Ready(_Q) and GMenu.cl.l.Q:Value() and ValidTarget(minion, 300) then
                    CastSpell(_Q)
                end
                --E
                if Ready(_E) and GMenu.cl.l.E:Value() and ValidTarget(minion, GarenE.range) and GetCastName(myHero, _E) == "GarenE" and MinionsAround(minion, 950) >= 3 then
                    CastSpell(_E)
                end
            end
        end
    end
    --[[JungleClear doesnt work :doge:]]
    if Mode() == "LaneClear" then 
        for _, mob in pairs(minionManager.objects) do
            if GetTeam(mob) == MINION_JUNGLE then
                --Q
                if Ready(_Q) and GMenu.cl.j.Q:Value() and ValidTarget(mob, 300) then
                    CastSpell(_Q)
                end
                --E
                if Ready(_E) and GMenu.cl.j.E:Value() and ValidTarget(mob, GarenE.range) and GetCastName(myHero, _E) == "GarenE" then
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

--CB
OnProcessSpell(function(unit,spell)    
    if unit.isMe and spell.name:lower():find("attack") and EnemiesAround(myHero, 950) >= GMenu.Auto.Wlim:Value() then     
        if GMenu.Auto.W:Value() and Ready(_W) and GetPercentHP(myHero) < GMenu.Auto.Whp:Value() then 
            CastSpell(_W)   
        end
    end
end)

print("<font color=\"#0099FF\"><b>[Garen]: Loaded</b></font> || Version: "..ver," ", "|| LoL Support : "..LoL)
