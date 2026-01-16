{{ config(
    materialized='ephemeral'
) }}

{# This is an ephemeral model #}
{# The 'hosts' query here is passed onto dim_bookings.yml #}

-- Defines a temporary table called 'hosts'
-- No: RESPONSE_RATE because it's a number
WITH hosts AS
(
    SELECT
        HOST_ID,
        HOST_NAME,
        HOST_SINCE,
        IS_SUPERHOST,
        RESPONSE_RATE_QUALITY,
        HOST_CREATED_AT
    FROM {{ ref('obt') }}
)
-- RETURNING THE FINAL RESULT  TO THE DIM_BOOKINGS MODEL
SELECT * FROM hosts