# How to Find Your Computer's IP Address

## For Android Physical Device Connection

Your Android phone needs to connect to your backend server running on your computer. To do this, you need to use your computer's **local IP address** instead of `localhost`.

### Windows:
1. Open Command Prompt (CMD) or PowerShell
2. Type: `ipconfig`
3. Look for **"IPv4 Address"** under your active network adapter (usually WiFi or Ethernet)
4. It will look like: `192.168.1.xxx` or `192.168.0.xxx` or `10.0.0.xxx`

### Mac:
1. Open Terminal
2. Type: `ifconfig | grep "inet " | grep -v 127.0.0.1`
3. Look for the IP address (usually starts with `192.168.` or `10.0.`)

### Linux:
1. Open Terminal
2. Type: `ip addr` or `ifconfig`
3. Look for your network interface (usually `wlan0` or `eth0`)
4. Find the `inet` address (usually `192.168.x.x`)

## Steps to Update:

1. **Find your IP** using the methods above
2. **Update `frontend/lib/services/api_service.dart`**:
   - Change line 9: `static const String baseUrl = 'http://YOUR_IP_HERE:4000/api';`
   - Example: `static const String baseUrl = 'http://192.168.1.105:4000/api';`

3. **Make sure**:
   - ✅ Your computer and phone are on the **same WiFi network**
   - ✅ Your backend is running (`cd backend && npm run dev`)
   - ✅ Windows Firewall allows connections on port 4000 (or temporarily disable firewall for testing)

4. **Hot restart** your Flutter app after changing the IP

## Test Connection:

You can test if your phone can reach the backend by opening a browser on your phone and visiting:
`http://YOUR_IP:4000/api/health`

If you see a JSON response, the connection works!









