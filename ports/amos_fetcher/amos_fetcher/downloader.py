#!/usr/bin/env python3
"""
Real File Downloader - Maximum Speed Optimizations
"""
import urllib.request
import urllib.parse
import sys
import os
import json
import re
import time
import socket
import threading
from urllib.error import URLError, HTTPError
from concurrent.futures import ThreadPoolExecutor, as_completed

# Import platform URLs from fetcher.py to maintain single source of truth
try:
    from fetcher import PLATFORM_URLS
except ImportError:
    # Fallback in case fetcher.py is not available
    PLATFORM_URLS = {}

def get_platform_folder(platform_name):
    """Get platform folder from get_platforms.py output"""
    try:
        import subprocess
        result = subprocess.run(['python3', 'get_platforms.py'], 
                              capture_output=True, text=True, cwd=os.path.dirname(__file__))
        
        if result.returncode == 0:
            import json
            data = json.loads(result.stdout)
            for platform in data.get('platforms', []):
                if platform['name'] == platform_name:
                    return platform['folder']
    except Exception as e:
        print(f"Error getting platform folder: {e}", file=sys.stderr)
    
    
    return fallback_folders.get(platform_name, platform_name.lower().replace(" ", ""))

def clean_filename(filename):
    """Clean filename for filesystem compatibility"""
    # Remove or replace problematic characters
    cleaned = re.sub(r'[<>:"/\|?*]', '_', filename)
    # Remove control characters
    cleaned = re.sub(r'[\x00-\x1f\x7f-\x9f]', '', cleaned)
    # Limit length
    if len(cleaned) > 200:
        name, ext = os.path.splitext(cleaned)
        cleaned = name[:196] + ext
    return cleaned

def setup_socket_optimizations():
    """Configure socket optimizations for faster downloads"""
    # Set default socket timeout
    socket.setdefaulttimeout(60)
    
    # Configure TCP socket options for better performance
    original_socket = socket.socket
    
    def optimized_socket(*args, **kwargs):
        sock = original_socket(*args, **kwargs)
        try:
            # Enable TCP_NODELAY to disable Nagle's algorithm (reduces latency)
            sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
            # Set larger socket buffer sizes
            sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 1024 * 1024)  # 1MB receive buffer
            sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 1024 * 1024)  # 1MB send buffer
        except (OSError, AttributeError):
            pass  # Some systems may not support these options
        return sock
    
    socket.socket = optimized_socket

def parallel_chunk_download(url, start_byte, end_byte, chunk_id):
    """Download a specific byte range of a file"""
    try:
        req = urllib.request.Request(url)
        req.add_header('User-Agent', 'File Downloader/1.0 (Parallel)')
        req.add_header('Accept-Encoding', 'gzip, deflate')
        req.add_header('Connection', 'keep-alive')
        req.add_header('Range', f'bytes={start_byte}-{end_byte}')
        
        response = urllib.request.urlopen(req, timeout=45)
        data = response.read()
        
        return chunk_id, start_byte, data
        
    except Exception as e:
        print(f"Chunk {chunk_id} download failed: {e}", file=sys.stderr)
        return chunk_id, start_byte, None

def test_server_supports_ranges(url):
    """Test if server supports HTTP range requests for parallel downloads"""
    try:
        req = urllib.request.Request(url)
        req.add_header('User-Agent', 'File Downloader/1.0 (Range Test)')
        req.add_header('Range', 'bytes=0-1023')  # Request first 1KB
        
        response = urllib.request.urlopen(req, timeout=10)
        return response.status == 206  # Partial Content
    except:
        return False

