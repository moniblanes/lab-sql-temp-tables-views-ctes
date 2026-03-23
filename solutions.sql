USE sakila;

-- =========================
-- STEP 1: CREATE VIEW
-- =========================

CREATE VIEW rental_summary AS
SELECT 
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    customer.email,
    COUNT(rental.rental_id) AS rental_count
FROM customer
LEFT JOIN rental
    ON customer.customer_id = rental.customer_id
GROUP BY 
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    customer.email;


-- =========================
-- STEP 2: TEMPORARY TABLE
-- =========================

CREATE TEMPORARY TABLE payment_summary AS
SELECT 
    rental_summary.customer_id,
    SUM(payment.amount) AS total_paid
FROM rental_summary
LEFT JOIN payment
    ON rental_summary.customer_id = payment.customer_id
GROUP BY rental_summary.customer_id;


-- =========================
-- STEP 3: CTE + FINAL REPORT
-- =========================

WITH customer_report AS (
    SELECT 
        rental_summary.first_name,
        rental_summary.last_name,
        rental_summary.email,
        rental_summary.rental_count,
        payment_summary.total_paid
    FROM rental_summary
    LEFT JOIN payment_summary
        ON rental_summary.customer_id = payment_summary.customer_id
)

SELECT 
    CONCAT(first_name, ' ', last_name) AS customer_name,
    email,
    rental_count,
    total_paid,
    ROUND(total_paid / rental_count, 2) AS avg_payment_per_rental
FROM customer_report;