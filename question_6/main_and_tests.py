import pandas as pd
import json
import os
from typing import Dict, Optional

# Load the dataset
github_url = "https://raw.githubusercontent.com/OrtensiaV/technical-interview-april-2026/refs/heads/main/question_6/adae.csv"
df = pd.read_csv(github_url)

# Schema description for the LLM
SCHEMA_DESCRIPTION = """
You are analysing a clinical trial adverse events dataset with the following columns:

- AESEV: Adverse event severity. Contains values: MILD, MODERATE, SEVERE
  Users might ask about: "severity", "intensity", "how serious", "mild events", "severe reactions"

- AETERM: Specific adverse event term (the actual condition/symptom)
  Contains 242 different conditions like: DIARRHOEA, ERYTHEMA, APPLICATION SITE PRURITUS, HEADACHE, etc.
  Users might ask about: specific conditions, symptoms, "headache", "diarrhoea", "rash"

- AESOC: System Organ Class (body system affected)
  Contains 23 categories like: CARDIAC DISORDERS, GASTROINTESTINAL DISORDERS, SKIN AND SUBCUTANEOUS TISSUE DISORDERS
  Users might ask about: "cardiac", "heart", "skin", "gastrointestinal", "stomach", "body systems"

- ACTARM: Treatment arm the patient was assigned to
  Contains: Placebo, Xanomeline High Dose, Xanomeline Low Dose
  Users might ask about: "treatment group", "placebo", "high dose", "which drug"

- USUBJID: Unique subject identifier (patient ID)
  This is what it is counted and returned in results
"""


class ClinicalTrialDataAgent:
    """
    An agent that translates natural language questions into structured queries
    for the clinical trial adverse events dataset.
    """
    
    def __init__(self, dataframe: pd.DataFrame, use_openai: bool = False, api_key: Optional[str] = None):
        """
        Initialise the agent.
        
        Args:
            dataframe: The adverse events dataframe
            use_openai: Whether to use OpenAI API (requires api_key)
            api_key: OpenAI API key (optional, only needed if use_openai=True)
        """
        self.df = dataframe
        self.use_openai = use_openai
        self.api_key = api_key
        
        # Initialise OpenAI if requested
        if self.use_openai:
            if not api_key:
                raise ValueError("API key required when use_openai=True")
            try:
                from openai import OpenAI
                self.client = OpenAI(api_key=api_key)
            except ImportError:
                raise ImportError("Please install openai package: pip install openai")
    
    def parse_question(self, question: str) -> Dict[str, str]:
        """
        Parse a natural language question into structured query parameters.
        
        Args:
            question: User's natural language question
            
        Returns:
            Dictionary with 'target_column' and 'filter_value'
        """
        if self.use_openai:
            return self._parse_with_openai(question)
        else:
            return self._parse_with_mock(question)
    
    def _parse_with_mock(self, question: str) -> Dict[str, str]:
        """
        Mock LLM parser using rule-based logic.
        This demonstrates the logic flow without requiring an API key.
        """
        question_lower = question.lower()
        
        # Check for severity-related keywords
        severity_keywords = ['severity', 'serious', 'mild', 'moderate', 'severe', 'intensity']
        if any(keyword in question_lower for keyword in severity_keywords):
            if 'mild' in question_lower:
                return {'target_column': 'AESEV', 'filter_value': 'MILD'}
            elif 'moderate' in question_lower:
                return {'target_column': 'AESEV', 'filter_value': 'MODERATE'}
            elif 'severe' in question_lower:
                return {'target_column': 'AESEV', 'filter_value': 'SEVERE'}
            else:
                return {'target_column': 'AESEV', 'filter_value': None}
        
        # Check for treatment arm keywords
        treatment_keywords = ['treatment', 'arm', 'placebo', 'dose', 'drug']
        if any(keyword in question_lower for keyword in treatment_keywords):
            if 'placebo' in question_lower:
                return {'target_column': 'ACTARM', 'filter_value': 'Placebo'}
            elif 'high dose' in question_lower:
                return {'target_column': 'ACTARM', 'filter_value': 'Xanomeline High Dose'}
            elif 'low dose' in question_lower:
                return {'target_column': 'ACTARM', 'filter_value': 'Xanomeline Low Dose'}
        
        # Check for system organ class keywords
        soc_keywords = ['cardiac', 'heart', 'skin', 'gastrointestinal', 'stomach', 'system', 'organ']
        if any(keyword in question_lower for keyword in soc_keywords):
            for soc in self.df['AESOC'].unique():
                if soc and any(word in soc.lower() for word in question_lower.split()):
                    return {'target_column': 'AESOC', 'filter_value': soc}
            return {'target_column': 'AESOC', 'filter_value': None}
        
        # Check for specific adverse event terms
        for term in self.df['AETERM'].unique():
            if term and term.lower() in question_lower:
                return {'target_column': 'AETERM', 'filter_value': term}
        
        # Default: assume they're asking about a specific condition
        return {'target_column': 'AETERM', 'filter_value': None}
    
    def _parse_with_openai(self, question: str) -> Dict[str, str]:
        """
        Parse question using OpenAI API.
        """
        prompt = f"""
{SCHEMA_DESCRIPTION}

User question: "{question}"

Based on the question, determine:
1. Which column should be queried (AESEV, AETERM, AESOC, or ACTARM)
2. What value to filter for (if specific value mentioned)

Respond ONLY with a JSON object in this exact format:
{{"target_column": "COLUMN_NAME", "filter_value": "VALUE or null"}}

Examples:
- "Show me severe adverse events" → {{"target_column": "AESEV", "filter_value": "SEVERE"}}
- "Which patients had headaches?" → {{"target_column": "AETERM", "filter_value": "HEADACHE"}}
- "Cardiac problems" → {{"target_column": "AESOC", "filter_value": "CARDIAC DISORDERS"}}
- "Give me the subjects who had adverse events of moderate severity" → {{"target_column": "AESEV", "filter_value": "MODERATE"}}

Important: 
- For severity, use exact values: MILD, MODERATE, or SEVERE (all caps)
- For AETERM, use the exact term from the dataset (all caps, e.g., DIARRHOEA, HEADACHE)
- For AESOC, match the full system name (e.g., CARDIAC DISORDERS, SKIN AND SUBCUTANEOUS TISSUE DISORDERS)
- If no specific value is mentioned, set filter_value to null
"""
        
        try:
            response = self.client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "You are a clinical data query assistant. Respond only with valid JSON."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0,
                max_tokens=150
            )
            
            result_text = response.choices[0].message.content.strip()
            
            # Remove markdown code blocks if present
            if result_text.startswith('```'):
                result_text = result_text.split('```')[1]
                if result_text.startswith('json'):
                    result_text = result_text[4:]
                result_text = result_text.strip()
            
            result = json.loads(result_text)
            
            # Handle null values
            if result.get('filter_value') == 'null' or result.get('filter_value') is None:
                result['filter_value'] = None
            
            return result
            
        except Exception as e:
            print(f"OpenAI API error: {e}")
            print("Falling back to mock parser")
            return self._parse_with_mock(question)
    
    def execute_query(self, parsed_query: Dict[str, str]) -> Dict[str, any]:
        """
        Execute the parsed query on the dataframe.
        
        Args:
            parsed_query: Dictionary with 'target_column' and 'filter_value'
            
        Returns:
            Dictionary with 'count' and 'unique_subjects'
        """
        target_column = parsed_query['target_column']
        filter_value = parsed_query['filter_value']
        
        # Validate column exists
        if target_column not in self.df.columns:
            return {
                'error': f"Column {target_column} not found in dataset",
                'count': 0,
                'unique_subjects': []
            }
        
        # Apply filter if value specified
        if filter_value:
            filtered_df = self.df[self.df[target_column] == filter_value]
        else:
            # No specific value, return all records for that column
            filtered_df = self.df[self.df[target_column].notna()]
        
        # Get unique subjects
        unique_subjects = filtered_df['USUBJID'].unique().tolist()
        
        return {
            'target_column': target_column,
            'filter_value': filter_value,
            'count': len(unique_subjects),
            'unique_subjects': unique_subjects
        }
    
    def ask(self, question: str) -> Dict[str, any]:
        """
        Main method: Ask a question in natural language and get results.
        
        Args:
            question: Natural language question
            
        Returns:
            Query results with count and subject IDs
        """
        print(f"\nQuestion: {question}")
        
        # Step 1: Parse the question
        parsed = self.parse_question(question)
        print(f"Parsed as: {parsed}")
        
        # Step 2: Execute the query
        results = self.execute_query(parsed)
        print(f"Results: Found {results.get('count', 0)} unique subjects")
        
        return results