def optimized_download_with_progress(url, target_file, progress_callback=None):
    """
    Maximum speed download with parallel chunks and optimizations
    """
    setup_socket_optimizations()
    
    # First, get file size and test for range support
    req = urllib.request.Request(url)
    req.add_header('User-Agent', 'File Downloader/1.0 (Speed Optimized)')
    req.add_header('Accept-Encoding', 'gzip, deflate')
    req.add_header('Connection', 'keep-alive')
    
    try:
        response = urllib.request.urlopen(req, timeout=30)
        total_size = int(response.headers.get('Content-Length', 0))
        response.close()
        
        # Immediately show file size info
        if progress_callback and total_size > 0:
            progress_callback(0, total_size)
        
        print(f"File size: {total_size / (1024*1024):.1f} MB", file=sys.stderr)
        
        # For small files or servers that don't support ranges, use single-threaded download
        if total_size < 5 * 1024 * 1024 or not test_server_supports_ranges(url):  # < 5MB
            print("Using single-threaded download", file=sys.stderr)
            return single_threaded_download(url, target_file, progress_callback, total_size)
        
        # Use parallel download for larger files
        print("Using parallel download (4 threads)", file=sys.stderr)
        return parallel_download(url, target_file, progress_callback, total_size)
        
    except (URLError, HTTPError, OSError) as e:
        print(f"Download error: {e}", file=sys.stderr)
        return False

def single_threaded_download(url, target_file, progress_callback, total_size):
    """Optimized single-threaded download"""
    req = urllib.request.Request(url)
    req.add_header('User-Agent', 'File Downloader/1.0 (Single Thread)')
    req.add_header('Accept-Encoding', 'gzip, deflate')
    req.add_header('Connection', 'keep-alive')
    
    try:
        response = urllib.request.urlopen(req, timeout=60)
        
        # Use very large buffer for single-threaded downloads
        buffer_size = 2 * 1024 * 1024  # 2MB chunks
        downloaded = 0
        last_progress_update = 0
        progress_update_interval = 0.2
        
        with open(target_file, 'wb') as f:
            while True:
                chunk = response.read(buffer_size)
                if not chunk:
                    break
                
                f.write(chunk)
                downloaded += len(chunk)
                
                # Update progress
                current_time = time.time()
                if progress_callback and (current_time - last_progress_update) >= progress_update_interval:
                    progress_callback(downloaded, total_size)
                    last_progress_update = current_time
        
        # Final progress update
        if progress_callback:
            progress_callback(downloaded, total_size)
            
        return True
        
    except Exception as e:
        print(f"Single-threaded download error: {e}", file=sys.stderr)
        return False

def parallel_download(url, target_file, progress_callback, total_size):
    """Parallel multi-threaded download"""
    num_threads = 4
    chunk_size = total_size // num_threads
    
    # Create download tasks
    tasks = []
    for i in range(num_threads):
        start_byte = i * chunk_size
        end_byte = start_byte + chunk_size - 1
        if i == num_threads - 1:  # Last chunk gets remainder
            end_byte = total_size - 1
        tasks.append((start_byte, end_byte, i))
    
    print(f"Downloading {len(tasks)} parallel chunks", file=sys.stderr)
    
    # Download chunks in parallel
    chunks = {}
    downloaded = 0
    last_progress_update = 0
    
    with ThreadPoolExecutor(max_workers=num_threads) as executor:
        # Submit all download tasks
        future_to_chunk = {
            executor.submit(parallel_chunk_download, url, start, end, chunk_id): chunk_id
            for start, end, chunk_id in tasks
        }
        
        # Collect results as they complete
        for future in as_completed(future_to_chunk):
            chunk_id, start_byte, data = future.result()
            
            if data is not None:
                chunks[chunk_id] = (start_byte, data)
                downloaded += len(data)
                
                # Update progress
                current_time = time.time()
                if progress_callback and (current_time - last_progress_update) >= 0.2:
                    progress_callback(downloaded, total_size)
                    last_progress_update = current_time
                    
                print(f"Chunk {chunk_id} completed ({len(data)} bytes)", file=sys.stderr)
            else:
                print(f"Chunk {chunk_id} failed, falling back to single-threaded", file=sys.stderr)
                return single_threaded_download(url, target_file, progress_callback, total_size)
    
    # Write chunks to file in correct order
    try:
        with open(target_file, 'wb') as f:
            for i in range(num_threads):
                if i in chunks:
                    start_byte, data = chunks[i]
                    f.write(data)
                else:
                    print(f"Missing chunk {i}, download failed", file=sys.stderr)
                    return False
        
        # Final progress update
        if progress_callback:
            progress_callback(total_size, total_size)
            
        print("Parallel download completed successfully", file=sys.stderr)
        return True
        
    except Exception as e:
        print(f"Error writing parallel chunks: {e}", file=sys.stderr)
        return False

