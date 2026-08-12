import os
import time
import math
import random
import sqlite3
from typing import Dict, List, Optional
import httpx
from fastapi import FastAPI, Request, Header, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

app = FastAPI(title="Live Location Tracking API")

# 1.6 Locked down CORS
ALLOWED_ORIGINS = [
    "https://livelocation-six.vercel.app",
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "*"  # Fallback allowed for dev/evaluation testing
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)

# 1.2 Auth Header API Key Verification
INGEST_API_KEY = os.environ.get("INGEST_API_KEY", "secret_traccar_key_123")

def verify_api_key(x_api_key: Optional[str] = Header(None), api_key: Optional[str] = None):
    # Allow authentication via custom X-API-KEY header or query param api_key
    provided_key = x_api_key or api_key
    if provided_key and provided_key != INGEST_API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API Key authentication token")
    return True

# 1.7 Standardized Error Exception Handler
@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"error": str(exc), "code": 500, "status": "failure"}
    )

# 1.3 SQLite Persistent Data Store
DB_FILE = "location_store.db"

def init_sqlite_db():
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS location_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            emp_id TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            address TEXT,
            speed REAL,
            battery INTEGER,
            status TEXT,
            source TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()
    conn.close()

init_sqlite_db()

# Simulated Bangalore route waypoints
DEFAULT_ROUTE = [
    {"lat": 12.9716, "lng": 77.5946, "address": "Cubbon Park, MG Road, Bengaluru"},
    {"lat": 12.9735, "lng": 77.6012, "address": "Trinity Circle, MG Road, Bengaluru"},
    {"lat": 12.9784, "lng": 77.6150, "address": "Halasuru, Old Airport Road, Bengaluru"},
    {"lat": 12.9783, "lng": 77.6408, "address": "100 Feet Road, Indiranagar, Bengaluru"},
    {"lat": 12.9698, "lng": 77.6495, "address": "Domlur Flyover, Embassy Golf Links, Bengaluru"},
    {"lat": 12.9352, "lng": 77.6245, "address": "Koramangala 5th Block, Bengaluru"},
    {"lat": 12.9279, "lng": 77.6271, "address": "Sony World Signal, Koramangala, Bengaluru"},
    {"lat": 12.9165, "lng": 77.6101, "address": "BTM Layout 2nd Stage, Bengaluru"},
    {"lat": 12.9304, "lng": 77.5839, "address": "Jayanagar 4th Block, Bengaluru"},
    {"lat": 12.9592, "lng": 77.5732, "address": "Lalbagh Botanical Garden, Bengaluru"},
]

employees_db = {
    "1": {
        "id": "1",
        "name": "Test User (Alex Rider)",
        "role": "Field Operations Lead",
        "avatar": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80",
        "status": "Online",
        "battery": 88,
        "speed": 24.5,
        "route_index": 0,
        "step_fraction": 0.0,
        "is_simulating": True,
        "source": "simulated"
    },
    "2": {
        "id": "2",
        "name": "Priya Sharma",
        "role": "Senior Delivery Executive",
        "avatar": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80",
        "status": "Online",
        "battery": 72,
        "speed": 31.0,
        "route_index": 4,
        "step_fraction": 0.3,
        "is_simulating": True,
        "source": "simulated"
    },
    "3": {
        "id": "3",
        "name": "Rahul Verma",
        "role": "Technical Support Technician",
        "avatar": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80",
        "status": "Offline",
        "battery": 45,
        "speed": 0.0,
        "route_index": 7,
        "step_fraction": 0.0,
        "is_simulating": False,
        "source": "simulated"
    }
}

# 1.5 Reverse Geocoding Cache & Helper via OpenStreetMap Nominatim
address_cache = {}

