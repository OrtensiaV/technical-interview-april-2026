"""
Development and Testing Code for Clinical Trial Data API
Contains all test cases and development experiments.
"""

import pandas as pd
from fastapi import HTTPException
from pydantic import BaseModel
from typing import Optional, List

# Import the app and models from main (if testing separately)
# from main import app, AEQueryRequest, read_root, query_adverse_events, get_subject_risk

# Load dataset from GitHub for testing
github_url = "https://raw.githubusercontent.com/your-username/your-repo/main/adae.csv"

try:
    df = pd.read_csv(github_url)
    print(f"Dataset loaded successfully: {len(df)} records")
    print(f"Columns: {list(df.columns)}")
except Exception as e:
    print(f"Error loading dataset: {e}")
    df = pd.DataFrame()

# Pydantic models (for standalone testing)
class AEQueryRequest(BaseModel):
    """Request model for adverse event filtering"""
    severity: Optional[List[str]] = None
    treatment_arm: Optional[str] = None

# Endpoint functions (copied for standalone testing)
def read_root():
    """Welcome endpoint"""
    return {"message": "Clinical Trial Data API is running"}


def query_adverse_events(request: AEQueryRequest):
    """Filter adverse events based on severity and/or treatment arm"""
    filtered_df = df.copy()
    
    if request.severity is not None and len(request.severity) > 0:
        filtered_df = filtered_df[filtered_df['AESEV'].isin(request.severity)]
    
    if request.treatment_arm is not None:
        filtered_df = filtered_df[filtered_df['ACTARM'] == request.treatment_arm]
    
    unique_subjects = filtered_df['USUBJID'].unique().tolist()
    
    return {
        "count": len(filtered_df),
        "unique_subjects": unique_subjects
    }


def get_subject_risk(subject_id: str):
    """Calculate safety risk score for a specific subject"""
    subject_data = df[df['USUBJID'] == subject_id]
    
    if subject_data.empty:
        raise HTTPException(
            status_code=404,
            detail=f"Subject ID '{subject_id}' not found in the dataset"
        )
    
    severity_weights = {'MILD': 1, 'MODERATE': 3, 'SEVERE': 5}
    
    risk_score = 0
    for severity in subject_data['AESEV']:
        risk_score += severity_weights.get(severity, 0)
    
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

# Test cases
print("\n")
print("Testing endpoint 1: GET /")
result = read_root()
print(f"Result: {result}")

print("\n")
print("Testing endpoint 2: POST /ae-query")

# Test Case 1: Filter by severity and treatment arm
print("\nTest 1: Severity=['MILD', 'MODERATE'] and Treatment='Placebo'")
test_request_1 = AEQueryRequest(
    severity=["MILD", "MODERATE"],
    treatment_arm="Placebo"
)
result_1 = query_adverse_events(test_request_1)
print(f"Count: {result_1['count']}")
print(f"Number of unique subjects: {len(result_1['unique_subjects'])}")
print(f"First 5 subjects: {result_1['unique_subjects'][:5]}")

# Test Case 2: Filter by severity only
print("\nTest 2: Severity=['SEVERE'] only")
test_request_2 = AEQueryRequest(severity=["SEVERE"])
result_2 = query_adverse_events(test_request_2)
print(f"Count: {result_2['count']}")
print(f"Number of unique subjects: {len(result_2['unique_subjects'])}")

# Test Case 3: Filter by treatment arm only
print("\nTest 3: Treatment='Xanomeline High Dose' only")
test_request_3 = AEQueryRequest(treatment_arm="Xanomeline High Dose")
result_3 = query_adverse_events(test_request_3)
print(f"Count: {result_3['count']}")
print(f"Number of unique subjects: {len(result_3['unique_subjects'])}")

# Test Case 4: No filters
print("\nTest 4: No filters (should return all records)")
test_request_4 = AEQueryRequest()
result_4 = query_adverse_events(test_request_4)
print(f"Count: {result_4['count']}")
print(f"Total unique subjects: {len(result_4['unique_subjects'])}")

print("\n")
print("Testing endpoint 3: GET /subject-risk/{subject_id}")

# Test Case 1: Example from exercise
print("\nTest 1: Subject '01-701-1015'")
try:
    result_1 = get_subject_risk("01-701-1015")
    print(f"Subject ID: {result_1['subject_id']}")
    print(f"Risk Score: {result_1['risk_score']}")
    print(f"Risk Category: {result_1['risk_category']}")
except HTTPException as e:
    print(f"Error: {e.detail}")

# Test Case 2: Valid subject from dataset
print("\nTest 2: Using first subject from dataset")
if not df.empty:
    valid_subject = df['USUBJID'].iloc[0]
    result_2 = get_subject_risk(valid_subject)
    print(f"Subject ID: {result_2['subject_id']}")
    print(f"Risk Score: {result_2['risk_score']}")
    print(f"Risk Category: {result_2['risk_category']}")

# Test Case 3: Invalid subject (error handling)
print("\nTest 3: Invalid subject ID (should return 404)")
try:
    result_3 = get_subject_risk("INVALID-ID-999")
except HTTPException as e:
    print(f"Error caught successfully: {e.detail}")

# Test Case 4: Risk distribution analysis
print("\nTest 4: Risk distribution across first 10 subjects")
if not df.empty:
    all_subjects = df['USUBJID'].unique()
    risk_distribution = {"Low": 0, "Medium": 0, "High": 0}
    
    for subject in all_subjects[:10]:
        result = get_subject_risk(subject)
        risk_distribution[result['risk_category']] += 1
    
    print("Risk distribution:")
    for category, count in risk_distribution.items():
        print(f"  {category}: {count}")

