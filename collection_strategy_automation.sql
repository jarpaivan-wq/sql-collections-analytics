-- =====================================================
-- COLLECTION STRATEGY AUTOMATION
-- =====================================================
-- File: collection_strategy_automation.sql
-- Author: Iván Jarpa
-- Date: January 2026
-- Version: 1.0
-- =====================================================

-- DESCRIPTION:
-- This query automates the assignment of contact strategies
-- for past-due accounts based on customer segment and days past due.
--
-- BUSINESS CONTEXT:
-- In collection operations with 10,000+ daily cases, manual
-- strategy assignment consumes valuable executive time.
-- This query encodes business policies to fully automate
-- that process.
--
-- IMPACT:
-- - 10,000 cases processed per day
-- - Assignment time: < 1 second per case
-- - 100% consistency in policy application
-- - Executives freed for high-value complex cases

-- =====================================================
-- DECISION MATRIX
-- =====================================================
--
-- PREMIUM SEGMENT (High-value customers):
--   ≤ 30 days past due  → Courteous call
--   ≤ 60 days past due  → Email + Personalized call
--   > 60 days past due  → Senior executive visit
--
-- STANDARD SEGMENT (Operational volume):
--   ≤ 30 days past due  → Automated email
--   ≤ 60 days past due  → Standard call
--   > 60 days past due  → Intensive collection
--
-- BASIC SEGMENT (Operational efficiency):
--   ≤ 60 days past due  → Mass SMS
--   > 60 days past due  → Legal action
--
-- =====================================================

-- =====================================================
-- PREREQUISITES
-- =====================================================
-- 
-- Required tables:
--   1. debtors: Customer information
--      - debtor_id (PK)
--      - name
--      - surname
--      - segment (VARCHAR: 'PREMIUM', 'STANDARD', 'BASIC')
--
--   2. debts: Debt information
--      - debt_id (PK)
--      - debtor_id (FK)
--      - days_past_due (INT)
--      - current_amount (DECIMAL)
--      - status (VARCHAR: 'CURRENT', 'PAST_DUE', 'CHARGED_OFF', 'PAID')
--
-- =====================================================

-- =====================================================
-- MAIN QUERY
-- =====================================================

SELECT
    d.debtor_id,
    d.name,
    d.surname,
    d.segment,
    de.days_past_due,
    de.current_amount,
    de.status,
    
    -- Strategy assignment based on segment and days past due
    CASE
        -- =====================================
        -- PREMIUM SEGMENT
        -- =====================================
        WHEN UPPER(TRIM(d.segment)) = 'PREMIUM' THEN
            CASE
                WHEN de.days_past_due <= 30 THEN 'COURTEOUS CALL'
                WHEN de.days_past_due <= 60 THEN 'EMAIL + CALL'
                ELSE 'SENIOR EXECUTIVE VISIT'
            END
            
        -- =====================================
        -- STANDARD SEGMENT
        -- =====================================
        WHEN UPPER(TRIM(d.segment)) = 'STANDARD' THEN
            CASE
                WHEN de.days_past_due <= 30 THEN 'AUTOMATED EMAIL'
                WHEN de.days_past_due <= 60 THEN 'STANDARD CALL'
                ELSE 'INTENSIVE COLLECTION'
            END
            
        -- =====================================
        -- BASIC SEGMENT (default)
        -- =====================================
        ELSE
            CASE
                WHEN de.days_past_due <= 60 THEN 'MASS SMS'
                ELSE 'LEGAL ACTION'
            END
            
    END AS collection_strategy,
    
    -- Metadata for audit
    CURRENT_TIMESTAMP AS assignment_date
    
FROM debtors d
INNER JOIN debts de
    ON d.debtor_id = de.debtor_id
    
-- Only active past-due cases
WHERE UPPER(TRIM(de.status)) = 'PAST_DUE'
    AND de.days_past_due > 0

-- Order by priority (more days past due first)
ORDER BY 
    de.days_past_due DESC,
    de.current_amount DESC;

-- =====================================================
-- TECHNICAL NOTES
-- =====================================================
--
-- 1. UPPER(TRIM()) in comparisons:
--    Protects against data inconsistencies (spaces,
--    upper/lowercase) common in legacy systems.
--
-- 2. INNER JOIN vs LEFT JOIN:
--    INNER JOIN is used because we only care about debtors
--    who have active past-due debts.
--
-- 3. CASE evaluation order:
--    The first WHEN that is TRUE assigns the value.
--    That's why ranges are ordered from smallest to largest.
--
-- 4. Performance:
--    - Recommended indexes on: debts.status, debts.days_past_due
--    - Executes in < 1 second for 10,000 records
--
-- 5. BI Integration:
--    This query can connect directly to Power BI
--    or QuickSight for real-time operational dashboards.
--
-- =====================================================

-- =====================================================
-- ADDITIONAL USE CASES
-- =====================================================
--
-- VARIANT 1: Only Premium customers past due >60 days
-- (cases requiring senior executive)
--
-- SELECT * FROM (
--     [complete query above]
-- ) AS strategies
-- WHERE segment = 'PREMIUM' 
--   AND days_past_due > 60;
--
-- =====================================================
--
-- VARIANT 2: Count by assigned strategy
-- (to size necessary resources)
--
-- SELECT 
--     collection_strategy,
--     COUNT(*) as cases,
--     SUM(current_amount) as total_debt
-- FROM (
--     [complete query above]
-- ) AS strategies
-- GROUP BY collection_strategy
-- ORDER BY cases DESC;
--
-- =====================================================

-- =====================================================
-- CHANGELOG
-- =====================================================
-- v1.0 (January 2026)
-- - Initial version with 3 segments and 8 strategies
-- - Added UPPER(TRIM()) for inconsistent data
-- - Complete documentation
--
-- =====================================================
