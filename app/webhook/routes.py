from flask import Blueprint, json, request, jsonify, render_template, current_app
from datetime import datetime
from app.extensions import mongo

webhook = Blueprint('Webhook', __name__, url_prefix='/webhook')

# In-memory storage for demo mode (when MongoDB is not available)
demo_events = []

@webhook.route('/receiver', methods=["POST"])
def receiver():
    """
    Receives GitHub webhook events and stores them in MongoDB
    Handles: Push, Pull Request, and Merge events
    """
    try:
        payload = request.json
        
        # Extract event type from headers
        event_type = request.headers.get('X-GitHub-Event')
        
        event_data = None
        
        if event_type == 'push':
            event_data = handle_push_event(payload)
        elif event_type == 'pull_request':
            event_data = handle_pull_request_event(payload)
        else:
            # Log unhandled events for debugging
            print(f"Unhandled event type: {event_type}")
            return {"message": "Event received but not processed"}, 200
        
        if event_data:
            # Store in MongoDB or in-memory
            if current_app.config.get('MONGO_AVAILABLE', True):
                try:
                    mongo.db.events.insert_one(event_data)
                except Exception as e:
                    print(f"MongoDB error: {e}")
                    event_data['_id'] = len(demo_events)
                    demo_events.append(event_data)
            else:
                event_data['_id'] = len(demo_events)
                demo_events.append(event_data)
            return {"message": "Event stored successfully"}, 200
        else:
            return {"message": "Event received but not stored"}, 200
            
    except Exception as e:
        print(f"Error processing webhook: {str(e)}")
        return {"error": str(e)}, 500


def handle_push_event(payload):
    """
    Handle push events
    Format: {author} pushed to {to_branch} on {timestamp}
    """
    try:
        author = payload['pusher']['name']
        ref = payload['ref']  # refs/heads/branch-name
        branch = ref.split('/')[-1]
        timestamp = datetime.utcnow()
        
        return {
            'author': author,
            'action': 'push',
            'to_branch': branch,
            'from_branch': None,
            'timestamp': timestamp
        }
    except KeyError as e:
        print(f"Error parsing push event: {e}")
        return None


def handle_pull_request_event(payload):
    """
    Handle pull request events (includes both PR creation and merge)
    For PR: {author} submitted a pull request from {from_branch} to {to_branch} on {timestamp}
    For Merge: {author} merged branch {from_branch} to {to_branch} on {timestamp}
    """
    try:
        pr_action = payload['action']
        pull_request = payload['pull_request']
        
        author = pull_request['user']['login']
        from_branch = pull_request['head']['ref']
        to_branch = pull_request['base']['ref']
        timestamp = datetime.utcnow()
        
        # Check if this is a merge event (PR was closed and merged)
        if pr_action == 'closed' and pull_request.get('merged', False):
            action = 'merge'
        elif pr_action == 'opened':
            action = 'pull_request'
        else:
            # Other PR actions we don't track
            return None
        
        return {
            'author': author,
            'action': action,
            'from_branch': from_branch,
            'to_branch': to_branch,
            'timestamp': timestamp
        }
    except KeyError as e:
        print(f"Error parsing pull request event: {e}")
        return None


@webhook.route('/events', methods=["GET"])
def get_events():
    """
    API endpoint to fetch recent events from MongoDB or in-memory storage
    Returns events sorted by timestamp (most recent first)
    """
    try:
        if current_app.config.get('MONGO_AVAILABLE', True):
            try:
                events = list(mongo.db.events.find().sort('timestamp', -1).limit(50))
                
                # Convert ObjectId to string for JSON serialization
                for event in events:
                    event['_id'] = str(event['_id'])
                    event['timestamp'] = event['timestamp'].isoformat()
            except Exception as e:
                print(f"MongoDB error, using demo data: {e}")
                events = sorted(demo_events, key=lambda x: x['timestamp'], reverse=True)[:50]
                for event in events:
                    if '_id' not in event:
                        event['_id'] = len(demo_events)
                    event['timestamp'] = event['timestamp'].isoformat()
        else:
            events = sorted(demo_events, key=lambda x: x['timestamp'], reverse=True)[:50]
            for event in events:
                if '_id' not in event:
                    event['_id'] = len(demo_events)
                event['timestamp'] = event['timestamp'].isoformat()
        
        return jsonify(events), 200
    except Exception as e:
        print(f"Error fetching events: {str(e)}")
        return jsonify([]), 200


@webhook.route('/', methods=["GET"])
def index():
    """
    Render the UI dashboard
    """
    return render_template('index.html')
