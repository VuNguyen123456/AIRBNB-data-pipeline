{{ config(
    materialized='ephemeral'
) }}

{# This is an ephemeral model #}
{# The 'listings' query here is passed onto dim_listings.yml #}
{# Deduplicates listings - takes most recent version if multiple rows exist for same LISTING_ID #}

WITH listings_with_rank AS (
    SELECT
        LISTING_ID,
        PROPERTY_TYPE,
        ROOM_TYPE,
        CITY,
        COUNTRY,
        PRICE_PER_NIGHT_TAG,
        LISTING_CREATED_AT,
        ROW_NUMBER() OVER (PARTITION BY LISTING_ID ORDER BY LISTING_CREATED_AT DESC) as rn
    FROM {{ ref('obt') }}
)
SELECT
    LISTING_ID,
    PROPERTY_TYPE,
    ROOM_TYPE,
    CITY,
    COUNTRY,
    PRICE_PER_NIGHT_TAG,
    LISTING_CREATED_AT
FROM listings_with_rank
WHERE rn = 1