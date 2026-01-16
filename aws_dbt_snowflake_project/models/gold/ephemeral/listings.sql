{{ config(
    materialized='ephemeral'
) }}

{# This is an ephemeral model #}
{# The 'bookings' query here is passed onto dim_bookings.yml #}

-- Defines a temporary table called 'listings'
WITH listings AS
(
    SELECT
        LISTING_ID,
        PROPERTY_TYPE,
        ROOM_TYPE,
        CITY,
        COUNTRY,
        PRICE_PER_NIGHT_TAG,
        LISTING_CREATED_AT
    FROM {{ ref('obt') }}
)
-- RETURNING THE FINAL RESULT  TO THE DIM_BOOKINGS MODEL
SELECT * FROM listings