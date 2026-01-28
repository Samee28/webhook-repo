# GitHub Webhook Receiver - Developer Assessment

A Flask-based webhook receiver that captures GitHub events (Push, Pull Request, Merge) and displays them in a real-time dashboard.

## 🚀 Features

- ✅ Receives GitHub webhook events for Push, Pull Request, and Merge actions
- ✅ Stores event data in MongoDB with proper schema
- ✅ Real-time UI dashboard with auto-refresh every 15 seconds
- ✅ Clean and minimal design with event-specific formatting
- ✅ RESTful API endpoints for event management

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- Python 3.7 or higher
- MongoDB (running locally or remotely)
- Git

## 🛠️ Setup Instructions

### 1. Clone the Repository

```bash
git clone <your-webhook-repo-url>
cd webhook-repo
```

### 2. Create Virtual Environment

```bash
# Install virtualenv if you don't have it
pip install virtualenv

# Create virtual environment
virtualenv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Set Up MongoDB

Make sure MongoDB is running on your system:

```bash
# On macOS (using Homebrew):
brew services start mongodb-community

# On Linux:
sudo systemctl start mongod

# On Windows:
# MongoDB should start automatically if installed as a service
```

The application will automatically create a database called `github_webhooks` and a collection called `events`.

### 5. Run the Application

```bash
python run.py
```

The application will start on `http://127.0.0.1:5000`

## 🌐 Endpoints

### Webhook Receiver
- **POST** `/webhook/receiver`
  - Receives GitHub webhook payloads
  - Processes Push, Pull Request, and Merge events
  - Stores events in MongoDB

### API Endpoints
- **GET** `/webhook/events`
  - Returns all events from MongoDB (sorted by timestamp)
  - Used by the UI for polling

### UI Dashboard
- **GET** `/webhook/`
  - Main dashboard displaying all events
  - Auto-refreshes every 15 seconds

## 🔧 GitHub Webhook Configuration

### Step 1: Create Your Action Repository

1. Create a new GitHub repository called `action-repo`
2. Add some initial files (README, code files, etc.)

### Step 2: Set Up ngrok (for local testing)

Since GitHub webhooks need a public URL, use ngrok to expose your local server:

```bash
# Install ngrok from https://ngrok.com/
# Run ngrok to expose port 5000
ngrok http 5000
```

Copy the HTTPS URL provided by ngrok (e.g., `https://abc123.ngrok.io`)

### Step 3: Configure GitHub Webhook

1. Go to your `action-repo` on GitHub
2. Navigate to **Settings** → **Webhooks** → **Add webhook**
3. Configure the webhook:
   - **Payload URL**: `https://your-ngrok-url.ngrok.io/webhook/receiver`
   - **Content type**: `application/json`
   - **Secret**: (optional, can be left blank for testing)
   - **Which events**: Select individual events:
     - ✅ Pushes
     - ✅ Pull requests
   - ✅ Active

4. Click **Add webhook**

### Step 4: Test the Integration

1. Make a push to your `action-repo`:
   ```bash
   echo "Test" >> README.md
   git add .
   git commit -m "Test push event"
   git push
   ```

2. Create a pull request in your `action-repo`

3. Merge the pull request

4. Check your dashboard at `http://127.0.0.1:5000/webhook/`

## 📊 Event Formats

The dashboard displays events in the following formats:

### Push Event
```
"Travis" pushed to "staging" on 1st April 2021 - 9:30 PM UTC
```

### Pull Request Event
```
"Travis" submitted a pull request from "staging" to "master" on 1st April 2021 - 9:00 AM UTC
```

### Merge Event
```
"Travis" merged branch "dev" to "master" on 2nd April 2021 - 12:00 PM UTC
```

## 🗄️ MongoDB Schema

Events are stored with the following schema:

```json
{
  "_id": "ObjectId",
  "author": "string",
  "action": "string",
  "from_branch": "string | null",
  "to_branch": "string",
  "timestamp": "datetime"
}
```

### Field Descriptions:
- **author**: GitHub username of the person who triggered the event
- **action**: Type of event (`push`, `pull_request`, or `merge`)
- **from_branch**: Source branch (null for push events)
- **to_branch**: Destination/target branch
- **timestamp**: UTC timestamp when the event occurred

## 🏗️ Project Structure

```
webhook-repo/
├── app/
│   ├── __init__.py           # Flask app initialization
│   ├── extensions.py         # MongoDB setup
│   ├── templates/
│   │   └── index.html        # UI dashboard
│   └── webhook/
│       ├── __init__.py
│       └── routes.py         # Webhook routes and logic
├── venv/                     # Virtual environment
├── requirements.txt          # Python dependencies
├── run.py                    # Application entry point
└── README.md                 # This file
```

## 🔍 Troubleshooting

### MongoDB Connection Issues
- Ensure MongoDB is running: `mongosh` (should connect successfully)
- Check MongoDB URI in [app/__init__.py](app/__init__.py)

### Webhook Not Receiving Events
- Verify ngrok is running and the URL is correct
- Check GitHub webhook delivery status in Settings → Webhooks
- Look for webhook delivery attempts and responses

### UI Not Updating
- Check browser console for errors
- Verify `/webhook/events` endpoint returns data
- Ensure MongoDB has events stored

## 🚀 Production Deployment

For production deployment:

1. Use a proper WSGI server like Gunicorn:
   ```bash
   pip install gunicorn
   gunicorn -w 4 -b 0.0.0.0:5000 run:app
   ```

2. Use a cloud MongoDB service (MongoDB Atlas)

3. Deploy to a cloud platform (Heroku, AWS, DigitalOcean, etc.)

4. Set up proper environment variables for sensitive data

## 📝 Notes

- The application automatically creates the MongoDB database and collection
- Events are stored with UTC timestamps
- The UI polls the API every 15 seconds for new events
- Only Push, Pull Request (open), and Merge events are tracked


**Repository Links:**
- **webhook-repo**: (this repository)
- **action-repo**: https://github.com/Samee28/action-repo