def accelerated_file_download(url, target_file):
    """
    Ultra-fast download using multiple simultaneous connections
    """
    class DownloadAccelerator:
        def __init__(self, url, target_file, num_connections=6):
            self.url = url
            self.target_file = target_file
            self.num_connections = num_connections
            self.total_size = 0
            self.downloaded = 0
            self.chunks = {}
            self.lock = threading.Lock()
            
        def get_file_size(self):
            try:
                req = urllib.request.Request(self.url)
                req.add_header('User-Agent', 'File Accelerator/1.0')
                response = urllib.request.urlopen(req, timeout=10)
                self.total_size = int(response.headers.get('Content-Length', 0))
                response.close()
                return self.total_size > 0
            except:
                return False
        
        def test_range_support(self):
            try:
                req = urllib.request.Request(self.url)
                req.add_header('User-Agent', 'File Accelerator/1.0')
                req.add_header('Range', 'bytes=0-1023')
                response = urllib.request.urlopen(req, timeout=10)
                supports_ranges = response.status == 206
                response.close()
                return supports_ranges
            except:
                return False
        
        def download_chunk(self, connection_id, start_byte, end_byte):
            try:
                req = urllib.request.Request(self.url)
                req.add_header('User-Agent', f'File Accelerator/1.0 (Conn {connection_id})')
                req.add_header('Accept-Encoding', 'gzip, deflate')
                req.add_header('Connection', 'keep-alive')
                
                if start_byte is not None and end_byte is not None:
                    req.add_header('Range', f'bytes={start_byte}-{end_byte}')
                
                response = urllib.request.urlopen(req, timeout=45)
                
                data = b''
                buffer_size = 128 * 1024  # 128KB buffer
                
                while True:
                    chunk = response.read(buffer_size)
                    if not chunk:
                        break
                    data += chunk
                    
                    with self.lock:
                        self.downloaded += len(chunk)
                        if self.downloaded % (256 * 1024) == 0:  # Every 256KB
                            self.update_progress()
                
                response.close()
                return connection_id, start_byte, data
                
            except Exception as e:
                print(f"Connection {connection_id} error: {e}", file=sys.stderr)
                return connection_id, start_byte, None
        
        def update_progress(self):
            if self.total_size > 0:
                percent = min(100, (self.downloaded * 100) // self.total_size)
                mb_downloaded = self.downloaded / (1024 * 1024)
                mb_total = self.total_size / (1024 * 1024)
                
                status = {
                    "status": "downloading",
                    "percent": percent,
                    "downloaded_mb": round(mb_downloaded, 1),
                    "total_mb": round(mb_total, 1)
                }
                
                try:
                    with open("/tmp/file_download_progress.json", "w") as f:
                        json.dump(status, f)
                        f.flush()
                except:
                    pass
        
        def accelerated_download(self):
            setup_socket_optimizations()
            
            if not self.get_file_size():
                return False
            
            print(f"Accelerated download: {self.total_size / (1024*1024):.1f} MB with {self.num_connections} connections", file=sys.stderr)
            
            if not self.test_range_support():
                print("No range support, using single connection", file=sys.stderr)
                return False
            
            # Calculate chunks
            chunk_size = self.total_size // self.num_connections
            tasks = []
            
            for i in range(self.num_connections):
                start_byte = i * chunk_size
                end_byte = start_byte + chunk_size - 1
                if i == self.num_connections - 1:
                    end_byte = self.total_size - 1
                tasks.append((i, start_byte, end_byte))
            
            # Download in parallel
            with ThreadPoolExecutor(max_workers=self.num_connections) as executor:
                future_to_connection = {
                    executor.submit(self.download_chunk, conn_id, start, end): conn_id
                    for conn_id, start, end in tasks
                }
                
                for future in as_completed(future_to_connection):
                    conn_id, start_byte, data = future.result()
                    
                    if data is not None:
                        self.chunks[conn_id] = (start_byte, data)
                        print(f"Connection {conn_id} done: {len(data)} bytes", file=sys.stderr)
                    else:
                        print(f"Connection {conn_id} failed", file=sys.stderr)
                        return False
            
            # Write file
            try:
                with open(self.target_file, 'wb') as f:
                    for i in range(self.num_connections):
                        if i in self.chunks:
                            start_byte, data = self.chunks[i]
                            f.write(data)
                        else:
                            return False
                
                # Final progress
                self.downloaded = self.total_size
                self.update_progress()
                print("Accelerated download completed!", file=sys.stderr)
                return True
                
            except Exception as e:
                print(f"File write error: {e}", file=sys.stderr)
                return False
    
    accelerator = DownloadAccelerator(url, target_file)
    return accelerator.accelerated_download()

def write_progress_status(downloaded, total_size):
    """Optimized progress writer with reduced frequency"""
    if total_size > 0:
        percent = min(100, (downloaded * 100) // total_size)
        mb_downloaded = downloaded / (1024 * 1024)
        mb_total = total_size / (1024 * 1024)
        
        status = {
            "status": "downloading",
            "percent": percent,
            "downloaded_mb": round(mb_downloaded, 1),
            "total_mb": round(mb_total, 1)
        }
        
        # Debug output to stderr for troubleshooting
        print(f"Progress: {percent}% ({mb_downloaded:.1f}/{mb_total:.1f} MB)", file=sys.stderr)
        
        # Write progress to file for UI to read
        try:
            with open("/tmp/file_download_progress.json", "w") as f:
                json.dump(status, f)
                f.flush()  # Ensure data is written immediately
        except OSError as e:
            print(f"Progress write error: {e}", file=sys.stderr)
            pass  # Don't fail download if progress file can't be written

def download_file(platform_name, file_filename):
    """Download file to appropriate platform folder with proper URL handling"""
    if platform_name not in PLATFORM_URLS:
        return {"error": f"Platform {platform_name} not supported"}
    
    try:
        # Handle URL encoding properly
        base_url = PLATFORM_URLS[platform_name]
        
        # If file_filename is already URL-encoded, use it as-is
        # If not, encode it properly
        if '%' in file_filename:
            # Already encoded
            encoded_filename = file_filename
            clean_filename_for_save = urllib.parse.unquote(file_filename)
        else:
            # Need to encode
            encoded_filename = urllib.parse.quote(file_filename)
            clean_filename_for_save = file_filename
        
        # Construct download URL - handle GitHub repositories specially
        if 'github.com' in base_url:
            if '/tree/' in base_url:
                # GitHub folder/tree URL
                # From: https://github.com/user/repo/tree/main/pico-8
                # To: https://raw.githubusercontent.com/user/repo/main/pico-8/
                raw_base = base_url.replace('github.com', 'raw.githubusercontent.com')
                raw_base = raw_base.replace('/tree/', '/')
                if not raw_base.endswith('/'):
                    raw_base += '/'
                # file_filename contains full path like "pico-8/romnix.p8.png"
                # Extract just the filename for the URL
                filename_only = file_filename.split('/')[-1]
                file_url = raw_base + filename_only
            elif '/blob/' in base_url:
                # GitHub blob URL - single file
                # From: https://github.com/user/repo/blob/main/pico-8/file.png
                # To: https://raw.githubusercontent.com/user/repo/main/pico-8/file.png
                raw_base = base_url.replace('github.com', 'raw.githubusercontent.com')
                raw_base = raw_base.replace('/blob/', '/')
                file_url = raw_base
            else:
                # Regular GitHub repo URL
                raw_base = base_url.replace('github.com', 'raw.githubusercontent.com')
                if not raw_base.endswith('/'):
                    raw_base += '/'
                if '/main/' not in raw_base and '/master/' not in raw_base:
                    raw_base += 'main/'
                file_url = raw_base + encoded_filename
        else:
            # For Myrient and other direct download sites
            if not base_url.endswith('/'):
                base_url += '/'
            file_url = base_url + encoded_filename
        
        # Clean the filename for filesystem
        clean_filename_for_save = clean_filename(clean_filename_for_save)
        
        # Determine target folder using dynamic lookup
        platform_folder = get_platform_folder(platform_name)
        target_dir = f"/storage/roms/{platform_folder}"
        
        # Create target directory if it doesn't exist
        os.makedirs(target_dir, exist_ok=True)
        
        # Target file path
        target_file = os.path.join(target_dir, clean_filename_for_save)
        
        print(f"Downloading: {clean_filename_for_save}", file=sys.stderr)
        print(f"From URL: {file_url}", file=sys.stderr)
        print(f"To: {target_file}", file=sys.stderr)
        
        # Initialize progress
        with open("/tmp/file_download_progress.json", "w") as f:
            json.dump({"status": "starting", "percent": 0}, f)
        
        # Use optimized download with progress tracking and retry logic
        print(f"Starting maximum speed download...", file=sys.stderr)
        
        # Write initial downloading status
        with open("/tmp/file_download_progress.json", "w") as f:
            json.dump({"status": "downloading", "percent": 0, "downloaded_mb": 0.0, "total_mb": 0.0}, f)
            f.flush()
        
        # Try accelerated download first, then fallback to optimized download
        print("Attempting accelerated multi-connection download...", file=sys.stderr)
        success = accelerated_file_download(file_url, target_file)
        
        if not success:
            print("Accelerated download failed, trying optimized single download...", file=sys.stderr)
            # Retry download with exponential backoff
            max_retries = 3
            for attempt in range(max_retries):
                if attempt > 0:
                    wait_time = 2 ** attempt  # 2, 4, 8 seconds
                    print(f"Retry attempt {attempt + 1}/{max_retries} after {wait_time}s delay...", file=sys.stderr)
                    time.sleep(wait_time)
                
                success = optimized_download_with_progress(file_url, target_file, write_progress_status)
                if success:
                    break
            else:
                return {"error": "Download failed after all retry attempts"}
        
        if not success:
            return {"error": "Download failed - network error"}
        
        # Check if file was downloaded successfully
        if os.path.exists(target_file):
            file_size = os.path.getsize(target_file)
            file_size_mb = file_size / (1024 * 1024)
            
            result = {
                "status": "success",
                "message": f"File downloaded successfully!",
                "file": target_file,
                "size_mb": round(file_size_mb, 1),
                "platform": platform_name,
                "folder": platform_folder,
                "filename": clean_filename_for_save
            }
            
            # Write final status
            with open("/tmp/file_download_progress.json", "w") as f:
                json.dump(result, f)
            
            return result
        else:
            return {"error": "Download failed - file not created"}
            
    except Exception as e:
        error_msg = str(e)
        print(f"Download error: {error_msg}", file=sys.stderr)
        
        error_result = {"error": f"Download failed: {error_msg}", "status": "error"}
        with open("/tmp/file_download_progress.json", "w") as f:
            json.dump(error_result, f)
        return error_result

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 downloader.py <platform_name> <file_filename>")
        sys.exit(1)
    
    platform = sys.argv[1]
    file_name = sys.argv[2]
    
    result = download_file(platform, file_name)
    print(json.dumps(result, indent=2))
