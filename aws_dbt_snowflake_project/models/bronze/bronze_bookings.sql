{{ config(materialized='incremental')}}

{# You do this so you have incremental load making it manageable with the amount of data you have and will need to update from staging into bronze on different day #}
{# So only the new stuff get loaded in not the whole ew and old making lots of resource wasted#}
{# Coaleses to handle where nothing is in this table #}

SELECT * FROM {{ source('staging', 'bookings') }}
{% if is_incremental() %}
    WHERE CREATED_AT > (SELECT COALESCE(MAX(CREATED_AT), '1900-01-01') FROM {{ this }})
{% endif %}