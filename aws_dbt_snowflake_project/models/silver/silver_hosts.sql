{{
  config(
    materialized = 'incremental',
    key = 'HOST_ID'
    )
}}

SELECT 
    HOST_ID,
    REPLACE(HOST_NAME, ' ', '_') AS HOST_NAME,
    HOST_SINCE,
    IS_SUPERHOST,
    RESPONSE_RATE,
    CASE
        WHEN RESPONSE_RATE >= 95 THEN 'VERY_GOOD'
        WHEN RESPONSE_RATE >= 80 THEN 'GOOD'
        WHEN RESPONSE_RATE >= 60 THEN 'FAIR'
        ELSE 'POOR'
    END AS RESPONSE_RATE_QUALITY,
    CREATED_AT
FROM {{ ref('bronze_hosts') }}