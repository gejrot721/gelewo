-- PhoneSystemServer.lua
-- Main server script untuk menjalankan sistem handphone

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import main server module
local PhoneServer = require(script.Parent.PhoneServer)

-- Initialize phone server
PhoneServer.initialize()

print("Phone System Server loaded successfully")