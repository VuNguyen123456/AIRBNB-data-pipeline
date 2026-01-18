{{ config(
    materialized='ephemeral'
) }}

{# This is an ephemeral model #}
{# The 'hosts' query here is passed onto dim_hosts.yml #}
{# Deduplicates hosts - takes most recent version if multiple rows exist for same HOST_ID #}

WITH hosts_with_rank AS (
    SELECT
        HOST_ID,
        HOST_NAME,
        HOST_SINCE,
        IS_SUPERHOST,
        RESPONSE_RATE_QUALITY,
        HOST_CREATED_AT,
        ROW_NUMBER() OVER (PARTITION BY HOST_ID ORDER BY HOST_CREATED_AT DESC) as rn
    FROM {{ ref('obt') }}
)
SELECT
    HOST_ID,
    HOST_NAME,
    HOST_SINCE,
    IS_SUPERHOST,
    RESPONSE_RATE_QUALITY,
    HOST_CREATED_AT
FROM hosts_with_rank
WHERE rn = 1