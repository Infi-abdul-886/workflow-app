# Auto-generated from table_structure.sql
# This file represents the complete database schema as Django models.

from django.db import models

# Note: Django's built-in auth models (auth_group, auth_permission, etc.) and
# system tables (django_migrations, etc.) are omitted as they are managed by Django internally.

# ==============================================================================
# User, Corporate, and Group Management Models
# ==============================================================================

class UserDetails(models.Model):
    user_id = models.AutoField(primary_key=True)
    group_id = models.IntegerField(blank=True, null=True)
    corporate_id = models.IntegerField(blank=True, null=True)
    title = models.CharField(max_length=16, blank=True, null=True)
    first_name = models.CharField(max_length=32, blank=True, null=True)
    last_name = models.CharField(max_length=32, blank=True, null=True)
    email_id = models.CharField(max_length=100, blank=True, null=True)
    user_password = models.CharField(max_length=90, blank=True, null=True)
    user_address = models.CharField(max_length=256, blank=True, null=True)
    phone_number = models.CharField(max_length=32, blank=True, null=True)
    approved_status = models.CharField(max_length=1, default='N')
    email_verification_status = models.CharField(max_length=1, default='N')
    confirm_code = models.CharField(max_length=100, blank=True, null=True)
    created_date = models.DateTimeField(blank=True, null=True)
    time_zone_interval = models.CharField(max_length=40, default='')
    time_zone_key = models.CharField(max_length=352, default='')
    ip_address = models.CharField(max_length=40, default='')
    country_code = models.CharField(max_length=16, blank=True, null=True)
    last_login_ip_address = models.CharField(max_length=40, default='')
    last_login_date = models.DateTimeField()
    country_number = models.CharField(max_length=15, blank=True, null=True)
    city_id = models.IntegerField(blank=True, null=True)
    user_zip_code = models.CharField(max_length=36, blank=True, null=True)
    user_name = models.CharField(max_length=36, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'user_details'

class CorporateDetails(models.Model):
    corporate_id = models.AutoField(primary_key=True)
    corporate_type_id = models.IntegerField(blank=True, null=True)
    user = models.ForeignKey('UserDetails', models.DO_NOTHING, db_column='user_id', blank=True, null=True, db_constraint=False)
    corporate_name = models.CharField(max_length=100, blank=True, null=True)
    agent_name = models.CharField(max_length=52, blank=True, null=True)
    iata_code = models.CharField(max_length=36, blank=True, null=True)
    pcc_code = models.CharField(max_length=36, blank=True, null=True)
    airlines_code = models.CharField(max_length=3, default='0')
    corporate_address = models.CharField(max_length=256, blank=True, null=True)
    fax = models.CharField(max_length=32, blank=True, null=True)
    office_number = models.CharField(max_length=32, blank=True, null=True)
    corporate_status = models.CharField(max_length=1, default='N')
    created_date = models.DateTimeField(blank=True, null=True)
    time_zone_interval = models.CharField(max_length=40, default='')
    time_zone_key = models.CharField(max_length=352, default='')
    pos_code = models.CharField(max_length=32, blank=True, null=True)
    customer_category_id = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'corporate_details'

class CorporateTypeDetails(models.Model):
    corporate_type_id = models.AutoField(primary_key=True)
    corporate_type_name = models.CharField(max_length=30, blank=True, null=True)
    status = models.CharField(max_length=1, default='Y')

    class Meta:
        managed = False
        db_table = 'corporate_type_details'

class CorporateSalespersonMapping(models.Model):
    salesperson_mapping_id = models.AutoField(primary_key=True)
    corporate_id = models.IntegerField(blank=True, null=True)
    user = models.ForeignKey('UserDetails', models.DO_NOTHING, db_column='user_id', blank=True, null=True, db_constraint=False)

    class Meta:
        managed = False
        db_table = 'corporate_salesperson_mapping'

class GroupDetails(models.Model):
    group_id = models.AutoField(primary_key=True)
    group_name = models.CharField(max_length=30, blank=True, null=True)
    group_alias_name = models.CharField(unique=True, max_length=3, blank=True, null=True)
    corporate_type_id = models.IntegerField(blank=True, null=True)
    active_status = models.CharField(max_length=1, default='Y')
    access_group_id = models.CharField(max_length=50)
    default_module = models.CharField(max_length=150)

    class Meta:
        managed = False
        db_table = 'group_details'

# ==============================================================================
# Request and Transaction Models
# ==============================================================================

# class RequestMaster(models.Model):
#     request_master_id = models.AutoField(primary_key=True)
#     user = models.ForeignKey('UserDetails', models.DO_NOTHING, db_column='user_id', blank=True, null=True, db_constraint=False)
#     request_type = models.CharField(max_length=20, blank=True, null=True)
#     request_type_id = models.IntegerField(default=0)
#     trip_type = models.CharField(max_length=1, default='')
#     series_type = models.CharField(max_length=2, blank=True, null=True)
#     user_currency = models.CharField(max_length=3)
#     request_fare = models.FloatField(default=0)
#     exchange_rate = models.FloatField(default=0)
#     requested_date = models.DateTimeField(blank=True, null=True)
#     number_of_passenger = models.IntegerField(blank=True, null=True)
#     number_of_adult = models.IntegerField(default=0)
#     number_of_child = models.IntegerField(default=0)
#     number_of_infant = models.IntegerField(default=0)
#     remarks = models.TextField(blank=True, null=True)
#     fare_acceptance_transaction_id = models.IntegerField(blank=True, null=True)
#     request_source = models.CharField(max_length=100, blank=True, null=True)
#     requested_corporate = models.CharField(max_length=100, blank=True, null=True)
#     opened_by = models.IntegerField()
#     opened_time = models.DateTimeField()
#     view_status = models.CharField(max_length=10)
#     request_raised_by = models.IntegerField(default=0)
#     priority = models.IntegerField(default=0)
#     auto_pilot_policy_id = models.IntegerField(default=0)
#     auto_pilot_status = models.CharField(max_length=10, default='NA')
#     reference_request_master_id = models.IntegerField(default=0)
#     quote_type = models.CharField(max_length=2, blank=True, null=True)
#     request_group_name = models.CharField(max_length=100, default='')
#     group_category_id = models.IntegerField(blank=True, null=True)
#     flexible_on_dates = models.CharField(max_length=1, default='N')
#     pnr_ignore_status = models.CharField(max_length=1, default='N')
#     queue_no = models.IntegerField(default=0)

#     class Meta:
#         managed = False
#         db_table = 'request_master'

class RequestDetails(models.Model):
    request_id = models.AutoField(primary_key=True)
    request_master = models.ForeignKey('RequestMaster', models.DO_NOTHING, db_column='request_master_id', blank=True, null=True, db_constraint=False)
    origin_airport_code = models.CharField(max_length=5, blank=True, null=True)
    dest_airport_code = models.CharField(max_length=5, blank=True, null=True)
    flight_number = models.CharField(max_length=200, blank=True, null=True)
    cabin = models.CharField(max_length=20, blank=True, null=True)
    from_date = models.DateField(blank=True, null=True)
    to_date = models.DateField(blank=True, null=True)
    start_time = models.CharField(max_length=5, blank=True, null=True)
    end_time = models.CharField(max_length=5, blank=True, null=True)
    series_weekdays = models.CharField(max_length=50, blank=True, null=True)
    baggage_allowance = models.CharField(max_length=250, default='')
    ancillary = models.CharField(max_length=50, blank=True, null=True)
    meals_code = models.CharField(max_length=6, blank=True, null=True)
    pnr = models.CharField(max_length=25, blank=True, null=True)
    trip_name = models.IntegerField()
    trip_type = models.CharField(max_length=1)

    class Meta:
        managed = False
        db_table = 'request_details'

class SeriesRequestDetails(models.Model):
    series_request_id = models.AutoField(primary_key=True)
    request = models.ForeignKey('RequestDetails', models.DO_NOTHING, db_column='request_id', blank=True, null=True, db_constraint=False)
    departure_date = models.DateField(blank=True, null=True)
    number_of_passenger = models.IntegerField(default=0)
    number_of_adult = models.IntegerField(default=0)
    number_of_child = models.IntegerField(default=0)
    number_of_infant = models.IntegerField(default=0)
    cabin = models.CharField(max_length=20, blank=True, null=True)
    start_time = models.CharField(max_length=5, blank=True, null=True)
    end_time = models.CharField(max_length=5, blank=True, null=True)
    baggage_allowance = models.CharField(max_length=250, blank=True, null=True)
    ancillary = models.CharField(max_length=50, blank=True, null=True)
    meals_code = models.CharField(max_length=6, blank=True, null=True)
    pnr = models.CharField(max_length=25, blank=True, null=True)
    expected_fare = models.FloatField(blank=True, null=True)
    flexible_on_dates = models.CharField(max_length=1, default='N')
    group_category_id = models.IntegerField(default=0)
    mapped_series_request_id = models.IntegerField(default=0)
    series_group_id = models.IntegerField(default=1)
    parent_series_group_id = models.IntegerField(default=0)
    flight_number = models.CharField(max_length=200, blank=True, null=True)
    current_load_factor = models.CharField(max_length=100, blank=True, null=True)
    forecast_load_factor = models.CharField(max_length=100, blank=True, null=True)
    future_load_factor = models.CharField(max_length=100, blank=True, null=True)
    parent_series_request_id = models.IntegerField(default=0)
    flight_status = models.CharField(max_length=2, default='HK')
    foc_pax = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'series_request_details'

class TransactionMaster(models.Model):
    transaction_id = models.AutoField(primary_key=True)
    airlines_request = models.ForeignKey('AirlinesRequestMapping', models.DO_NOTHING, db_column='airlines_request_id', blank=True, null=True, db_constraint=False)
    request_master_history_id = models.IntegerField(default=0)
    fare_advised = models.FloatField(default=0)
    child_fare = models.FloatField(default=0)
    infant_fare = models.FloatField(default=0)
    exchange_rate = models.FloatField(default=0)
    fare_negotiable = models.CharField(max_length=20, blank=True, null=True)
    auto_approval = models.CharField(max_length=1, default='Y')
    transaction_fee = models.CharField(max_length=1, blank=True, null=True)
    fare_validity = models.IntegerField(blank=True, null=True)
    fare_validity_type_id = models.IntegerField(blank=True, null=True)
    fare_expiry_type = models.IntegerField(default=1)
    payment_validity = models.IntegerField(default=0)
    payment_validity_type = models.IntegerField(default=0)
    payment_expiry_type = models.IntegerField(default=1)
    passenger_validity = models.IntegerField(default=0)
    passenger_validity_type = models.IntegerField(default=0)
    passenger_expiry_type = models.IntegerField(default=1)
    transaction_date = models.DateTimeField(blank=True, null=True)
    fare_expiry_date = models.DateTimeField()
    payment_expiry_date = models.DateTimeField()
    passenger_expiry_date = models.DateTimeField()
    active_status = models.IntegerField(blank=True, null=True)
    remarks = models.TextField(blank=True, null=True)
    alternate_flight_remarks = models.TextField(blank=True, null=True)
    timelimit_remarks = models.TextField(blank=True, null=True)
    response_source = models.CharField(max_length=50, blank=True, null=True)
    cancel_policy_id = models.IntegerField(default=0)
    time_line_id = models.IntegerField(default=0)
    negotiation_policy_id = models.IntegerField(default=0)
    sales_promo_status = models.CharField(max_length=1, default='N')
    payment_in_percent = models.CharField(max_length=3, default='Y')

    class Meta:
        managed = False
        db_table = 'transaction_master'

class RequestApprovedFlightDetails(models.Model):
    request_approved_flight_id = models.AutoField(primary_key=True)
    airlines_request = models.ForeignKey('AirlinesRequestMapping', models.DO_NOTHING, db_column='airlines_request_id', blank=True, null=True, db_constraint=False)
    transaction_master = models.ForeignKey('TransactionMaster', models.DO_NOTHING, db_column='transaction_master_id', blank=True, null=True, db_constraint=False)
    request = models.ForeignKey('RequestDetails', models.DO_NOTHING, db_column='request_id', default=0, db_constraint=False)
    request_details_history_id = models.IntegerField(default=0)
    series_request = models.ForeignKey('SeriesRequestDetails', models.DO_NOTHING, db_column='series_request_id', default=0, db_constraint=False)
    series_request_history_id = models.IntegerField(default=0)
    request_option_id = models.IntegerField(default=0)
    airline_code = models.CharField(max_length=5, blank=True, null=True)
    flight_code = models.CharField(max_length=10, blank=True, null=True)
    flight_number = models.CharField(max_length=20, blank=True, null=True)
    source = models.CharField(max_length=5, blank=True, null=True)
    destination = models.CharField(max_length=5, blank=True, null=True)
    departure_date = models.DateField()
    arrival_date = models.DateField()
    dep_time = models.CharField(max_length=6, default='00:00')
    arr_time = models.CharField(max_length=6, default='00:00')
    journey_time = models.CharField(max_length=6, default='00:00')
    fare_filter_method = models.CharField(max_length=30, default='')
    no_of_adult = models.IntegerField(default=0)
    no_of_child = models.IntegerField(default=0)
    no_of_infant = models.IntegerField(default=0)
    displacement_cost = models.FloatField(default=0)
    base_fare = models.FloatField(default=0)
    tax = models.FloatField(default=0)
    fare_passenger = models.FloatField(default=0)
    tax_breakup = models.CharField(max_length=300, blank=True, null=True)
    child_base_fare = models.FloatField(default=0)
    child_tax = models.FloatField(default=0)
    child_tax_breakup = models.CharField(max_length=300, blank=True, null=True)
    infant_base_fare = models.FloatField(default=0)
    infant_tax = models.FloatField(default=0)
    infant_tax_breakup = models.CharField(max_length=300, blank=True, null=True)
    baggauge_fare = models.FloatField(default=0)
    meals_fare = models.FloatField(default=0)
    baggage_code = models.CharField(max_length=5)
    meals_code = models.CharField(max_length=6, blank=True, null=True)
    stops = models.IntegerField(blank=True, null=True)
    capacity = models.IntegerField(default=0)
    sold = models.IntegerField(default=0)
    seat_availability = models.IntegerField(default=0)
    discount_fare = models.FloatField(default=0)
    child_discount_fare = models.FloatField(default=0)
    sales_promo_discount_fare = models.FloatField(default=0)
    adjusted_amount = models.FloatField(default=0)
    accepted_flight_status = models.CharField(max_length=1, default='Y')
    displacement_fare_remarks = models.TextField(blank=True, null=True)
    surcharge = models.FloatField(default=0)
    ancillary_fare = models.TextField(blank=True, null=True)
    free_cost_count = models.IntegerField(default=0)
    foc_base_fare = models.FloatField(default=0)
    foc_tax = models.FloatField(default=0)
    foc_tax_breakup = models.CharField(max_length=300, blank=True, null=True)
    lfid = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'request_approved_flight_details'

class AirlinesRequestMapping(models.Model):
    airlines_request_id = models.AutoField(primary_key=True)
    request_master = models.ForeignKey('RequestMaster', models.DO_NOTHING, db_column='request_master_id', blank=True, null=True, db_constraint=False)
    corporate = models.ForeignKey('CorporateDetails', models.DO_NOTHING, db_column='corporate_id', blank=True, null=True, db_constraint=False)
    current_status = models.ForeignKey('StatusDetails', models.DO_NOTHING, db_column='current_status', blank=True, null=True, db_constraint=False)
    last_updated = models.DateTimeField(blank=True, null=True)
    request_upload_batch_id = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'airlines_request_mapping'

class PassengerDetails(models.Model):
    passenger_id = models.AutoField(primary_key=True)
    airlines_request = models.ForeignKey('AirlinesRequestMapping', models.DO_NOTHING, db_column='airlines_request_id', blank=True, null=True, db_constraint=False)
    request_approved_flight = models.ForeignKey('RequestApprovedFlightDetails', models.DO_NOTHING, db_column='request_approved_flight_id', blank=True, null=True, db_constraint=False)
    series_request = models.ForeignKey('SeriesRequestDetails', models.DO_NOTHING, db_column='series_request_id', blank=True, null=True, db_constraint=False)
    name_number = models.CharField(max_length=10, default='0')
    pnr = models.CharField(max_length=20, blank=True, null=True)
    title = models.CharField(max_length=16, blank=True, null=True)
    first_name = models.TextField(blank=True, null=True)
    last_name = models.TextField(blank=True, null=True)
    middle_name = models.CharField(max_length=35, blank=True, null=True)
    age = models.CharField(max_length=16, blank=True, null=True)
    pax_email_id = models.CharField(max_length=32, blank=True, null=True)
    pax_mobile_number = models.CharField(max_length=16, blank=True, null=True)
    pax_employee_code = models.CharField(max_length=16, blank=True, null=True)
    pax_employee_id = models.CharField(max_length=16, blank=True, null=True)
    passenger_type = models.CharField(max_length=10, blank=True, null=True)
    id_proof = models.CharField(max_length=16, blank=True, null=True)
    id_proof_number = models.CharField(max_length=16, blank=True, null=True)
    sex = models.CharField(max_length=16, blank=True, null=True)
    dob = models.CharField(max_length=16, blank=True, null=True)
    citizenship = models.CharField(max_length=16, blank=True, null=True)
    passport_no = models.CharField(max_length=16, blank=True, null=True)
    date_of_issue = models.BinaryField(blank=True, null=True)
    date_of_expiry = models.BinaryField(blank=True, null=True)
    submitted_date = models.DateTimeField(blank=True, null=True)
    traveller_number = models.CharField(max_length=16, blank=True, null=True)
    frequent_flyer_number = models.CharField(max_length=16, blank=True, null=True)
    passport_issued_place = models.CharField(max_length=80, blank=True, null=True)
    meal_code = models.CharField(max_length=6, blank=True, null=True)
    place_of_birth = models.CharField(max_length=40, blank=True, null=True)
    address = models.CharField(max_length=200, blank=True, null=True)
    additional_details = models.TextField()
    passenger_status = models.CharField(max_length=2, default='Y')
    foc_status = models.CharField(max_length=1, default='N')
    parent_pax_id = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'passenger_details'

class PnrBlockingDetails(models.Model):
    pnr_blocking_id = models.AutoField(primary_key=True)
    request_master = models.ForeignKey('RequestMaster', models.DO_NOTHING, db_column='request_master_id', default=0, db_constraint=False)
    request_approved_flight = models.ForeignKey('RequestApprovedFlightDetails', models.DO_NOTHING, db_column='request_approved_flight_id', default=0, db_constraint=False)
    via_flight_id = models.IntegerField(default=0)
    pnr = models.CharField(max_length=10, default='')
    no_of_adult = models.IntegerField(default=0)
    no_of_child = models.IntegerField(default=0)
    no_of_infant = models.IntegerField(default=0)
    no_of_foc = models.IntegerField(default=0)
    pnr_amount = models.FloatField(default=0)
    price_quote_at = models.TextField(blank=True, null=True)
    status = models.CharField(max_length=30, blank=True, null=True)
    created_date = models.DateTimeField(default='0000-00-00 00:00:00')

    class Meta:
        managed = False
        db_table = 'pnr_blocking_details'
        
class StatusDetails(models.Model):
    status_id = models.AutoField(primary_key=True)
    status_code = models.CharField(max_length=5, blank=True, null=True)
    status_name = models.CharField(max_length=150, blank=True, null=True)
    front_end = models.CharField(max_length=1, default='Y')
    back_end = models.CharField(max_length=1, default='Y')

    class Meta:
        managed = False
        db_table = 'status_details'

class AirportDetails(models.Model):
    airport_id = models.AutoField(primary_key=True)
    airport_code = models.CharField(unique=True, max_length=3)
    airport_name = models.CharField(max_length=100, blank=True, null=True)
    country_code = models.CharField(max_length=2)
    display_status = models.CharField(max_length=1, default='Y')
    user_id = models.IntegerField(blank=True, null=True)
    created_date = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'airport_details'

class CabinDetails(models.Model):
    cabin_id = models.AutoField(primary_key=True)
    cabin_name = models.CharField(max_length=250, blank=True, null=True)
    cabin_status = models.CharField(max_length=1, blank=True, null=True)
    cabin_value = models.CharField(max_length=25, blank=True, null=True)
    pnr_blocking_class = models.CharField(max_length=5, default='')

    class Meta:
        managed = False
        db_table = 'cabin_details'

class CurrencyDetails(models.Model):
    currency_id = models.AutoField(primary_key=True)
    currency_type = models.CharField(unique=True, max_length=3, blank=True, null=True)
    currency_symbol = models.CharField(max_length=5)
    exchange_rate = models.FloatField()
    decimal_precision = models.IntegerField(default=2)
    display_order = models.IntegerField(default=0)
    created_date = models.DateField()
    currency_status = models.CharField(max_length=1, default='y')

    class Meta:
        managed = False
        db_table = 'currency_details'

class CitizenshipDetails(models.Model):
    citizenship_id = models.AutoField(primary_key=True)
    citizenship_name = models.CharField(max_length=100, blank=True, null=True)
    citizen_code = models.CharField(unique=True, max_length=3, blank=True, null=True)
    user_id = models.IntegerField(blank=True, null=True)
    created_date = models.DateTimeField(blank=True, null=True)
    status = models.CharField(max_length=1, default='Y')
    currency_code = models.CharField(max_length=5, default='')
    phone_code = models.CharField(max_length=10, default='')

    class Meta:
        managed = False
        db_table = 'citizenship_details'

class MealCodeDetails(models.Model):
    meal_id = models.AutoField(primary_key=True)
    meal_description = models.CharField(max_length=250, blank=True, null=True)
    meal_code = models.CharField(max_length=6)

    class Meta:
        managed = False
        db_table = 'meal_code_details'

class BaggageDetails(models.Model):
    baggage_id = models.AutoField(primary_key=True)
    baggage_name = models.CharField(max_length=250, blank=True, null=True)
    baggage_code = models.CharField(max_length=5)
    baggage_cabin = models.CharField(max_length=25, default='')
    baggage_market = models.CharField(max_length=25, default='')
    pax_type = models.CharField(max_length=10, default='Adult')
    baggage_status = models.CharField(max_length=1, default='Y')

    class Meta:
        managed = False
        db_table = 'baggage_details'

class TimeLineMatrixList(models.Model):
    time_line_matrix_list_id = models.AutoField(primary_key=True)
    time_line_matrix_name = models.CharField(max_length=48, blank=True, null=True)
    activation_status = models.CharField(max_length=1, default='Y')
    default_status = models.CharField(max_length=1, default='N')
    create_date = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'time_line_matrix_list'

class TimeLineMatrix(models.Model):
    time_line_id = models.AutoField(primary_key=True)
    corporate_id = models.IntegerField(blank=True, null=True)
    days_to_departure = models.IntegerField(blank=True, null=True)
    payment_validity = models.IntegerField(blank=True, null=True)
    payment_type_id = models.IntegerField(blank=True, null=True)
    passenger_validity = models.IntegerField(blank=True, null=True)
    passenger_type_id = models.IntegerField(blank=True, null=True)
    fare_validity = models.IntegerField(blank=True, null=True)
    fare_type_id = models.IntegerField(blank=True, null=True)
    time_line_matrix_list = models.ForeignKey('TimeLineMatrixList', models.DO_NOTHING, db_column='time_line_matrix_list_id', db_constraint=False)
    expiry_type_id = models.IntegerField(default=1)
    payment_expiry_type_id = models.IntegerField(default=1)
    passenger_expiry_type_id = models.IntegerField(default=1)
    payment_percentage = models.FloatField(default=100)
    payment_in_percent = models.CharField(max_length=3, default='Y')
    payment_currency = models.CharField(max_length=5, default='')
    materialization = models.IntegerField(blank=True, null=True)
    policy = models.CharField(max_length=5, blank=True, null=True)
    penalty_value = models.IntegerField(blank=True, null=True)
    penalty_type_id = models.IntegerField(blank=True, null=True)
    penalty_expiry_id = models.IntegerField(default=1)

    class Meta:
        managed = False
        db_table = 'time_line_matrix'

class CancelPolicyDetails(models.Model):
    cancel_policy_id = models.AutoField(primary_key=True)
    corporate_id = models.IntegerField(blank=True, null=True)
    cancel_policy_name = models.CharField(max_length=150, blank=True, null=True)
    cancel_policy_description = models.TextField(blank=True, null=True)
    activation_status = models.CharField(max_length=1, default='Y')
    default_status = models.CharField(max_length=1, default='N')
    start_date = models.DateTimeField(blank=True, null=True)
    end_date = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'cancel_policy_details'

class NegotiationPolicyMaster(models.Model):
    negotiation_policy_id = models.AutoField(primary_key=True)
    negotiation_policy_name = models.CharField(max_length=100, blank=True, null=True)
    priority = models.IntegerField(blank=True, null=True)
    active_status = models.CharField(max_length=1, blank=True, null=True)
    negotiation_status = models.CharField(max_length=1, blank=True, null=True)
    negotiation_limit = models.IntegerField(blank=True, null=True)
    start_date = models.DateTimeField(blank=True, null=True)
    end_date = models.DateTimeField(blank=True, null=True)
    policy_dow = models.CharField(max_length=100, blank=True, null=True)
    created_date = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'negotiation_policy_master'
        
class PolicyMaster(models.Model):
    policy_id = models.AutoField(primary_key=True)
    policy_name = models.CharField(max_length=100, blank=True, null=True)
    discount_matrix_id = models.IntegerField(blank=True, null=True)
    priority = models.IntegerField(blank=True, null=True)
    active_status = models.CharField(max_length=1, default='Y')
    active_date = models.DateTimeField(blank=True, null=True)
    start_date = models.DateTimeField(blank=True, null=True)
    end_date = models.DateTimeField(blank=True, null=True)
    policy_dow = models.CharField(max_length=100, blank=True, null=True)
    created_date = models.DateTimeField(blank=True, null=True)
    updated_date = models.DateTimeField(blank=True, null=True)
    updated_by = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'policy_master'

class SurchargePolicyMaster(models.Model):
    surcharge_policy_id = models.AutoField(primary_key=True)
    surcharge_policy_name = models.CharField(max_length=100, blank=True, null=True)
    surcharge_matrix_id = models.IntegerField(blank=True, null=True)
    priority = models.IntegerField(blank=True, null=True)
    active_status = models.CharField(max_length=1, blank=True, null=True)
    start_date = models.DateTimeField(blank=True, null=True)
    end_date = models.DateTimeField(blank=True, null=True)
    policy_dow = models.CharField(max_length=100)
    created_date = models.DateTimeField(blank=True, null=True)
    updated_date = models.DateTimeField(blank=True, null=True)
    updated_by = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'surcharge_policy_master'

class PaymentMaster(models.Model):
    payment_master_id = models.AutoField(primary_key=True)
    airlines_request = models.ForeignKey('AirlinesRequestMapping', models.DO_NOTHING, db_column='airlines_request_id', blank=True, null=True, db_constraint=False)
    payment_percentage = models.FloatField(default=0)
    percentage_amount = models.FloatField(blank=True, null=True)
    exchange_rate = models.FloatField(default=0)
    payment_validity_date = models.DateTimeField(blank=True, null=True)
    payment_requested_date = models.DateTimeField(blank=True, null=True)
    payment_remarks = models.CharField(max_length=300, blank=True, null=True)
    payment_status = models.IntegerField(blank=True, null=True)
    paid_date = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'payment_master'

class PnrPaymentDetails(models.Model):
    pnr_payment_id = models.AutoField(primary_key=True)
    payment_master = models.ForeignKey('PaymentMaster', models.DO_NOTHING, db_column='payment_master_id', db_constraint=False)
    pnr = models.CharField(max_length=10, default='')
    paid_amount = models.FloatField(default=0)
    paid_date = models.DateTimeField()
    group_pax_paid = models.CharField(max_length=100, default='')
    group_pax_percent = models.FloatField(blank=True, null=True)
    payment_status = models.CharField(max_length=20, default='')
    payment_service_id = models.CharField(max_length=100, default='')
    topup_id = models.IntegerField(default=0)
    pnr_payment_validity_date = models.DateTimeField(blank=True, null=True)
    request_timeline_id = models.IntegerField(blank=True, null=True)
    pnr_percentage_amount = models.FloatField(blank=True, null=True)
    convinence_charge = models.FloatField(default=0)

    class Meta:
        managed = False
        db_table = 'pnr_payment_details'

class AgencyCodeDetails(models.Model):
    agency_code_id = models.AutoField(primary_key=True)
    agency_code = models.CharField(max_length=30, blank=True, null=True)
    corporate_id = models.IntegerField(blank=True, null=True)
    airline_code = models.CharField(max_length=2)
    code_type = models.CharField(max_length=2, default='PC')
    status = models.CharField(max_length=10, blank=True, null=True)
    created_by = models.CharField(max_length=20, blank=True, null=True)
    created_date = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'agency_code_details'
        
class SsrCategoryDetails(models.Model):
    ssr_category_id = models.AutoField(primary_key=True)
    ssr_category_name = models.CharField(max_length=30)
    display_status = models.CharField(max_length=1, default='Y')

    class Meta:
        managed = False
        db_table = 'ssr_category_details'

class SsrSubcategoryDetails(models.Model):
    ssr_subcategory_id = models.AutoField(primary_key=True)
    ssr_category_id = models.IntegerField()
    ssr_subcategory_name = models.CharField(max_length=30)
    display_status = models.CharField(max_length=1, default='Y')

    class Meta:
        managed = False
        db_table = 'ssr_subcategory_details'

class SsrList(models.Model):
    ssr_list_id = models.AutoField(primary_key=True)
    ssr_category_id = models.IntegerField()
    ssr_subcategory_id = models.IntegerField(blank=True, null=True)
    ssr_code = models.CharField(max_length=10)
    ssr_description = models.CharField(max_length=250)
    start_date = models.DateField()
    end_date = models.DateField()
    display_status = models.CharField(max_length=1, default='Y')

    class Meta:
        managed = False
        db_table = 'ssr_list'

class SsrMaster(models.Model):
    ssr_master_id = models.AutoField(primary_key=True)
    request_master = models.ForeignKey('RequestMaster', models.DO_NOTHING, db_column='request_master_id', db_constraint=False)
    pnr = models.CharField(max_length=10, default='')
    ssr_amount = models.FloatField(default=0)
    updated_by = models.IntegerField()
    ssr_updated_date = models.DateTimeField()
    last_transaction = models.CharField(max_length=1, default='N')
    status = models.CharField(max_length=32, default='')
    ssr_category_id = models.IntegerField(default=0)

    class Meta:
        managed = False
        db_table = 'ssr_master'

class SsrDetails(models.Model):
    ssr_details_id = models.AutoField(primary_key=True)
    ssr_master = models.ForeignKey('SsrMaster', models.DO_NOTHING, db_column='ssr_master_id', db_constraint=False)
    ssr_pax_id = models.IntegerField(default=0)
    ssr_category_id = models.IntegerField()
    ssr_code = models.CharField(max_length=50, default='')
    ssr_base_fare = models.FloatField(default=0)
    ssr_tax = models.FloatField(default=0)
    ssr_total_fare = models.FloatField(default=0)
    emd_id = models.IntegerField(default=0)
    ssr_status = models.CharField(max_length=32, default='')
    remarks = models.CharField(max_length=200, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ssr_details'

class ActionMaster(models.Model):
    action_master_id = models.AutoField(primary_key=True)
    action_name = models.CharField(max_length=100, blank=True, null=True)
    status = models.CharField(max_length=1, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'action_master'

class ActionEmailMapping(models.Model):
    action_email_mapping_id = models.AutoField(primary_key=True)
    action_master_id = models.IntegerField(blank=True, null=True)
    from_email_id = models.CharField(max_length=100, blank=True, null=True)
    to_email_id = models.CharField(max_length=100, blank=True, null=True)
    cc_email_id = models.CharField(max_length=100, blank=True, null=True)
    bcc_email_id = models.CharField(max_length=100, blank=True, null=True)
    template_id = models.IntegerField(blank=True, null=True)
    status = models.CharField(max_length=1, default='Y')
    created_date = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'action_email_mapping'

class PackageDetails(models.Model):
    package_id = models.AutoField(primary_key=True)
    pnr_blocking = models.ForeignKey('PnrBlockingDetails', models.DO_NOTHING, db_column='pnr_blocking_id', db_constraint=False)
    adult = models.IntegerField()
    child = models.IntegerField()
    infant = models.IntegerField()
    status = models.CharField(max_length=1, default='Y')
    parent_package_id = models.IntegerField(default=0)
    ref_package_id = models.IntegerField()
    created_at = models.DateTimeField()
    created_by = models.IntegerField()
    passenger_mapping = models.JSONField(default=dict)

    class Meta:
        managed = False
        db_table = 'package_details'

class SectorManagement(models.Model):
    sector_id = models.AutoField(primary_key=True)
    origin = models.CharField(max_length=3, blank=True, null=True)
    destination = models.CharField(max_length=3, blank=True, null=True)
    active_status = models.CharField(max_length=1, default='Y')
    created_date = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'sector_management'

class SectorUserMapping(models.Model):
    sector_user_id = models.AutoField(primary_key=True)
    sector = models.ForeignKey('SectorManagement', models.DO_NOTHING, db_column='sector_id', blank=True, null=True, db_constraint=False)
    user = models.ForeignKey('UserDetails', models.DO_NOTHING, db_column='user_id', blank=True, null=True, db_constraint=False)
    group_id = models.IntegerField(default=0)
    status = models.CharField(max_length=1, blank=True, null=True)
    primary_user = models.IntegerField(default=0)

    class Meta:
        managed = False
        db_table = 'sector_user_mapping'

class CronEmailDetails(models.Model):
    cron_email_id = models.AutoField(primary_key=True)
    request_master = models.ForeignKey('RequestMaster', models.DO_NOTHING, db_column='request_master_id', db_constraint=False)
    email_type = models.IntegerField(default=0)
    email_subject = models.CharField(max_length=50)
    sent_to = models.CharField(max_length=70)
    expiry_date = models.CharField(max_length=20)
    sent_date = models.DateTimeField()
    pnr = models.CharField(max_length=10, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'cron_email_details'

class ExternalDataBatchDetails(models.Model):
    extenal_data_batch_id = models.AutoField(primary_key=True)
    external_data_type = models.CharField(max_length=2)
    file_name = models.CharField(max_length=200, blank=True, null=True)
    data_count = models.IntegerField(default=0)
    inserted_data_count = models.IntegerField(default=0)
    file_uploaded_date = models.DateTimeField(blank=True, null=True)
    batch_date = models.DateTimeField(blank=True, null=True)
    batch_updated_date = models.DateTimeField(blank=True, null=True)
    batch_file_status = models.CharField(max_length=1, default='Y')

    class Meta:
        managed = False
        db_table = 'external_data_batch_details'

class SystemSettings(models.Model):
    key_id = models.AutoField(primary_key=True)
    key_index = models.CharField(max_length=100, blank=True, null=True)
    key_name = models.CharField(max_length=100, blank=True, null=True)
    extra_key_name = models.CharField(max_length=100, blank=True, null=True)
    key_value = models.TextField(blank=True, null=True)
    value_type = models.CharField(max_length=1, blank=True, null=True)
    description = models.CharField(max_length=200, blank=True, null=True)
    status = models.CharField(max_length=1, blank=True, null=True)
    backend_status = models.CharField(max_length=1, default='N')
    last_updated_by = models.IntegerField(blank=True, null=True)
    last_updated_date = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'system_settings'

class PaymentAdditionalChargeDetails(models.Model):
    payment_charge_id = models.AutoField(primary_key=True)
    request_master_id = models.IntegerField(default=0)
    ssr_list_id = models.IntegerField(default=0)
    ssr_master_id = models.IntegerField(blank=True, null=True, default=0)
    pnr_blocking_id = models.IntegerField(default=0)
    additional_amount = models.FloatField(default=0)
    pnr_payment = models.ForeignKey('PnrPaymentDetails', models.DO_NOTHING, db_column='pnr_payment_id', blank=True, null=True, db_constraint=False)
    paid_status = models.CharField(max_length=20, blank=True, null=True)
    remarks = models.CharField(max_length=300, blank=True, null=True)
    modified_details = models.TextField(blank=True, null=True)
    series_group_id = models.IntegerField(blank=True, null=True)
    ssr_status = models.CharField(max_length=10, default='N')

    class Meta:
        managed = False
        db_table = 'payment_additional_charge_details'

class BatchDetails(models.Model):
    batch_id = models.AutoField(primary_key=True)
    request_master = models.ForeignKey('RequestMaster', models.DO_NOTHING, db_column='request_master_id', db_constraint=False)
    initiated_by = models.IntegerField(blank=True, null=True)
    batch_date = models.DateTimeField()
    batch_status = models.CharField(max_length=20, default='')

    class Meta:
        managed = False
        db_table = 'batch_details'

class PolicyTypeDetails(models.Model):
    policy_type_id = models.AutoField(primary_key=True)
    policy_type_code = models.CharField(max_length=5, blank=True, null=True)
    policy_type_name = models.CharField(max_length=100, blank=True, null=True)
    policy_type_value = models.CharField(max_length=100, blank=True, null=True)
    matrix_table_name = models.CharField(max_length=100, blank=True, null=True)
    policy_type_status = models.CharField(max_length=1, default='Y')

    class Meta:
        managed = False
        db_table = 'policy_type_details'

class CommonPolicyMaster(models.Model):
    policy_id = models.AutoField(primary_key=True)
    # --- CORRECTED FOREIGN KEY ---
    policy_type = models.ForeignKey('PolicyTypeDetails', models.DO_NOTHING, db_column='policy_type_id', blank=True, null=True, db_constraint=False)
    policy_name = models.CharField(max_length=100, blank=True, null=True)
    matrix_id = models.IntegerField(blank=True, null=True)
    matrix_type = models.CharField(max_length=5, blank=True, null=True)
    priority = models.IntegerField(blank=True, null=True)
    active_status = models.CharField(max_length=1, default='Y')
    remarks = models.CharField(max_length=300, blank=True, null=True)
    process_type = models.CharField(max_length=2, blank=True, null=True)
    # Add other fields from your schema as needed

    class Meta:
        managed = False
        db_table = 'common_policy_master'

class RequestMaster(models.Model):
    request_master_id = models.AutoField(primary_key=True)
    user = models.ForeignKey('UserDetails', models.DO_NOTHING, db_column='user_id', blank=True, null=True, db_constraint=False)
    request_type = models.CharField(max_length=20, blank=True, null=True)
    request_type_id = models.IntegerField(default=0)
    trip_type = models.CharField(max_length=1, default='')
    series_type = models.CharField(max_length=2, blank=True, null=True)
    user_currency = models.CharField(max_length=3)
    request_fare = models.FloatField(default=0)
    exchange_rate = models.FloatField(default=0)
    requested_date = models.DateTimeField(blank=True, null=True)
    number_of_passenger = models.IntegerField(blank=True, null=True)
    number_of_adult = models.IntegerField(default=0)
    number_of_child = models.IntegerField(default=0)
    number_of_infant = models.IntegerField(default=0)
    remarks = models.TextField(blank=True, null=True)
    fare_acceptance_transaction_id = models.IntegerField(blank=True, null=True)
    request_source = models.CharField(max_length=100, blank=True, null=True)
    requested_corporate = models.CharField(max_length=100, blank=True, null=True)
    opened_by = models.IntegerField()
    opened_time = models.DateTimeField()
    view_status = models.CharField(max_length=10)
    request_raised_by = models.IntegerField(default=0)
    priority = models.IntegerField(default=0)
    # --- CORRECTED FOREIGN KEY ---
    auto_pilot_policy = models.ForeignKey('CommonPolicyMaster', models.DO_NOTHING, db_column='auto_pilot_policy_id', db_constraint=False)
    auto_pilot_status = models.CharField(max_length=10, default='NA')
    reference_request_master_id = models.IntegerField(default=0)
    quote_type = models.CharField(max_length=2, blank=True, null=True)
    request_group_name = models.CharField(max_length=100, default='')
    group_category_id = models.IntegerField(blank=True, null=True)
    flexible_on_dates = models.CharField(max_length=1, default='N')
    pnr_ignore_status = models.CharField(max_length=1, default='N')
    queue_no = models.IntegerField(default=0)

    class Meta:
        managed = False
        db_table = 'request_master'
