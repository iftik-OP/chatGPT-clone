# Troubleshooting Guide

## Network Connectivity Issues

### Error: "Failed host lookup: 'api.openai.com'"

This error indicates that your app cannot connect to the OpenAI API. Here are the steps to resolve this:

### Error: "Request timed out. Please try again"

This error indicates that the request to OpenAI API is taking too long to complete. Here are the steps to resolve this:

#### 1. Check Internet Connection
- Ensure your device has a stable internet connection
- Try opening a web browser and visiting https://api.openai.com
- If the website doesn't load, you have a general internet connectivity issue

#### 2. Check API Key Configuration
- Verify that your `.env` file contains a valid OpenAI API key:
  ```
  OPENAI_API_KEY=your_actual_api_key_here
  ```
- Make sure there are no extra spaces or quotes around the API key
- Ensure the API key is valid and has sufficient credits

#### 3. Network Restrictions
- Check if you're behind a firewall or VPN that blocks API calls
- Some corporate networks block external API calls
- Try switching between WiFi and mobile data

#### 4. DNS Issues
- Try using a different DNS server (8.8.8.8 or 1.1.1.1)
- Restart your network router
- Clear DNS cache on your device

#### 5. App Permissions
- Ensure the app has internet permission
- On Android: Check Settings > Apps > ChatGPT Clone > Permissions
- On iOS: Check Settings > Privacy & Security > Network

#### 6. Development Environment
- If testing on an emulator, ensure it has internet access
- Try running on a physical device
- Check if your development machine has internet access

#### 7. Timeout-Specific Solutions
- **Slow Network**: Try using a faster internet connection
- **Server Load**: OpenAI servers might be busy, try again in a few minutes
- **Large Requests**: Try sending shorter messages
- **Model Selection**: Try using a faster model like GPT-3.5-turbo instead of GPT-4
- **Retry Logic**: The app now automatically retries failed requests

### Common Solutions

1. **Restart the app** - Close and reopen the application
2. **Restart your device** - Sometimes a simple restart fixes network issues
3. **Check OpenAI Status** - Visit https://status.openai.com to see if there are any service issues
4. **Update the app** - Ensure you're using the latest version
5. **Clear app cache** - Clear the app's cache and data

### Testing API Key

You can test your API key by making a simple curl request:

```bash
curl -X POST https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 10
  }'
```

If this returns an error, the issue is with your API key or network configuration.

### Still Having Issues?

If you continue to experience problems:

1. Check the app logs for more detailed error messages
2. Try using a different network (mobile data vs WiFi)
3. Contact your network administrator if on a corporate network
4. Verify your OpenAI account has sufficient credits
5. Check if your API key has the necessary permissions

### Fallback Mode

The app includes a fallback mode that will show helpful error messages when the API is unavailable, so you'll know exactly what the issue is. 