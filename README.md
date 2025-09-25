# Roblox Phone System

A comprehensive phone system for Roblox with modern Android-style UI, featuring individual and group calls, chat, contacts, and voice chat integration.

## Features

### 📱 Core Features
- **Modern Android UI**: Clean, responsive design following Material Design principles
- **Cross-Platform**: Optimized for mobile, PC, and console devices
- **Auto-scaling**: UI automatically adjusts to different screen sizes
- **Touch-Friendly**: Designed for easy mobile interaction

### 📞 Communication Features
- **Individual Calls**: One-on-one voice calls between players
- **Group Calls**: Multi-player voice calls with up to 8 participants
- **Text Chat**: Real-time messaging system
- **Voice Chat Integration**: Seamless voice communication using Roblox Voice Chat

### 👥 Contact Management
- **Player Search**: Find and contact any online player
- **Contact List**: View all available players
- **Quick Actions**: Fast access to call and chat functions

### 🎨 UI/UX Features
- **Menu Toggle**: Easy access button positioned center-right
- **Navigation**: Intuitive bottom navigation bar
- **Notifications**: Pop-up notifications for calls and messages
- **Animations**: Smooth transitions and feedback

## Installation

### Step 1: Setup Scripts

1. **Client Script** (`PhoneSystem.lua`):
   - Place in `StarterPlayerScripts` or `StarterGui`
   - This handles the client-side UI and interactions

2. **Server Script** (`PhoneSystemServer.lua`):
   - Place in `ServerScriptService`
   - Handles server-side logic and communication

3. **Configuration** (`PhoneSystemConfig.lua`):
   - Place in `ReplicatedStorage` or `ServerStorage`
   - Customize colors, features, and settings

### Step 2: Enable Voice Chat

1. In Roblox Studio, go to **Game Settings**
2. Navigate to **Privacy** tab
3. Enable **Allow Voice Chat**
4. Set **Voice Chat Mode** to "Enabled"

### Step 3: Configure Permissions

1. In **Game Settings** → **Security**
2. Enable **Allow HTTP Requests** (if using external features)
3. Set appropriate **Place Permissions**

## Usage

### Opening the Phone
- Click the green phone button in the center-right of the screen
- The phone will animate in with a smooth transition

### Making Calls
1. Open the phone menu
2. Go to **Contacts** tab
3. Find the player you want to call
4. Click the green phone icon next to their name
5. Wait for them to answer

### Group Calls
1. From the home screen, click **Group Call**
2. Select players to invite
3. Start the group call
4. All members can join the voice chat

### Chatting
1. Go to **Chat** tab
2. Select a contact or start typing a player's name
3. Type your message and press send
4. Messages appear in real-time

### Navigation
- **Home**: Quick actions and main menu
- **Contacts**: Browse and search for players
- **Chat**: Send and receive messages
- **Calls**: Call controls and active call management

## Customization

### Colors and Theme
Edit `PhoneSystemConfig.lua` to customize:
```lua
PhoneConfig.Colors.Primary = Color3.fromRGB(76, 175, 80)  -- Main green color
PhoneConfig.Colors.Background = Color3.fromRGB(33, 33, 33) -- Dark background
```

### Features
Enable/disable features in the config:
```lua
PhoneConfig.Features = {
    IndividualCalls = true,
    GroupCalls = true,
    Chat = true,
    VoiceChat = true
}
```

### UI Scaling
Adjust autoscaling behavior:
```lua
PhoneConfig.Autoscale = {
    MinScale = 0.8,
    MaxScale = 1.2,
    ReferenceResolution = {X = 1920, Y = 1080}
}
```

## Technical Details

### RemoteEvents
The system uses three main RemoteEvents:
- `CallPlayer`: Handles call requests and responses
- `ChatMessage`: Manages text messaging
- `GroupCall`: Controls group call functionality

### Voice Chat Integration
- Uses Roblox's built-in Voice Chat Service
- Creates dedicated voice channels for calls
- Supports echo cancellation and noise suppression

### Performance Optimization
- Efficient UI updates with RunService
- Memory-conscious contact management
- Optimized animations with TweenService

## Troubleshooting

### Common Issues

**Phone won't open:**
- Check if the script is in the correct location
- Verify RemoteEvents are properly created
- Check for script errors in Developer Console

**Voice chat not working:**
- Ensure Voice Chat is enabled in game settings
- Check player's microphone permissions
- Verify Voice Chat Service is available

**UI scaling issues:**
- Adjust autoscale settings in config
- Check device resolution compatibility
- Test on different screen sizes

**Calls not connecting:**
- Verify server script is running
- Check network connectivity
- Ensure RemoteEvents are properly connected

### Performance Tips

1. **Limit active calls**: Too many simultaneous calls can impact performance
2. **Optimize UI**: Disable unnecessary animations on lower-end devices
3. **Memory management**: Regular cleanup of old chat history
4. **Network optimization**: Limit message frequency to prevent spam

## API Reference

### Client Functions
```lua
-- Open/close phone
phoneSystem:TogglePhone()

-- Start a call
phoneSystem:StartCall(playerName)

-- Send a message
phoneSystem:SendMessage(playerName, message)

-- Join group call
phoneSystem:JoinGroupCall(groupId)
```

### Server Functions
```lua
-- Handle call request
PhoneServer:HandleCall(sender, target, action)

-- Process chat message
PhoneServer:HandleChat(sender, target, message)

-- Manage group calls
PhoneServer:HandleGroupCall(sender, action, members)
```

## Support

For issues, feature requests, or questions:
1. Check this README for common solutions
2. Review the script comments for technical details
3. Test in a private server before publishing
4. Verify all dependencies are properly installed

## License

This phone system is provided as-is for educational and entertainment purposes. Feel free to modify and adapt for your specific needs.

---

**Note**: This system requires Roblox Voice Chat to be enabled and may not work in all game environments. Test thoroughly before publishing to ensure compatibility with your specific game setup.