# Test the agent
print("ClinicalTrialDataAgent class created successfully!")

## Set the OpenAI API key (if you have quota available)
#api_key = 'your_openai_api_key'
## Create the agent
#agent = ClinicalTrialDataAgent(df, use_openai=True, api_key=api_key)
## Test with the example from the exercise
#result = agent.ask("give me the subjects who had adverse events of moderate severity")
#print(f"\nFound {result['count']} subjects")
#print(f"First 10 subjecct IDs: {result['unique_subjects'][:10]}")

# Use the mock parser for the rest of the exercise
agent = ClinicalTrialDataAgent(df, use_openai=False)

# Test script with queries

print("Clinical Trial Assistant - Test queries")

# Create the agent (using mock parser to avoid API costs)
agent = ClinicalTrialDataAgent(df, use_openai=False)

# Test Query 1: Severity-based query (from the exercise example)
print("Test Query 1: Severity-based filtering")
result1 = agent.ask("Give me the subjects who had adverse events of moderate severity")
print(f"\nSummary:")
print(f"  - Total subjects found: {result1['count']}")
print(f"  - First 5 subject IDs: {result1['unique_subjects'][:5]}")
print("\n")

# Test Query 2: Specific condition query
print("Test Query 2: Specific adverse event term")
result2 = agent.ask("Which patients experienced diarrhoea?")
print(f"\nSummary:")
print(f"  - Total subjects found: {result2['count']}")
print(f"  - First 5 subject IDs: {result2['unique_subjects'][:5]}")
print("\n")

# Test Query 3: System organ class query
print("Test Query 3: Body system filtering")
result3 = agent.ask("Show me patients with cardiac disorders")
print(f"\nSummary:")
print(f"  - Total subjects found: {result3['count']}")
print(f"  - First 5 subject IDs: {result3['unique_subjects'][:5]}")
print("\n")

# Test Query 4: Treatment arm query
print("Test Query 4: Treatment arm")
result4 = agent.ask("Which subjects were on placebo?")
print(f"\nSummary:")
print(f"  - Total subjects found: {result4['count']}")
print(f"  - First 5 subject IDs: {result4['unique_subjects'][:5]}")
print("\n")

# Test Query 5: Severe events
print("Test Query 5: Severe events")
result5 = agent.ask("Show me all severe adverse events")
print(f"\nSummary:")
print(f"  - Total subjects found: {result5['count']}")
print(f"  - First 5 subject IDs: {result5['unique_subjects'][:5]}")
print("\n")

