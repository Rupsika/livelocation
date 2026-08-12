import time
import math
import random
from typing import Dict, List, Optional
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI(title="Live Location Tracking Simulator API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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
        "history": []
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
        "history": []
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
        "history": []
    }
}

def interpolate(p1, p2, t):
    lat = p1["lat"] + (p2["lat"] - p1["lat"]) * t
    lng = p1["lng"] + (p2["lng"] - p1["lng"]) * t
    return lat, lng

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

    curr_time = time.strftime("%I:%M:%S %p")
    address = p1["address"] if emp["step_fraction"] < 0.5 else p2["address"]

    log_entry = {
        "time": curr_time,
        "latitude": round(lat, 6),
        "longitude": round(lng, 6),
        "address": address,
        "speed": speed,
        "battery": emp["battery"],
        "status": emp["status"]
    }

    emp["history"].insert(0, log_entry)
    emp["history"] = emp["history"][:20]

@app.get("/")
def root():
    return {"message": "Live Location Simulator API Running", "status": "active"}

@app.get("/api/employees")
def get_employees():
    return [
        {
            "id": emp["id"],
            "name": emp["name"],
            "role": emp["role"],
            "avatar": emp["avatar"],
            "status": emp["status"]
        }
        for emp in employees_db.values()
    ]

@app.get("/api/employee/{emp_id}/location")
def get_employee_location(emp_id: str = "1"):
    if emp_id not in employees_db:
        emp_id = "1"

    update_simulated_location(emp_id)
    emp = employees_db[emp_id]

    latest_history = emp["history"][0] if emp["history"] else {
        "time": time.strftime("%I:%M:%S %p"),
        "latitude": DEFAULT_ROUTE[0]["lat"],
        "longitude": DEFAULT_ROUTE[0]["lng"],
        "address": DEFAULT_ROUTE[0]["address"],
        "speed": 0.0,
        "battery": 85,
        "status": emp["status"]
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
        "history": emp["history"]
    }

class LocationPayload(BaseModel):
    id: Optional[str] = "1"
    name: Optional[str] = "Test User"
    latitude: float
    longitude: float
    address: Optional[str] = "Manual Ingest / GPS Sender"
    speed: Optional[float] = 0.0
    battery: Optional[int] = 90
    status: Optional[str] = "Online"

@app.post("/api/location/update")
def post_location_update(payload: LocationPayload):
    emp_id = payload.id or "1"
    if emp_id not in employees_db:
        employees_db[emp_id] = {
            "id": emp_id,
            "name": payload.name or "Test User",
            "role": "Field Device",
            "avatar": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80",
            "status": payload.status,
            "battery": payload.battery,
            "speed": payload.speed,
            "route_index": 0,
            "step_fraction": 0.0,
            "is_simulating": False,
            "history": []
        }

    emp = employees_db[emp_id]
    emp["status"] = payload.status
    emp["battery"] = payload.battery
    emp["speed"] = payload.speed
    emp["is_simulating"] = False

    curr_time = time.strftime("%I:%M:%S %p")
    log_entry = {
        "time": curr_time,
        "latitude": payload.latitude,
        "longitude": payload.longitude,
        "address": payload.address,
        "speed": payload.speed,
        "battery": payload.battery,
        "status": payload.status
    }

    emp["history"].insert(0, log_entry)
    emp["history"] = emp["history"][:20]

    return {"status": "success", "message": "Location updated successfully", "data": log_entry}

@app.post("/api/employee/{emp_id}/simulation")
def toggle_simulation(emp_id: str, action: str):
    if emp_id in employees_db:
        if action == "start":
            employees_db[emp_id]["is_simulating"] = True
            employees_db[emp_id]["status"] = "Online"
        elif action == "stop":
            employees_db[emp_id]["is_simulating"] = False
            employees_db[emp_id]["status"] = "Offline"
    return {"status": "ok", "is_simulating": employees_db.get(emp_id, {}).get("is_simulating", False)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
