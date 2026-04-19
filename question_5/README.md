# Clinical Trial Data API

A RESTful API built with FastAPI for querying and analysing clinical trial adverse event data.

## Features

- Dynamic filtering of adverse events by severity and treatment arm
- Patient risk score calculation based on adverse event severity
- RESTful API design with comprehensive error handling

## Project Files

### main.py
Production-ready FastAPI application containing:
  - Complete API implementation
- All three endpoints (welcome, query, risk calculation)
- Data loading with fallback to GitHub
- Full documentation and error handling

**Usage**: Run this file to start the API server.

### dev_test_code.py
Development and testing suite containing:
  - Comprehensive test cases for all endpoints
- Data validation tests
- Edge case handling verification
- Example usage patterns

**Usage**: Run this file to verify all functionality works correctly before deployment.

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

3. Ensure `adae.csv` is in the project directory or update the file path in `main.py`.

## Running the API Locally

Start the API server using uvicorn:
  
  ```bash
uvicorn main:app --reload
```

The API will be available at `http://localhost:8000`

- Interactive API documentation: `http://localhost:8000/docs`
- Alternative documentation: `http://localhost:8000/redoc`

## Testing

Run the comprehensive test suite:
  
  ```bash
python dev_test_code.py
```

This will execute all test cases and display results for:
  - Welcome endpoint functionality
- Dynamic filtering with various parameter combinations
- Risk score calculations for multiple subjects
- Error handling for invalid inputs

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

## Development Workflow

1. **Make changes** to `main.py`
2. **Add corresponding tests** to `dev_test_code.py`
3. **Run tests** to verify functionality: `python dev_test_code.py`
4. **Start the server** to test interactively: `uvicorn main:app --reload`
5. **Use Swagger UI** at `http://localhost:8000/docs` for manual testing

## Additional Testing Methods

### Using cURL
```bash
curl -X POST "http://localhost:8000/ae-query" \
-H "Content-Type: application/json" \
-d '{"severity": ["MILD"], "treatment_arm": "Placebo"}'
```

### Using Python requests
```python
import requests
response = requests.post(
  "http://localhost:8000/ae-query",
  json={"severity": ["MILD", "MODERATE"]}
)
print(response.json())
```

## Author

Ortensia Vito

## Licence

MIT
```
