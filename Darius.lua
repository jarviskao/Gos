--[[
by Jarviskao 
source: https://github.com/jarviskao/Gos/blob/master/Darius.lua

]]

--Hero
if GetObjectName(GetMyHero()) ~= "Darius" then return end

--Load Libs
require ("DamageLib")

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
DMenu.Combo:Slider("Wrange", "Min. range for use W", 200, 0, 500, 10)
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
DMenu.KillSteal:Boolean("Q", "Use Q", true)
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
local rDebuff = {}

--Spells
local DariusQ = { range = 425 }
local DariusE = { range = GetCastRange(myHero, _E) }
local DariusR = { range = GetCastRange(myHero, _R) }

--Mode
function Mode()
    if _G.IOW_Loaded and IOW:Mode() then
        return IOW:Mode()
	elseif _G.PW_Loaded and PW:Mode() then
        return PW:Mode()
	elseif _G.DAC_Loaded and DAC:Mode() then
        return DAC:Mode()
	elseif _G.AutoCarry_Loaded and DACR:Mode() then
        return DACR:Mode()
	elseif _G.SLW_Loaded and SLW:Mode() then
        return SLW:Mode()
    end
end

--Start
OnTick(function (myHero)
	if not IsDead(myHero) then
		--Locals
		local target = GetCurrentTarget()
		--Functions
		OnCombo(target)
		OnClear()
        KillSteal()
	end
end)

OnDraw(function(myHero)
    --Range
    if not IsDead(myHero) then
		if DMenu.Draw.Spells.Q:Value() then 
			DrawCircle(myHero,205+GetHitBox(myHero),1,15,GoS.Red)
			DrawCircle(myHero,DariusQ.range,1,15,GoS.Red)
		end
        if DMenu.Draw.Spells.E:Value() then DrawCircle(myHero, DariusE.range, 1, 15, GoS.Green) end
        if DMenu.Draw.Spells.R:Value() then DrawCircle(myHero, DariusR.range, 1, 15, GoS.Blue) end
    end 
end)

OnUpdateBuff (function(unit, buff)
  if not unit or not buff then
    return
  end
  if buff.Name:lower() == "dariushemo" and GetTeam(buff) ~= (GetTeam(myHero)) and myHero.type == unit.type then
        rDebuff[unit.networkID] = buff.Count
    end
end)

OnRemoveBuff (function(unit, buff)
  if not unit or not buff then
    return
  end
  if buff.Name:lower() == "dariushemo" and GetTeam(buff) ~= (GetTeam(myHero)) and myHero.type == unit.type then
        rDebuff[unit.networkID] = 0
    end
end)

--Functions
function OnCombo(target)
	if Mode() == "Combo" then
		--Q
		if Ready(_Q) and DMenu.Combo.Q:Value() and ValidTarget(target,DariusQ.range) then
			CastSpell(_Q)
		end
		--W
		if Ready(_W) and DMenu.Combo.W:Value() and ValidTarget(target, DMenu.Combo.Wrange:Value()) then
			CastSpell(_W)
		end
	end
end

function OnClear()
    if Mode() == "LaneClear" then
        for _, minion in pairs(minionManager.objects) do
            if GetTeam(minion) == MINION_ENEMY then
                --Q
                if Ready(_Q) and DMenu.Clear.LaneClear.Q:Value() and ValidTarget(minion, 300) then
                    CastSpell(_Q)
                end 
            end
        end
    end
    if Mode() == "LaneClear" then 
        for _, mob in pairs(minionManager.objects) do
            if GetTeam(mob) == MINION_JUNGLE then
                --Q
                if Ready(_Q) and DMenu.Clear.JungleClear.Q:Value() and ValidTarget(mob, 300) then
                    CastSpell(_Q)
                end
                --W
                if Ready(_W) and  DMenu.Clear.JungleClear.W:Value() and ValidTarget(mob, 200) then
                    CastSpell(_W)
                end
            end
        end
    end
end

function KillSteal()
        for i,unit in pairs(GetEnemyHeroes()) do
        if rDebuff ~= nil then
			local rStacks = rDebuff[unit.networkID] or 0
			local rStacksDamage = (rStacks * ((GetSpellData(myHero, _R).level * 20) + (GetBonusDmg(myHero) * 0.15) ))
			local rDamage = getdmg("R",unit,myHero)
            if DMenu.KillSteal.R:Value() and Ready(_R) and ValidTarget(unit,DariusR.range) and  GetCurrentHP(unit) + GetDmgShield(unit) + GetHPRegen(unit) * 0.25 < rDamage + rStacksDamage then
				CastTargetSpell(unit, _R)
            end
		end
			local qDamage = getdmg("Q",unit,myHero)
		    if DMenu.KillSteal.Q:Value() and Ready(_Q) and ValidTarget(unit,DariusQ.range) and GetCurrentHP(unit) + GetDmgShield(unit) <  qDamage then  
				CastSpell(_Q)
			end

        end
end

print("<font color=\"#0099FF\"><b>[Darius]: Loaded</b></font> || Version: "..ver," ", "|| LoL Support : "..LoL)
