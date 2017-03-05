--Hero
if GetObjectName(GetMyHero()) ~= "Garen" then return end

--Load Libs
require ("DamageLib")

--Auto Update
local ver = "1.00"


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

--Ultimate Menu
GMenu:SubMenu("Ultimate", "Ultimate")
GMenu.Ultimate:Boolean("R", "Use R", true)
GMenu.Ultimate:SubMenu("black", "Ultimate White List")
DelayAction(function()
    for _, unit in pairs(GetEnemyHeroes()) do
        GMenu.Ultimate.black:Boolean(unit.name, "Use R On: "..unit.charName, true)
    end
end, 0.01)

--Auto Menu
GMenu:SubMenu("a", "Auto")
GMenu.a:Boolean("W", "Use W", true)
GMenu.a:Slider("Whp", "Use W if HP(%) <= X", 70, 0, 100, 5)
GMenu.a:Slider("Wlim", "Use W if Enemy Count >= X", 1, 1, 5, 1)

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

--Draw Menu
GMenu:SubMenu("d", "Draw")
--GMenu.d:SubMenu("dt", "Text")
--GMenu.d.dt:Boolean("Stats", "Draw HP and R Damage Info", true)
--GMenu.d.dt:Boolean("R", "Draw R kill Notification", true)
GMenu.d:SubMenu("ds", "Spells")
GMenu.d.ds:Boolean("E", "Draw E Range", true)
GMenu.d.ds:Boolean("R", "Draw R Range", true)

--Skin Menu
GMenu:SubMenu("s", "Skin Changer")
  skinMeta = {["Garen"] = {"Classic", "Sanguine", "Desert Trooper", "Commando", "Dreadknight", "Rugged", "Steel Legion", "Chroma Pack: Garnet", "Chroma Pack: Plum", "Chroma Pack: Ivory", "Rogue Admiral"}}
  GMenu.s:DropDown('skin', myHero.charName.. " Skins", 1, skinMeta[myHero.charName],function(model)
        HeroSkinChanger(myHero, model - 1) print(skinMeta[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") 
    end,
true)

--Locals
local LoL = "7.x"

--Spells
local GarenE_Range = GetCastRange(myHero, _E)
local GarenR_Range = GetCastRange(myHero, _R)

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
        OnLastHit()
        OnHarass(target)
        OnClear()
        CastR()
	end
end)

OnDraw(function(myHero)
--[[
    --Text
    for x,unit in pairs(GetEnemyHeroes()) do 
        if ValidTarget(unit,2000) and WorldToScreen(0,unit.pos).flag and GMenu.d.dt.Stats:Value() then
            if Ready(_R) then
                DrawText("R Damage: "..getdmg("R",unit,myHero), 16, GetHPBarPos(unit).x, GetHPBarPos(unit).y-58, GoS.Yellow)
            end
            if not Ready(_R) then
                DrawText("R Damage: Not Ready", 16, GetHPBarPos(unit).x, GetHPBarPos(unit).y-58, GoS.Yellow)
            end
            DrawText("Current HP:  "..math.round(GetCurrentHP(unit)), 16, GetHPBarPos(unit).x, GetHPBarPos(unit).y-43, GoS.Red)
        end
        if GMenu.d.dt.R:Value() and Ready(_R) and ValidTarget(unit,1500) and GetCurrentHP(unit) + GetDmgShield(unit) <  getdmg("R",unit,myHero) then
            if GMenu.Ultimate.black[unit.name]:Value() then
                DrawText("Finish Him!", 25, GetHPBarPos(unit).x, GetHPBarPos(unit).y+18, GoS.Red)
                DrawCircle(unit, 120, 3, 15, GoS.Red)
                DrawCircle(unit, 90, 3, 15, GoS.Red)
                DrawCircle(unit, 60, 3, 15, GoS.Red)
            end
        end
    end
--]]
    --Range
    if not IsDead(myHero) then
        if GMenu.d.ds.E:Value() then DrawCircle(myHero, GetCastRange(myHero, _E), 2, 15, GoS.Red) end
        if GMenu.d.ds.R:Value() then DrawCircle(myHero, GetCastRange(myHero, _R), 2, 15, GoS.Green) end
    end 
end)

--Functions
function OnCombo(target)
	if Mode() == "Combo" then
		--Q
		if Ready(_Q) and GMenu.c.Q:Value() and ValidTarget(target, GMenu.c.Qrange:Value()) then
			CastSpell(_Q)
		end
		--E
		if Ready(_E) and GMenu.c.E:Value() and ValidTarget(target, GarenE_Range) and GetCastName(myHero, _E) == "GarenE" then
			CastSpell(_E)
		end
	end
end

function OnLastHit()
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

function OnHarass(target)
    if Mode() == "Harass" then
        --Q
        if Ready(_Q) and GMenu.h.Q:Value() and ValidTarget(target, GMenu.h.Qrange:Value()) then
            CastSpell(_Q)
        end
        --E
        if Ready(_E) and GMenu.h.E:Value() and ValidTarget(target, GarenE_Range) and GetCastName(myHero, _E) == "GarenE" then
            CastSpell(_E)
        end
    end
end

function OnClear()
    if Mode() == "LaneClear" then
        for _, minion in pairs(minionManager.objects) do
            if GetTeam(minion) == MINION_ENEMY then
                --Q
                if Ready(_Q) and GMenu.cl.l.Q:Value() and ValidTarget(minion, 300) then
                    CastSpell(_Q)
                end
                --E
                if Ready(_E) and GMenu.cl.l.E:Value() and ValidTarget(minion, GarenE_Range) and GetCastName(myHero, _E) == "GarenE" and MinionsAround(minion, 950) >= 3 then
                    CastSpell(_E)
                end
            end
        end
    end
    if Mode() == "LaneClear" then --[[JungleClear doesnt work :doge:]]
        for _, mob in pairs(minionManager.objects) do
            if GetTeam(mob) == MINION_JUNGLE then
                --Q
                if Ready(_Q) and GMenu.cl.j.Q:Value() and ValidTarget(mob, 300) then
                    CastSpell(_Q)
                end
                --E
                if Ready(_E) and GMenu.cl.j.E:Value() and ValidTarget(mob, GarenE_Range) and GetCastName(myHero, _E) == "GarenE" then
                    CastSpell(_E)
                end
            end
        end
    end
end

function CastR()
    for _,unit in pairs(GetEnemyHeroes()) do
        if GMenu.Ultimate.R:Value() and Ready(_R) and ValidTarget(unit, GarenR_Range) and GetCurrentHP(unit) + GetDmgShield(unit) <  getdmg("R",unit,myHero) then
            if GMenu.Ultimate.black[unit.name]:Value() then
                CastTargetSpell(unit,_R)
            end
        end
    end
end

--CB
OnProcessSpell(function(unit,spellProc)    
    if unit.isMe and spellProc.name:lower():find("attack") and EnemiesAround(myHero, 950) >= GMenu.a.Wlim:Value() then     
        if GMenu.a.W:Value() and Ready(_W) and GetPercentHP(myHero) < GMenu.a.Whp:Value() then 
            CastSpell(_W)   
        end
    end
end)

print("<font color=\"#0099FF\"><b>[Garen]: Loaded</b></font> || Version: "..ver," ", "|| LoL Support : "..LoL)
