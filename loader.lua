--//Written by Hexa

game.Loaded:Connect(function()
    if game.PlaceId ~= 1111083356 then return end

    local LatestVersion = tonumber(syn.request({Url = "https://raw.githubusercontent.com/HexaRG/rb64-better-replication/master/version.txt"}).Body)
    
    if isfolder("rb64br") then
        local Version = tonumber(readfile("rb64br/version.txt"))
        if Version ~= LatestVersion then
            writefile("rb64br/main.lua",syn.request({Url = "https://raw.githubusercontent.com/HexaRG/rb64-better-replication/master/main.lua"}).Body)
            writefile("rb64br/version.txt",tostring(LatestVersion))
        end
    else
        makefolder("rb64br")
        writefile("rb64br/version.txt",tostring(LatestVersion))
        writefile("rb64br/main.lua",syn.request({Url = "https://raw.githubusercontent.com/HexaRG/rb64-better-replication/master/main.lua"}).Body)
    end
    loadstring(readfile("rb64br/main.lua"))()
end)