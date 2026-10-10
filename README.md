# MCS4302 Mobile Computing - running system (index 24440329)

Flutter client (`mobile_client/`) for a FastAPI backend (`backend/`), started in
the Week 4 lab and kept for Weeks 5, 6, 7, 9 and 10.

## Backend (host)

```
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1        # Windows PowerShell
python -m pip install -r requirements.txt
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Swagger: http://localhost:8000/docs

## Flutter client (Android Emulator)

```
cd mobile_client
flutter pub get
flutter run
```

The emulator reaches the host at `http://10.0.2.2:8000` (`lib/config.dart`).
Plain HTTP is allowed in `AndroidManifest.xml` for this local lab only and is
removed when HTTPS is enabled in Week 9.

## Week 4 results

Raw output of the Part 5 retry experiment (seeds 42, 43, 44) is in
`measurements/week4_retry_experiment.csv`, one row per condition per run, as
copied from the app's **Copy CSV** button.

Note: `lib/main.dart` uses `setState(() { _future = api.getItems(); })` rather
than the code pack's arrow form `setState(() => _future = ...)`. The arrow
closure returns the Future, which fails a debug assertion in `setState` and
skips the rebuild, so the refresh button never updated the screen.
