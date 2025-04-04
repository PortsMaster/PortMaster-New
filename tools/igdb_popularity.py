#!/usr/bin/env python3
"""
Script to generate popularity metrics for PortMaster games from IGDB.
Scans all port.json files for IGDB IDs, fetches popularity metrics,
and outputs them to ports/popularity.json
"""

import os
import sys
import json
import requests
import time
import glob

# === Configuration ===
CLIENT_ID = 'ljcuthcgsxztbyax36whgzdst5s68u'
CLIENT_SECRET = 'l6fzl17soljtxhsswavk7kbps5s876'

# Get script location and determine paths
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(SCRIPT_DIR)  # Go up one level
PORTS_PATH = os.path.join(REPO_ROOT, "ports")
OUTPUT_FILE = os.path.join(PORTS_PATH, "popularity.json")

# === Authorization & Setup ===
def get_access_token():
    if not CLIENT_ID or not CLIENT_SECRET:
        print("Missing CLIENT_ID or CLIENT_SECRET.", file=sys.stderr)
        sys.exit(1)
        
    try:
        resp = requests.post(
            "https://id.twitch.tv/oauth2/token",
            params={
                "client_id": CLIENT_ID,
                "client_secret": CLIENT_SECRET,
                "grant_type": "client_credentials"
            },
            timeout=10
        )
        resp.raise_for_status()
        return resp.json()["access_token"]
    except requests.RequestException as e:
        print(f"Failed to get token: {e}", file=sys.stderr)
        sys.exit(1)

# === Robust request with retries ===
def retry_request(method, url, **kwargs):
    for attempt in range(5):
        try:
            resp = requests.request(method, url, timeout=15, **kwargs)
            print(f"Got status code {resp.status_code}", file=sys.stderr)
            if resp.status_code == 400 and attempt < 4:
                print("Warning: 400 error – retrying...", file=sys.stderr)
                time.sleep(2 ** attempt)
                continue
            resp.raise_for_status()
            return resp
        except Exception as e:
            print(f"Attempt {attempt+1} failed: {e}", file=sys.stderr)
            time.sleep(2 ** attempt)
    print(f"Failed after 5 attempts: {url}", file=sys.stderr)
    return None

# === Extract IGDB IDs from port.json files ===
def extract_igdb_ids():
    igdb_ids = []
    port_count = 0
    
    print("Scanning port.json files for IGDB IDs...")
    
    for port_json_path in glob.glob(os.path.join(PORTS_PATH, "*/port.json")):
        port_count += 1
        try:
            with open(port_json_path, 'r') as f:
                port_json = json.load(f)
                
            port_dir = os.path.basename(os.path.dirname(port_json_path))
            
            # Extract igdb_id if present
            if 'attr' in port_json and 'igdb_id' in port_json['attr'] and port_json['attr']['igdb_id']:
                igdb_id = str(port_json['attr']['igdb_id'])
                igdb_ids.append(igdb_id)
                print(f"Found IGDB ID {igdb_id} for port {port_dir}")
        except (json.JSONDecodeError, FileNotFoundError) as e:
            print(f"Error processing {port_json_path}: {e}")
    
    print(f"Found {len(igdb_ids)} IGDB IDs out of {port_count} ports")
    return igdb_ids

# === Fetch popularity data for all IDs ===
def fetch_popularity_data(game_ids, headers):
    metrics_by_game = {}
    type_ids = set()
    
    print(f"Fetching popularity data for {len(game_ids)} games...")
    
    for i, gid in enumerate(game_ids):
        print(f"Processing game {i+1}/{len(game_ids)}: ID {gid}")
        
        # Respect rate limits
        time.sleep(1.0)  # IGDB rate limit: max 4 req/sec
        
        query = (
            "fields calculated_at,checksum,created_at,external_popularity_source,game_id,"
            "popularity_source,popularity_type,updated_at,value;"
            f"where game_id = {gid};"
        )
        resp = retry_request("POST", "https://api.igdb.com/v4/popularity_primitives", headers=headers, data=query)
        if not resp:
            continue

        primitives = resp.json()
        if not primitives:
            print(f"No popularity data for game ID {gid}")
            continue

        metrics_by_game[gid] = {}
        for p in primitives:
            tid = str(p["popularity_type"])
            metrics_by_game[gid][tid] = p["value"]
            type_ids.add(p["popularity_type"])
    
    return metrics_by_game, type_ids

# === Fetch popularity type names ===
def fetch_popularity_types(headers):
    print("Fetching popularity type information...")
    
    types_dict = {}
    type_query = "fields name,popularity_source,updated_at; sort id asc;"
    
    resp = retry_request("POST", "https://api.igdb.com/v4/popularity_types", headers=headers, data=type_query)
    if resp:
        types = resp.json()
        types_dict = {str(t["id"]): t["name"] for t in types}
    
    return types_dict

# === Main function ===
def main():
    # Get authentication token
    ACCESS_TOKEN = get_access_token()
    HEADERS = {
        "Client-ID": CLIENT_ID,
        "Authorization": f"Bearer {ACCESS_TOKEN}",
        "Accept": "application/json"
    }

    # Extract IDs from port files
    game_ids = extract_igdb_ids()
    if not game_ids:
        print("No valid IGDB IDs found in port.json files.", file=sys.stderr)
        sys.exit(1)
    
    # Get existing popularity data if available
    existing_data = {}
    if os.path.exists(OUTPUT_FILE):
        try:
            with open(OUTPUT_FILE, 'r') as f:
                existing_data = json.load(f)
                print(f"Loaded existing popularity data with {len(existing_data.get('popularity_metrics', {}))} entries")
        except (json.JSONDecodeError, FileNotFoundError) as e:
            print(f"Error loading existing popularity data: {e}")
    
    # Fetch metrics for games
    metrics_by_game, type_ids = fetch_popularity_data(game_ids, HEADERS)
    
    # Fetch popularity type names
    types_dict = fetch_popularity_types(HEADERS)
    
    # Merge with existing data if available
    if existing_data:
        # Merge metrics
        existing_metrics = existing_data.get('popularity_metrics', {})
        for game_id, metrics in metrics_by_game.items():
            existing_metrics[game_id] = metrics
        metrics_by_game = existing_metrics
        
        # Merge types
        existing_types = existing_data.get('popularity_types', {})
        types_dict.update(existing_types)
    
    # Prepare output
    output = {
        "popularity_types": types_dict,
        "popularity_metrics": metrics_by_game
    }
    
    # Write to file
    with open(OUTPUT_FILE, 'w') as f:
        json.dump(output, indent=2, sort_keys=True, f)
    
    print(f"Successfully wrote popularity data for {len(metrics_by_game)} games to {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
