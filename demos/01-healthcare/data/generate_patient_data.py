"""
Healthcare Clinical Decision Support - Synthetic Patient Data Generator
Generates de-identified patient records for RAI demo

Usage:
    python generate_patient_data.py --num_patients 10000 --output_dir ./sample_data
"""

import pandas as pd
import numpy as np
from faker import Faker
from datetime import datetime, timedelta
import json
import os
import argparse
from typing import List, Dict


class PatientDataGenerator:
    """Generate synthetic patient data for emergency department triage demo"""
    
    def __init__(self, seed: int = 42):
        self.fake = Faker()
        Faker.seed(seed)
        np.random.seed(seed)
        
        # Medical conditions with associated symptoms and severity
        self.conditions = {
            'acute_coronary_syndrome': {
                'symptoms': ['chest_pain', 'shortness_of_breath', 'nausea', 'sweating'],
                'vital_signs': {'hr': (80, 120), 'bp_sys': (110, 150), 'temp': (98.0, 99.5)},
                'severity': 'high',
                'prevalence_by_age': {'18-30': 0.02, '31-50': 0.08, '51-70': 0.20, '70+': 0.35}
            },
            'anxiety_disorder': {
                'symptoms': ['chest_discomfort', 'rapid_heartbeat', 'dizziness', 'shortness_of_breath'],
                'vital_signs': {'hr': (90, 130), 'bp_sys': (120, 145), 'temp': (97.5, 98.8)},
                'severity': 'low',
                'prevalence_by_age': {'18-30': 0.15, '31-50': 0.12, '51-70': 0.08, '70+': 0.05}
            },
            'pneumonia': {
                'symptoms': ['cough', 'fever', 'shortness_of_breath', 'chest_pain'],
                'vital_signs': {'hr': (90, 115), 'bp_sys': (100, 130), 'temp': (100.5, 103.0)},
                'severity': 'medium',
                'prevalence_by_age': {'18-30': 0.05, '31-50': 0.08, '51-70': 0.15, '70+': 0.25}
            },
            'gastroesophageal_reflux': {
                'symptoms': ['chest_burning', 'nausea', 'difficulty_swallowing'],
                'vital_signs': {'hr': (65, 85), 'bp_sys': (110, 135), 'temp': (97.5, 98.6)},
                'severity': 'low',
                'prevalence_by_age': {'18-30': 0.10, '31-50': 0.18, '51-70': 0.22, '70+': 0.20}
            },
            'pulmonary_embolism': {
                'symptoms': ['chest_pain', 'shortness_of_breath', 'rapid_heartbeat', 'cough'],
                'vital_signs': {'hr': (100, 140), 'bp_sys': (90, 120), 'temp': (98.0, 99.5)},
                'severity': 'high',
                'prevalence_by_age': {'18-30': 0.01, '31-50': 0.03, '51-70': 0.08, '70+': 0.15}
            },
        }
        
        self.age_groups = ['18-30', '31-50', '51-70', '70+']
        self.ethnicities = ['White', 'Black', 'Hispanic', 'Asian', 'Other']
        self.genders = ['Male', 'Female']
        
    def generate_patient_demographics(self, num_patients: int) -> pd.DataFrame:
        """Generate patient demographic information"""
        patients = []
        
        for i in range(num_patients):
            age_group = np.random.choice(self.age_groups, p=[0.25, 0.35, 0.25, 0.15])
            
            # Age within group
            if age_group == '18-30':
                age = np.random.randint(18, 31)
            elif age_group == '31-50':
                age = np.random.randint(31, 51)
            elif age_group == '51-70':
                age = np.random.randint(51, 71)
            else:
                age = np.random.randint(71, 90)
            
            patient = {
                'patient_id': f'PT{i+1:06d}',
                'age': age,
                'age_group': age_group,
                'gender': np.random.choice(self.genders),
                'ethnicity': np.random.choice(self.ethnicities, p=[0.60, 0.13, 0.18, 0.06, 0.03]),
            }
            patients.append(patient)
        
        return pd.DataFrame(patients)
    
    def generate_clinical_cases(self, demographics: pd.DataFrame) -> pd.DataFrame:
        """Generate clinical cases with conditions and symptoms"""
        cases = []
        
        for _, patient in demographics.iterrows():
            # Select condition based on age group prevalence
            age_group = patient['age_group']
            condition_probs = [
                self.conditions[cond]['prevalence_by_age'][age_group] 
                for cond in self.conditions.keys()
            ]
            # Normalize probabilities
            total = sum(condition_probs)
            condition_probs = [p/total for p in condition_probs]
            
            condition_name = np.random.choice(list(self.conditions.keys()), p=condition_probs)
            condition = self.conditions[condition_name]
            
            # Generate vital signs within condition-specific ranges
            hr_min, hr_max = condition['vital_signs']['hr']
            bp_min, bp_max = condition['vital_signs']['bp_sys']
            temp_min, temp_max = condition['vital_signs']['temp']
            
            vital_signs = {
                'heart_rate': np.random.randint(hr_min, hr_max + 1),
                'blood_pressure_systolic': np.random.randint(bp_min, bp_max + 1),
                'blood_pressure_diastolic': np.random.randint(60, 95),
                'temperature': round(np.random.uniform(temp_min, temp_max), 1),
                'respiratory_rate': np.random.randint(12, 24),
                'oxygen_saturation': np.random.randint(92, 100),
            }
            
            # Generate symptoms
            symptoms = condition['symptoms'].copy()
            if np.random.random() < 0.3:  # 30% chance of additional symptom
                all_symptoms = ['fatigue', 'weakness', 'headache', 'back_pain']
                symptoms.append(np.random.choice(all_symptoms))
            
            # Medical history
            has_history = {
                'heart_disease': np.random.random() < 0.15 if patient['age'] > 50 else np.random.random() < 0.05,
                'diabetes': np.random.random() < 0.12 if patient['age'] > 40 else np.random.random() < 0.03,
                'hypertension': np.random.random() < 0.25 if patient['age'] > 50 else np.random.random() < 0.10,
                'smoking': np.random.random() < 0.18,
            }
            
            # Lab values (for certain conditions)
            lab_values = {}
            if 'acute_coronary_syndrome' in condition_name or 'pulmonary' in condition_name:
                lab_values['troponin'] = round(np.random.uniform(0.5, 3.0), 2) if condition['severity'] == 'high' else round(np.random.uniform(0.0, 0.3), 2)
                lab_values['d_dimer'] = round(np.random.uniform(200, 2000), 0) if 'pulmonary' in condition_name else round(np.random.uniform(0, 400), 0)
            
            case = {
                **patient.to_dict(),
                'condition': condition_name,
                'severity': condition['severity'],
                'symptoms': ','.join(symptoms),
                'chief_complaint': symptoms[0].replace('_', ' ').title(),
                **vital_signs,
                'history_heart_disease': has_history['heart_disease'],
                'history_diabetes': has_history['diabetes'],
                'history_hypertension': has_history['hypertension'],
                'history_smoking': has_history['smoking'],
                'lab_troponin': lab_values.get('troponin', None),
                'lab_d_dimer': lab_values.get('d_dimer', None),
                'triage_timestamp': (datetime.now() - timedelta(days=np.random.randint(0, 365))).isoformat(),
            }
            cases.append(case)
        
        return pd.DataFrame(cases)
    
    def generate_ai_predictions(self, cases: pd.DataFrame) -> pd.DataFrame:
        """Generate AI model predictions with confidence scores"""
        predictions = []
        
        for _, case in cases.iterrows():
            # Simulate AI prediction
            severity = case['severity']
            
            # Confidence varies by severity and patient factors
            if severity == 'high':
                confidence = np.random.uniform(0.75, 0.95)
                correct = np.random.random() < 0.90  # 90% accuracy for high severity
            elif severity == 'medium':
                confidence = np.random.uniform(0.60, 0.80)
                correct = np.random.random() < 0.85
            else:
                confidence = np.random.uniform(0.45, 0.70)
                correct = np.random.random() < 0.75
            
            # Predicted condition
            if correct:
                predicted_condition = case['condition']
            else:
                # Predict similar condition if wrong
                similar_conditions = {
                    'acute_coronary_syndrome': 'anxiety_disorder',
                    'anxiety_disorder': 'acute_coronary_syndrome',
                    'pneumonia': 'pulmonary_embolism',
                    'pulmonary_embolism': 'pneumonia',
                    'gastroesophageal_reflux': 'acute_coronary_syndrome',
                }
                predicted_condition = similar_conditions.get(case['condition'], case['condition'])
            
            pred = {
                **case.to_dict(),
                'predicted_condition': predicted_condition,
                'confidence_score': round(confidence, 3),
                'prediction_correct': correct,
                'recommended_action': 'immediate_cardiology_consult' if severity == 'high' else 'standard_evaluation',
            }
            predictions.append(pred)
        
        return pd.DataFrame(predictions)


