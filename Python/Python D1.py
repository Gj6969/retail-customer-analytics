import pandas as pd
import numpy as np

df = pd.read_csv("C:/Users/GAUTAM JAIN/Downloads/cleaned_customer_data.csv")
# MANUAL MIN MAX SCALER
def min_max(series):
    return (series - series.min()) / (series.max() - series.min())

# BINARY VARIABLES
df['discount_flag'] = df['discount_applied'].map({
    'Yes':1,
    'No':0
})

df['promo_flag'] = df['promo_code_used'].map({
    'Yes':1,
    'No':0
})

df['subscription_flag'] = df['subscription_status'].map({
    'Yes':1,
    'No':0
})
# PURCHASE FREQUENCY SCORE
frequency_map = {
    'Weekly':7,
    'Bi-Weekly':6,
    'Fortnightly':5,
    'Monthly':4,
    'Quarterly':3,
    'Every 3 Months':2,
    'Annually':1
}

df['frequency_score'] = df['frequency_of_purchases'].map(
    frequency_map
)
# NORMALIZATION
df['purchase_norm'] = min_max(
    df['purchase_amount_usd']
)

df['previous_purchase_norm'] = min_max(
    df['previous_purchases']
)

df['rating_norm'] = min_max(
    df['review_rating']
)

df['frequency_norm'] = min_max(
    df['frequency_score']
)

# CUSTOMER VALUE SCORE
df['customer_value_score'] = (
      0.40 * df['purchase_norm']
    + 0.35 * df['previous_purchase_norm']
    + 0.25 * df['frequency_norm']
)
# SATISFACTION FLAG
df['satisfaction_flag'] = np.where(
    df['review_rating'] >= 4,
    'Satisfied',
    np.where(
        df['review_rating'] >= 3,
        'Neutral',
        'Unsatisfied'
    )
)

# LOYALTY SCORE A
# BEHAVIORAL LOYALTY
df['loyalty_score_A'] = (
      0.50 * df['previous_purchase_norm']
    + 0.30 * df['frequency_norm']
    + 0.20 * df['subscription_flag']
)
# PROMOTION DEPENDENCY SCORE
inverse_loyalty = (
    1 - df['previous_purchase_norm']
)

df['dependency_score'] = (
      0.40 * df['discount_flag']
    + 0.40 * df['promo_flag']
    + 0.20 * inverse_loyalty
)
# LOYALTY SCORE B
# ECONOMIC LOYALTY
df['loyalty_score_B'] = (
      0.40 * df['purchase_norm']
    + 0.40 * df['previous_purchase_norm']
    + 0.20 * (1 - df['dependency_score'])
)
# COMPARE LOYALTY DEFINITIONS
corr_A = df['loyalty_score_A'].corr(
    df['purchase_amount_usd']
)

corr_B = df['loyalty_score_B'].corr(
    df['purchase_amount_usd']
)

print("\nCorrelation with Revenue")
print("Loyalty A =", round(corr_A,4))
print("Loyalty B =", round(corr_B,4))

if corr_A > corr_B:
    df['final_loyalty_score'] = df['loyalty_score_A']
    selected_model = "A"
else:
    df['final_loyalty_score'] = df['loyalty_score_B']
    selected_model = "B"

print("\nSelected Loyalty Model:", selected_model)

# VALUE TIERS
df['value_tier'] = pd.qcut(
    df['customer_value_score'],
    q=4,
    labels=[
        'Bronze',
        'Silver',
        'Gold',
        'Platinum'
    ]
)
# ORGANIC DEMAND SCORE
df['organic_demand_scre'] = (
    df['customer_value_score']
    * (1 - df['dependency_score'])
)
# DYNAMIC THRESHOLDS

loyal_cutoff = df[
    'final_loyalty_score'
].quantile(0.75)

dependency_cutoff = df[
    'dependency_score'
].quantile(0.75)

value_cutoff = df[
    'customer_value_score'
].quantile(0.75)

# CUSTOMER SEGMENTATION
conditions = [

    (
        (df['final_loyalty_score'] >= loyal_cutoff)
        &
        (df['dependency_score'] < dependency_cutoff)
    ),

    (
        (df['dependency_score'] >= dependency_cutoff)
        &
        (df['final_loyalty_score'] < loyal_cutoff)
    ),

    (
        (df['satisfaction_flag'] == 'Satisfied')
        &
        (df['final_loyalty_score'] >=
         df['final_loyalty_score'].quantile(0.50))
    ),

    (
        (df['customer_value_score'] >= value_cutoff)
        &
        (df['satisfaction_flag'] == 'Unsatisfied')
    )
]

choices = [
    'Brand Loyalist',
    'Discount Addict',
    'High Potential',
    'Revenue At Risk'
]

df['customer_segment'] = np.select(
    conditions,
    choices,
    default='Dormant Buyer'
)


# PROMO RELIANT FLAG
df['promo_reliant_customer'] = np.where(
    df['dependency_score']
    >= dependency_cutoff,
    'Yes',
    'No'
)

summary = df.groupby(
    'customer_segment'
).agg({
    'customer_id':'count',
    'purchase_amount_usd':'mean',
    'previous_purchases':'mean',
    'review_rating':'mean'
})

print("\nSegment Summary")
print(summary)


output_path = r"C:\Users\GAUTAM JAIN\Downloads\customer_metrics_final.csv"

df.to_csv(
    output_path,
    index=False
)

print(f"\nFile Saved Successfully")
print(f"Location: {output_path}")

