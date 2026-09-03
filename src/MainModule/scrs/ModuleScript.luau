local source = script:GetAttribute("Source");script:SetAttribute("Source", "")
local loadstring = (function()
	local lsenabled = pcall(loadstring, "x=1")
	if not lsenabled then
		return require(script:FindFirstChild("_vLuau"):Clone())
	else
		if script:FindFirstChild("_vLuau") then
			script:FindFirstChild("_vLuau"):Destroy()
		end
		return loadstring
	end
end)()
return loadstring(source)()