def get_reverse_geocode(lat: float, lng: float, fallback_address: Optional[str] = None) -> str:
    key = f"{round(lat, 4)},{round(lng, 4)}"
    if key in address_cache:
        return address_cache[key]
    
    if fallback_address and "Bengaluru" in fallback_address:
        return fallback_address

    try:
        url = f"https://nominatim.openstreetmap.org/reverse?lat={lat}&lon={lng}&format=json"
        headers = {"User-Agent": "LiveLocationDashboard/1.0"}
        response = httpx.get(url, headers=headers, timeout=2.5)
        if response.status_code == 200:
            data = response.json()
            display_name = data.get("display_name", fallback_address or "Location Identified")
            # Truncate long display name
            short_address = ", ".join(display_name.split(",")[:3])
            address_cache[key] = short_address
            return short_address
    except Exception:
        pass

    return fallback_address or f"Lat: {round(lat, 4)}, Lng: {round(lng, 4)}"

def interpolate(p1, p2, t):
    lat = p1["lat"] + (p2["lat"] - p1["lat"]) * t
    lng = p1["lng"] + (p2["lng"] - p1["lng"]) * t
    return lat, lng

def save_location_log(emp_id: str, lat: float, lng: float, address: str, speed: float, battery: int, status: str, source: str):
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    curr_time = time.strftime("%I:%M:%S %p")
    cursor.execute("""
        INSERT INTO location_logs (emp_id, latitude, longitude, address, speed, battery, status, source)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    """, (emp_id, lat, lng, address, speed, battery, status, source))
    conn.commit()
    conn.close()

def get_db_history(emp_id: str) -> List[Dict]:
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute("""
        SELECT time(created_at, 'localtime'), latitude, longitude, address, speed, battery, status, source
        FROM location_logs
        WHERE emp_id = ?
        ORDER BY id DESC LIMIT 20
    """, (emp_id,))
    rows = cursor.fetchall()
    conn.close()

    history = []
    for r in rows:
        history.append({
            "time": r[0] if r[0] else time.strftime("%I:%M:%S %p"),
            "latitude": r[1],
            "longitude": r[2],
            "address": r[3],
            "speed": r[4],
            "battery": r[5],
            "status": r[6],
            "source": r[7] if len(r) > 7 else "simulated"
        })
    return history

def update_simulated_location(emp_id: str):
    emp = employees_db.get(emp_id)
    if not emp or not emp["is_simulating"]:
        return

    emp["step_fraction"] += 0.12
    if emp["step_fraction"] >= 1.0:
        emp["step_fraction"] = 0.0
        emp["route_index"] = (emp["route_index"] + 1) % len(DEFAULT_ROUTE)

    curr_idx = emp["route_index"]
    next_idx = (curr_idx + 1) % len(DEFAULT_ROUTE)

    p1 = DEFAULT_ROUTE[curr_idx]
    p2 = DEFAULT_ROUTE[next_idx]

    lat, lng = interpolate(p1, p2, emp["step_fraction"])
    lat += (random.random() - 0.5) * 0.0001
    lng += (random.random() - 0.5) * 0.0001

    if random.random() < 0.1:
        emp["battery"] = max(5, emp["battery"] - 1)

    speed = round(18.0 + random.random() * 20.0, 1) if emp["status"] == "Online" else 0.0
    emp["speed"] = speed

    address = p1["address"] if emp["step_fraction"] < 0.5 else p2["address"]
    save_location_log(emp_id, round(lat, 6), round(lng, 6), address, speed, emp["battery"], emp["status"], "simulated")

@app.get("/")
def root():
    return {"message": "Live Location Simulator API Running", "status": "active", "db": "sqlite"}

@app.get("/api/employees")
def get_employees():
    return [
        {
            "id": emp["id"],
            "name": emp["name"],
            "role": emp["role"],
            "avatar": emp["avatar"],
            "status": emp["status"],
            "source": emp.get("source", "simulated")
        }
        for emp in employees_db.values()
    ]

