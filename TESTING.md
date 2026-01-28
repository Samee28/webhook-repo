# GitHub Webhook Testing Guide

## Quick Test Checklist

### 1. Local Setup Test
- [ ] MongoDB is running
- [ ] Virtual environment is activated
- [ ] Dependencies are installed
- [ ] Flask app starts without errors
- [ ] Can access http://127.0.0.1:5000/webhook/

### 2. API Endpoint Test
Test the events endpoint:
```bash
curl http://127.0.0.1:5000/webhook/events
```
Should return an empty array `[]` initially.

### 3. Manual Webhook Test (Without GitHub)

Test the webhook receiver with sample payloads:

#### Test Push Event:
```bash
curl -X POST http://127.0.0.1:5000/webhook/receiver \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -d '{
    "pusher": {
      "name": "TestUser"
    },
    "ref": "refs/heads/main"
  }'
```

#### Test Pull Request Event:
```bash
curl -X POST http://127.0.0.1:5000/webhook/receiver \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: pull_request" \
  -d '{
    "action": "opened",
    "pull_request": {
      "user": {
        "login": "TestUser"
      },
      "head": {
        "ref": "feature-branch"
      },
      "base": {
        "ref": "main"
      }
    }
  }'
```

#### Test Merge Event:
```bash
curl -X POST http://127.0.0.1:5000/webhook/receiver \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: pull_request" \
  -d '{
    "action": "closed",
    "pull_request": {
      "merged": true,
      "user": {
        "login": "TestUser"
      },
      "head": {
        "ref": "feature-branch"
      },
      "base": {
        "ref": "main"
      }
    }
  }'
```

### 4. Verify Data in MongoDB

Check if events are stored:
```bash
mongosh github_webhooks --eval "db.events.find().pretty()"
```

### 5. UI Test
- [ ] Open http://127.0.0.1:5000/webhook/ in browser
- [ ] Events appear after sending test webhooks
- [ ] Events have correct format and styling
- [ ] Page auto-refreshes every 15 seconds
- [ ] Event count updates correctly

### 6. GitHub Integration Test

#### Setup ngrok:
1. Download and install ngrok from https://ngrok.com/
2. Run: `ngrok http 5000`
3. Copy the HTTPS URL (e.g., https://abc123.ngrok.io)

#### Configure GitHub Webhook:
1. Go to your action-repo on GitHub
2. Settings → Webhooks → Add webhook
3. Payload URL: `https://your-ngrok-url.ngrok.io/webhook/receiver`
4. Content type: `application/json`
5. Select events: Pushes, Pull requests
6. Add webhook

#### Test Real Events:
- [ ] Make a commit and push to action-repo
- [ ] Create a pull request
- [ ] Merge the pull request
- [ ] Check webhook delivery in GitHub (Settings → Webhooks → Recent Deliveries)
- [ ] Verify events appear in dashboard

### 7. Performance Test
- [ ] Dashboard loads within 2 seconds
- [ ] Polling works consistently every 15 seconds
- [ ] Can handle 50+ events without issues
- [ ] No memory leaks after extended use

## Common Issues and Solutions

### Issue: MongoDB Connection Error
**Solution**: 
```bash
# Check if MongoDB is running
mongosh

# Start MongoDB
brew services start mongodb-community  # macOS
sudo systemctl start mongod            # Linux
```

### Issue: Webhook Not Receiving Events
**Solution**:
- Verify ngrok is running
- Check GitHub webhook delivery status
- Look at response codes in GitHub webhook deliveries
- Check Flask logs for errors

### Issue: UI Not Updating
**Solution**:
- Check browser console for JavaScript errors
- Verify `/webhook/events` endpoint returns valid JSON
- Clear browser cache
- Check CORS settings

### Issue: Wrong Event Format
**Solution**:
- Verify GitHub webhook is sending the correct event type
- Check X-GitHub-Event header
- Review webhook payload in GitHub delivery details

## Expected Results

After successful setup and testing:
1. ✅ All three event types (Push, PR, Merge) are captured
2. ✅ Events are stored in MongoDB with correct schema
3. ✅ UI displays events in the specified format
4. ✅ Dashboard auto-refreshes every 15 seconds
5. ✅ Clean, minimal UI design
6. ✅ Timestamps are in UTC with proper formatting

## Next Steps for Submission

1. ✅ Test all functionality thoroughly
2. ✅ Create your action-repo and configure webhooks
3. ✅ Take screenshots of working dashboard
4. ✅ Document any custom configurations
5. ✅ Push code to GitHub
6. ✅ Submit repository links via Google Form
