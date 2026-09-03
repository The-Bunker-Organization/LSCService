export type config = {
	source: string,
	parent: Instance?,
	type: "Script" | "ModuleScript" | "LocalScript" | "vLuau", --reminder: make this shit BETTER
	runcontext: Enum.RunContext?
}

local typeof=typeof
local setfenv=setfenv
local table=table
local Enum=Enum

local folder, vLuau = script.scrs:Clone(), script._vLuau:Clone()
local bindfunction=Instance.new("BindableFunction")

setfenv(0,table.freeze{})
setfenv(1,table.freeze{})

local function handleInteraction(config:config): BaseScript
	if config == "vLuau" then return vLuau:Clone() end

	if typeof(config)~="table" or typeof(config.source)~="string" or typeof(config.type)~="string" then
		return nil
	end

	--assert(config and typeof(config) == "table", "Config must be provided and must be a table")
	--assert(config.source and typeof(config.source) == "string", "source must be provided and be a string")
	--assert(config.type == nil or typeof(config.type) == "string", "type must be provided and be a string")

	local scr = (function()
		if config.runcontext and config.runcontext == Enum.RunContext.Client then
			return folder:FindFirstChild("ClientRunContext")
		elseif config.runcontext and config.runcontext==Enum.RunContext.Server then
			return folder:FindFirstChild("ServerRunContext")
		end

		return folder:FindFirstChild(config.type) or folder.Script
	end)()

	local new = scr:Clone()

	new:SetAttribute("Source", config.source)

	vLuau:Clone().Parent = new

	if typeof(config.parent)=="Instance" or config.parent==nil then new.Parent = config.parent end

	return new
end

bindfunction.OnInvoke=handleInteraction

return setfenv(function(...)
	return bindfunction:Invoke(...)
end,table.freeze{})