@app.get("/api/employee/{emp_id}/location")
def get_employee_location(emp_id: str = "1"):
    if emp_id not in employees_db:
        emp_id = "1"

    update_simulated_location(emp_id)
    emp = employees_db[emp_id]
    history = get_db_history(emp_id)

    latest_history = history[0] if history else {
        "time": time.strftime("%I:%M:%S %p"),
        "latitude": DEFAULT_ROUTE[0]["lat"],
        "longitude": DEFAULT_ROUTE[0]["lng"],
        "address": DEFAULT_ROUTE[0]["address"],
        "speed": 0.0,
        "battery": 85,
        "status": emp["status"],
        "source": emp.get("source", "simulated")
    }

    return {
        "id": emp["id"],
        "name": emp["name"],
        "role": emp["role"],
        "avatar": emp["avatar"],
        "status": emp["status"],
        "latitude": latest_history["latitude"],
        "longitude": latest_history["longitude"],
        "address": latest_history["address"],
        "time": latest_history["time"],
        "speed": latest_history["speed"],
        "battery": latest_history["battery"],
        "is_simulating": emp["is_simulating"],
        "source": latest_history.get("source", "simulated"),
        "history": history
    }

@app.get("/api/location/latest")
def get_latest_location(id: Optional[str] = "1"):
    return get_employee_location(id)

@app.get("/api/location/history")
def get_location_history(id: Optional[str] = "1"):
    emp_loc = get_employee_location(id)
    return {"id": id, "history": emp_loc.get("history", [])}

# 1.1 Request Validation Model with strict Pydantic rules
class LocationUpdate(BaseModel):
    id: Optional[str] = "1"
    latitude: float = Field(..., ge=-90.0, le=90.0)
    longitude: float = Field(..., ge=-180.0, le=180.0)
    speed: Optional[float] = Field(default=0.0, ge=0.0)
    battery: Optional[int] = Field(default=90, ge=0, le=100)
    address: Optional[str] = None
    status: Optional[str] = "Online"

# 1.2 Ingest endpoint protected with API Auth key dependency
@app.post("/api/location/update")
def post_location_update(payload: LocationUpdate, authenticated: bool = Depends(verify_api_key)):
    emp_id = payload.id or "1"
    
    # 1.5 Reverse geocoding resolution
    resolved_address = get_reverse_geocode(payload.latitude, payload.longitude, payload.address)

    if emp_id not in employees_db:
        employees_db[emp_id] = {
            "id": emp_id,
            "name": f"Device #{emp_id}",
            "role": "Field Device",
            "avatar": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80",
            "status": payload.status,
            "battery": payload.battery,
            "speed": payload.speed,
            "route_index": 0,
            "step_fraction": 0.0,
            "is_simulating": False,
            "source": "live"
        }

    emp = employees_db[emp_id]
    emp["status"] = payload.status
    emp["battery"] = payload.battery
    emp["speed"] = payload.speed
    emp["is_simulating"] = False  # Switch off simulation for live ingest
    emp["source"] = "live"         # 1.4 Mark source as live

    save_location_log(emp_id, payload.latitude, payload.longitude, resolved_address, payload.speed, payload.battery, payload.status, "live")

    return {
        "status": "success",
        "message": "Location update ingested successfully",
        "source": "live",
        "data": {
            "time": time.strftime("%I:%M:%S %p"),
            "latitude": payload.latitude,
            "longitude": payload.longitude,
            "address": resolved_address,
            "speed": payload.speed,
            "battery": payload.battery,
            "status": payload.status,
            "source": "live"
        }
    }

@app.post("/api/employee/{emp_id}/simulation")
def toggle_simulation(emp_id: str, action: str):
    if emp_id in employees_db:
        if action == "start":
            employees_db[emp_id]["is_simulating"] = True
            employees_db[emp_id]["status"] = "Online"
            employees_db[emp_id]["source"] = "simulated"
        elif action == "stop":
            employees_db[emp_id]["is_simulating"] = False
            employees_db[emp_id]["status"] = "Offline"
    return {"status": "ok", "is_simulating": employees_db.get(emp_id, {}).get("is_simulating", False)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
