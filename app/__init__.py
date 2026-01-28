from flask import Flask
from flask_cors import CORS
import os
from dotenv import load_dotenv

from app.webhook.routes import webhook
from app.extensions import mongo

# Load environment variables from .env file
load_dotenv()

# Creating our flask app
def create_app():

    app = Flask(__name__)
    
    # MongoDB configuration - read from .env or use default
    mongo_uri = os.getenv('MONGO_URI', 'mongodb://localhost:27017/github_webhooks')
    app.config["MONGO_URI"] = mongo_uri
    
    print(f"Using MongoDB URI: {mongo_uri[:50]}...")
    
    # Initialize extensions (with error handling)
    try:
        mongo.init_app(app)
        app.config['MONGO_AVAILABLE'] = True
        print("✓ MongoDB connected successfully")
    except Exception as e:
        print(f"⚠ Warning: MongoDB not available - {e}")
        print("⚠ Running in demo mode with in-memory storage")
        app.config['MONGO_AVAILABLE'] = False
    
    CORS(app)
    
    # registering all the blueprints
    app.register_blueprint(webhook)
    
    return app
