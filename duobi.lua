local Enabled = true

-- 1 = 100%, 0.25 = 25%
local COUNTER_MODE = false -- NOT RECOMMEND
local Legit = {
   Enabled = true,
   LightChance = 0.3,
   HeavyChance = 0.75,
}


local Client = game.Players.LocalPlayer
local States = workspace.States
local Effect = require(game:GetService("ReplicatedStorage").Modules.EffectHelper)

function get(n,s)
   return States[n.Name]:FindFirstChild(s, true).Value
end
function get_root(chr)
   return chr.HumanoidRootPart
end
function attack(char)
   game:GetService("ReplicatedStorage").dataRemoteEvent:FireServer({{"02010000",char},"\20"})
end

function dashToBehind(target, _direction)
   local targetCfr = get_root(target).CFrame
   local targetPos = (targetCfr * CFrame.new(0,0,-1)).p
   local myCFrame = Client.Character.HumanoidRootPart.CFrame
   local direction = myCFrame.p - targetCfr.p
   local right = targetCfr.RightVector
   -- print(right:Dot(direction))
   game:GetService("ReplicatedStorage").dataRemoteEvent:FireServer({{direction, _direction},"\21"})
end
function random()
   return math.random(1,100)/100
end
local waiting = {}
function waitValid(name,func)
   if not waiting[name] then waiting[name] = {} end
   table.insert(waiting[name], func)
   warn("Added Queue :", name)
end
function valid(name,...)
   for i=1,#waiting[name] do
       task.spawn(waiting[name][i], ...)
   end
   waiting[name] = nil
   warn("Cleared Queue :", name)
end

shared.BaseEffectFunction = shared.BaseEffectFunction or {}
for i,v in pairs(Effect) do
   shared.BaseEffectFunction[i] = shared.BaseEffectFunction[i] or v
   Effect[i] = function(d,...)
       task.spawn(function()
           if not Enabled then return end
           if type(d) == "table" and typeof(d[2]) == "Instance" then
               local Target = get(Client, "LockedOn")
               -- if Target == d[2] then table.foreach(d,print) warn("------------")  end
               local Distance = Client:DistanceFromCharacter(get_root(d[2]).Position)
               if Distance > 10 then return end
               if d[1] == "AttackTrail" and d[2] ~= Client.Character then
                   if Legit.Enabled and d[5] < 0.15 then return end
                   waitValid(d[2].Name ,function(LightAttack)
                       if Legit.Enabled then
                           if LightAttack and random() > Legit.LightChance or random() > Legit.HeavyChance then
                               return
                           end
                           if get(Client,"Punching") then return end
                       end
                       if COUNTER_MODE then
                           attack(d[2])
                       else
                           local delay = d[5] * .75
                           -- warn("waiting to dash :", delay)
                           task.wait(delay)
                           dashToBehind(d[2], "Right")
                       end
                   end)
               end
               if d[1] == "StartupHighlight" then
                   valid(d[2].Name, not (d[3] or d[4] or d[5]))
               end
           end
       end)
       return shared.BaseEffectFunction[i](d,...)
   end
end
