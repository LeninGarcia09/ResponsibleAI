"""
Financial Loan Decision System - Synthetic Loan Application Data Generator
Generates loan applications with demographic data for fairness testing

Usage:
    python generate_loan_data.py --num_applications 10000 --output_dir ./sample_data
"""

import pandas as pd
import numpy as np
from faker import Faker
from datetime import datetime, timedelta
import json
import os
import argparse
from typing import List, Dict


class LoanDataGenerator:
    """Generate synthetic loan application data for fairness demo"""
    
    def __init__(self, seed: int = 42):
        self.fake = Faker()
        Faker.seed(seed)
        np.random.seed(seed)
        
        self.age_groups = ['18-25', '26-35', '36-50', '51-65', '65+']
        self.genders = ['Male', 'Female']
        self.ethnicities = ['White', 'Black', 'Hispanic', 'Asian', 'Other']
        self.employment_types = ['Full-time', 'Part-time', 'Self-employed', 'Contract']
        self.education_levels = ['High School', 'Some College', 'Bachelor', 'Master', 'PhD']
        
    def generate_applicant_demographics(self, num_applications: int) -> pd.DataFrame:
        """Generate applicant demographic information"""
        applicants = []
        
        for i in range(num_applications):
            # Age group influences other factors
            age_group = np.random.choice(self.age_groups, p=[0.10, 0.30, 0.35, 0.20, 0.05])
            
            if age_group == '18-25':
                age = np.random.randint(18, 26)
                education_weights = [0.35, 0.40, 0.20, 0.05, 0.00]
                employment_weights = [0.40, 0.30, 0.15, 0.15]
            elif age_group == '26-35':
                age = np.random.randint(26, 36)
                education_weights = [0.15, 0.25, 0.40, 0.18, 0.02]
                employment_weights = [0.60, 0.15, 0.15, 0.10]
            elif age_group == '36-50':
                age = np.random.randint(36, 51)
                education_weights = [0.12, 0.20, 0.38, 0.25, 0.05]
                employment_weights = [0.65, 0.10, 0.20, 0.05]
            elif age_group == '51-65':
                age = np.random.randint(51, 66)
                education_weights = [0.20, 0.25, 0.30, 0.20, 0.05]
                employment_weights = [0.60, 0.10, 0.25, 0.05]
            else:
                age = np.random.randint(65, 80)
                education_weights = [0.30, 0.30, 0.25, 0.12, 0.03]
                employment_weights = [0.20, 0.15, 0.50, 0.15]
            
            applicant = {
                'application_id': f'LA{i+1:06d}',
                'age': age,
                'age_group': age_group,
                'gender': np.random.choice(self.genders),
                'ethnicity': np.random.choice(self.ethnicities, p=[0.60, 0.13, 0.18, 0.06, 0.03]),
                'education': np.random.choice(self.education_levels, p=education_weights),
                'employment_type': np.random.choice(self.employment_types, p=employment_weights),
                'marital_status': np.random.choice(['Single', 'Married', 'Divorced', 'Widowed'], 
                                                   p=[0.35, 0.50, 0.12, 0.03]),
            }
            applicants.append(applicant)
        
        return pd.DataFrame(applicants)
    
    def generate_financial_profile(self, demographics: pd.DataFrame) -> pd.DataFrame:
        """Generate financial information for each applicant"""
        financial_data = []
        
        for _, applicant in demographics.iterrows():
            age = applicant['age']
            education = applicant['education']
            employment = applicant['employment_type']
            
            # Income influenced by age, education, employment
            base_income = {
                'High School': 35000,
                'Some College': 42000,
                'Bachelor': 65000,
                'Master': 85000,
                'PhD': 95000,
            }[education]
            
            # Age experience bonus
            age_multiplier = 1.0 + ((age - 18) / 100) if age < 60 else 1.4
            
            # Employment type adjustment
            employment_multiplier = {
                'Full-time': 1.0,
                'Part-time': 0.6,
                'Self-employed': 1.2,
                'Contract': 0.9,
            }[employment]
            
            annual_income = int(base_income * age_multiplier * employment_multiplier * np.random.uniform(0.8, 1.3))
            
            # Credit score influenced by age and income
            credit_base = 650 + (age - 18) * 2  # Older = higher baseline
            credit_income_boost = (annual_income - 35000) / 2000
            credit_score = int(np.clip(credit_base + credit_income_boost + np.random.normal(0, 50), 300, 850))
            
            # Loan amount (typically 0.5-2x annual income for personal loans)
            loan_amount = int(annual_income * np.random.uniform(0.3, 2.5))
            loan_amount = (loan_amount // 1000) * 1000  # Round to thousands
            
            # Existing debts
            monthly_debt = int(annual_income * np.random.uniform(0.10, 0.45) / 12)
            
            # Employment length (years) - ensure minimum of 1 to avoid randint error
            max_employment_years = max(1, min(age - 18, 25))
            employment_length = np.random.randint(0, max_employment_years)
            
            # Savings/assets
            savings = int(annual_income * np.random.uniform(0.1, 3.0) * (age / 50))
            
            financial = {
                **applicant.to_dict(),
                'annual_income': annual_income,
                'monthly_income': annual_income // 12,
                'loan_amount_requested': loan_amount,
                'loan_purpose': np.random.choice(['Debt Consolidation', 'Home Improvement', 
                                                 'Medical', 'Business', 'Other'], 
                                                p=[0.35, 0.25, 0.15, 0.15, 0.10]),
                'credit_score': credit_score,
                'monthly_debt_payments': monthly_debt,
                'debt_to_income_ratio': round((monthly_debt / (annual_income/12)) * 100, 2),
                'employment_length_years': employment_length,
                'savings': savings,
                'num_credit_lines': np.random.randint(1, 15),
                'num_delinquencies': np.random.choice([0, 0, 0, 1, 2], p=[0.70, 0.15, 0.10, 0.03, 0.02]),
                'home_ownership': np.random.choice(['Rent', 'Own', 'Mortgage'], p=[0.35, 0.25, 0.40]),
            }
            financial_data.append(financial)
        
        return pd.DataFrame(financial_data)
    
    def generate_loan_decisions(self, applications: pd.DataFrame) -> pd.DataFrame:
        """Generate ground truth loan decisions based on financial factors"""
        decisions = []
        
        for _, app in applications.iterrows():
            # Decision factors (no demographic factors - this is the fair baseline)
            score = 0
            
            # Credit score (0-40 points)
            if app['credit_score'] >= 750:
                score += 40
            elif app['credit_score'] >= 700:
                score += 35
            elif app['credit_score'] >= 650:
                score += 25
            elif app['credit_score'] >= 600:
                score += 15
            else:
                score += 5
            
            # Debt-to-income ratio (0-30 points)
            dti = app['debt_to_income_ratio']
            if dti < 20:
                score += 30
            elif dti < 30:
                score += 25
            elif dti < 40:
                score += 15
            elif dti < 50:
                score += 5
            else:
                score += 0
            
            # Income stability (0-15 points)
            if app['employment_length_years'] >= 5:
                score += 15
            elif app['employment_length_years'] >= 2:
                score += 10
            else:
                score += 5
            
            # Savings/assets (0-15 points)
            savings_ratio = app['savings'] / app['annual_income']
            if savings_ratio >= 1.0:
                score += 15
            elif savings_ratio >= 0.5:
                score += 10
            elif savings_ratio >= 0.2:
                score += 5
            
            # Delinquencies penalty
            score -= app['num_delinquencies'] * 10
            
            # Final score (0-100)
            final_score = max(0, min(100, score))
            
            # Decision threshold (with some noise to create realistic variation)
            threshold = 60 + np.random.normal(0, 5)
            approved = final_score >= threshold
            
            # Interest rate (approved loans only)
            if approved:
                base_rate = 8.0
                credit_adjustment = (750 - app['credit_score']) / 50
                interest_rate = round(base_rate + credit_adjustment + np.random.uniform(-0.5, 0.5), 2)
                interest_rate = max(5.0, min(25.0, interest_rate))
            else:
                interest_rate = None
            
            decision = {
                **app.to_dict(),
                'risk_score': round(final_score, 2),
                'decision': 'Approved' if approved else 'Denied',
                'interest_rate': interest_rate,
                'decision_date': (datetime.now() - timedelta(days=np.random.randint(0, 365))).isoformat(),
            }
            decisions.append(decision)
        
        return pd.DataFrame(decisions)
    
    def add_biased_predictions(self, applications: pd.DataFrame) -> pd.DataFrame:
        """Add biased model predictions for comparison (before fairness interventions)"""
        biased_preds = []
        
        for _, app in applications.iterrows():
            # Start with fair risk score
            base_score = app['risk_score']
            
            # Add demographic bias (this is what we want to fix!)
            bias_adjustment = 0
            
            # Age bias: younger applicants penalized more heavily
            if app['age_group'] in ['18-25']:
                bias_adjustment -= 12
            elif app['age_group'] in ['26-35']:
                bias_adjustment -= 8
            
            # Gender bias: historical data might show male-favoring bias
            # (simulating historical bias, not endorsing it!)
            if app['gender'] == 'Female':
                bias_adjustment -= 10
            
            # Biased score
            biased_score = base_score + bias_adjustment + np.random.normal(0, 2)
            biased_score = max(0, min(100, biased_score))
            
            # Biased decision
            biased_threshold = 60
            biased_approved = biased_score >= biased_threshold
            
            pred = {
                **app.to_dict(),
                'biased_risk_score': round(biased_score, 2),
                'biased_decision': 'Approved' if biased_approved else 'Denied',
                'bias_present': abs(bias_adjustment) > 0,
            }
            biased_preds.append(pred)
        
        return pd.DataFrame(biased_preds)


def main():
    parser = argparse.ArgumentParser(description='Generate synthetic loan application data')
    parser.add_argument('--num_applications', type=int, default=10000, 
                       help='Number of loan applications to generate')
    parser.add_argument('--output_dir', type=str, default='./sample_data', 
                       help='Output directory')
    parser.add_argument('--seed', type=int, default=42, help='Random seed')
    
    args = parser.parse_args()
    
    # Create output directory
    os.makedirs(args.output_dir, exist_ok=True)
    
    print(f"Generating {args.num_applications} synthetic loan applications...")
    
    # Generate data
    generator = LoanDataGenerator(seed=args.seed)
    
    print("Step 1/4: Generating applicant demographics...")
    demographics = generator.generate_applicant_demographics(args.num_applications)
    
    print("Step 2/4: Generating financial profiles...")
    financial = generator.generate_financial_profile(demographics)
    
    print("Step 3/4: Generating fair loan decisions...")
    decisions = generator.generate_loan_decisions(financial)
    
    print("Step 4/4: Adding biased predictions for comparison...")
    final_data = generator.add_biased_predictions(decisions)
    
    # Save datasets
    output_file = os.path.join(args.output_dir, 'loan_applications.csv')
    final_data.to_csv(output_file, index=False)
    print(f"✓ Saved loan applications to: {output_file}")
    
    # Generate summary statistics
    summary = {
        'total_applications': len(final_data),
        'demographics': {
            'age_groups': final_data['age_group'].value_counts().to_dict(),
            'genders': final_data['gender'].value_counts().to_dict(),
            'ethnicities': final_data['ethnicity'].value_counts().to_dict(),
        },
        'financial_summary': {
            'avg_income': int(final_data['annual_income'].mean()),
            'avg_credit_score': int(final_data['credit_score'].mean()),
            'avg_dti_ratio': round(final_data['debt_to_income_ratio'].mean(), 2),
        },
        'fair_decisions': {
            'approval_rate': round(final_data[final_data['decision'] == 'Approved'].shape[0] / len(final_data), 3),
            'avg_interest_rate': round(final_data['interest_rate'].mean(), 2),
        },
        'bias_analysis': {
            'biased_approval_rate': round(final_data[final_data['biased_decision'] == 'Approved'].shape[0] / len(final_data), 3),
            'approval_rate_male': round(final_data[(final_data['gender'] == 'Male') & (final_data['biased_decision'] == 'Approved')].shape[0] / 
                                       final_data[final_data['gender'] == 'Male'].shape[0], 3),
            'approval_rate_female': round(final_data[(final_data['gender'] == 'Female') & (final_data['biased_decision'] == 'Approved')].shape[0] / 
                                         final_data[final_data['gender'] == 'Female'].shape[0], 3),
        },
        'generation_timestamp': datetime.now().isoformat(),
    }
    
    # Calculate disparate impact
    summary['bias_analysis']['disparate_impact'] = round(
        summary['bias_analysis']['approval_rate_female'] / summary['bias_analysis']['approval_rate_male'], 3
    )
    
    summary_file = os.path.join(args.output_dir, 'data_summary.json')
    with open(summary_file, 'w') as f:
        json.dump(summary, f, indent=2)
    print(f"✓ Saved summary statistics to: {summary_file}")
    
    # Print summary
    print("\n" + "="*60)
    print("DATA GENERATION SUMMARY")
    print("="*60)
    print(f"Total Applications: {summary['total_applications']}")
    print(f"\nFinancial Profile:")
    print(f"  Average Income: ${summary['financial_summary']['avg_income']:,}")
    print(f"  Average Credit Score: {summary['financial_summary']['avg_credit_score']}")
    print(f"  Average DTI Ratio: {summary['financial_summary']['avg_dti_ratio']}%")
    print(f"\nFair Model:")
    print(f"  Approval Rate: {summary['fair_decisions']['approval_rate']*100:.1f}%")
    print(f"\nBiased Model (Before Mitigation):")
    print(f"  Male Approval Rate: {summary['bias_analysis']['approval_rate_male']*100:.1f}%")
    print(f"  Female Approval Rate: {summary['bias_analysis']['approval_rate_female']*100:.1f}%")
    print(f"  Disparate Impact: {summary['bias_analysis']['disparate_impact']:.3f} {'⚠️ BELOW 0.8 THRESHOLD' if summary['bias_analysis']['disparate_impact'] < 0.8 else '✓ Compliant'}")
    print("="*60)
    print(f"\n✓ Data generation complete! Files saved to: {args.output_dir}")


if __name__ == '__main__':
    main()
