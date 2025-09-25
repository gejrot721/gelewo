-- VoiceChatService.lua
-- Service untuk mengelola voice chat Roblox

local VoiceChatService = game:GetService("VoiceChatService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PhoneConfig = require(script.Parent.Parent.Shared.PhoneConfig)
local PhoneTypes = require(script.Parent.Parent.Shared.PhoneTypes)

local VoiceChatManager = {}

-- Voice chat state
local voiceChatState = {
    isEnabled = false,
    isMuted = false,
    isSpeakerOn = true,
    currentChannel = nil,
    participants = {},
    volume = 1.0
}

-- Initialize voice chat
function VoiceChatManager.initialize()
    print("Initializing Voice Chat Service...")
    
    -- Check if voice chat is available
    if not VoiceChatService.Available then
        warn("Voice chat is not available on this platform")
        return false
    end
    
    -- Enable voice chat
    VoiceChatManager.enableVoiceChat()
    
    -- Set up event listeners
    VoiceChatManager.setupEventListeners()
    
    return true
end

-- Enable voice chat
function VoiceChatManager.enableVoiceChat()
    if VoiceChatService.Available then
        VoiceChatService:RequestPermissionsForVoiceChat()
        
        -- Wait for permissions
        VoiceChatService.PromptForPermissionOnVoiceChatActivation = false
        
        voiceChatState.isEnabled = true
        print("Voice chat enabled")
    else
        warn("Voice chat not available")
        voiceChatState.isEnabled = false
    end
end

-- Setup event listeners
function VoiceChatManager.setupEventListeners()
    -- Listen for voice chat state changes
    VoiceChatService.StateChanged:Connect(function(oldState, newState)
        print("Voice chat state changed:", oldState, "->", newState)
        VoiceChatManager.onVoiceChatStateChanged(newState)
    end)
    
    -- Listen for participant changes
    VoiceChatService.ParticipantAdded:Connect(function(participant)
        print("Participant added:", participant)
        VoiceChatManager.onParticipantAdded(participant)
    end)
    
    VoiceChatService.ParticipantRemoved:Connect(function(participant)
        print("Participant removed:", participant)
        VoiceChatManager.onParticipantRemoved(participant)
    end)
    
    -- Listen for speaking changes
    VoiceChatService.ParticipantSpeakingChanged:Connect(function(participant, speaking)
        print("Participant speaking changed:", participant, speaking)
        VoiceChatManager.onParticipantSpeakingChanged(participant, speaking)
    end)
end

-- Handle voice chat state changes
function VoiceChatManager.onVoiceChatStateChanged(newState)
    if newState == Enum.VoiceChatState.Idle then
        voiceChatState.currentChannel = nil
        voiceChatState.participants = {}
    elseif newState == Enum.VoiceChatState.Joining then
        print("Joining voice chat...")
    elseif newState == Enum.VoiceChatState.Joined then
        print("Successfully joined voice chat")
    elseif newState == Enum.VoiceChatState.Leaving then
        print("Leaving voice chat...")
    elseif newState == Enum.VoiceChatState.Failed then
        warn("Voice chat failed")
        VoiceChatManager.handleVoiceChatFailure()
    end
end

-- Handle participant added
function VoiceChatManager.onParticipantAdded(participant)
    voiceChatState.participants[participant] = {
        userId = participant.UserId,
        username = participant.Name,
        isSpeaking = false,
        isMuted = false
    }
    
    print("Added participant:", participant.Name)
end

-- Handle participant removed
function VoiceChatManager.onParticipantRemoved(participant)
    voiceChatState.participants[participant] = nil
    print("Removed participant:", participant.Name)
end

-- Handle participant speaking changed
function VoiceChatManager.onParticipantSpeakingChanged(participant, speaking)
    if voiceChatState.participants[participant] then
        voiceChatState.participants[participant].isSpeaking = speaking
    end
    
    -- Notify UI about speaking changes
    VoiceChatManager.notifySpeakingChange(participant, speaking)
end

-- Start individual call
function VoiceChatManager.startIndividualCall(targetUserId)
    if not voiceChatState.isEnabled then
        warn("Voice chat not enabled")
        return false
    end
    
    print("Starting individual call with:", targetUserId)
    
    -- Create a unique channel for this call
    local callId = "call_" .. tostring(tick())
    
    -- Join the call channel
    local success = pcall(function()
        VoiceChatService:JoinByGroupIdToken(callId)
    end)
    
    if success then
        voiceChatState.currentChannel = callId
        print("Successfully started individual call")
        return true
    else
        warn("Failed to start individual call")
        return false
    end
end

-- Start group call
function VoiceChatManager.startGroupCall(participantUserIds)
    if not voiceChatState.isEnabled then
        warn("Voice chat not enabled")
        return false
    end
    
    print("Starting group call with participants:", participantUserIds)
    
    -- Create a unique channel for this group call
    local groupCallId = "group_" .. tostring(tick())
    
    -- Join the group call channel
    local success = pcall(function()
        VoiceChatService:JoinByGroupIdToken(groupCallId)
    end)
    
    if success then
        voiceChatState.currentChannel = groupCallId
        print("Successfully started group call")
        return true
    else
        warn("Failed to start group call")
        return false
    end
end

-- Join existing call
function VoiceChatManager.joinCall(callId)
    if not voiceChatState.isEnabled then
        warn("Voice chat not enabled")
        return false
    end
    
    print("Joining call:", callId)
    
    local success = pcall(function()
        VoiceChatService:JoinByGroupIdToken(callId)
    end)
    
    if success then
        voiceChatState.currentChannel = callId
        print("Successfully joined call")
        return true
    else
        warn("Failed to join call")
        return false
    end
end

-- End current call
function VoiceChatManager.endCall()
    if voiceChatState.currentChannel then
        print("Ending call:", voiceChatState.currentChannel)
        
        local success = pcall(function()
            VoiceChatService:LeaveChannel()
        end)
        
        if success then
            voiceChatState.currentChannel = nil
            voiceChatState.participants = {}
            print("Successfully ended call")
            return true
        else
            warn("Failed to end call")
            return false
        end
    end
    
    return true
end

-- Toggle mute
function VoiceChatManager.toggleMute()
    if not voiceChatState.isEnabled then
        return false
    end
    
    voiceChatState.isMuted = not voiceChatState.isMuted
    
    local success = pcall(function()
        VoiceChatService:SetMicEnabled(not voiceChatState.isMuted)
    end)
    
    if success then
        print("Mute toggled:", voiceChatState.isMuted)
        return true
    else
        warn("Failed to toggle mute")
        voiceChatState.isMuted = not voiceChatState.isMuted -- Revert
        return false
    end
end

-- Set mute state
function VoiceChatManager.setMuted(muted)
    if voiceChatState.isMuted == muted then
        return true
    end
    
    voiceChatState.isMuted = muted
    
    local success = pcall(function()
        VoiceChatService:SetMicEnabled(not voiceChatState.isMuted)
    end)
    
    if success then
        print("Mute set to:", voiceChatState.isMuted)
        return true
    else
        warn("Failed to set mute state")
        return false
    end
end

-- Toggle speaker
function VoiceChatManager.toggleSpeaker()
    voiceChatState.isSpeakerOn = not voiceChatState.isSpeakerOn
    
    -- Adjust volume based on speaker state
    if voiceChatState.isSpeakerOn then
        VoiceChatManager.setVolume(1.0)
    else
        VoiceChatManager.setVolume(0.3) -- Lower volume for earpiece
    end
    
    print("Speaker toggled:", voiceChatState.isSpeakerOn)
    return true
end

-- Set volume
function VoiceChatManager.setVolume(volume)
    volume = math.clamp(volume, 0.0, 1.0)
    voiceChatState.volume = volume
    
    -- Apply volume to voice chat
    local success = pcall(function()
        -- Note: Roblox VoiceChatService doesn't have direct volume control
        -- This would need to be implemented through audio processing
        print("Volume set to:", volume)
    end)
    
    return success
end

-- Get voice chat state
function VoiceChatManager.getState()
    return voiceChatState
end

-- Get participants
function VoiceChatManager.getParticipants()
    return voiceChatState.participants
end

-- Check if participant is speaking
function VoiceChatManager.isParticipantSpeaking(participant)
    if voiceChatState.participants[participant] then
        return voiceChatState.participants[participant].isSpeaking
    end
    return false
end

-- Handle voice chat failure
function VoiceChatManager.handleVoiceChatFailure()
    voiceChatState.isEnabled = false
    voiceChatState.currentChannel = nil
    voiceChatState.participants = {}
    
    -- Notify UI about failure
    VoiceChatManager.notifyVoiceChatFailure()
end

-- Notify UI about speaking changes
function VoiceChatManager.notifySpeakingChange(participant, speaking)
    -- This will be connected to UI components
    local event = ReplicatedStorage:FindFirstChild("PhoneSystemEvent")
    if event then
        event:FireServer("ParticipantSpeakingChanged", {
            participant = participant.UserId,
            speaking = speaking
        })
    end
end

-- Notify UI about voice chat failure
function VoiceChatManager.notifyVoiceChatFailure()
    local event = ReplicatedStorage:FindFirstChild("PhoneSystemEvent")
    if event then
        event:FireServer("VoiceChatFailed", {})
    end
end

-- Check if voice chat is available
function VoiceChatManager.isAvailable()
    return VoiceChatService.Available
end

-- Check if voice chat is enabled
function VoiceChatManager.isEnabled()
    return voiceChatState.isEnabled
end

-- Get current call channel
function VoiceChatManager.getCurrentChannel()
    return voiceChatState.currentChannel
end

-- Clean up voice chat
function VoiceChatManager.cleanup()
    VoiceChatManager.endCall()
    voiceChatState.isEnabled = false
    voiceChatState.participants = {}
    print("Voice chat service cleaned up")
end

return VoiceChatManager