def main():
    parser = argparse.ArgumentParser(description='Generate synthetic patient data for healthcare RAI demo')
    parser.add_argument('--num_patients', type=int, default=10000, help='Number of patients to generate')
    parser.add_argument('--output_dir', type=str, default='./sample_data', help='Output directory')
    parser.add_argument('--seed', type=int, default=42, help='Random seed')
    
    args = parser.parse_args()
    
    # Create output directory
    os.makedirs(args.output_dir, exist_ok=True)
    
    print(f"Generating {args.num_patients} synthetic patient records...")
    
    # Generate data
    generator = PatientDataGenerator(seed=args.seed)
    
    print("Step 1/3: Generating patient demographics...")
    demographics = generator.generate_patient_demographics(args.num_patients)
    
    print("Step 2/3: Generating clinical cases...")
    cases = generator.generate_clinical_cases(demographics)
    
    print("Step 3/3: Generating AI predictions...")
    predictions = generator.generate_ai_predictions(cases)
    
    # Save datasets
    output_file = os.path.join(args.output_dir, 'patient_cases.csv')
    predictions.to_csv(output_file, index=False)
    print(f"✓ Saved patient cases to: {output_file}")
    
    # Generate summary statistics
    summary = {
        'total_patients': len(predictions),
        'demographics': {
            'age_groups': predictions['age_group'].value_counts().to_dict(),
            'genders': predictions['gender'].value_counts().to_dict(),
            'ethnicities': predictions['ethnicity'].value_counts().to_dict(),
        },
        'conditions': predictions['condition'].value_counts().to_dict(),
        'severity_distribution': predictions['severity'].value_counts().to_dict(),
        'model_performance': {
            'overall_accuracy': round(predictions['prediction_correct'].mean(), 3),
            'average_confidence': round(predictions['confidence_score'].mean(), 3),
            'high_severity_accuracy': round(
                predictions[predictions['severity'] == 'high']['prediction_correct'].mean(), 3
            ),
        },
        'generation_timestamp': datetime.now().isoformat(),
    }
    
    summary_file = os.path.join(args.output_dir, 'data_summary.json')
    with open(summary_file, 'w') as f:
        json.dump(summary, f, indent=2)
    print(f"✓ Saved summary statistics to: {summary_file}")
    
    # Print summary
    print("\n" + "="*60)
    print("DATA GENERATION SUMMARY")
    print("="*60)
    print(f"Total Patients: {summary['total_patients']}")
    print(f"\nAge Distribution:")
    for age_group, count in summary['demographics']['age_groups'].items():
        print(f"  {age_group}: {count} ({count/summary['total_patients']*100:.1f}%)")
    print(f"\nModel Performance:")
    print(f"  Overall Accuracy: {summary['model_performance']['overall_accuracy']*100:.1f}%")
    print(f"  Average Confidence: {summary['model_performance']['average_confidence']*100:.1f}%")
    print(f"  High Severity Accuracy: {summary['model_performance']['high_severity_accuracy']*100:.1f}%")
    print("="*60)
    print(f"\n✓ Data generation complete! Files saved to: {args.output_dir}")


if __name__ == '__main__':
    main()
