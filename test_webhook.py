#!/usr/bin/env python3
"""
Quick test script to verify the webhook receiver is working correctly
Run this after starting the Flask app to test basic functionality
"""

import requests
import time
import json
from datetime import datetime

BASE_URL = "http://127.0.0.1:5000"

def test_connection():
    """Test if the Flask app is running"""
    print("Testing Flask app connection...")
    try:
        response = requests.get(f"{BASE_URL}/webhook/")
        if response.status_code == 200:
            print("✓ Flask app is running")
            return True
        else:
            print(f"✗ Flask app returned status code: {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("✗ Cannot connect to Flask app. Is it running?")
        return False

def test_events_endpoint():
    """Test the events API endpoint"""
    print("\nTesting events API endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/webhook/events")
        if response.status_code == 200:
            events = response.json()
            print(f"✓ Events endpoint working. Found {len(events)} events")
            return True
        else:
            print(f"✗ Events endpoint returned status code: {response.status_code}")
            return False
    except Exception as e:
        print(f"✗ Error testing events endpoint: {e}")
        return False

def send_test_push():
    """Send a test push event"""
    print("\nSending test PUSH event...")
    payload = {
        "pusher": {
            "name": "TestUser"
        },
        "ref": "refs/heads/main"
    }
    headers = {
        "Content-Type": "application/json",
        "X-GitHub-Event": "push"
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/webhook/receiver",
            json=payload,
            headers=headers
        )
        if response.status_code == 200:
            print("✓ Push event sent successfully")
            return True
        else:
            print(f"✗ Push event failed with status: {response.status_code}")
            print(f"Response: {response.text}")
            return False
    except Exception as e:
        print(f"✗ Error sending push event: {e}")
        return False

def send_test_pull_request():
    """Send a test pull request event"""
    print("\nSending test PULL REQUEST event...")
    payload = {
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
    }
    headers = {
        "Content-Type": "application/json",
        "X-GitHub-Event": "pull_request"
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/webhook/receiver",
            json=payload,
            headers=headers
        )
        if response.status_code == 200:
            print("✓ Pull request event sent successfully")
            return True
        else:
            print(f"✗ Pull request event failed with status: {response.status_code}")
            return False
    except Exception as e:
        print(f"✗ Error sending pull request event: {e}")
        return False

def send_test_merge():
    """Send a test merge event"""
    print("\nSending test MERGE event...")
    payload = {
        "action": "closed",
        "pull_request": {
            "merged": True,
            "user": {
                "login": "TestUser"
            },
            "head": {
                "ref": "dev"
            },
            "base": {
                "ref": "main"
            }
        }
    }
    headers = {
        "Content-Type": "application/json",
        "X-GitHub-Event": "pull_request"
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/webhook/receiver",
            json=payload,
            headers=headers
        )
        if response.status_code == 200:
            print("✓ Merge event sent successfully")
            return True
        else:
            print(f"✗ Merge event failed with status: {response.status_code}")
            return False
    except Exception as e:
        print(f"✗ Error sending merge event: {e}")
        return False

def verify_events_stored():
    """Verify that events were stored in the database"""
    print("\nVerifying events were stored...")
    time.sleep(1)  # Give the database a moment to process
    
    try:
        response = requests.get(f"{BASE_URL}/webhook/events")
        if response.status_code == 200:
            events = response.json()
            print(f"✓ Found {len(events)} events in database")
            
            # Display the events
            if events:
                print("\nStored events:")
                for i, event in enumerate(events[:5], 1):  # Show first 5
                    print(f"  {i}. {event['action'].upper()}: {event['author']} - {event['to_branch']}")
            
            return len(events) > 0
        else:
            print("✗ Could not fetch events")
            return False
    except Exception as e:
        print(f"✗ Error verifying events: {e}")
        return False

def main():
    print("=" * 60)
    print("GitHub Webhook Receiver - Test Suite")
    print("=" * 60)
    print("\nMake sure:")
    print("1. MongoDB is running")
    print("2. Flask app is running (python run.py)")
    print("\nStarting tests in 3 seconds...")
    time.sleep(3)
    
    results = []
    
    # Run tests
    results.append(("Connection Test", test_connection()))
    
    if not results[-1][1]:
        print("\n❌ Flask app is not running. Please start it with: python run.py")
        return
    
    results.append(("Events API Test", test_events_endpoint()))
    results.append(("Push Event Test", send_test_push()))
    results.append(("Pull Request Test", send_test_pull_request()))
    results.append(("Merge Event Test", send_test_merge()))
    results.append(("Storage Verification", verify_events_stored()))
    
    # Summary
    print("\n" + "=" * 60)
    print("Test Summary")
    print("=" * 60)
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for test_name, result in results:
        status = "✓ PASS" if result else "✗ FAIL"
        print(f"{status} - {test_name}")
    
    print(f"\nResults: {passed}/{total} tests passed")
    
    if passed == total:
        print("\n🎉 All tests passed! Your webhook receiver is working correctly.")
        print(f"\n👉 Open your browser and visit: {BASE_URL}/webhook/")
        print("   You should see the test events displayed on the dashboard.")
    else:
        print("\n⚠️ Some tests failed. Please check the error messages above.")
    
    print("\n" + "=" * 60)

if __name__ == "__main__":
    main()
