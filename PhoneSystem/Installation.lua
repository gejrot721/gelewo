-- Installation.lua
-- Script untuk instalasi otomatis sistem handphone

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")

local Installation = {}

-- Check if PhoneSystem already exists
function Installation.checkExistingInstallation()
    local phoneSystem = ReplicatedStorage:FindFirstChild("PhoneSystem")
    if phoneSystem then
        warn("PhoneSystem already exists in ReplicatedStorage!")
        return false
    end
    return true
end

-- Create folder structure
function Installation.createFolderStructure()
    print("Creating folder structure...")
    
    -- Main PhoneSystem folder
    local phoneSystemFolder = Instance.new("Folder")
    phoneSystemFolder.Name = "PhoneSystem"
    phoneSystemFolder.Parent = ReplicatedStorage
    
    -- Client folder
    local clientFolder = Instance.new("Folder")
    clientFolder.Name = "Client"
    clientFolder.Parent = phoneSystemFolder
    
    -- Server folder
    local serverFolder = Instance.new("Folder")
    serverFolder.Name = "Server"
    serverFolder.Parent = phoneSystemFolder
    
    -- Shared folder
    local sharedFolder = Instance.new("Folder")
    sharedFolder.Name = "Shared"
    sharedFolder.Parent = phoneSystemFolder
    
    -- Client subfolders
    local clientControllers = Instance.new("Folder")
    clientControllers.Name = "Controllers"
    clientControllers.Parent = clientFolder
    
    local clientServices = Instance.new("Folder")
    clientServices.Name = "Services"
    clientServices.Parent = clientFolder
    
    local clientUI = Instance.new("Folder")
    clientUI.Name = "UI"
    clientUI.Parent = clientFolder
    
    local clientPhoneUI = Instance.new("Folder")
    clientPhoneUI.Name = "Phone"
    clientPhoneUI.Parent = clientUI
    
    local clientContactsUI = Instance.new("Folder")
    clientContactsUI.Name = "Contacts"
    clientContactsUI.Parent = clientUI
    
    local clientChatUI = Instance.new("Folder")
    clientChatUI.Name = "Chat"
    clientChatUI.Parent = clientUI
    
    local clientCallsUI = Instance.new("Folder")
    clientCallsUI.Name = "Calls"
    clientCallsUI.Parent = clientUI
    
    -- Shared subfolders
    local sharedUtils = Instance.new("Folder")
    sharedUtils.Name = "Utils"
    sharedUtils.Parent = sharedFolder
    
    print("Folder structure created successfully!")
    return phoneSystemFolder
end

-- Install scripts
function Installation.installScripts(phoneSystemFolder)
    print("Installing scripts...")
    
    -- Create server script
    local serverScript = Instance.new("Script")
    serverScript.Name = "PhoneSystemServer"
    serverScript.Source = [[-- PhoneSystemServer.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhoneServer = require(script.Parent.PhoneServer)
PhoneServer.initialize()
print("Phone System Server loaded successfully")]]
    serverScript.Parent = ServerScriptService
    
    -- Create client script
    local clientScript = Instance.new("LocalScript")
    clientScript.Name = "PhoneSystemClient"
    clientScript.Source = [[-- PhoneSystemClient.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local PhoneController = require(script.Parent.Controllers.PhoneController)

local function initializePhoneSystem()
    ReplicatedStorage:WaitForChild("PhoneSystemEvent")
    PhoneController.initialize()
    print("Phone System loaded for player:", player.Name)
end

player.CharacterAdded:Connect(function()
    if not PhoneController.getState().screenGui then
        initializePhoneSystem()
    end
end)

if player.Character then
    initializePhoneSystem()
else
    player.CharacterAdded:Connect(initializePhoneSystem)
end

game:BindToClose(function()
    PhoneController.cleanup()
end)]]
    clientScript.Parent = StarterPlayerScripts
    
    print("Scripts installed successfully!")
end

-- Create installation instructions
function Installation.createInstructions()
    local instructions = [[
# PhoneSystem Installation Complete!

## Next Steps:

1. **Copy Files**: Copy all the PhoneSystem files from the provided folder structure to your ReplicatedStorage/PhoneSystem/

2. **Verify Installation**: Make sure all files are in place:
   - Shared/PhoneConfig.lua
   - Shared/PhoneTypes.lua
   - Shared/Utils/UIScale.lua
   - Client/Controllers/PhoneController.lua
   - Client/Services/VoiceChatService.lua
   - Client/UI/Phone/PhoneUI.lua
   - Client/UI/Phone/MenuButton.lua
   - Client/UI/Contacts/ContactsUI.lua
   - Client/UI/Chat/ChatUI.lua
   - Client/UI/Calls/CallUI.lua
   - Client/UI/Calls/GroupCallUI.lua
   - Server/PhoneServer.lua

3. **Test the System**: 
   - Start the game
   - Look for the phone button (📱) in the top-right corner
   - Click it to open the phone system

4. **Voice Chat Setup**:
   - Enable Voice Chat in Game Settings
   - Make sure players have Voice Chat permissions
   - Test calls between players

## Troubleshooting:

- If the phone button doesn't appear, check the console for errors
- If voice chat doesn't work, verify Voice Chat is enabled in game settings
- If UI is not responsive, check UIScale.lua is properly loaded

## Support:

Refer to the README.md file for detailed documentation and configuration options.
]]
    
    print(instructions)
end

-- Main installation function
function Installation.install()
    print("Starting PhoneSystem installation...")
    
    -- Check if already installed
    if not Installation.checkExistingInstallation() then
        print("Installation cancelled - PhoneSystem already exists!")
        return false
    end
    
    -- Create folder structure
    local phoneSystemFolder = Installation.createFolderStructure()
    
    -- Install scripts
    Installation.installScripts(phoneSystemFolder)
    
    -- Show instructions
    Installation.createInstructions()
    
    print("PhoneSystem installation completed!")
    return true
end

-- Run installation
Installation.install()

return Installation