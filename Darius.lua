--[[
made by Jarviskao 
source: https://github.com/jarviskao/Gos/blob/master/Darius.lua
]]

--Hero
if GetObjectName(GetMyHero()) ~= "Darius" then return end

--Load Libs
require "DamageLib"

--Auto Update
local ver = "1.0"


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
DMenu.Combo:Boolean("E", "Use E", true)

--Clear Menu
DMenu:SubMenu("Clear", "Clear")
DMenu.Clear:SubMenu("LaneClear", "Lane Clear")
DMenu.Clear.LaneClear:Boolean("Q", "Use Q", false)
DMenu.Clear.LaneClear:Boolean("W", "Use W", false)
DMenu.Clear:SubMenu("JungleClear", "Jungle Clear")
DMenu.Clear.JungleClear:Boolean("Q", "Use Q", true)
DMenu.Clear.JungleClear:Boolean("W", "Use W", true)

--KillSteal Menu
DMenu:SubMenu("KillSteal", "KillSteal")
DMenu.KillSteal:Boolean("R", "Use R", true)
DMenu.KillSteal:SubMenu("black", "KillSteal White List")
DelayAction(function()
    for _, unit in pairs(GetEnemyHeroes()) do
        DMenu.KillSteal.black:Boolean(unit.name, "Use R On: "..unit.charName, true)
    end
end, 0.01)

--Draw Menu
DMenu:SubMenu("Draw", "Draw")
DMenu.Draw:SubMenu("Spells", "Spells")
DMenu.Draw.Spells:Boolean("Q", "Draw Q Range", false)
DMenu.Draw.Spells:Boolean("E", "Draw E Range", false)
DMenu.Draw.Spells:Boolean("R", "Draw R Range", false)

--Locals
local LoL = "7.x"

--Spells
local DariusQ = { range = 425 }
local DariusE = { range = GetCastRange(myHero, _E) }
local DariusR = { range = GetCastRange(myHero, _R) }

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

OnDraw(function()
    --Range
    if not IsDead(myHero) then
		if DMenu.Draw.Spells.Q:Value() then 
			DrawCircle(myHero,205+GetHitBox(myHero),0,50,ARGB(255, 0, 255, 0))
			DrawCircle(myHero,DariusQ.range,0,50,ARGB(255, 0, 255, 0))
		end
        if DMenu.Draw.Spells.E:Value() then 
			DrawCircle(myHero, DariusE.range,0,50,ARGB(255, 173, 255, 47)) 
		end
        if DMenu.Draw.Spells.R:Value() then 
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
	else
		return DACR:GetTarget()
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
                if Ready(_Q) and DMenu.Clear.LaneClear.Q:Value() and ValidTarget(unit, DariusQ.range) then
                    CastSpell(_Q)
                end 
            end
			--Jungle Clear
            if GetTeam(unit) == MINION_JUNGLE then
                --Q
                if Ready(_Q) and DMenu.Clear.JungleClear.Q:Value() and ValidTarget(unit, DariusQ.range) then
                    CastSpell(_Q)
                end
                --W
                if Ready(_W) and  DMenu.Clear.JungleClear.W:Value() and ValidTarget(unit, DMenu.Combo.Wrange:Value()) then
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
				CastTargetSpell(unit, _R)
			end
		end
	end
end

print("<font color=\"#0099FF\"><b>[Darius]: Loaded</b></font> || Version: "..ver," ", "|| LoL Support : "..LoL)
