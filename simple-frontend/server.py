#!/usr/bin/env python3
"""
Simple HTTP server for Onyx frontend demo
Serves the static HTML interface on port 12000
"""

import http.server
import socketserver
import os
import sys
from pathlib import Path

# Set the port for the runtime environment
PORT = 12000
HOST = "0.0.0.0"

class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(Path(__file__).parent), **kwargs)
    
    def end_headers(self):
        # Add CORS headers for cross-origin requests
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()
    
    def do_OPTIONS(self):
        # Handle preflight requests
        self.send_response(200)
        self.end_headers()
    
    def log_message(self, format, *args):
        # Custom logging
        print(f"[{self.address_string()}] {format % args}")

def main():
    try:
        # Change to the directory containing this script
        os.chdir(Path(__file__).parent)
        
        with socketserver.TCPServer((HOST, PORT), CustomHTTPRequestHandler) as httpd:
            print(f"🚀 Onyx Simple Frontend Server")
            print(f"📱 Serving at: http://{HOST}:{PORT}")
            print(f"🌐 External URL: https://work-1-gqvpkgutqrgfvhqq.prod-runtime.all-hands.dev")
            print(f"📁 Directory: {Path(__file__).parent}")
            print(f"🛑 Press Ctrl+C to stop")
            print("-" * 60)
            
            httpd.serve_forever()
            
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
        sys.exit(0)
    except OSError as e:
        if e.errno == 98:  # Address already in use
            print(f"❌ Port {PORT} is already in use")
            print("💡 Try: sudo lsof -ti:12000 | xargs sudo kill -9")
        else:
            print(f"❌ Error starting server: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()