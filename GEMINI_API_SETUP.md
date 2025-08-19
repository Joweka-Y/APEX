# Gemini API Setup Guide

To make the chatbot work, you need to set up your Gemini API key:

## Step 1: Get Your API Key
1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the generated API key

## Step 2: Add API Key to the App
1. Open `lib/services/gemini_service.dart`
2. Find this line:
   ```dart
   static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
   ```
3. Replace `'YOUR_GEMINI_API_KEY_HERE'` with your actual API key:
   ```dart
   static const String _apiKey = 'AIzaSyYourActualAPIKeyHere';
   ```

## Step 3: Test the Chatbot
1. Run the app
2. Go to the Chat tab
3. Send a message to test if it works

## Troubleshooting
- If you see "API service not available" error, check your API key
- If you see "quota exceeded" error, you may need to wait or upgrade your plan
- Make sure you have an active internet connection

## Note
The Gemini API has usage limits. For development and testing, the free tier should be sufficient.
