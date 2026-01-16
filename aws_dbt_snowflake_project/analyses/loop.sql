{% set cols = ["NIGHTS_BOOKED", "BOOKING_ID", "BOOKING_AMOUNT"] %}

{# For each col in cols, we will select it from the bronze_bookings table. #}
SELECT
{% for col in cols %}
    {{ col }}
        {% if not loop.last %}, {% endif %}
{% endfor %}
FROM {{ ref('bronze_bookings') }}