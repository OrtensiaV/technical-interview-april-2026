"""
Clinical Trial Data API
FastAPI application for querying and analysing clinical trial adverse event data.
"""

import pandas as pd
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional, List
import uvicorn

# ============================================================================
# DATA LOADING
# ============================================================================

# Load dataset (update path as needed for local vs GitHub deployment)
try:
    # For local execution
    df = pd.read_csv('adae.csv')
    print(f"Dataset loaded successfully: {len(df)} records")
except FileNotFoundError:
    # For GitHub/remote execution
    github_url = "https://raw.githubusercontent.com/your-username/your-repo/main/adae.csv"
    df = pd.read_csv(github_url)
    print(f"Dataset loaded from GitHub: {len(df)} records")

# ============================================================================
# PYDANTIC MODELS
# ============================================================================

class AEQueryRequest(BaseModel):
    """Request model for adverse event filtering"""
    severity: Optional[List[str]] = None
    treatment_arm: Optional[str] = None

# ============================================================================
# FASTAPI APPLICATION
# ============================================================================

app = FastAPI(
    title="Clinical Trial Data API",
    description="API for querying and analysing clinical trial adverse event data",
    version="1.0.0"
)

# ============================================================================
# ENDPOINTS
# ============================================================================

@app.get("/")
def read_root():
    """Welcome endpoint"""
    return {"message": "Clinical Trial Data API is running"}


@app.post("/ae-query")
def query_adverse_events(request: AEQueryRequest):
    """
    Filter adverse events based on severity and/or treatment arm.
    
    Args:
        request: AEQueryRequest containing optional severity list and treatment_arm
    
    Returns:
        JSON with count of matching records and list of unique subject IDs
    """
    # Start with full dataset
    filtered_df = df.copy()
    
    # Apply severity filter if provided
    if request.severity is not None and len(request.severity) > 0:
        filtered_df = filtered_df[filtered_df['AESEV'].isin(request.severity)]
    
    # Apply treatment arm filter if provided
    if request.treatment_arm is not None:
        filtered_df = filtered_df[filtered_df['ACTARM'] == request.treatment_arm]
    
    # Get unique subject IDs
    unique_subjects = filtered_df['USUBJID'].unique().tolist()
    
    return {
        "count": len(filtered_df),
        "unique_subjects": unique_subjects
    }


@app.get("/subject-risk/{subject_id}")
def get_subject_risk(subject_id: str):
    """
    Calculate safety risk score for a specific subject.
    
    Scoring:
    - MILD: 1 point
    - MODERATE: 3 points
    - SEVERE: 5 points
    
    Risk Categories:
    - Low: Score < 5
    - Medium: 5 <= Score < 15
    - High: Score >= 15
    
    Args:
        subject_id: Unique subject identifier
    
    Returns:
        JSON with subject_id, risk_score, and risk_category
    
    Raises:
        HTTPException: 404 if subject_id not found
    """
    # Filter data for specific subject
    subject_data = df[df['USUBJID'] == subject_id]
    
    # Check if subject exists
    if subject_data.empty:
        raise HTTPException(
            status_code=404,
            detail=f"Subject ID '{subject_id}' not found in the dataset"
        )
    
    # Define severity weights
    severity_weights = {
        'MILD': 1,
        'MODERATE': 3,
        'SEVERE': 5
    }
    
    # Calculate risk score
    risk_score = 0
    for severity in subject_data['AESEV']:
        risk_score += severity_weights.get(severity, 0)
    
    # Determine risk category
    if risk_score < 5:
        risk_category = "Low"
    elif risk_score < 15:
        risk_category = "Medium"
    else:
        risk_category = "High"
    
    return {
        "subject_id": subject_id,
        "risk_score": risk_score,
        "risk_category": risk_category
    }

# ============================================================================
# SERVER STARTUP
# ============================================================================

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
