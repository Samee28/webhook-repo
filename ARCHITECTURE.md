# Application Flow Diagram

## Complete System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         GitHub (action-repo)                     │
│                                                                  │
│  User Actions:                                                   │
│  • Push code to branch                                           │
│  • Create Pull Request                                           │
│  • Merge Pull Request                                            │
│                                                                  │
└────────────────────────────┬─────────────────────────────────────┘
                             │
                             │ Webhook Event (JSON Payload)
                             │ + X-GitHub-Event Header
                             ▼
                    ┌────────────────────┐
                    │  ngrok (Optional)  │
                    │  Public URL Proxy  │
                    └────────┬───────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Flask Application (webhook-repo)              │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  POST /webhook/receiver                                   │  │
│  │                                                            │  │
│  │  1. Receives webhook payload                              │  │
│  │  2. Reads X-GitHub-Event header                           │  │
│  │  3. Parses event data:                                    │  │
│  │     • Push: author, to_branch                             │  │
│  │     • PR: author, from_branch, to_branch                  │  │
│  │     • Merge: author, from_branch, to_branch               │  │
│  │  4. Validates and processes data                          │  │
│  └──────────────────────┬────────────────────────────────────┘  │
│                         │                                        │
│                         ▼                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  MongoDB Storage                                          │  │
│  │                                                            │  │
│  │  Collection: events                                       │  │
│  │  Schema: {                                                │  │
│  │    author: string,                                        │  │
│  │    action: "push|pull_request|merge",                    │  │
│  │    from_branch: string|null,                             │  │
│  │    to_branch: string,                                    │  │
│  │    timestamp: datetime                                    │  │
│  │  }                                                        │  │
│  └──────────────────────┬────────────────────────────────────┘  │
│                         │                                        │
│                         │                                        │
│  ┌──────────────────────┴────────────────────────────────────┐  │
│  │  GET /webhook/events (API)                                │  │
│  │                                                            │  │
│  │  • Queries MongoDB                                        │  │
│  │  • Sorts by timestamp (desc)                              │  │
│  │  • Returns JSON array of events                           │  │
│  │  • Limits to 50 most recent                               │  │
│  └──────────────────────┬────────────────────────────────────┘  │
│                         │                                        │
│                         │                                        │
│  ┌──────────────────────┴────────────────────────────────────┐  │
│  │  GET /webhook/ (Dashboard UI)                             │  │
│  │                                                            │  │
│  │  • Renders HTML template                                  │  │
│  │  • JavaScript polls /webhook/events every 15 seconds     │  │
│  │  • Displays events with formatted messages                │  │
│  │  • Shows live status and event count                      │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                             │
                             │ HTTP Response (HTML + JS)
                             ▼
                    ┌────────────────────┐
                    │   User's Browser   │
                    │                    │
                    │  • Beautiful UI    │
                    │  • Auto-refresh    │
                    │  • Event display   │
                    └────────────────────┘
```

## Data Flow Examples

### Example 1: Push Event

```
1. Developer pushes to action-repo
   ↓
2. GitHub sends webhook:
   POST /webhook/receiver
   Header: X-GitHub-Event: push
   Body: {
     "pusher": {"name": "John"},
     "ref": "refs/heads/main"
   }
   ↓
3. Flask parses data:
   author = "John"
   action = "push"
   to_branch = "main"
   timestamp = current_time
   ↓
4. Stores in MongoDB:
   {
     "_id": "...",
     "author": "John",
     "action": "push",
     "from_branch": null,
     "to_branch": "main",
     "timestamp": "2026-01-29T15:30:00Z"
   }
   ↓
5. UI polls /webhook/events
   ↓
6. Browser displays:
   "John" pushed to "main" on 29th January 2026 - 3:30 PM UTC
```

### Example 2: Pull Request Event

```
1. Developer creates PR in action-repo
   ↓
2. GitHub sends webhook:
   POST /webhook/receiver
   Header: X-GitHub-Event: pull_request
   Body: {
     "action": "opened",
     "pull_request": {
       "user": {"login": "Jane"},
       "head": {"ref": "feature"},
       "base": {"ref": "main"}
     }
   }
   ↓
