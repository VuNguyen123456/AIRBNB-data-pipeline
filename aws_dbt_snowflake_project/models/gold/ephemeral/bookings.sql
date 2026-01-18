{{ config(
    materialized='ephemeral'
) }}

{# This is an ephemeral model #}
{# The 'bookings' query here is passed onto dim_bookings.yml #}
{# Deduplicates bookings - takes most recent version if multiple rows exist for same BOOKING_ID (shouldn't happen, but safe guard) #}

WITH bookings_with_rank AS (
    SELECT
        BOOKING_ID,
        BOOKING_DATE,
        BOOKING_STATUS,
        CREATED_AT,
        ROW_NUMBER() OVER (PARTITION BY BOOKING_ID ORDER BY CREATED_AT DESC) as rn
    FROM {{ ref('obt') }}
)
SELECT
    BOOKING_ID,
    BOOKING_DATE,
    BOOKING_STATUS,
    CREATED_AT
FROM bookings_with_rank
WHERE rn = 1