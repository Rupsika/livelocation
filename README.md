# Demo Project – Live Location Tracking Dashboard (Flutter Web)

A state-of-the-art **Flutter Web Live Location Tracking Dashboard** designed for operations leads and fleet managers to monitor real-time device locations on an interactive OpenStreetMap.

🔗 **Live Web App**: [https://livelocation-six.vercel.app/](https://livelocation-six.vercel.app/)  
📁 **GitHub Repository**: [https://github.com/Rupsika/livelocation](https://github.com/Rupsika/livelocation)

---

## 📐 System Architecture & Data Flowchart

```
[ Android Mobile Device ]              [ Dashboard Ingest Simulator ]
 (Traccar Client / OwnTracks)             (Manual Ingest Modal)
              │                                        │
              │ HTTP POST /api/location/update         │
              │ Header: X-API-KEY (Auth Token)         │
              └───────────────────┬────────────────────┘
                                  │
                                  ▼
             ┌──────────────────────────────────────────┐
             │      Python FastAPI Backend Service      │
             │           (backend/server.py)            │
             ├──────────────────────────────────────────┤
             │ ── Pydantic Input Validation             │
             │ ── X-API-KEY Token Security              │
             │ ── SQLite Store (location_store.db)      │
             │ ── OSM Reverse Geocoding Address Cache   │
             │ ── Bangalore Route Waypoint Simulator    │
             │ ── Live vs Simulated Source Distinction   │
             │                                          │
             │  Endpoints:                              │
             │  • GET  /api/employees                   │
             │  • GET  /api/employee/{id}/location      │
             │  • GET  /api/location/latest             │
             │  • GET  /api/location/history            │
             │  • POST /api/location/update             │
             └────────────────────┬─────────────────────┘
                                  │
                                  │ HTTP GET (Polled every 3–5 seconds)
                                  ▼
             ┌──────────────────────────────────────────┐
             │       Flutter Web Dashboard (Vercel)     │
             │     (https://livelocation-six.vercel.app)│
             ├──────────────────────────────────────────┤
             │ • Provider State Management              │
             │ • OpenStreetMap (flutter_map + latlong2) │
             │ • Dynamic Moving Marker & Polyline Trail │
             │ • Live vs Simulated Source Badges        │
             │ • Top 20 Location History Log Table      │
             │ • Employee Sidebar & Telemetry Cards     │
             └──────────────────────────────────────────┘
```

---

## ⚡ Technical Overview & Features

### 1. Presentation Layer (Flutter Web)
- **Interactive OpenStreetMap (`flutter_map` + `latlong2`)**:
  - Live moving marker featuring employee photo avatar, glowing status halo, speed badge, and detail popups.
  - **Polyline Layer**: Real-time travel route trail visualization.
  - **Auto-Follow Device Camera**: Recenter camera view automatically as new coordinates arrive.
- **Employee Telemetry Card**:
  - Displays Online/Offline status, battery level, speed (km/h), timestamp, reverse-geocoded address, and copyable lat/lng coordinates.
  - Prominent **`LIVE (TRACCAR)`** vs **`SIMULATED`** data source badge indicator.
- **Location History Table**:
  - Displays up to the latest **20 records** with search filter and "Highlight on Map" buttons.
- **Dashboard Controls**:
  - Start/Stop tracking toggle, 3s/5s/10s auto-refresh speed selection, and manual Traccar simulator ingest modal.

### 2. Backend & Ingestion Layer (`backend/server.py`)
- **FastAPI REST API**: Serves JSON endpoints with locked-down CORS and standardized error handlers.
- **SQLite Persistence**: Stores historical coordinate logs in `location_store.db`.
- **Pydantic Validation**: Enforces coordinate bounds, battery ranges, and speed constraints.
- **Reverse Geocoding**: Resolves coordinates to real street addresses via OpenStreetMap Nominatim with caching.
- **Security**: Ingestion endpoint protected via `X-API-KEY` token verification.

---

## 🚀 How to Run Locally

### 1. Run Python Backend Server
```bash
cd backend
pip install -r requirements.txt
python server.py
```
*(Backend runs on `http://127.0.0.1:8000`)*

### 2. Run Flutter Web Dashboard
```bash
flutter run -d chrome
```

---

## 📲 How to Connect Traccar Client (Android)

1. Install **Traccar Client** (Free on Google Play Store).
2. Configure settings:
   - **Server URL**: `http://<YOUR_IP>:8000/api/location/update`
   - **Location Frequency**: 3–5 seconds
   - **HTTP Headers**: `X-API-KEY: secret_traccar_key_123`
3. Turn on **Service Status** in the app.
4. Watch the web dashboard marker move live with a **`LIVE (TRACCAR)`** badge!
