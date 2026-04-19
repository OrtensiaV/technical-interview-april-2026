# Clinical Trial Data API

A RESTful API built with FastAPI for querying and analysing clinical trial adverse event data.

## Features

- Dynamic filtering of adverse events by severity and treatment arm
- Patient risk score calculation based on adverse event severity
- RESTful API design with comprehensive error handling

## Requirements

- Python 3.8+
  - FastAPI
- Uvicorn
- Pandas
- Pydantic

## Installation

1. Clone the repository:
  ```bash
git clone https://github.com/your-username/your-repo.git
cd your-repo
```

2. Install dependencies:
  ```bash
pip install fastapi uvicorn pandas pydantic
```

3. Ensure `adae.csv` is in the project directory or update the file path in the script.

## Running the API Locally

Start the API server using uvicorn:
  
  ```bash
uvicorn main:app --reload
```

The API will be available at `http://localhost:8000`

- Interactive API documentation: `http://localhost:8000/docs`
- Alternative documentation: `http://localhost:8000/redoc`

## API Endpoints

### 1. GET `/`
Returns a welcome message confirming the API is running.

**Response:**
  ```json
{
  "message": "Clinical Trial Data API is running"
}
```

### 2. POST `/ae-query`
Filter adverse events dynamically based on severity and/or treatment arm.

**Request Body:**
  ```json
{
  "severity": ["MILD", "MODERATE"],
  "treatment_arm": "Placebo"
}
```

**Response:**
  ```json
{
  "count": 145,
  "unique_subjects": ["01-701-1015", "01-701-1023", ...]
}
```

**Notes:**
  - Both fields are optional
- If a field is omitted, no filter is applied for that dimension
- `severity` accepts a list of values: "MILD", "MODERATE", "SEVERE"

### 3. GET `/subject-risk/{subject_id}`
Calculate safety risk score for a specific patient.

**Example Request:**
  ```
GET /subject-risk/01-701-1015
```

**Response:**
  ```json
{
  "subject_id": "01-701-1015",
  "risk_score": 8,
  "risk_category": "Medium"
}
```

**Risk Scoring:**
  - MILD: 1 point
- MODERATE: 3 points
- SEVERE: 5 points

**Risk Categories:**
  - Low: Score < 5
- Medium: 5 ≤ Score < 15
- High: Score ≥ 15

**Error Response (404):**
  ```json
{
  "detail": "Subject ID 'INVALID-ID' not found in the dataset"
}
```

## Testing

You can test the API using:
  
  1. **Interactive Docs**: Navigate to `http://localhost:8000/docs`
2. **cURL**:
  ```bash
curl -X POST "http://localhost:8000/ae-query" \
-H "Content-Type: application/json" \
-d '{"severity": ["MILD"], "treatment_arm": "Placebo"}'
```
3. **Python requests**:
  ```python
import requests
response = requests.post(
  "http://localhost:8000/ae-query",
  json={"severity": ["MILD", "MODERATE"]}
)
print(response.json())
```

## Project Structure

```
.
├── main.py              # FastAPI application
├── adae.csv            # Clinical trial adverse event data
└── README.md           # This file
```

## Author

Ortensia Vito

## Licence

MIT