3. Flask parses data:
   author = "Jane"
   action = "pull_request"
   from_branch = "feature"
   to_branch = "main"
   ↓
4. Stores in MongoDB
   ↓
5. UI displays:
   "Jane" submitted a pull request from "feature" to "main" on 29th January 2026 - 3:45 PM UTC
```

### Example 3: Merge Event

```
1. PR is merged in action-repo
   ↓
2. GitHub sends webhook:
   POST /webhook/receiver
   Header: X-GitHub-Event: pull_request
   Body: {
     "action": "closed",
     "pull_request": {
       "merged": true,
       "user": {"login": "Jane"},
       "head": {"ref": "feature"},
       "base": {"ref": "main"}
     }
   }
   ↓
3. Flask detects merge (closed + merged=true):
   author = "Jane"
   action = "merge"
   from_branch = "feature"
   to_branch = "main"
   ↓
4. Stores in MongoDB
   ↓
5. UI displays:
   "Jane" merged branch "feature" to "main" on 29th January 2026 - 4:00 PM UTC
```

## UI Auto-Refresh Flow

```
┌─────────────────────────────────────────┐
│  Browser JavaScript                      │
│                                          │
│  1. Page loads                           │
│     ↓                                    │
│  2. fetchEvents() called immediately     │
│     ↓                                    │
│  3. GET /webhook/events                  │
│     ↓                                    │
│  4. Display events in UI                 │
│     ↓                                    │
│  5. Wait 15 seconds                      │
│     ↓                                    │
│  6. fetchEvents() called again           │
│     ↓                                    │
│  7. Update UI with new events            │
│     ↓                                    │
│  8. Loop back to step 5                  │
│                                          │
└─────────────────────────────────────────┘
```

## Component Responsibilities

### Flask App (run.py + app/__init__.py)
- Initialize Flask application
- Configure MongoDB connection
- Register blueprints
- Enable CORS

### Extensions (app/extensions.py)
- MongoDB client initialization
- Database connection management

### Webhook Routes (app/webhook/routes.py)
- Receive GitHub webhooks
- Parse event data
- Store events in MongoDB
- Serve API endpoints
- Render UI template

### UI Template (app/templates/index.html)
- Display dashboard
- Poll API every 15 seconds
- Format event messages
- Handle loading/error states
- Provide beautiful UX

### MongoDB
- Store events persistently
- Index by timestamp
- Support queries and sorting

## Security Considerations (Future Enhancements)

```
1. Webhook Secret Verification
   • GitHub can sign webhooks with a secret
   • Verify signature in Flask before processing

2. Rate Limiting
   • Prevent abuse of API endpoints
   • Use Flask-Limiter

3. Authentication
   • Protect dashboard with login
   • Use Flask-Login (already in requirements)

4. HTTPS in Production
   • Use proper SSL certificates
   • Configure reverse proxy (Nginx)

5. Environment Variables
   • Store secrets in .env
   • Use python-dotenv (already in requirements)
```

## Performance Optimizations

```
1. Database Indexing
   • Index on timestamp for faster queries
   • Index on action for filtering

2. Caching
   • Cache recent events in memory
   • Use Redis for distributed caching

3. Pagination
   • Limit API responses (currently 50)
   • Implement cursor-based pagination

4. WebSocket (Advanced)
   • Replace polling with WebSocket
   • Real-time event push to clients
```

## Deployment Architecture (Production)

```
┌──────────────┐
│   GitHub     │
│  (Webhooks)  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Nginx       │
│  (Reverse    │
│   Proxy)     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Gunicorn    │
│  (4 workers) │
└──────┬───────┘
       │
       ▼
┌──────────────┐      ┌──────────────┐
│  Flask App   │◄────►│  MongoDB     │
│  (webhook-   │      │  (Atlas)     │
│   repo)      │      │              │
└──────────────┘      └──────────────┘
       │
       ▼
┌──────────────┐
│  Browser     │
│  (Dashboard) │
└──────────────┘
```

---

This diagram provides a complete visual understanding of how all components work together!
