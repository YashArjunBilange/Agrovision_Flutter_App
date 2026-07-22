# AgroVision Backend

This backend provides a FastAPI REST API for the AgroVision plant disease classification model.
It loads a YOLOv8 classification model and returns exactly one top-1 prediction.

## Project Structure

- `main.py` - FastAPI application and prediction endpoints.
- `remedies.py` - Existing disease remedy dictionary.
- `best.pt` - YOLOv8 classification model.
- `requirements.txt` - Python dependencies.
- `render.yaml` - Render deployment configuration.
- `.gitignore` - Ignored files.

## Local Setup

1. Install dependencies:

```bash
pip install -r requirements.txt
```

2. Run locally:

```bash
uvicorn main:app --reload
```

3. Open in browser:

- Swagger UI: `http://127.0.0.1:8000/docs`
- ReDoc: `http://127.0.0.1:8000/redoc`

## API Endpoints

### `GET /`
Returns API status.

### `GET /health`
Returns health check details for Render.

### `GET /model-info`
Returns model type, class count, and class names.

### `POST /predict`
Accepts a multipart form upload with key `file`.
Supported MIME types: `image/jpeg`, `image/jpg`, `image/png`, `image/webp`.

Example `curl`:

```bash
curl -X POST \
  "http://127.0.0.1:8000/predict" \
  -H "accept: application/json" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@tomato.jpg"
```

## Prediction Behavior

- Loads `best.pt` once when the app starts.
- Converts uploaded images to RGB with PIL.
- Uses YOLOv8 classification output.
- Returns only the top-1 prediction.
- Looks up remedies from `remedies.remedies` using normalized class names.
- Does not save uploaded images to disk.

## Render Deployment

Use the `render.yaml` file for Render Web Service deployment.
Render will run:

- Build: `pip install -r requirements.txt`
- Start: `uvicorn main:app --host 0.0.0.0 --port $PORT`
- Health check path: `/health`
