USE CustomerRetention;
GO

/*QUERY 1
   CUSTOMER SEGMENT OVERVIEW*/

  SELECT
    customer_segment,
    COUNT(*) AS customers,
    ROUND(AVG(purchase_amount_usd),2) AS avg_spend,
    ROUND(AVG(final_loyalty_score),2) AS avg_loyalty,
    ROUND(AVG(dependency_score),2) AS avg_dependency
FROM customer_metrics_final
GROUP BY customer_segment
ORDER BY customers DESC;


/* 
  QUERY 2
   REVENUE BY SEGMENT
 */

SELECT
    customer_segment,
    SUM(purchase_amount_usd) AS revenue
FROM customer_metrics_final
GROUP BY customer_segment
ORDER BY revenue DESC;


/* =====================================================
   QUERY 3
   PROMOTION DEPENDENCY ANALYSIS
   ===================================================== */

SELECT
    promo_reliant_customer,
    COUNT(*) AS customers,
    ROUND(AVG(final_loyalty_score),2) AS avg_loyalty,
    ROUND(AVG(purchase_amount_usd),2) AS avg_spend
FROM customer_metrics_final
GROUP BY promo_reliant_customer;


/* =====================================================
   QUERY 4
   VALUE TIER ANALYSIS
   BUSINESS QUESTION:
   What predicts high customer value?
   ===================================================== */

SELECT
    value_tier,
    COUNT(*) AS customers,
    ROUND(AVG(previous_purchases),2) AS avg_previous_purchases,
    ROUND(AVG(review_rating),2) AS avg_rating,
    ROUND(AVG(final_loyalty_score),2) AS avg_loyalty,
    ROUND(AVG(dependency_score),2) AS avg_dependency
FROM customer_metrics_final
GROUP BY value_tier
ORDER BY avg_loyalty DESC;


/* =====================================================
   QUERY 5
   CATEGORY RETENTION ANALYSIS
   ===================================================== */

SELECT
    category,
    ROUND(AVG(previous_purchases),2) AS avg_previous_purchases,
    ROUND(AVG(final_loyalty_score),2) AS avg_loyalty,
    ROUND(AVG(dependency_score),2) AS avg_dependency,
    ROUND(AVG(purchase_amount_usd),2) AS avg_spend
FROM customer_metrics_final
GROUP BY category
ORDER BY avg_loyalty DESC;


/* =====================================================
   QUERY 6
   CATEGORY VS CUSTOMER SEGMENT
   ENTRY CATEGORY VS RETENTION CATEGORY
   ===================================================== */

SELECT
    category,
    customer_segment,
    COUNT(*) AS customers
FROM customer_metrics_final
GROUP BY
    category,
    customer_segment
ORDER BY
    category,
    customers DESC;


/* =====================================================
   QUERY 7
   GEOGRAPHIC OPPORTUNITY ANALYSIS
   ===================================================== */

SELECT
    location,
    COUNT(*) AS customers,
    ROUND(AVG(organic_demand_score),3) AS organic_demand,
    ROUND(AVG(purchase_amount_usd),2) AS avg_spend,
    ROUND(AVG(dependency_score),2) AS avg_dependency
FROM customer_metrics_final
GROUP BY location
HAVING COUNT(*) > 20
ORDER BY organic_demand DESC;


/* =====================================================
   QUERY 8
   UNDERLEVERAGED MARKETS
   HIGH ORGANIC DEMAND + LOW CUSTOMER COUNT
   ===================================================== */

SELECT TOP 15
    location,
    COUNT(*) AS customers,
    ROUND(AVG(organic_demand_score),3) AS organic_demand,
    ROUND(AVG(purchase_amount_usd),2) AS avg_spend
FROM customer_metrics_final
GROUP BY location
ORDER BY organic_demand DESC;


/* =====================================================
   QUERY 9
   IDEAL CUSTOMER PROFILE - GENDER
   ===================================================== */

SELECT
    gender,
    COUNT(*) AS customers,
    ROUND(AVG(final_loyalty_score),2) AS avg_loyalty,
    ROUND(AVG(purchase_amount_usd),2) AS avg_spend
FROM customer_metrics_final
WHERE value_tier = 'Platinum'
GROUP BY gender;


/* =====================================================
   QUERY 10
   IDEAL CUSTOMER PROFILE - CATEGORY
   ===================================================== */

SELECT
    category,
    COUNT(*) AS customers,
    ROUND(AVG(final_loyalty_score),2) AS avg_loyalty,
    ROUND(AVG(purchase_amount_usd),2) AS avg_spend
FROM customer_metrics_final
WHERE value_tier = 'Platinum'
GROUP BY category
ORDER BY customers DESC;


/* =====================================================
   QUERY 11
   IDEAL CUSTOMER PROFILE - PAYMENT METHOD
   ===================================================== */

SELECT
    payment_method,
    COUNT(*) AS customers,
    ROUND(AVG(final_loyalty_score),2) AS avg_loyalty,
    ROUND(AVG(purchase_amount_usd),2) AS avg_spend
FROM customer_metrics_final
WHERE value_tier = 'Platinum'
GROUP BY payment_method
ORDER BY customers DESC;


/* =====================================================
   QUERY 12
   IDEAL CUSTOMER PROFILE - SEASON
   ===================================================== */

SELECT
    season,
    COUNT(*) AS customers,
    ROUND(AVG(final_loyalty_score),2) AS avg_loyalty,
    ROUND(AVG(purchase_amount_usd),2) AS avg_spend
FROM customer_metrics_final
WHERE value_tier = 'Platinum'
GROUP BY season
ORDER BY customers DESC;


/* =====================================================
   QUERY 13
   REVENUE AT RISK
   ===================================================== */

SELECT
    customer_segment,
    COUNT(*) AS customers,
    SUM(purchase_amount_usd) AS revenue_at_risk,
    ROUND(AVG(review_rating),2) AS avg_rating
FROM customer_metrics_final
WHERE customer_segment = 'Revenue At Risk'
GROUP BY customer_segment;


/* =====================================================
   QUERY 14
   LOYALITY VS PROMOTION DEPENDENCY MATRIX
   ===================================================== */

SELECT
    CASE
        WHEN final_loyalty_score >= 0.7 THEN 'High Loyalty'
        ELSE 'Low Loyalty'
    END AS loyalty_group,

    CASE
        WHEN dependency_score >= 0.6 THEN 'High Dependency'
        ELSE 'Low Dependency'
    END AS dependency_group,

    COUNT(*) AS customers,
    ROUND(AVG(purchase_amount_usd),2) AS avg_spend
FROM customer_metrics_final
GROUP BY
    CASE
        WHEN final_loyalty_score >= 0.7 THEN 'High Loyalty'
        ELSE 'Low Loyalty'
    END,
    CASE
        WHEN dependency_score >= 0.6 THEN 'High Dependency'
        ELSE 'Low Dependency'
    END
ORDER BY customers DESC;