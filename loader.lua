--//Written by Hexa

if game.PlaceId ~= 1111083356 then return end

local LatestVersion = tonumber(syn.request("https://raw.githubusercontent.com/HexaRG/rb64-better-replication/master/version.txt","GET"))

if isfolder("rb64br") then
    local Version = tonumber(readfile("rb64br/version.txt"))
    if Version ~= LatestVersion then
        writefile("rb64br/main.lua",syn.request("https://raw.githubusercontent.com/HexaRG/rb64-better-replication/master/main.lua","GET"))
        writefile("rb64br/version.txt",tostring(LatestVersion))
    end
else
    makefolder("rb64br")
    writefile("rb64br/version.txt",tostring(LatestVersion))
    writefile("rb64br/main.lua",syn.request("https://raw.githubusercontent.com/HexaRG/rb64-better-replication/master/main.lua","GET"))
end