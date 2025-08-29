"""
Production-ready main.py with static file serving for Railway deployment
"""
import os
from pathlib import Path
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse

# Import the original main.py content
from .main import app, socket_app

# Determine if we're in production mode
PROD = os.getenv("PROD", "false").lower() == "true"
SERVER_PORT = int(os.getenv("SERVER_PORT", os.getenv("PORT", "8181")))

if PROD:
    # Find the static directory
    static_paths = [
        Path("/app/static"),  # Docker container path
        Path("/app/python/static"),  # Alternative Docker path
        Path("./static"),  # Local path
        Path("./python/static"),  # Alternative local path
    ]
    
    static_dir = None
    for path in static_paths:
        if path.exists() and path.is_dir():
            static_dir = path
            print(f"Found static directory at: {static_dir}")
            break
    
    if static_dir:
        # Mount static files at /static
        app.mount("/static", StaticFiles(directory=str(static_dir)), name="static")
        
        # Serve index.html for all non-API routes (SPA support)
        @app.get("/{full_path:path}")
        async def serve_spa(full_path: str):
            # Skip API routes
            if full_path.startswith("api/") or full_path.startswith("socket.io/"):
                return {"error": "Not found"}, 404
            
            # Check if requesting a static file
            file_path = static_dir / full_path
            if file_path.exists() and file_path.is_file():
                return FileResponse(file_path)
            
            # For all other routes, serve index.html (SPA routing)
            index_path = static_dir / "index.html"
            if index_path.exists():
                return FileResponse(index_path)
            
            return {"error": "Frontend not found"}, 404
        
        print(f"✅ Static file serving configured for production at port {SERVER_PORT}")
    else:
        print("⚠️ Warning: Static directory not found in production mode")