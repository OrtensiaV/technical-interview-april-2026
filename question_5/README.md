# Clinical Trial Data API

A REST API for querying and analysing adverse event data from clinical trials, built with FastAPI.

## What It Does

The API lets you filter adverse events by severity and treatment group, and calculate safety risk scores for individual patients. It is designed to be simple to use whilst handling errors properly.

## The Files

**main.py** contains the actual API - this is what you run.

**dev_test_code.py** has all the test cases I used during development. You can run it to verify everything works, but it is not required for the API itself.

## What You'll Need

- Python 3.8 or newer
- A few Python packages (FastAPI, Uvicorn, Pandas, Pydantic)

## Getting Set Up

### Clone and Navigate

```bash
git clone https://github.com/OrtensiaV/technical-interview-april-2026/
cd technical-interview-april-2026/question_5
```

### Install Dependencies

```bash
pip install fastapi uvicorn pandas pydantic
```

### Check You Have Everything

Make sure these files are in the folder:
- `main.py`
- `adae.csv`

## Running It

Start the server from the `exercise5` folder:
  
  ```bash
uvicorn main:app --reload
```

You should see something like:
  ```
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
INFO:     Started reloader process
INFO:     Application startup complete.
```

The `--reload` flag is handy during development - it automatically restarts the server when you save changes.

To stop the server, just press `CTRL+C` in the terminal.

## Using the API

### Interactive Documentation (Easiest Way)

Go to **`http://localhost:8000/docs`** in your browser. You'll see all three endpoints with "Try it out" buttons. Click one, enter your parameters, hit "Execute", and you'll see the response immediately.

There's also an alternative documentation view at **`http://localhost:8000/redoc`**.

### The Endpoints

**1. GET `/`**

Just returns a welcome message to confirm the API is running.

```json
{
  "message": "Clinical Trial Data API is running"
}
```

**2. POST `/ae-query`**

Filter adverse events by severity and/or treatment arm. Both parameters are optional - if you leave one out, it won't filter on that dimension.

Example request:
  ```json
{
  "severity": ["MILD", "MODERATE"],
  "treatment_arm": "Placebo"
}
```

Response:
  ```json
{
  "count": 145,
  "unique_subjects": ["01-701-1015", "01-701-1023", ...]
}
```

**3. GET `/subject-risk/{subject_id}`**
  
  Calculate a safety risk score for a specific patient based on their adverse events.

The scoring works like this:
- MILD events: 1 point each
- MODERATE events: 3 points each
- SEVERE events: 5 points each

Then it categorises the total:
- Low risk: under 5 points
- Medium risk: 5 to 14 points
- High risk: 15 points or more

Example response:
  ```json
{
  "subject_id": "01-701-1015",
  "risk_score": 8,
  "risk_category": "Medium"
}
```

If you request a subject ID that doesn't exist, you'll get a 404 error with a helpful message.

## Testing

### Using the Interactive Docs

This is the simplest way - just go to `http://localhost:8000/docs`, click on an endpoint, hit "Try it out", enter your parameters, and click "Execute". You'll see the response straight away.

### Using the Test Script

Run all the test cases at once:

```bash
python dev_test_code.py
```

## Common Issues

**"Can't find module fastapi"**
You need to install the dependencies: `pip install fastapi uvicorn pandas pydantic`

**"Can't find adae.csv"**
Make sure `adae.csv` is in the same folder as `main.py`

**"Port 8000 is already in use"**
Either something else is using that port, or you've already got the API running. Try a different port: `uvicorn main:app --reload --port 8001`

**"My code changes aren't showing up"**
  Make sure you saved the file and you're using the `--reload` flag when starting the server.

## Author

Ortensia Vito
```
