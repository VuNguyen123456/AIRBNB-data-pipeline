{{ config(
    materialized='ephemeral'
) }}

{# This is an ephemeral model #}
{# The 'bookings' query here is passed onto dim_bookings.yml #}

-- Defines a temporary table called 'bookings'
WITH bookings AS
(
    SELECT
        BOOKING_ID,
        BOOKING_DATE,
        BOOKING_STATUS,
        CREATED_AT
    FROM {{ ref('obt') }}
)
-- RETURNING THE FINAL RESULT  TO THE DIM_BOOKINGS MODEL
SELECT * FROM bookings