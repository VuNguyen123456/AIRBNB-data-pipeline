{# Meta-data driven pipeline approach #}
{# Meta-data driven HIGHTLIGHT THE CONFIG, JINJA, in interview this part worths alot! #}

{% set configs = [
    {
        "table" : "AIRBNB.SILVER.SILVER_BOOKINGS",
        "columns" : "SILVER_bookings.*",
        "alias" : "SILVER_bookings"
    },
    {
        "table" : "AIRBNB.SILVER.SILVER_LISTINGS",
        "columns" : "SILVER_listings.HOST_ID, SILVER_listings.PROPERTY_TYPE, SILVER_listings.ROOM_TYPE, SILVER_listings.CITY, SILVER_listings.COUNTRY, SILVER_listings.ACCOMMODATES, SILVER_listings.BEDROOMS, SILVER_listings.BATHROOMS, SILVER_listings.PRICE_PER_NIGHT, SILVER_listings.PRICE_PER_NIGHT_TAG, SILVER_listings.CREATED_AT AS LISTING_CREATED_AT",
        "alias" : "SILVER_listings",
        "join_condition" : "SILVER_bookings.listing_id = SILVER_listings.listing_id"
    },
    {
        "table" : "AIRBNB.SILVER.SILVER_HOSTS",
        "columns" : "SILVER_hosts.HOST_NAME, SILVER_hosts.HOST_SINCE, SILVER_hosts.IS_SUPERHOST, SILVER_hosts.RESPONSE_RATE, SILVER_hosts.RESPONSE_RATE_QUALITY, SILVER_hosts.CREATED_AT AS HOST_CREATED_AT",
        "alias" : "SILVER_hosts",
        "join_condition" : "SILVER_listings.host_id = SILVER_hosts.host_id"
    }
] %}

{# ============================================ #}
{# Dynamic SQL Generation                      #}
{# ============================================ #}
{# Benefits:                                    #}
{# - To add new tables: just modify config     #}
{# - No need to change SQL logic below         #}
{# - Maintainable and scalable                 #}
{# ============================================ #}

SELECT
    {# Loop through each config to build SELECT clause #}
    {# Grabs all columns from each table as defined in config #}
    {% for config in configs %}
        {{ config['columns'] }}{% if not loop.last %},{% endif %}
    {% endfor %}
FROM
    {# Loop through configs to build FROM/JOIN clause #}
    {% for config in configs %}
        {# First table in config becomes the base table (FROM clause) #}
        {% if loop.first %}
            {{ config['table'] }} AS {{ config['alias'] }}
        {# Subsequent tables are LEFT JOINed to the chain #}
        {% else %}
            LEFT JOIN {{ config['table'] }} AS {{ config['alias'] }}
            ON {{ config['join_condition'] }}
        {% endif %}
    {% endfor %}
