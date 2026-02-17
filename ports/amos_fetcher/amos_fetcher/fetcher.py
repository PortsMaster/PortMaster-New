#!/usr/bin/env python3
"""
File Fetcher with Caching
"""
import urllib.request
import urllib.parse
import re
import sys
import json
import os
import time

# Platform URLs Single Source of Truth
# "FOLDER_NAME": "YOUR_LINK_GOES_HERE",
PLATFORM_URLS = {
    "pico-8": "https://github.com/amosjerbi/fetcher/tree/main/pico-8",
}

# GitHub raw URL converter - converts tree URLs to raw content URLs
GITHUB_RAW_BASE = "https://raw.githubusercontent.com/amosjerbi/fetcher/main/"

CACHE_DIR = "/tmp/file_cache"
CACHE_EXPIRY = 3600  # 1 hour cache

def ensure_cache_dir():
    """Create cache directory if it doesn't exist"""
    if not os.path.exists(CACHE_DIR):
        os.makedirs(CACHE_DIR)

def get_cache_file(platform_name):
    """Get cache file path for platform"""
    safe_name = platform_name.replace(" ", "_").replace("/", "_")
    return os.path.join(CACHE_DIR, f"{safe_name}.json")

def is_cache_valid(cache_file):
    """Check if cache file is valid and not expired"""
    if not os.path.exists(cache_file):
        return False
    
    # Check if cache is not too old
    cache_time = os.path.getmtime(cache_file)
    current_time = time.time()
    
    return (current_time - cache_time) < CACHE_EXPIRY

def load_from_cache(cache_file):
    """Load file list from cache"""
    try:
        with open(cache_file, 'r') as f:
            return json.load(f)
    except:
        return None

def save_to_cache(cache_file, data):
    """Save file list to cache"""
    try:
        with open(cache_file, 'w') as f:
            json.dump(data, f)
    except:
        pass

def simple_html_parse(html_content, max_files=999, url=None):
    """Complete HTML parsing - get ALL files"""
    files = []
    
    # Check if this is a GitHub tree (folder) URL
    is_github_tree = url and 'github.com' in url and '/tree/' in url
    
    if is_github_tree:
        # GitHub embeds file list as JSON in a script tag
        # Look for: <script type="application/json" data-target="react-app.embeddedData">
        json_pattern = r'<script type="application/json" data-target="react-app\.embeddedData">([^<]+)</script>'
        match = re.search(json_pattern, html_content)
        
        if match:
            try:
                import json as json_module
                data = json_module.loads(match.group(1))
                tree_items = data.get('payload', {}).get('tree', {}).get('items', [])
                
                for item in tree_items:
                    if item.get('contentType') == 'file':
                        name = item.get('name', '')
                        path = item.get('path', '')  # Full path like "pico-8/romnix.p8.png"
                        
                        # For GitHub, use full path as filename for download URL construction
                        filename = path
                        
                        # Clean up the file name for display
                        display_name = urllib.parse.unquote(name)
                        if display_name.endswith('.zip'):
                            display_name = display_name[:-4]
                        elif display_name.endswith('.p8.png'):
                            display_name = display_name[:-7]
                        
                        files.append({
                            "name": display_name,
                            "filename": filename,
                            "path": path
                        })
            except Exception as e:
                print(f"Error parsing GitHub JSON: {e}", file=sys.stderr)
    else:
        # Standard pattern for other sites
        file_pattern = r'href="([^"]*\.(?:zip|p8\.png|rom|bin|cue|iso|7z))"'
        matches = re.findall(file_pattern, html_content)
        
        for match in matches:
            if match.startswith('../'):
                continue
            
            if match.startswith('/') and '/blob/' in match:
                filename = match.split('/')[-1]
            elif match.startswith('/'):
                continue
            else:
                filename = match
                
            display_name = urllib.parse.unquote(filename)
            if display_name.endswith('.zip'):
                display_name = display_name[:-4]
            elif display_name.endswith('.p8.png'):
                display_name = display_name[:-7]
            
            files.append({
                "name": display_name,
                "filename": filename
            })
    
    return files

def github_url_to_raw(url, filename):
    """Convert GitHub URL to raw content URL"""
    # Convert tree URLs to raw content URLs
    # https://github.com/user/repo/tree/main/pico-8/file.png
    # -> https://raw.githubusercontent.com/user/repo/main/pico-8/file.png
    if 'github.com' in url and '/tree/' in url:
        # Remove github.com part and tree/branch part
        raw_url = url.replace('github.com', 'raw.githubusercontent.com')
        raw_url = raw_url.replace('/tree/', '/')
        # Add filename at the end
        if not raw_url.endswith('/'):
            raw_url += '/'
        raw_url += filename
        return raw_url
    return None

def fetch_file_list(platform_name, max_files=999):
    """Fast file list fetching with caching"""
    ensure_cache_dir()
    cache_file = get_cache_file(platform_name)
    
    # Try cache first
    if is_cache_valid(cache_file):
        print(f"Loading {platform_name} from cache...", file=sys.stderr)
        cached_data = load_from_cache(cache_file)
        if cached_data:
            return cached_data
    
    if platform_name not in PLATFORM_URLS:
        return {"error": f"Platform {platform_name} not found"}
    
    url = PLATFORM_URLS[platform_name]
    
    try:
        print(f"Fast-fetching {platform_name} files...", file=sys.stderr)
        
        # Create request with optimized headers and timeout
        req = urllib.request.Request(url)
        req.add_header('User-Agent', 'File Downloader/1.0 (Fast Fetcher)')
        req.add_header('Connection', 'keep-alive')
        
        response = urllib.request.urlopen(req, timeout=15)  # Increased timeout for better reliability
        html = response.read().decode('utf-8', errors='ignore')
        
        # Fast HTML parsing - only get first 15 files
        files = simple_html_parse(html, max_files, url)
        
        # Store the base URL for downloading
        result_base_url = url
        
        print(f"Found {len(files)} files (showing first {max_files})", file=sys.stderr)
        
        result = {
            "platform": platform_name,
            "count": len(files),
            "files": files,
            "status": "success",
            "cached": False,
            "note": f"Showing first {max_files} files for speed"
        }
        
        # Save to cache for next time
        save_to_cache(cache_file, result)
        
        return result
        
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        return {"error": f"Failed to fetch files: {str(e)}", "status": "error"}

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 fetcher.py <platform_name>")
        sys.exit(1)
    
    platform = sys.argv[1]
    result = fetch_file_list(platform)
    print(json.dumps(result, indent=2))
