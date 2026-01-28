# Action Repository Setup Guide

This guide will help you create the `action-repo` that will trigger webhooks to your webhook receiver.

## Step 1: Create the Action Repository

1. Go to GitHub.com and sign in
2. Click the "+" icon in the top right → "New repository"
3. Repository settings:
   - **Name**: `action-repo` (or any name you prefer)
   - **Description**: "Test repository for GitHub webhook events"
   - **Visibility**: Public or Private (both work)
   - **Initialize**: ✅ Add a README file
   - Click "Create repository"

## Step 2: Set Up Local Development

Clone your new repository:
```bash
git clone https://github.com/YOUR_USERNAME/action-repo.git
cd action-repo
```

Add some sample files to make testing easier:
```bash
# Create a sample Python file
echo "print('Hello, World!')" > main.py

# Create a development branch
git checkout -b dev

# Commit and push
git add .
git commit -m "Add initial files"
git push origin dev

# Switch back to main
git checkout main
```

## Step 3: Expose Your Webhook Receiver

Since GitHub needs a public URL to send webhooks, use ngrok:

### Install ngrok:
1. Go to https://ngrok.com/
2. Sign up for a free account
3. Download ngrok for your OS
4. Follow installation instructions

### Run ngrok:
```bash
# In a separate terminal window
ngrok http 5000
```

You'll see output like:
```
Forwarding    https://abc123.ngrok.io -> http://localhost:5000
```

**Copy the HTTPS URL** (e.g., `https://abc123.ngrok.io`)

**Important**: Keep this terminal running! If you restart ngrok, the URL will change.

## Step 4: Configure GitHub Webhook

1. Go to your `action-repo` on GitHub
2. Click **Settings** (repository settings, not account settings)
3. In the left sidebar, click **Webhooks**
4. Click **Add webhook**

Configure the webhook:

| Field | Value |
|-------|-------|
| **Payload URL** | `https://your-ngrok-url.ngrok.io/webhook/receiver` |
| **Content type** | `application/json` |
| **Secret** | Leave blank (or add one if you implement signature verification) |
| **SSL verification** | Enable SSL verification |
| **Which events?** | Select "Let me select individual events" |

Select these events:
- ✅ **Pushes** - Triggers when code is pushed
- ✅ **Pull requests** - Triggers when PR is opened, closed, etc.

- ✅ **Active** - Make sure the webhook is enabled

Click **Add webhook**

## Step 5: Test the Webhook

GitHub will send a ping event immediately. Check:
1. The webhook page should show a green checkmark ✓
2. Click on the webhook to see "Recent Deliveries"
3. You should see a `ping` event with a 200 response

## Step 6: Trigger Real Events

### Test 1: Push Event

```bash
cd action-repo

# Make a change
echo "# Test Push" >> README.md

# Commit and push
git add .
git commit -m "Test push webhook"
git push origin main
```

**Expected Result**: 
- Check GitHub webhook deliveries → should see a `push` event
- Check your dashboard → should show: `"YourName" pushed to "main" on [timestamp]`

### Test 2: Pull Request Event

```bash
# Create a feature branch
git checkout -b feature-test

# Make a change
echo "print('Feature code')" > feature.py

# Commit and push
git add .
git commit -m "Add feature"
git push origin feature-test
```

Now create a PR:
1. Go to your repo on GitHub
2. Click "Pull requests" → "New pull request"
3. Base: `main`, Compare: `feature-test`
4. Click "Create pull request"
5. Add title and description
6. Click "Create pull request"

**Expected Result**: 
- Check webhook deliveries → should see a `pull_request` event (action: opened)
- Check your dashboard → should show: `"YourName" submitted a pull request from "feature-test" to "main" on [timestamp]`

### Test 3: Merge Event

1. In the same PR you just created
2. Click "Merge pull request"
3. Click "Confirm merge"

**Expected Result**: 
- Check webhook deliveries → should see a `pull_request` event (action: closed, merged: true)
- Check your dashboard → should show: `"YourName" merged branch "feature-test" to "main" on [timestamp]`

## Step 7: Verify Everything Works

Your dashboard at `http://127.0.0.1:5000/webhook/` should show:

```
🚀 GitHub Webhook Monitor
Auto-refreshing every 15 seconds | 3 events tracked

MERGE
"YourName" merged branch "feature-test" to "main" on 29th January 2026 - 3:45 PM UTC

PULL REQUEST
"YourName" submitted a pull request from "feature-test" to "main" on 29th January 2026 - 3:40 PM UTC

PUSH
"YourName" pushed to "main" on 29th January 2026 - 3:30 PM UTC
```

## Troubleshooting

### Webhook not receiving events?

1. **Check ngrok is running**: The terminal should show `Forwarding` status
2. **Verify webhook URL**: Go to GitHub webhook settings, check the URL is correct
3. **Check Recent Deliveries**: Click on webhook → Recent Deliveries tab
   - Green checkmark ✓ = Success
   - Red X = Failed (click to see error details)
4. **Check Flask logs**: Look at your Flask terminal for incoming requests
5. **Test manually**: Use the "Redeliver" button in GitHub webhook deliveries

### Events not appearing in UI?

1. **Check MongoDB**: 
   ```bash
   mongosh github_webhooks --eval "db.events.find().pretty()"
   ```
2. **Check browser console**: Press F12, look for JavaScript errors
3. **Verify API**: Visit http://127.0.0.1:5000/webhook/events directly

### ngrok URL keeps changing?

- Free ngrok URLs change each time you restart ngrok
- Options:
  - Keep ngrok running
  - Get a paid ngrok account for a permanent URL
  - Deploy your webhook receiver to a cloud platform

## Production Setup (Optional)

For a permanent solution, deploy your webhook receiver to:

### Option 1: Heroku
```bash
# Install Heroku CLI
# Create Procfile
echo "web: gunicorn run:app" > Procfile

# Deploy
heroku create your-webhook-app
heroku addons:create mongolab
git push heroku main
```

### Option 2: DigitalOcean
- Create a droplet
- Install MongoDB
- Deploy Flask app
- Configure reverse proxy (Nginx)

### Option 3: Railway/Render/Fly.io
- Push code to GitHub
- Connect to deployment platform
- Add MongoDB addon
- Deploy

## Submission Checklist

Before submitting:

- [ ] `webhook-repo` is pushed to GitHub
- [ ] `action-repo` is created and configured
- [ ] Webhook is configured and showing green checkmark
- [ ] All three event types work (Push, PR, Merge)
- [ ] Dashboard displays events correctly
- [ ] Dashboard auto-refreshes every 15 seconds
- [ ] README contains setup instructions
- [ ] Code is clean and well-commented
- [ ] Both repository links are ready for submission

## Repository Links for Submission

When filling out the Google Form, provide:

1. **webhook-repo**: `https://github.com/YOUR_USERNAME/webhook-repo`
2. **action-repo**: `https://github.com/YOUR_USERNAME/action-repo`

Make sure both repositories are:
- Public (so evaluators can access them)
- Have clear README files
- Contain all necessary code and documentation

---

**Good luck with your submission! 🚀**
