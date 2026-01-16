{# Meta-data driven pipeline approach #}
{# Meta-data driven HIGHTLIGHT THE CONFIG, JINJA, in interview this part worths alot! #}

{% set configs = [
    {
        "table" : "AIRBNB.GOLD.OBT",
        "columns" : "GOLD_obt.BOOKING_ID, GOLD_obt.HOST_ID, GOLD_obt.LISTING_ID, GOLD_obt.TOTAL_BOOKING_AMOUNT, GOLD_obt.SERVICE_FEE, GOLD_obt.CLEANING_FEE, GOLD_obt.ACCOMMODATES, GOLD_obt.BEDROOMS, GOLD_obt.BATHROOMS, GOLD_obt.PRICE_PER_NIGHT, GOLD_obt.RESPONSE_RATE",
        "alias" : "GOLD_obt"
    },
    {
        "table" : "AIRBNB.GOLD.DIM_LISTINGS",
        "columns" : "",
        "alias" : "DIM_listings",
        "join_condition" : "GOLD_obt.listing_id = DIM_listings.listing_id"
    },
    {
        "table" : "AIRBNB.GOLD.DIM_HOSTS",
        "columns" : "",
        "alias" : "DIM_hosts",
        "join_condition" : "GOLD_obt.host_id = DIM_hosts.host_id"
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
    {{ configs[0]['columns'] }}
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
