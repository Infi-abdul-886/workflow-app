-- Adminer 5.3.0 MySQL 8.0.42-0ubuntu0.20.04.1 dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;

CREATE TABLE `action_email_mapping` (
  `action_email_mapping_id` int NOT NULL AUTO_INCREMENT,
  `action_master_id` int DEFAULT NULL,
  `from_email_id` varchar(100) DEFAULT NULL,
  `to_email_id` varchar(100) DEFAULT NULL,
  `cc_email_id` varchar(100) DEFAULT NULL,
  `bcc_email_id` varchar(100) DEFAULT NULL,
  `template_id` int DEFAULT NULL COMMENT 'Id to fetch the template from template_details ',
  `status` enum('Y','N') DEFAULT 'Y' COMMENT 'status to enable and disable the mapping',
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`action_email_mapping_id`),
  KEY `action_master_id` (`action_master_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Send the Email to Common email ID';


CREATE TABLE `action_master` (
  `action_master_id` int NOT NULL AUTO_INCREMENT,
  `action_name` varchar(100) DEFAULT NULL,
  `status` char(1) DEFAULT NULL,
  PRIMARY KEY (`action_master_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data for email actions list';


CREATE TABLE `agency_code_details` (
  `agency_code_id` int NOT NULL AUTO_INCREMENT,
  `agency_code` varchar(30) DEFAULT NULL,
  `corporate_id` int DEFAULT NULL,
  `airline_code` char(2) NOT NULL,
  `code_type` enum('PC','AC') NOT NULL DEFAULT 'PC',
  `status` varchar(10) DEFAULT NULL,
  `created_by` varchar(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`agency_code_id`),
  KEY `corporate_id` (`corporate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Stored agency code information for payment its based on corporate level';


CREATE TABLE `agency_code_history` (
  `agency_code_history_id` int NOT NULL AUTO_INCREMENT,
  `agency_code_id` int DEFAULT NULL,
  `agency_code` varchar(30) DEFAULT NULL,
  `corporate_id` int DEFAULT NULL,
  `airline_code` char(2) NOT NULL,
  `code_type` enum('PC','AC') NOT NULL DEFAULT 'PC',
  `status` varchar(10) DEFAULT NULL,
  `created_by` varchar(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`agency_code_history_id`),
  KEY `agency_code_id` (`agency_code_id`),
  KEY `corporate_id` (`corporate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Maintain agency  code history details for payment.';


CREATE TABLE `agency_code_user_mapping` (
  `agency_code_user_mapping_id` int NOT NULL AUTO_INCREMENT,
  `agency_code_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `status` varchar(10) DEFAULT NULL,
  `created_by` varchar(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`agency_code_user_mapping_id`),
  KEY `agency_code_id` (`agency_code_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Stored user level agency code for payment';


CREATE TABLE `agency_payment_failed_history` (
  `agency_payment_failed_id` int NOT NULL AUTO_INCREMENT,
  `payment_master_id` int DEFAULT NULL,
  `request_master_id` int DEFAULT NULL,
  `payment_type_id` int DEFAULT NULL,
  `pnr` varchar(10) DEFAULT NULL,
  `amount_to_pay` double DEFAULT NULL,
  `paid_by` int DEFAULT NULL,
  `agent_id` varchar(200) DEFAULT NULL,
  `pnr_status` varchar(20) DEFAULT NULL,
  `payment_status` varchar(20) DEFAULT NULL,
  `card_authorization` varchar(20) DEFAULT NULL,
  `error` varchar(300) DEFAULT NULL,
  `updated_date` datetime DEFAULT NULL,
  PRIMARY KEY (`agency_payment_failed_id`),
  KEY `payment_master_id` (`payment_master_id`),
  KEY `request_master_id` (`request_master_id`),
  KEY `agent_id` (`agent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Agency payment Failed transaction details';


CREATE TABLE `airlines_request_mapping` (
  `airlines_request_id` int NOT NULL AUTO_INCREMENT,
  `request_master_id` int DEFAULT NULL,
  `corporate_id` int DEFAULT NULL,
  `current_status` int DEFAULT NULL,
  `last_updated` datetime DEFAULT NULL,
  `request_upload_batch_id` int DEFAULT NULL,
  PRIMARY KEY (`airlines_request_id`),
  KEY `request_master_id` (`request_master_id`),
  KEY `current_status` (`current_status`),
  KEY `last_updated` (`last_updated`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Maintain status for all request';


CREATE TABLE `airport_details` (
  `airport_id` int NOT NULL AUTO_INCREMENT,
  `airport_code` char(3) NOT NULL,
  `airport_name` varchar(100) DEFAULT NULL,
  `country_code` varchar(2) NOT NULL,
  `display_status` enum('Y','N') NOT NULL DEFAULT 'Y',
  `user_id` int DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`airport_id`),
  UNIQUE KEY `airport_code` (`airport_code`),
  KEY `city_name` (`airport_name`),
  KEY `country_code` (`country_code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data for airport and city details';


CREATE TABLE `alternate_series_request_details` (
  `alternate_series_request_id` int NOT NULL AUTO_INCREMENT,
  `transaction_master_id` int DEFAULT '0',
  `series_request_id` int DEFAULT '0',
  `request_id` int DEFAULT '0',
  `origin` varchar(3) DEFAULT NULL,
  `destination` varchar(3) DEFAULT NULL,
  `departure_date` date DEFAULT NULL,
  `number_of_passenger` int DEFAULT '0',
  `number_of_adult` int DEFAULT '0',
  `number_of_child` int DEFAULT '0',
  `number_of_infant` int DEFAULT '0',
  `cabin` varchar(20) DEFAULT NULL,
  `start_time` varchar(20) DEFAULT NULL,
  `end_time` varchar(5) DEFAULT NULL,
  `baggage_allowance` varchar(250) DEFAULT NULL,
  `ancillary` char(5) DEFAULT NULL,
  `meals_code` char(5) DEFAULT NULL,
  `pnr` varchar(25) DEFAULT NULL,
  `expected_fare` double DEFAULT NULL,
  `group_category_id` int DEFAULT '0',
  `flight_status` varchar(5) DEFAULT '',
  `response_id` int DEFAULT '0',
  `airlines_request_id` int DEFAULT NULL,
  `mapped_series_request_id` int DEFAULT '0',
  PRIMARY KEY (`alternate_series_request_id`),
  KEY `transaction_master_id` (`transaction_master_id`),
  KEY `series_request_id` (`series_request_id`),
  KEY `request_id` (`request_id`),
  KEY `response_id` (`response_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='For any alternate flights, request details to be stored';


CREATE TABLE `attachment_details` (
  `attachment_id` int NOT NULL AUTO_INCREMENT,
  `attachment_type_id` int NOT NULL,
  `attachment_name` varchar(255) NOT NULL,
  `mime_type` varchar(255) NOT NULL,
  `file_szie` varchar(64) NOT NULL,
  `meta_info` varchar(255) NOT NULL,
  `original_name` varchar(255) NOT NULL,
  PRIMARY KEY (`attachment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `attachment_log` (
  `attachment_log_id` int NOT NULL AUTO_INCREMENT,
  `action` enum('upload','download') NOT NULL,
  `attachment_id` int NOT NULL,
  `user_id` int NOT NULL,
  `create_datetime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP,
  `update_timestamp` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`attachment_log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `attachment_mapping` (
  `attachment_mapping_id` int NOT NULL AUTO_INCREMENT,
  `attachment_type_id` int NOT NULL,
  `attachment_id` int NOT NULL,
  `id` int NOT NULL,
  PRIMARY KEY (`attachment_mapping_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `attachment_type_master` (
  `attachment_type_id` int NOT NULL AUTO_INCREMENT,
  `attachment_type` varchar(64) NOT NULL,
  `attachment_folder` varchar(64) NOT NULL,
  `mapping_ref_table` varchar(64) NOT NULL,
  PRIMARY KEY (`attachment_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `attachment_user_mapping` (
  `attachment_mapping_id` int NOT NULL AUTO_INCREMENT,
  `attachment_id` int NOT NULL,
  `level` enum('user','group','all') NOT NULL,
  `id` int NOT NULL,
  `status` enum('Y','N') NOT NULL,
  `create_timestamp` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP,
  `update_timestamp` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`attachment_mapping_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


SET NAMES utf8mb4;

CREATE TABLE `auth_group` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `auth_group_permissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `auth_permission` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`),
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `authtoken_token` (
  `key` varchar(40) NOT NULL,
  `created` datetime(6) NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`key`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `authtoken_token_user_id_35299eff_fk` FOREIGN KEY (`user_id`) REFERENCES `system_t_users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `auto_pilot_criteria_master` (
  `criteria_id` int NOT NULL AUTO_INCREMENT,
  `criteria_name` varchar(100) DEFAULT NULL,
  `criteria_type` char(3) DEFAULT NULL,
  `display_status` char(1) DEFAULT NULL,
  `negotiation_auto_pilot_display_status` char(1) DEFAULT 'Y' COMMENT 'To display the criteria in negotiation auto pilot policy',
  `criteria_logical_id` varchar(100) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`criteria_id`),
  KEY `criteria_logical_id` (`criteria_logical_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Maintain criteria for auto pilot policy.';


CREATE TABLE `auto_pilot_policy_details` (
  `policy_details_id` int NOT NULL AUTO_INCREMENT,
  `policy_id` int DEFAULT NULL,
  `criteria_id` int DEFAULT NULL,
  `loop_value` int NOT NULL DEFAULT '0',
  `operator_id` int DEFAULT NULL,
  `policy_value` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`policy_details_id`),
  KEY `policy_id` (`policy_id`),
  KEY `operator_id` (`operator_id`),
  KEY `criteria_id` (`criteria_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Its map auto pilot policy and auto pilot criteria details';


CREATE TABLE `auto_pilot_policy_master` (
  `policy_id` int NOT NULL AUTO_INCREMENT,
  `policy_name` varchar(100) DEFAULT NULL,
  `priority` int DEFAULT NULL,
  `active_status` char(1) DEFAULT 'Y',
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `policy_dow` varchar(100) DEFAULT NULL,
  `process_type` varchar(2) DEFAULT 'AD',
  `created_date` datetime DEFAULT NULL,
  `policy_type` char(1) DEFAULT 'A',
  `remarks` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`policy_id`),
  KEY `active_status` (`active_status`),
  KEY `policy_name` (`policy_name`),
  KEY `priority` (`priority`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Maintain auto pilot policy details';


CREATE TABLE `baggage_details` (
  `baggage_id` int NOT NULL AUTO_INCREMENT,
  `baggage_name` varchar(250) DEFAULT NULL,
  `baggage_code` varchar(5) NOT NULL,
  `baggage_cabin` varchar(25) NOT NULL DEFAULT '',
  `baggage_market` varchar(25) NOT NULL DEFAULT '',
  `pax_type` varchar(10) NOT NULL DEFAULT 'Adult',
  `baggage_status` enum('Y','N') NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`baggage_id`),
  KEY `baggage_code` (`baggage_code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data for baggage details';


CREATE TABLE `baggage_mapping` (
  `baggage_mapping_id` int NOT NULL AUTO_INCREMENT,
  `baggage_matrix_id` int DEFAULT NULL,
  `days_to_departure` int DEFAULT NULL,
  `booked_load_factor` int DEFAULT NULL,
  `forecast_load_factor` int DEFAULT '0',
  PRIMARY KEY (`baggage_mapping_id`),
  KEY `baggage_matrix_id` (`baggage_matrix_id`),
  KEY `days_to_departure` (`days_to_departure`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Mapping the days to departure and load factors for baggage';


CREATE TABLE `baggage_matrix` (
  `baggage_matrix_id` int NOT NULL AUTO_INCREMENT,
  `baggage_matrix_name` varchar(50) DEFAULT NULL,
  `status` enum('Y','N','D') DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `load_factor_type` char(5) DEFAULT NULL,
  PRIMARY KEY (`baggage_matrix_id`),
  KEY `status` (`status`),
  KEY `baggage_matrix_name` (`baggage_matrix_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Matrix details for baggage';


CREATE TABLE `baggage_value_mapping` (
  `baggage_value_mapping_id` int NOT NULL AUTO_INCREMENT,
  `baggage_mapping_id` int DEFAULT NULL,
  `group_size` int DEFAULT NULL,
  `baggage_code` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`baggage_value_mapping_id`),
  KEY `baggage_mapping_id` (`baggage_mapping_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='This table maintains group size against baggage_mapping_id';


CREATE TABLE `bank_details` (
  `bank_details_id` int NOT NULL AUTO_INCREMENT,
  `bank_name` varchar(70) DEFAULT NULL,
  `account_number` varchar(20) DEFAULT NULL,
  `branch_code` varchar(50) DEFAULT NULL COMMENT 'Branch code or branch name',
  `beneficiary_name` varchar(50) DEFAULT NULL COMMENT 'Beneficiary name',
  `additional_data` text COMMENT 'Extra information about bank',
  `created_date` datetime DEFAULT NULL,
  `status` enum('Y','N','D') DEFAULT NULL,
  PRIMARY KEY (`bank_details_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data for bank details using for cash mode payment';


CREATE TABLE `bank_pos_mapping` (
  `bank_mapping_id` int NOT NULL AUTO_INCREMENT,
  `bank_details_id` int DEFAULT NULL,
  `pos_id` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`bank_mapping_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Mapping table for bank details with pos id';


CREATE TABLE `batch_details` (
  `batch_id` int NOT NULL AUTO_INCREMENT,
  `request_master_id` int NOT NULL,
  `initiated_by` int DEFAULT NULL,
  `batch_date` datetime NOT NULL,
  `batch_status` varchar(20) NOT NULL DEFAULT '',
  PRIMARY KEY (`batch_id`),
  KEY `request_master_id` (`request_master_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Run batch details for series request';


CREATE TABLE `bid_price_details` (
  `bid_price_id` int NOT NULL AUTO_INCREMENT,
  `request_approved_flight_id` int DEFAULT NULL,
  `via_flight_id` int DEFAULT NULL,
  `bid_fare` double DEFAULT NULL,
  `sold` int DEFAULT NULL,
  `seat_taken` int DEFAULT NULL,
  `bid_price_values` text,
  PRIMARY KEY (`bid_price_id`),
  KEY `via_flight_id` (`via_flight_id`),
  KEY `request_approved_flight_id` (`request_approved_flight_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Bid prices details which is applied for the flight';


CREATE TABLE `billing_details` (
  `payment_id` int DEFAULT NULL,
  `address_one` varchar(40) DEFAULT NULL,
  `address_two` varchar(40) DEFAULT NULL,
  `address_three` varchar(40) DEFAULT NULL,
  `city` varchar(20) DEFAULT NULL,
  `state` varchar(20) DEFAULT NULL,
  `country` varchar(20) DEFAULT NULL,
  `pincode` varchar(6) DEFAULT NULL,
  `area_code` varchar(5) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `mobile` varchar(12) DEFAULT NULL,
  `email_id` varchar(40) DEFAULT NULL,
  KEY `phone` (`phone`),
  KEY `mobile` (`mobile`),
  KEY `payment_id` (`payment_id`),
  KEY `email_id` (`email_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Credit card billing details (need to delete))';


CREATE TABLE `booking_profile_details` (
  `booking_profile_id` int NOT NULL AUTO_INCREMENT,
  `booking_profile_name` varchar(100) DEFAULT NULL,
  `booking_profile_type` char(5) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `load_factor_type` char(5) DEFAULT 'BOTH',
  `currency_type` char(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `active_status` char(1) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`booking_profile_id`),
  KEY `booking_profile_name` (`booking_profile_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Matrix master table for static fare matrix';


CREATE TABLE `cabin_details` (
  `cabin_id` int NOT NULL AUTO_INCREMENT,
  `cabin_name` varchar(250) DEFAULT NULL,
  `cabin_status` enum('Y','N') DEFAULT NULL,
  `cabin_value` varchar(25) DEFAULT NULL,
  `pnr_blocking_class` varchar(5) DEFAULT '',
  PRIMARY KEY (`cabin_id`),
  KEY `cabin_value` (`cabin_value`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data for cabin details (Business / Economy)';


CREATE TABLE `cancel_pnr_details` (
  `cancel_pnr_id` int NOT NULL AUTO_INCREMENT,
  `request_master_id` int NOT NULL DEFAULT '0',
  `request_approved_flight_id` int NOT NULL DEFAULT '0',
  `request_group_id` int DEFAULT '0',
  `pnr` varchar(7) NOT NULL DEFAULT '',
  `cancelled_by` int NOT NULL DEFAULT '0',
  `status` varchar(20) NOT NULL DEFAULT '',
  `cancelled_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cancel_remarks` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`cancel_pnr_id`),
  KEY `request_master_id` (`request_master_id`),
  KEY `pnr` (`pnr`),
  KEY `cancelled_by` (`cancelled_by`),
  KEY `request_approved_flight_id` (`request_approved_flight_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='PNR cancelled details';


CREATE TABLE `cancel_policy_criteria_master` (
  `criteria_id` int NOT NULL AUTO_INCREMENT,
  `criteria_name` varchar(100) NOT NULL,
  `criteria_type` char(3) NOT NULL,
  `display_status` char(1) NOT NULL DEFAULT 'Y',
  `criteria_logical_id` varchar(100) NOT NULL,
  `created_date` datetime NOT NULL,
  PRIMARY KEY (`criteria_id`),
  KEY `criteria_logical_id` (`criteria_logical_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data for T&C policy criteria details';


CREATE TABLE `cancel_policy_details` (
  `cancel_policy_id` int NOT NULL AUTO_INCREMENT,
  `corporate_id` int DEFAULT NULL,
  `cancel_policy_name` varchar(150) DEFAULT NULL,
  `cancel_policy_description` longtext,
  `activation_status` char(1) DEFAULT 'Y',
  `default_status` char(1) DEFAULT 'N',
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  PRIMARY KEY (`cancel_policy_id`),
  KEY `default_status` (`default_status`),
  KEY `corporate_id` (`corporate_id`),
  KEY `activation_status` (`activation_status`),
  KEY `cancel_policy_name` (`cancel_policy_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Store the T&C content and descriptions';


CREATE TABLE `cancel_policy_matrix_details` (
  `cancel_policy_matrix_detail_id` int NOT NULL AUTO_INCREMENT,
  `cancel_policy_matrix_master_id` int NOT NULL,
  `criteria_id` int NOT NULL,
  `loop_value` int NOT NULL DEFAULT '0',
  `operator_id` int NOT NULL,
  `policy_value` varchar(200) NOT NULL,
  PRIMARY KEY (`cancel_policy_matrix_detail_id`),
  KEY `cancel_policy_matrix_master_id` (`cancel_policy_matrix_master_id`),
  KEY `operator_id` (`operator_id`),
  KEY `criteria_id` (`criteria_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='T&C policy criteria value details';


CREATE TABLE `cancel_policy_matrix_master` (
  `cancel_policy_matrix_master_id` int NOT NULL AUTO_INCREMENT,
  `policy_name` varchar(100) NOT NULL,
  `cancel_policy_id` int NOT NULL,
  `priority` int NOT NULL,
  `active_status` char(1) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `created_date` datetime NOT NULL,
  `policy_dow` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`cancel_policy_matrix_master_id`),
  KEY `priority` (`priority`),
  KEY `cancel_policy_id` (`cancel_policy_id`),
  KEY `active_status` (`active_status`),
  KEY `policy_name` (`policy_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='T&C policy master table';


CREATE TABLE `card_details` (
  `payment_id` int DEFAULT NULL,
  `card_type` char(5) DEFAULT NULL,
  `card_number` varchar(30) DEFAULT NULL,
  `cvv_number` varchar(30) DEFAULT NULL,
  `expdate_year` varchar(5) DEFAULT NULL,
  `expdate_mon` varchar(2) DEFAULT NULL,
  `name_on_card` varchar(40) DEFAULT NULL,
  `middle_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  KEY `payment_id` (`payment_id`),
  KEY `card_number` (`card_number`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Store the Credit card informations';


CREATE TABLE `card_details_history` (
  `card_history_id` int NOT NULL AUTO_INCREMENT,
  `payment_id` int DEFAULT NULL,
  `card_type` char(5) DEFAULT NULL,
  `card_number` varchar(100) DEFAULT NULL,
  `cvv_number` varchar(30) DEFAULT NULL,
  `expdate_year` varchar(30) DEFAULT NULL,
  `expdate_mon` varchar(30) DEFAULT NULL,
  `name_on_card` varchar(30) DEFAULT NULL,
  `middle_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `update_date` datetime DEFAULT NULL,
  PRIMARY KEY (`card_history_id`),
  KEY `payment_id` (`payment_id`),
  KEY `card_number` (`card_number`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Failed transaction card details, stored for tracking purpose';


CREATE TABLE `category_subcategory_access_mapping` (
  `issue_category_id` int DEFAULT NULL,
  `issue_subcategory_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  KEY `issue_category_id` (`issue_category_id`),
  KEY `user_id` (`user_id`),
  KEY `issue_subcategory_id` (`issue_subcategory_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Help desk category assigning to airline users';


CREATE TABLE `citizenship_details` (
  `citizenship_id` int NOT NULL AUTO_INCREMENT,
  `citizenship_name` varchar(100) DEFAULT NULL,
  `citizen_code` char(3) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `status` enum('Y','N') DEFAULT 'Y',
  `currency_code` varchar(5) NOT NULL DEFAULT '',
  `phone_code` varchar(10) DEFAULT '',
  PRIMARY KEY (`citizenship_id`),
  UNIQUE KEY `citizen_code` (`citizen_code`),
  KEY `currency_code` (`currency_code`),
  KEY `phone_code` (`phone_code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data for country details';


CREATE TABLE `city_master` (
  `city_id` int NOT NULL AUTO_INCREMENT COMMENT 'Primary key of this table',
  `city_name` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pos_code` varchar(5) NOT NULL,
  `country_code` char(2) DEFAULT NULL,
  `status` enum('Y','N','D') DEFAULT 'Y' COMMENT 'Y-Active,N-Disable,D-Deleted',
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL,
  PRIMARY KEY (`city_id`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table that holds city details';


CREATE TABLE `common_policy_details` (
  `policy_details_id` int NOT NULL AUTO_INCREMENT,
  `policy_id` int DEFAULT NULL COMMENT 'Mapping id from common_policy_master table',
  `criteria_id` int DEFAULT NULL COMMENT 'Mapping id from criteria_master based on selected criteria',
  `operator_id` int DEFAULT NULL COMMENT 'Mapping id from operator_master based on selected condition',
  `policy_value` varchar(200) DEFAULT NULL COMMENT 'Policy value for selected criteria',
  `loop_value` int NOT NULL DEFAULT '0' COMMENT 'Looping value for selected criteria',
  PRIMARY KEY (`policy_details_id`),
  KEY `policy_id` (`policy_id`),
  KEY `criteria_id` (`criteria_id`),
  KEY `operator_id` (`operator_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Common policy details table with criteria values for all policies';


CREATE TABLE `common_policy_master` (
  `policy_id` int NOT NULL AUTO_INCREMENT COMMENT 'Policy id',
  `policy_type_id` int DEFAULT NULL COMMENT 'Mapping id from policy_type_details table to identify the policy type',
  `policy_name` varchar(100) DEFAULT NULL COMMENT 'Name of the policy',
  `matrix_id` int DEFAULT NULL COMMENT 'Matrix id of the mapped matrix in the policy',
  `matrix_type` varchar(5) DEFAULT NULL COMMENT 'Matrix type of the mapped matrix',
  `priority` int DEFAULT NULL COMMENT 'Priority of the policy',
  `active_status` char(1) DEFAULT 'Y' COMMENT 'Active status of the policy Y->Active, N->Inactive',
  `active_date` datetime DEFAULT NULL COMMENT 'Active date of the policy',
  `start_date` datetime DEFAULT NULL COMMENT 'Start date of the policy',
  `end_date` datetime DEFAULT NULL COMMENT 'End date of the policy',
  `created_date` datetime DEFAULT NULL COMMENT 'Created date of the policy',
  `negotiation_status` varchar(1) DEFAULT NULL COMMENT 'Negotiation status Y->Active, N->Inactive',
  `negotiation_limit` varchar(10) DEFAULT NULL COMMENT 'Negotiation limit to be control the request to raise negotiate',
  `materialization_rate` double DEFAULT NULL,
  `conversion_rate` enum('1','0') DEFAULT '0',
  `prediction_type` varchar(5) DEFAULT NULL,
  `process_type` varchar(2) DEFAULT NULL COMMENT 'Process type for the policy',
  `spl_fare_type` varchar(100) DEFAULT NULL,
  `additional_discount` char(1) DEFAULT NULL,
  `policy_dow` varchar(100) DEFAULT NULL COMMENT 'Day of week where the policy apply based on requested day',
  `remarks` varchar(300) DEFAULT NULL COMMENT 'Remarks which is entered while creating the policy',
  `policy_string` text NOT NULL COMMENT 'String for the policy which is matched when policy applied to the request',
  `fare_range` text,
  `additional_details` text CHARACTER SET latin1 COLLATE latin1_swedish_ci COMMENT 'Additional details of the policy',
  `updated_date` datetime DEFAULT NULL COMMENT 'Updated date of the policy',
  `updated_by` int DEFAULT NULL COMMENT 'Updated by this user',
  PRIMARY KEY (`policy_id`),
  KEY `policy_name` (`policy_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Common policy master table for all policies';


CREATE TABLE `competitor_fare_batch_details` (
  `batch_id` int NOT NULL AUTO_INCREMENT,
  `folder_name` varchar(200) DEFAULT NULL,
  `file_count` int DEFAULT NULL,
  `processed_file_count` int DEFAULT NULL,
  `backup_zip_file_name` varchar(200) DEFAULT NULL,
  `batch_type` varchar(10) DEFAULT NULL,
  `status` enum('Y','N') DEFAULT NULL,
  `batch_date` datetime DEFAULT NULL,
  PRIMARY KEY (`batch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Track the competitor files loaded status details';


CREATE TABLE `competitor_fare_batch_file_details` (
  `batch_file_id` int NOT NULL AUTO_INCREMENT,
  `batch_id` int DEFAULT NULL,
  `file_name` varchar(200) DEFAULT NULL,
  `status_msg` varchar(200) DEFAULT NULL,
  `status` enum('Y','N') DEFAULT NULL,
  `moved_date` datetime DEFAULT NULL,
  PRIMARY KEY (`batch_file_id`),
  KEY `batch_id` (`batch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Status of the competitor(INFARE) file uploaded details';


CREATE TABLE `competitor_flight_details` (
  `competitor_flight_id` int NOT NULL AUTO_INCREMENT,
  `batch_id` int DEFAULT NULL,
  `batch_file_id` int DEFAULT NULL,
  `origin` varchar(3) DEFAULT NULL,
  `destination` varchar(3) DEFAULT NULL,
  `carrier` varchar(5) DEFAULT NULL,
  `trip_type` char(1) DEFAULT NULL,
  `onward_departure_date` date DEFAULT NULL,
  `onward_departure_time` time DEFAULT NULL,
  `onward_arrival_date` date DEFAULT NULL,
  `onward_arrival_time` time DEFAULT NULL,
  `return_departure_date` date DEFAULT NULL,
  `return_departure_time` time DEFAULT NULL,
  `return_arrival_date` date DEFAULT NULL,
  `return_arrival_time` time DEFAULT NULL,
  `onward_stop` int DEFAULT NULL,
  `onward_flight` varchar(20) DEFAULT NULL,
  `onward_class` varchar(20) DEFAULT NULL,
  `return_stop` int DEFAULT NULL,
  `return_flight` varchar(20) DEFAULT NULL,
  `return_class` varchar(20) DEFAULT NULL,
  `currency_code` varchar(5) DEFAULT NULL,
  `base_fare` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `total_fare` double DEFAULT NULL,
  `status` enum('Y','N') DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`competitor_flight_id`),
  KEY `batch_id` (`batch_id`),
  KEY `batch_file_id` (`batch_file_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Airline competitor flight and fare details';


CREATE TABLE `competitor_flight_details_temp` (
  `competitor_flight_id` int NOT NULL AUTO_INCREMENT,
  `batch_id` int DEFAULT NULL,
  `batch_file_id` int DEFAULT NULL,
  `origin` varchar(3) DEFAULT NULL,
  `destination` varchar(3) DEFAULT NULL,
  `carrier` varchar(5) DEFAULT NULL,
  `trip_type` char(1) DEFAULT NULL,
  `onward_departure_date` date DEFAULT NULL,
  `onward_departure_time` time DEFAULT NULL,
  `onward_arrival_date` date DEFAULT NULL,
  `onward_arrival_time` time DEFAULT NULL,
  `return_departure_date` date DEFAULT NULL,
  `return_departure_time` time DEFAULT NULL,
  `return_arrival_date` date DEFAULT NULL,
  `return_arrival_time` time DEFAULT NULL,
  `onward_stop` int DEFAULT NULL,
  `onward_flight` varchar(20) DEFAULT NULL,
  `onward_class` varchar(20) DEFAULT NULL,
  `return_stop` int DEFAULT NULL,
  `return_flight` varchar(20) DEFAULT NULL,
  `return_class` varchar(20) DEFAULT NULL,
  `currency_code` varchar(5) DEFAULT NULL,
  `base_fare` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `total_fare` double DEFAULT NULL,
  `status` enum('Y','N') DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`competitor_flight_id`),
  KEY `batch_id` (`batch_id`),
  KEY `batch_file_id` (`batch_file_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Load the competitor data from CSV to table';


CREATE TABLE `competitor_policy_criteria_master` (
  `criteria_id` int NOT NULL AUTO_INCREMENT,
  `criteria_name` varchar(100) DEFAULT NULL,
  `criteria_type` char(3) DEFAULT NULL,
  `display_status` enum('Y','N') DEFAULT NULL,
  `logical_name` varchar(100) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`criteria_id`),
  KEY `logical_name` (`logical_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data of criteria details for Competitor fares';


CREATE TABLE `competitor_policy_details` (
  `policy_details_id` int NOT NULL AUTO_INCREMENT,
  `policy_id` int DEFAULT NULL,
  `criteria_id` int DEFAULT NULL,
  `loop_value` int DEFAULT '0',
  `operator_id` int DEFAULT NULL,
  `policy_value` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`policy_details_id`),
  KEY `policy_id` (`policy_id`),
  KEY `criteria_id` (`criteria_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Competitor fare criteria values mapping';


CREATE TABLE `competitor_policy_master` (
  `policy_id` int NOT NULL AUTO_INCREMENT,
  `policy_name` varchar(100) DEFAULT NULL,
  `competitor_rule_master_id` int DEFAULT NULL,
  `priority` int DEFAULT NULL,
  `active_date` datetime DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `policy_dow` varchar(100) DEFAULT NULL,
  `active_status` enum('Y','N','D') DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`policy_id`),
  KEY `policy_name` (`policy_name`),
  KEY `competitor_rule_master_id` (`competitor_rule_master_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Competitor fare policy master table to store the policy information';


CREATE TABLE `competitor_rule_airline_details` (
  `competitor_rule_airline_id` int NOT NULL AUTO_INCREMENT,
  `competitor_rule_master_id` int DEFAULT NULL,
  `airline_code` varchar(7) DEFAULT NULL,
  `flight_number` varchar(7) DEFAULT NULL,
  `departure_operator` varchar(15) DEFAULT NULL,
  `depart_time_range` varchar(15) DEFAULT NULL,
  `depart_fare_validity_type_id` varchar(15) DEFAULT NULL,
  `arrival_operator` varchar(15) DEFAULT NULL,
  `arrival_time_range` varchar(15) DEFAULT NULL,
  `arrival_fare_validity_type_id` varchar(15) DEFAULT NULL,
  `additive_factor` double DEFAULT NULL,
  `multiplicative_factor` double DEFAULT NULL,
  `priority` int DEFAULT NULL,
  `active_status` enum('Y','N','D') DEFAULT NULL,
  PRIMARY KEY (`competitor_rule_airline_id`),
  KEY `competitor_rule_master_id` (`competitor_rule_master_id`),
  KEY `airline_code` (`airline_code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Competitor fare flight details and the calculations setup';


CREATE TABLE `competitor_rule_criteria_master` (
  `competitor_criteria_id` int NOT NULL AUTO_INCREMENT,
  `competitor_criteria_name` varchar(50) DEFAULT NULL,
  `criteria_type` char(3) DEFAULT NULL,
  `show_status` enum('B','T') DEFAULT NULL,
  `display_status` enum('Y','N') DEFAULT NULL,
  `criteria_logic_name` varchar(50) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`competitor_criteria_id`),
  KEY `criteria_logic_name` (`criteria_logic_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data for competitor criteria details';


CREATE TABLE `competitor_rule_details` (
  `competitor_rule_id` int NOT NULL AUTO_INCREMENT,
  `competitor_rule_master_id` int DEFAULT NULL,
  `competitor_criteria_id` int DEFAULT NULL,
  `loop_value` int DEFAULT '0',
  `operator_id` int DEFAULT NULL,
  `competitor_criteria_value` varchar(200) DEFAULT NULL,
  `fare_validity_type_id` int DEFAULT NULL,
  PRIMARY KEY (`competitor_rule_id`),
  KEY `competitor_rule_master_id` (`competitor_rule_master_id`),
  KEY `competitor_criteria_id` (`competitor_criteria_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Setup the rules / values based on selected competitor criterias';


CREATE TABLE `competitor_rule_master` (
  `competitor_rule_master_id` int NOT NULL AUTO_INCREMENT,
  `competitor_rule_name` varchar(20) DEFAULT NULL,
  `minimum_fare` double DEFAULT NULL,
  `maximum_fare` double DEFAULT NULL,
  `calculate_using` enum('B','T') DEFAULT NULL,
  `include_connecting_flights` enum('Y','N') DEFAULT NULL,
  `include_hub` enum('Y','N') DEFAULT NULL,
  `fare_taken` varchar(3) NOT NULL DEFAULT 'PRI',
  `active_status` enum('Y','N','D') DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`competitor_rule_master_id`),
  KEY `competitor_rule_name` (`competitor_rule_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Rules for competitor fares and their calculation definitions';


CREATE TABLE `competitor_time_frame_details` (
  `competitor_time_frame_id` int NOT NULL AUTO_INCREMENT,
  `origin` varchar(3) DEFAULT NULL,
  `destination` varchar(3) DEFAULT NULL,
  `carrier` varchar(5) DEFAULT NULL,
  `interval_value` int DEFAULT NULL,
  `interval_type` varchar(10) DEFAULT NULL,
  `status` char(1) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`competitor_time_frame_id`),
  KEY `status` (`status`),
  KEY `origin` (`origin`),
  KEY `destination` (`destination`),
  KEY `carrier` (`carrier`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Time frame details are stored ';


CREATE TABLE `competitor_via_flight_details` (
  `competitor_via_flight_id` int NOT NULL AUTO_INCREMENT,
  `competitor_flight_id` int DEFAULT NULL,
  `origin` varchar(3) DEFAULT NULL,
  `destination` varchar(3) DEFAULT NULL,
  `carrier` varchar(5) DEFAULT NULL,
  `flight` varchar(20) DEFAULT NULL,
  `travel_type` char(1) DEFAULT NULL,
  `departure_date` date DEFAULT NULL,
  `departure_time` time DEFAULT NULL,
  `arrival_date` date DEFAULT NULL,
  `arrival_time` time DEFAULT NULL,
  `class` varchar(20) DEFAULT NULL,
  `currency_code` varchar(5) DEFAULT NULL,
  `base_fare` double DEFAULT NULL,
  `tax` double DEFAULT NULL,
  `total_fare` double DEFAULT NULL,
  `segment_order` tinyint DEFAULT NULL,
  PRIMARY KEY (`competitor_via_flight_id`),
  KEY `competitor_flight_id` (`competitor_flight_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Airline competitor via flight and fare details';


CREATE TABLE `contract_manager_details` (
  `contract_detail_id` int NOT NULL AUTO_INCREMENT,
  `contract_manager_master_id` int DEFAULT NULL,
  `contract_type` varchar(25) NOT NULL,
  `contract_value` mediumtext,
  PRIMARY KEY (`contract_detail_id`),
  KEY `contract_manager_master_id` (`contract_manager_master_id`),
  KEY `contract_type` (`contract_type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `contract_manager_master` (
  `contract_manager_master_id` int NOT NULL AUTO_INCREMENT,
  `contract_manager_name` varchar(100) DEFAULT NULL,
  `priority` int DEFAULT NULL,
  `activation_status` enum('Y','N','H','D') DEFAULT 'Y',
  `default_status` enum('Y','N') DEFAULT 'Y',
  `created_by` int NOT NULL,
  `created_date` datetime DEFAULT '0000-00-00 00:00:00',
  `updated_by` int NOT NULL,
  `updated_date` datetime DEFAULT '0000-00-00 00:00:00',
  `history_id` int NOT NULL,
  PRIMARY KEY (`contract_manager_master_id`),
  KEY `activation_status` (`activation_status`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `corporate_details` (
  `corporate_id` int NOT NULL AUTO_INCREMENT,
  `corporate_type_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `corporate_name` varchar(100) DEFAULT NULL,
  `agent_name` varchar(52) DEFAULT NULL,
  `iata_code` varchar(36) DEFAULT NULL,
  `pcc_code` varchar(36) DEFAULT NULL,
  `airlines_code` varchar(3) DEFAULT '0',
  `corporate_address` varchar(256) DEFAULT NULL,
  `fax` varchar(32) DEFAULT NULL,
  `office_number` varchar(32) DEFAULT NULL,
  `corporate_status` enum('Y','N','P','D') NOT NULL DEFAULT 'N',
  `created_date` datetime DEFAULT NULL,
  `time_zone_interval` varchar(40) DEFAULT '',
  `time_zone_key` varchar(352) DEFAULT '',
  `pos_code` varchar(32) DEFAULT NULL,
  `customer_category_id` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`corporate_id`),
  KEY `user_id` (`user_id`),
  KEY `pos_code` (`pos_code`),
  KEY `iata_code` (`iata_code`),
  KEY `pcc_code` (`pcc_code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Travel agency, Airline and Retail details';


CREATE TABLE `corporate_extjs_reports` (
  `report_id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `corporate_id` int DEFAULT NULL,
  `report_name` varchar(100) DEFAULT NULL,
  `report_file_name` varchar(100) DEFAULT NULL,
  `view_name` varchar(100) DEFAULT NULL,
  `created_by` int unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`report_id`),
  KEY `corporate_id` (`corporate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Storing the Custom report saved information';


CREATE TABLE `corporate_home_page_details` (
  `corporate_id` int DEFAULT NULL,
  `header_tpl_name` varchar(50) DEFAULT NULL,
  `footer_tpl_name` varchar(50) DEFAULT NULL,
  `landing_status` varchar(3) DEFAULT NULL COMMENT 'AL - After Login and BL - Before login',
  KEY `corporate_id` (`corporate_id`),
  KEY `landing_status` (`landing_status`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Show the Header and footer based on the airlines';


CREATE TABLE `corporate_module_settings` (
  `corporate_id` int DEFAULT NULL,
  `group_id` int DEFAULT NULL,
  `module_id` int DEFAULT NULL,
  `template_id` int DEFAULT NULL,
  `target_template_id` int DEFAULT NULL,
  KEY `corporate_id` (`corporate_id`),
  KEY `group_id` (`group_id`),
  KEY `module_id` (`module_id`),
  KEY `template_id` (`template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='To change the templates based on group ID';


CREATE TABLE `corporate_salesperson_mapping` (
  `salesperson_mapping_id` int NOT NULL AUTO_INCREMENT,
  `corporate_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  PRIMARY KEY (`salesperson_mapping_id`),
  KEY `corporate_id` (`corporate_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Travel agency and sales person mapping (Need to delete)';


CREATE TABLE `corporate_submenu_settings` (
  `corporate_submenu_settings_id` int NOT NULL AUTO_INCREMENT,
  `corporate_id` int NOT NULL DEFAULT '0',
  `group_id` int NOT NULL DEFAULT '0',
  `user_id` int NOT NULL DEFAULT '0',
  `submenu_id` int NOT NULL DEFAULT '0',
  `submenu_name` varchar(50) DEFAULT NULL,
  `submenu_link` varchar(100) DEFAULT NULL,
  `menu_id` int DEFAULT NULL,
  `display_status` char(3) DEFAULT NULL,
  `display_order` int DEFAULT NULL,
  PRIMARY KEY (`corporate_submenu_settings_id`),
  KEY `corporate_id` (`corporate_id`),
  KEY `group_id` (`group_id`),
  KEY `user_id` (`user_id`),
  KEY `submenu_id` (`submenu_id`),
  KEY `menu_id` (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='To customize the menu based on group, users, travel agency level';


CREATE TABLE `corporate_type_details` (
  `corporate_type_id` int NOT NULL AUTO_INCREMENT,
  `corporate_type_name` varchar(30) DEFAULT NULL,
  `status` enum('Y','N') DEFAULT 'Y',
  PRIMARY KEY (`corporate_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master date for customer types Airline, Travel agent and Retail users';


CREATE TABLE `criteria_master` (
  `criteria_id` int NOT NULL AUTO_INCREMENT,
  `criteria_name` varchar(100) DEFAULT NULL,
  `criteria_type` char(3) DEFAULT NULL,
  `display_status` char(1) DEFAULT 'Y',
  `criteria_logical_id` varchar(100) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `surcharge_status` enum('Y','N') DEFAULT 'Y',
  `farerequote` enum('Y','N') DEFAULT 'Y',
  `negotiateAutoPilot` enum('Y','N') DEFAULT 'Y',
  `aggregateFunction` enum('Y','N') DEFAULT 'Y',
  `autoPilotPolicy` enum('Y','N') DEFAULT 'Y',
  `cancelPolicy` enum('Y','N') DEFAULT 'Y',
  `timeLinePolicy` enum('Y','N') DEFAULT 'Y',
  `negotiationPolicy` enum('Y','N') DEFAULT 'Y',
  `nameUpdatePolicy` enum('Y','N') DEFAULT 'Y',
  `farePolicy` enum('Y','N') DEFAULT 'Y',
  `predictionPolicy` enum('Y','N') NOT NULL DEFAULT 'Y',
  `fareClassPolicy` enum('Y','N') CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT 'N',
  `fareBasisPolicy` enum('Y','N') CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT 'N',
  `contractManager` enum('Y','N') DEFAULT 'Y',
  `baggagePolicy` enum('Y','N') DEFAULT 'Y',
  `fareRangePolicy` enum('Y','N') DEFAULT 'N',
  PRIMARY KEY (`criteria_id`),
  KEY `display_status` (`display_status`),
  KEY `criteria_logical_id` (`criteria_logical_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data for Discount and surcharge criteria. Default criteria master table';


CREATE TABLE `cron_email_details` (
  `cron_email_id` int NOT NULL AUTO_INCREMENT,
  `request_master_id` int NOT NULL,
  `email_type` int NOT NULL DEFAULT '0',
  `email_subject` varchar(50) NOT NULL,
  `sent_to` varchar(70) NOT NULL,
  `expiry_date` varchar(20) NOT NULL,
  `sent_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `pnr` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`cron_email_id`),
  KEY `request_master_id` (`request_master_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='To maintain the log for Fare, payment and passenger name list submission expiry remainder alert';


CREATE TABLE `cron_update_pnr_details` (
  `cron_update_pnr_id` int NOT NULL AUTO_INCREMENT,
  `request_master_id` int NOT NULL DEFAULT '0',
  `series_request_id` int NOT NULL DEFAULT '0',
  `pnr_updated_status` varchar(15) NOT NULL DEFAULT '',
  `pnr_updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`cron_update_pnr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `currency_details` (
  `currency_id` int NOT NULL AUTO_INCREMENT,
  `currency_type` varchar(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `currency_symbol` varchar(5) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `exchange_rate` double NOT NULL,
  `decimal_precision` int NOT NULL DEFAULT '2',
  `display_order` int NOT NULL DEFAULT '0',
  `created_date` date NOT NULL,
  `currency_status` enum('y','n','d') NOT NULL DEFAULT 'y',
  PRIMARY KEY (`currency_id`),
  UNIQUE KEY `currency_type` (`currency_type`),
  KEY `currency_status` (`currency_status`),
  KEY `display_order` (`display_order`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master date for currency list';


CREATE TABLE `currency_mapping` (
  `currency_mapping_id` int NOT NULL AUTO_INCREMENT,
  `pos_id` int NOT NULL COMMENT 'Refer from pos_details',
  `currency_id` int NOT NULL COMMENT 'Refer from currency_details',
  `country_code` varchar(3) NOT NULL COMMENT 'country code for selected pos',
  `display_in_request` enum('Y','N') NOT NULL COMMENT 'To show in request page',
  `display_in_payment` varchar(4) NOT NULL COMMENT 'To show in payment page',
  PRIMARY KEY (`currency_mapping_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Currency mapping for choosing different currency';


CREATE TABLE `custom_report_details` (
  `custom_report_id` int NOT NULL AUTO_INCREMENT COMMENT 'Report id',
  `report_type` varchar(30) NOT NULL COMMENT 'Report type ',
  `report_type_language` varchar(100) NOT NULL COMMENT 'Report type language text',
  `based_on` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL COMMENT 'Report based on value',
  `parent_id` int DEFAULT NULL COMMENT 'Parent report id',
  `display_status` enum('Y','N') NOT NULL DEFAULT 'Y' COMMENT 'Report is enable or disable',
  `default_selected` enum('Y','N') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT 'N' COMMENT 'Dynamic filter for the columns',
  `menu_id` int DEFAULT NULL,
  PRIMARY KEY (`custom_report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Define various reports in custom report';


CREATE TABLE `custom_report_values` (
  `custom_report_values_id` int NOT NULL AUTO_INCREMENT COMMENT 'Value id ',
  `values_name` varchar(300) NOT NULL COMMENT 'Value name',
  `values_language` varchar(300) NOT NULL COMMENT 'Value language text',
  `service_name` varchar(300) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Service value to call from frontend for a particual values_functionality',
  `values_functionality` enum('A','D','H','M','T','DD','R') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT 'T' COMMENT 'Values functionality name (A - Autocomplete , D - Datepicker , M - Multiselect , T - Text , DD - Dropdown)',
  `values_type` enum('F','C','H') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT 'F' COMMENT 'Type of each value (F-Field,C-Condition,H-Header)',
  `display_status` enum('Y','N') NOT NULL DEFAULT 'Y' COMMENT 'Values is enable or disable',
  PRIMARY KEY (`custom_report_values_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='This table consist of all fields and conditions for all custom reports';


CREATE TABLE `custom_report_values_mapping` (
  `custom_report_values_mapping_id` int NOT NULL AUTO_INCREMENT COMMENT 'Values mapping id',
  `custom_report_values_id` int NOT NULL COMMENT 'Values reference id from custom_report_values table',
  `custom_report_id` int NOT NULL COMMENT 'Report reference id from custom_report_details table',
  `header_id` int NOT NULL COMMENT 'Header type value id from `custom_report_values`',
  `parent_id` int DEFAULT NULL,
  `corporate_id` int NOT NULL COMMENT 'Corporate id to display the fields and conditions ',
  `group_id` int NOT NULL COMMENT 'Group id to display the fields and conditions ',
  `user_id` int NOT NULL COMMENT 'User id to display the fields and conditions ',
  `display_status` enum('Y','N') NOT NULL COMMENT 'Mapping is disable or enable',
  `menu_id` int DEFAULT NULL,
  PRIMARY KEY (`custom_report_values_mapping_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='This table is used for mapping the fields and conditions values with respective reports based on its id reference from custom_report_details and custom_report_values table ';


CREATE TABLE `customer_category` (
  `customer_category_id` tinyint(1) NOT NULL AUTO_INCREMENT,
  `customer_category_name` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `status` enum('Y','N') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `created_date` datetime NOT NULL,
  `updated_date` datetime NOT NULL,
  PRIMARY KEY (`customer_category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `customer_insight_master` (
  `customer_insight_id` int NOT NULL AUTO_INCREMENT,
  `request_master_id` int DEFAULT NULL,
  `pnr` varchar(6) DEFAULT NULL,
  `unique_id` varchar(100) DEFAULT NULL,
  `login_id` varchar(100) DEFAULT NULL,
  `account_password` varchar(100) DEFAULT NULL,
  `created_date` timestamp NULL DEFAULT NULL,
  `status` enum('CIP','TBA','TKT') DEFAULT 'CIP',
  PRIMARY KEY (`customer_insight_id`),
  KEY `request_master_id` (`request_master_id`),
  KEY `unique_id` (`unique_id`),
  KEY `login_id` (`login_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='To create the Travel Bank account for travel agents';


CREATE TABLE `daily_product_details` (
  `daily_product_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int DEFAULT NULL,
  `booking_profile_id` int DEFAULT NULL,
  `cabin_code` char(1) DEFAULT NULL,
  `date_departure` date DEFAULT NULL,
  `time_departure` varchar(5) DEFAULT NULL,
  `time_arrival` varchar(5) DEFAULT NULL,
  `capacity` int DEFAULT NULL,
  `current_bookings` int DEFAULT NULL,
  `booking_fare` double DEFAULT NULL,
  `last_updated_date` datetime DEFAULT NULL,
  PRIMARY KEY (`daily_product_id`),
  KEY `cabin_code` (`cabin_code`),
  KEY `capacity` (`capacity`),
  KEY `booking_profile_id` (`booking_profile_id`),
  KEY `product_id` (`product_id`),
  KEY `current_bookings` (`current_bookings`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Used for static fare calculation (need to delete)';


CREATE TABLE `discount_fare_mapping` (
  `discount_fare_id` int NOT NULL AUTO_INCREMENT,
  `discount_mapping_id` int DEFAULT NULL,
  `group_size` int DEFAULT NULL,
  `discount_fare` double DEFAULT NULL,
  PRIMARY KEY (`discount_fare_id`),
  KEY `group_size` (`group_size`),
  KEY `discount_mapping_id` (`discount_mapping_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Mapping the discount fare and group size for discount matrix';


CREATE TABLE `discount_mapping_details` (
  `discount_mapping_id` int NOT NULL AUTO_INCREMENT,
  `discount_matrix_id` int DEFAULT NULL,
  `days_to_departure` int DEFAULT NULL,
  `booked_load_factor` int DEFAULT NULL,
  `forecast_load_factor` int DEFAULT '0',
  PRIMARY KEY (`discount_mapping_id`),
  KEY `discount_matrix_id` (`discount_matrix_id`),
  KEY `booked_load_factor` (`booked_load_factor`),
  KEY `days_to_departure` (`days_to_departure`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Mapping the days to departure and load factors for discount';


CREATE TABLE `discount_matrix` (
  `discount_matrix_id` int NOT NULL AUTO_INCREMENT,
  `discount_matrix_name` varchar(50) DEFAULT NULL,
  `discount_matrix_type` char(5) DEFAULT NULL,
  `currency_type` char(5) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `status` enum('Y','N','D') DEFAULT NULL,
  `load_factor_type` char(5) DEFAULT NULL,
  PRIMARY KEY (`discount_matrix_id`),
  KEY `status` (`status`),
  KEY `discount_matrix_name` (`discount_matrix_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Matrix details for discount';


CREATE TABLE `django_admin_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint unsigned NOT NULL,
  `change_message` longtext NOT NULL,
  `content_type_id` int DEFAULT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  KEY `django_admin_log_user_id_c564eba6_fk` (`user_id`),
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk` FOREIGN KEY (`user_id`) REFERENCES `system_t_users` (`id`),
  CONSTRAINT `django_admin_log_chk_1` CHECK ((`action_flag` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `django_apscheduler_djangojob` (
  `id` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `next_run_time` datetime(6) DEFAULT NULL,
  `job_state` longblob NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_apscheduler_djangojob_next_run_time_2f022619` (`next_run_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `django_apscheduler_djangojobexecution` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `status` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL,
  `run_time` datetime(6) NOT NULL,
  `duration` decimal(15,2) DEFAULT NULL,
  `finished` decimal(15,2) DEFAULT NULL,
  `exception` varchar(1000) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `traceback` longtext COLLATE utf8mb3_unicode_ci,
  `job_id` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_job_executions` (`job_id`,`run_time`),
  KEY `django_apscheduler_djangojobexecution_run_time_16edd96b` (`run_time`),
  CONSTRAINT `django_apscheduler_djangojobexecution_job_id_daf5090a_fk` FOREIGN KEY (`job_id`) REFERENCES `django_apscheduler_djangojob` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `django_celery_beat_clockedschedule` (
  `id` int NOT NULL AUTO_INCREMENT,
  `clocked_time` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `django_celery_beat_crontabschedule` (
  `id` int NOT NULL AUTO_INCREMENT,
  `minute` varchar(240) COLLATE utf8mb3_unicode_ci NOT NULL,
  `hour` varchar(96) COLLATE utf8mb3_unicode_ci NOT NULL,
  `day_of_week` varchar(64) COLLATE utf8mb3_unicode_ci NOT NULL,
  `day_of_month` varchar(124) COLLATE utf8mb3_unicode_ci NOT NULL,
  `month_of_year` varchar(64) COLLATE utf8mb3_unicode_ci NOT NULL,
  `timezone` varchar(63) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `django_celery_beat_intervalschedule` (
  `id` int NOT NULL AUTO_INCREMENT,
  `every` int NOT NULL,
  `period` varchar(24) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `django_celery_beat_periodictask` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(200) COLLATE utf8mb3_unicode_ci NOT NULL,
  `task` varchar(200) COLLATE utf8mb3_unicode_ci NOT NULL,
  `args` longtext COLLATE utf8mb3_unicode_ci NOT NULL,
  `kwargs` longtext COLLATE utf8mb3_unicode_ci NOT NULL,
  `queue` varchar(200) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `exchange` varchar(200) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `routing_key` varchar(200) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `expires` datetime(6) DEFAULT NULL,
  `enabled` tinyint(1) NOT NULL,
  `last_run_at` datetime(6) DEFAULT NULL,
  `total_run_count` int unsigned NOT NULL,
  `date_changed` datetime(6) NOT NULL,
  `description` longtext COLLATE utf8mb3_unicode_ci NOT NULL,
  `crontab_id` int DEFAULT NULL,
  `interval_id` int DEFAULT NULL,
  `solar_id` int DEFAULT NULL,
  `one_off` tinyint(1) NOT NULL,
  `start_time` datetime(6) DEFAULT NULL,
  `priority` int unsigned DEFAULT NULL,
  `headers` longtext COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT (_utf8mb3'{}'),
  `clocked_id` int DEFAULT NULL,
  `expire_seconds` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `django_celery_beat_p_crontab_id_d3cba168_fk_django_ce` (`crontab_id`),
  KEY `django_celery_beat_p_interval_id_a8ca27da_fk_django_ce` (`interval_id`),
  KEY `django_celery_beat_p_solar_id_a87ce72c_fk_django_ce` (`solar_id`),
  KEY `django_celery_beat_p_clocked_id_47a69f82_fk_django_ce` (`clocked_id`),
  CONSTRAINT `django_celery_beat_p_clocked_id_47a69f82_fk_django_ce` FOREIGN KEY (`clocked_id`) REFERENCES `django_celery_beat_clockedschedule` (`id`),
  CONSTRAINT `django_celery_beat_p_crontab_id_d3cba168_fk_django_ce` FOREIGN KEY (`crontab_id`) REFERENCES `django_celery_beat_crontabschedule` (`id`),
  CONSTRAINT `django_celery_beat_p_interval_id_a8ca27da_fk_django_ce` FOREIGN KEY (`interval_id`) REFERENCES `django_celery_beat_intervalschedule` (`id`),
  CONSTRAINT `django_celery_beat_p_solar_id_a87ce72c_fk_django_ce` FOREIGN KEY (`solar_id`) REFERENCES `django_celery_beat_solarschedule` (`id`),
  CONSTRAINT `django_celery_beat_periodictask_chk_1` CHECK ((`total_run_count` >= 0)),
  CONSTRAINT `django_celery_beat_periodictask_chk_2` CHECK ((`priority` >= 0)),
  CONSTRAINT `django_celery_beat_periodictask_chk_3` CHECK ((`expire_seconds` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `django_celery_beat_periodictasks` (
  `ident` smallint NOT NULL,
  `last_update` datetime(6) NOT NULL,
  PRIMARY KEY (`ident`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `django_celery_beat_solarschedule` (
  `id` int NOT NULL AUTO_INCREMENT,
  `event` varchar(24) COLLATE utf8mb3_unicode_ci NOT NULL,
  `latitude` decimal(9,6) NOT NULL,
  `longitude` decimal(9,6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_celery_beat_solar_event_latitude_longitude_ba64999a_uniq` (`event`,`latitude`,`longitude`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `django_celery_results_chordcounter` (
  `id` int NOT NULL AUTO_INCREMENT,
  `group_id` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `sub_tasks` longtext COLLATE utf8mb3_unicode_ci NOT NULL,
  `count` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `group_id` (`group_id`),
  CONSTRAINT `django_celery_results_chordcounter_chk_1` CHECK ((`count` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `django_celery_results_groupresult` (
  `id` int NOT NULL AUTO_INCREMENT,
  `group_id` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `date_created` datetime(6) NOT NULL,
  `date_done` datetime(6) NOT NULL,
  `content_type` varchar(128) COLLATE utf8mb3_unicode_ci NOT NULL,
  `content_encoding` varchar(64) COLLATE utf8mb3_unicode_ci NOT NULL,
  `result` longtext COLLATE utf8mb3_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `group_id` (`group_id`),
  KEY `django_cele_date_cr_bd6c1d_idx` (`date_created`),
  KEY `django_cele_date_do_caae0e_idx` (`date_done`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `django_celery_results_taskresult` (
  `id` int NOT NULL AUTO_INCREMENT,
  `task_id` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `status` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL,
  `content_type` varchar(128) COLLATE utf8mb3_unicode_ci NOT NULL,
  `content_encoding` varchar(64) COLLATE utf8mb3_unicode_ci NOT NULL,
  `result` longtext COLLATE utf8mb3_unicode_ci,
  `date_done` datetime(6) NOT NULL,
  `traceback` longtext COLLATE utf8mb3_unicode_ci,
  `meta` longtext COLLATE utf8mb3_unicode_ci,
  `task_args` longtext COLLATE utf8mb3_unicode_ci,
  `task_kwargs` longtext COLLATE utf8mb3_unicode_ci,
  `task_name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `worker` varchar(100) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `date_created` datetime(6) NOT NULL,
  `periodic_task_name` varchar(255) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `date_started` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `task_id` (`task_id`),
  KEY `django_cele_task_na_08aec9_idx` (`task_name`),
  KEY `django_cele_status_9b6201_idx` (`status`),
  KEY `django_cele_worker_d54dd8_idx` (`worker`),
  KEY `django_cele_date_cr_f04a50_idx` (`date_created`),
  KEY `django_cele_date_do_f59aad_idx` (`date_done`),
  KEY `django_cele_periodi_1993cf_idx` (`periodic_task_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `django_content_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `django_migrations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_expire_date_a5c62663` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `edit_user_history` (
  `edit_user_history_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `updated_by` int NOT NULL,
  `previous_user_details` text,
  `time_stamp` datetime DEFAULT NULL,
  `user_status` enum('P','U') NOT NULL DEFAULT 'U' COMMENT 'P-passenger, U-User',
  PRIMARY KEY (`edit_user_history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='History table to maintain user action';


CREATE TABLE `email_setting` (
  `email_setting_id` int NOT NULL AUTO_INCREMENT,
  `email_type` varchar(200) DEFAULT NULL,
  `display_status` char(1) DEFAULT NULL,
  `setting_status` char(1) DEFAULT NULL,
  `display_order` tinyint DEFAULT NULL,
  PRIMARY KEY (`email_setting_id`),
  KEY `display_status` (`display_status`),
  KEY `setting_status` (`setting_status`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for email type';


CREATE TABLE `email_template_details` (
  `email_template_id` int NOT NULL AUTO_INCREMENT,
  `corporate_id` int NOT NULL DEFAULT '0',
  `group_id` int NOT NULL DEFAULT '0',
  `email_setting_id` int NOT NULL DEFAULT '0',
  `template_id` int NOT NULL DEFAULT '0',
  `display_status` varchar(5) DEFAULT '',
  PRIMARY KEY (`email_template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for email template details';


CREATE TABLE `email_tracking_details` (
  `tracking_id` int NOT NULL AUTO_INCREMENT,
  `group_request_id` varchar(25) DEFAULT NULL,
  `email_type` int DEFAULT NULL,
  `from_email_id` varchar(200) DEFAULT NULL,
  `to_email_id` varchar(200) DEFAULT NULL,
  `to_user_id` int DEFAULT '0',
  `status` char(1) DEFAULT 'N',
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`tracking_id`),
  KEY `status` (`status`),
  KEY `email_type` (`email_type`),
  KEY `to_user_id` (`to_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='This table is to track email action';


CREATE TABLE `emd_details` (
  `emd_id` int NOT NULL AUTO_INCREMENT,
  `pnr_payment_id` int NOT NULL DEFAULT '0',
  `issued_document_number` varchar(25) DEFAULT NULL,
  `emd_amount` double NOT NULL DEFAULT '0',
  `issued_date` datetime NOT NULL,
  `emd_type` char(3) DEFAULT NULL COMMENT 'To identify the type of Payment(EMD or MSR)',
  `emd_status` int NOT NULL,
  `passenger_id` int DEFAULT NULL,
  PRIMARY KEY (`emd_id`),
  KEY `issued_document_number` (`issued_document_number`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='To maintain emd number and emd amount';


CREATE TABLE `expiry_type_master` (
  `expiry_type_id` int NOT NULL AUTO_INCREMENT,
  `expiry_type_name` varchar(20) NOT NULL DEFAULT '',
  `status` enum('Y','N') DEFAULT 'Y',
  PRIMARY KEY (`expiry_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for expiry type';


CREATE TABLE `external_data_batch_details` (
  `extenal_data_batch_id` int NOT NULL AUTO_INCREMENT,
  `external_data_type` enum('FF','CF') NOT NULL COMMENT 'FF-Forecast fare,CF-competitor fare',
  `file_name` varchar(200) DEFAULT NULL,
  `data_count` int DEFAULT '0',
  `inserted_data_count` int DEFAULT '0',
  `file_uploaded_date` datetime DEFAULT NULL,
  `batch_date` datetime DEFAULT NULL,
  `batch_updated_date` datetime DEFAULT NULL,
  `batch_file_status` enum('Y','N') DEFAULT 'Y',
  PRIMARY KEY (`extenal_data_batch_id`),
  KEY `file_name` (`file_name`),
  KEY `batch_date` (`batch_date`),
  KEY `batch_file_status` (`batch_file_status`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='To maintain batch details when extenal data download from the FTP server';


CREATE TABLE `fare_class_criteria_master` (
  `criteria_id` int NOT NULL AUTO_INCREMENT,
  `criteria_name` varchar(100) DEFAULT NULL,
  `criteria_type` char(3) DEFAULT NULL,
  `display_status` char(1) DEFAULT NULL,
  `criteria_logical_id` varchar(100) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`criteria_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data for criteria used in fare class policy';


CREATE TABLE `fare_class_master` (
  `fare_class_id` int NOT NULL AUTO_INCREMENT,
  `policy_type_code` varchar(100) DEFAULT NULL,
  `fare_class_name` varchar(100) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `active_status` char(1) DEFAULT NULL,
  PRIMARY KEY (`fare_class_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='To store the fare classes which is used in fare class policy to map with agents';


CREATE TABLE `fare_class_policy_details` (
  `fare_class_policy_details_id` int NOT NULL AUTO_INCREMENT,
  `fare_class_policy_id` int DEFAULT NULL,
  `criteria_id` int DEFAULT NULL,
  `loop_value` int DEFAULT NULL,
  `operator_id` int DEFAULT NULL,
  `policy_value` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`fare_class_policy_details_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='To store the policy Details of fare class policy master';


CREATE TABLE `fare_class_policy_master` (
  `fare_class_policy_id` int NOT NULL AUTO_INCREMENT,
  `fare_class_policy_name` varchar(100) DEFAULT NULL,
  `priority` int DEFAULT NULL,
  `active_status` char(1) DEFAULT NULL,
  `discount_status` varchar(1) DEFAULT NULL,
  `surcharge_status` varchar(1) NOT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`fare_class_policy_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Primary table for fare class policy';


CREATE TABLE `fare_details` (
  `fare_id` int NOT NULL AUTO_INCREMENT,
  `series_flight_schedule_id` int DEFAULT NULL,
  `series_via_flight_id` int DEFAULT NULL,
  `adult_base_fare` double NOT NULL,
  `adult_tax` double DEFAULT NULL,
  `adult_discount` double DEFAULT NULL,
  `child_base_fare` double NOT NULL,
  `child_tax` double DEFAULT NULL,
  `child_discount` double DEFAULT NULL,
  `infant_base_fare` double NOT NULL,
  `infant_tax` double DEFAULT NULL,
  `meals_fare` double NOT NULL,
  `baggage_fare` double NOT NULL,
  `tiger_connect_fare` double NOT NULL,
  `baggage_code` varchar(5) NOT NULL,
  `fare_basis_code` varchar(15) DEFAULT '',
  `rule_number` varchar(4) NOT NULL,
  `fare_sequence` varchar(250) DEFAULT NULL,
  `journey_sell_key` text,
  `class_of_service` varchar(3) DEFAULT NULL,
  `fare_application_type` varchar(10) NOT NULL,
  `seat_availability` int NOT NULL,
  `capacity` int NOT NULL,
  `sold` int NOT NULL,
  `seat_taken` int NOT NULL,
  `service_adult_base_fare` double DEFAULT NULL,
  `service_adult_tax` double DEFAULT NULL,
  `service_child_base_fare` double DEFAULT NULL,
  `service_child_tax` double DEFAULT NULL,
  `service_infant_base_fare` double DEFAULT NULL,
  `service_infant_tax` double DEFAULT NULL,
  `ssi_seats_availability` int DEFAULT NULL,
  `fare_type` varchar(5) NOT NULL DEFAULT '',
  `chd_inf_basis_code` text NOT NULL,
  `actual_fare` double NOT NULL DEFAULT '0',
  `fare_policy_details` text,
  `single_bid_price` int DEFAULT '0',
  `bid_price_seat_taken` int DEFAULT '0',
  `child_seat_taken` int DEFAULT '0',
  `group_booking_counter` int DEFAULT NULL,
  `gst_data` varchar(60) DEFAULT '',
  `class_fare_type` varchar(5) DEFAULT '',
  PRIMARY KEY (`fare_id`),
  KEY `series_flight_schedule_id` (`series_flight_schedule_id`),
  KEY `series_via_flight_id` (`series_via_flight_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='To maintain fare details against series_flight_schedule_id';


CREATE TABLE `fare_policy_details` (
  `fare_policy_details_id` int NOT NULL AUTO_INCREMENT,
  `fare_policy_type` varchar(25) NOT NULL,
  `fare_policy_details` text CHARACTER SET latin1 COLLATE latin1_swedish_ci,
  PRIMARY KEY (`fare_policy_details_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `fare_suggested_matrix` (
  `fare_suggested_id` int NOT NULL AUTO_INCREMENT,
  `booking_profile_id` int DEFAULT NULL,
  `days_to_departure` int DEFAULT NULL,
  `booking_capacity` double DEFAULT NULL,
  `forecast_load_factor` int DEFAULT '0',
  PRIMARY KEY (`fare_suggested_id`),
  KEY `days_to_departure` (`days_to_departure`),
  KEY `booking_profile_id` (`booking_profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Map the static fare for the load factor and days to departure';


CREATE TABLE `fare_suggested_matrix_value` (
  `fare_suggested_matrix_value_id` int NOT NULL AUTO_INCREMENT,
  `fare_suggested_id` int DEFAULT NULL,
  `group_size` int DEFAULT NULL,
  `static_fare` int DEFAULT NULL,
  PRIMARY KEY (`fare_suggested_matrix_value_id`),
  KEY `fare_suggested_id` (`fare_suggested_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Map the static fare based on the requested group pax';


CREATE TABLE `fare_type_mapping_details` (
  `fare_type_mapping_id` int NOT NULL AUTO_INCREMENT,
  `fare_type_matrix_id` int DEFAULT NULL,
  `days_to_departure` int DEFAULT NULL,
  `booked_load_factor` int DEFAULT NULL,
  `forecast_load_factor` int DEFAULT '0',
  PRIMARY KEY (`fare_type_mapping_id`),
  KEY `fare_type_matrix_id` (`fare_type_matrix_id`),
  KEY `days_to_departure` (`days_to_departure`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='This table maintains data against fare_type_matrix_id';


CREATE TABLE `fare_type_master` (
  `fare_type_master_id` int NOT NULL AUTO_INCREMENT,
  `fare_type_name` varchar(50) DEFAULT NULL,
  `fare_type_alias` varchar(10) DEFAULT NULL,
  `display_status` char(1) DEFAULT NULL,
  PRIMARY KEY (`fare_type_master_id`),
  KEY `display_status` (`display_status`),
  KEY `fare_type_name` (`fare_type_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for fare type';


CREATE TABLE `fare_type_matrix` (
  `fare_type_matrix_id` int NOT NULL AUTO_INCREMENT,
  `fare_type_matrix_name` varchar(100) DEFAULT NULL,
  `load_factor_type` char(5) DEFAULT 'BOTH',
  `created_date` datetime DEFAULT NULL,
  `status` enum('Y','N','D') DEFAULT NULL,
  PRIMARY KEY (`fare_type_matrix_id`),
  KEY `status` (`status`),
  KEY `fare_type_matrix_name` (`fare_type_matrix_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='To maintain fare type matrix details';


CREATE TABLE `fare_type_policy_criteria_master` (
  `criteria_id` int NOT NULL AUTO_INCREMENT,
  `criteria_name` varchar(100) DEFAULT NULL,
  `criteria_type` char(3) DEFAULT NULL,
  `display_status` char(1) DEFAULT NULL,
  `criteria_logical_id` varchar(100) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`criteria_id`),
  KEY `criteria_logical_id` (`criteria_logical_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for criteria';


CREATE TABLE `fare_type_policy_details` (
  `fare_type_policy_details_id` int NOT NULL AUTO_INCREMENT,
  `fare_type_policy_id` int DEFAULT NULL,
  `criteria_id` int DEFAULT NULL,
  `loop_value` int NOT NULL DEFAULT '0',
  `operator_id` int DEFAULT NULL,
  `policy_value` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`fare_type_policy_details_id`),
  KEY `operator_id` (`operator_id`),
  KEY `criteria_id` (`criteria_id`),
  KEY `fare_type_policy_id` (`fare_type_policy_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Policy details saved against fare_type_policy_id';


CREATE TABLE `fare_type_policy_master` (
  `fare_type_policy_id` int NOT NULL AUTO_INCREMENT,
  `fare_type_policy_name` varchar(100) DEFAULT NULL,
  `fare_type_matrix_id` int DEFAULT NULL,
  `priority` int DEFAULT NULL,
  `active_status` char(1) DEFAULT NULL,
  `active_date` datetime DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `policy_dow` varchar(100) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `updated_date` datetime DEFAULT NULL COMMENT 'Updated date of the policy',
  `updated_by` int DEFAULT NULL COMMENT 'Updated by this user',
  PRIMARY KEY (`fare_type_policy_id`),
  KEY `active_status` (`active_status`),
  KEY `priority` (`priority`),
  KEY `fare_type_policy_name` (`fare_type_policy_name`),
  KEY `fare_type_matrix_id` (`fare_type_matrix_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='To maintain fare type policy details';


CREATE TABLE `fare_type_value_mapping` (
  `fare_type_value_id` int NOT NULL AUTO_INCREMENT,
  `fare_type_mapping_id` int DEFAULT NULL,
  `group_size` int DEFAULT NULL,
  `fare_type_alias` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`fare_type_value_id`),
  KEY `fare_type_mapping_id` (`fare_type_mapping_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='This table maintains group size against fare_type_mapping_id';


CREATE TABLE `fare_validity_type_details` (
  `fare_validity_type_id` int NOT NULL AUTO_INCREMENT,
  `fare_validity_type` varchar(30) DEFAULT NULL,
  `fare_validity_values` varchar(15) DEFAULT NULL,
  `status` enum('Y','N') DEFAULT 'Y',
  PRIMARY KEY (`fare_validity_type_id`),
  KEY `fare_validity_values` (`fare_validity_values`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for validity type';


CREATE TABLE `field_type_details` (
  `field_type_id` int NOT NULL AUTO_INCREMENT,
  `condition_id` int NOT NULL DEFAULT '0',
  `field_type_value` varchar(15) NOT NULL DEFAULT '',
  `field_type_name` varchar(20) NOT NULL DEFAULT '',
  `field_type_status` enum('Y','N') NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`field_type_id`),
  UNIQUE KEY `field_type_value` (`field_type_value`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for validation based on field type';


CREATE TABLE `file_process_data_details` (
  `file_process_data_id` int NOT NULL AUTO_INCREMENT,
  `request_info` json DEFAULT NULL,
  `unique_string` text NOT NULL,
  `upload_request_type` varchar(3) NOT NULL,
  PRIMARY KEY (`file_process_data_id`),
  KEY `upload_request_type` (`upload_request_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `file_process_details` (
  `file_process_id` int NOT NULL AUTO_INCREMENT,
  `file_upload_batch_id` int NOT NULL,
  `upload_file_type` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `process_status` enum('FV','FQ','UR','ER','U','C','SU','IP','AR','SP','W','DR') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'FV-file verifying,FQ-fare quote,UR-user response,U-Upload,C-completed,DR-Duplicate Request',
  `request_info` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `request_master_id` int NOT NULL,
  `remarks` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `file_process_data_id` int NOT NULL,
  `sheet_row` int NOT NULL,
  PRIMARY KEY (`file_process_id`),
  KEY `file_upload_batch_id` (`file_upload_batch_id`),
  KEY `request_master_id` (`request_master_id`),
  KEY `process_status` (`process_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `file_upload_batch_details` (
  `file_upload_batch_id` int NOT NULL AUTO_INCREMENT,
  `file_name` varchar(200) DEFAULT NULL,
  `uploaded_date` datetime DEFAULT NULL,
  `processed_date` datetime DEFAULT NULL,
  `process_type` enum('S','N','U','D','RR','CP','RP','PM','BK','UF','MP') CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `file_status` enum('FU','H','P','C','D','ER','FV','W','FQ','VC','U','SU','IP','AR','PP','CP') CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL COMMENT 'U-upload,H-history,P- Fare quote process,C-completed,D-delete,E-error,V-file verification,W-Awaiting User response',
  `uploaded_by` int DEFAULT NULL,
  `backend_file_name` varchar(200) DEFAULT NULL,
  `parent_file_id` int DEFAULT NULL,
  `requested_user_id` int DEFAULT NULL,
  `additional_details` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  PRIMARY KEY (`file_upload_batch_id`),
  KEY `file_status` (`file_status`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='To track the schedule changes from uploaded excel sheet';


CREATE TABLE `flight_cabin_mapping_details` (
  `flight_cabin_mapping_id` int NOT NULL AUTO_INCREMENT,
  `request_approved_flight_id` int DEFAULT NULL,
  `via_flight_id` int DEFAULT NULL,
  `fare_basis_code` varchar(20) DEFAULT NULL,
  `rule_number` varchar(10) DEFAULT NULL,
  `fare_sequence` varchar(50) DEFAULT NULL,
  `journey_sell_key` text,
  `class_of_service` char(5) DEFAULT NULL,
  `seat_availability` int DEFAULT NULL,
  `seat_taken` int DEFAULT NULL,
  `cabin_base_fare` double DEFAULT NULL,
  `adult_base_fare` double DEFAULT NULL,
  `adult_tax` double DEFAULT NULL,
  `adult_total_fare` double DEFAULT NULL,
  `child_base_fare` double DEFAULT NULL,
  `child_tax` double DEFAULT NULL,
  `child_total_fare` double DEFAULT NULL,
  `infant_base_fare` double DEFAULT NULL,
  `infant_tax` double DEFAULT NULL,
  `infant_total_fare` double DEFAULT NULL,
  `fare_type` varchar(5) NOT NULL DEFAULT '',
  `chd_inf_basis_code` text NOT NULL,
  `actual_fare` double NOT NULL DEFAULT '0',
  `cabin_child_fare` double DEFAULT '0',
  `child_seat_taken` int DEFAULT '0',
  `class_fare_type` varchar(5) DEFAULT '',
  PRIMARY KEY (`flight_cabin_mapping_id`),
  KEY `request_approved_flight_id` (`request_approved_flight_id`),
  KEY `via_flight_id` (`via_flight_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Cabin details maintained against the request_approved_flight_id';


CREATE TABLE `flight_discount_mapping_details` (
  `flight_discount_mapping_id` int NOT NULL AUTO_INCREMENT,
  `request_approved_flight_id` int DEFAULT NULL,
  `via_flight_id` int NOT NULL DEFAULT '0',
  `policy_id` int DEFAULT NULL,
  `matrix_id` int DEFAULT NULL,
  `matrix_type` char(5) DEFAULT NULL,
  `discount_fare` double DEFAULT NULL,
  `days_to_departure` int DEFAULT NULL,
  `booked_load_factor` int DEFAULT NULL,
  `policy_currency_type` char(5) DEFAULT NULL,
  `existing_adult_base_fare` double DEFAULT NULL,
  `existing_adult_tax` double DEFAULT NULL,
  `existing_adult_total_fare` double DEFAULT NULL,
  `existing_child_base_fare` double DEFAULT NULL,
  `existing_child_tax` double DEFAULT NULL,
  `existing_child_total_fare` double DEFAULT NULL,
  `load_factor_type` char(5) DEFAULT NULL,
  `forecast_load_factor` int DEFAULT '0',
  `child_discount_fare` double DEFAULT '0',
  PRIMARY KEY (`flight_discount_mapping_id`),
  KEY `request_approved_flight_id` (`request_approved_flight_id`),
  KEY `policy_id` (`policy_id`),
  KEY `matrix_id` (`matrix_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Discount matrix details saved against request_approved_flight_id';


CREATE TABLE `flight_sales_promo_mapping` (
  `flight_sales_promo_mapping_id` int NOT NULL AUTO_INCREMENT,
  `request_approved_flight_id` int NOT NULL DEFAULT '0',
  `via_flight_id` int NOT NULL DEFAULT '0',
  `sales_promo_policy_id` int NOT NULL DEFAULT '0',
  `sales_promo_matrix_id` int NOT NULL DEFAULT '0',
  `sales_promo_matrix_type` char(5) NOT NULL DEFAULT '',
  `sales_promo_discount_percentage` double NOT NULL DEFAULT '0',
  `sales_promo_discount_fare` double NOT NULL DEFAULT '0',
  `sales_promo_currency_type` char(5) NOT NULL DEFAULT '',
  `original_base_fare` double NOT NULL DEFAULT '0',
  PRIMARY KEY (`flight_sales_promo_mapping_id`),
  KEY `request_approved_flight_id` (`request_approved_flight_id`),
  KEY `sales_promo_policy_id` (`sales_promo_policy_id`),
  KEY `sales_promo_matrix_id` (`sales_promo_matrix_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='sales promo policy details saved against request_approved_flight_id';


CREATE TABLE `flight_schedule_details` (
  `flight_schedule_id` int NOT NULL AUTO_INCREMENT,
  `corporate_id` int DEFAULT NULL,
  `origin_airport_code` varchar(3) DEFAULT NULL,
  `dest_airport_code` varchar(3) DEFAULT NULL,
  `airlines_code` varchar(7) DEFAULT NULL,
  `cabin` varchar(5) DEFAULT NULL,
  `arrival_time` varchar(5) DEFAULT NULL,
  `departure_time` varchar(5) DEFAULT NULL,
  `flight_number` varchar(5) DEFAULT NULL,
  `flight_jounary_time` varchar(5) DEFAULT NULL,
  `leg_count` int DEFAULT NULL,
  `routing` varchar(11) DEFAULT NULL,
  `from_date` date DEFAULT NULL,
  `to_date` date DEFAULT NULL,
  `series_weekdays` varchar(13) DEFAULT NULL,
  `displacement_fare` int DEFAULT NULL,
  `booking_profile_fare` int DEFAULT NULL,
  `competetor_fare` int DEFAULT NULL,
  `base_fare` int DEFAULT NULL,
  `tax` int DEFAULT NULL,
  `currency_type` char(3) DEFAULT NULL,
  PRIMARY KEY (`flight_schedule_id`),
  KEY `corporate_id_2` (`corporate_id`),
  KEY `origin_airport_code_2` (`origin_airport_code`),
  KEY `dest_airport_code` (`dest_airport_code`),
  KEY `origin_airport_code` (`origin_airport_code`),
  KEY `airlines_code` (`airlines_code`),
  KEY `dest_airport_code_2` (`dest_airport_code`),
  KEY `corporate_id` (`corporate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='while flight search,flight details are inserted';


CREATE TABLE `forecast_batch_details` (
  `forecast_batch_id` int NOT NULL AUTO_INCREMENT,
  `file_name` varchar(200) DEFAULT NULL,
  `data_count` int DEFAULT '0',
  `inserted_data_count` int DEFAULT '0',
  `file_uploaded_date` datetime DEFAULT NULL,
  `batch_date` datetime DEFAULT NULL,
  `batch_updated_date` datetime DEFAULT NULL,
  `batch_file_status` enum('Y','N') DEFAULT 'Y',
  PRIMARY KEY (`forecast_batch_id`),
  KEY `file_name` (`file_name`),
  KEY `batch_date` (`batch_date`),
  KEY `batch_file_status` (`batch_file_status`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='To maintain batch details when forecast file uploaded';


CREATE TABLE `forecast_data_details` (
  `forecast_data_id` int NOT NULL AUTO_INCREMENT,
  `forecast_batch_id` int DEFAULT '0',
  `carrier` varchar(5) DEFAULT NULL,
  `flight_number` varchar(20) DEFAULT NULL,
  `origin` varchar(3) DEFAULT NULL,
  `destination` varchar(3) DEFAULT NULL,
  `departure_date` date DEFAULT NULL,
  `depature_time` time DEFAULT NULL,
  `arrival_time` time DEFAULT NULL,
  `cabin` char(2) DEFAULT NULL,
  `authorized_capacity` int DEFAULT '0',
  `forecasted_demand` int DEFAULT '0',
  `groups_booked` int DEFAULT '0',
  `stand_deviation` double DEFAULT NULL,
  `currency` varchar(5) DEFAULT NULL,
  `avg_fare` double DEFAULT NULL,
  `status` enum('Y','N') DEFAULT 'Y',
  `forecasted_date` datetime DEFAULT NULL,
  PRIMARY KEY (`forecast_data_id`),
  KEY `cabin` (`cabin`),
  KEY `depature_time` (`depature_time`),
  KEY `carrier` (`carrier`),
  KEY `forecast_batch_id` (`forecast_batch_id`),
  KEY `status` (`status`),
  KEY `destination` (`destination`),
  KEY `departure_date` (`departure_date`),
  KEY `origin` (`origin`),
  KEY `flight_number` (`flight_number`),
  KEY `forecasted_date` (`forecasted_date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='To maintain forecast data against forecast batch';


CREATE TABLE `forecast_data_details_temp` (
  `forecast_data_id` int NOT NULL AUTO_INCREMENT,
  `forecast_batch_id` int NOT NULL,
  `carrier` varchar(5) DEFAULT NULL,
  `flight_number` varchar(20) DEFAULT NULL,
  `origin` varchar(3) DEFAULT NULL,
  `destination` varchar(3) DEFAULT NULL,
  `departure_date` date DEFAULT NULL,
  `depature_time` time DEFAULT NULL,
  `arrival_time` time DEFAULT NULL,
  `cabin` char(2) DEFAULT NULL,
  `authorized_capacity` int DEFAULT NULL,
  `forecasted_demand` double DEFAULT NULL,
  `groups_booked` double DEFAULT NULL,
  `stand_deviation` double DEFAULT NULL,
  `currency` varchar(5) DEFAULT NULL,
  `avg_fare` double DEFAULT NULL,
  `status` enum('Y','N') DEFAULT 'Y',
  `forecasted_date` datetime DEFAULT NULL,
  PRIMARY KEY (`forecast_data_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Temporary table to load the forecast file data directly from csv file to database';


CREATE TABLE `gender_title_details` (
  `gender_id` int NOT NULL AUTO_INCREMENT,
  `gender_type` varchar(20) NOT NULL,
  `gender_title_value` varchar(10) NOT NULL,
  `display_value` varchar(30) DEFAULT NULL,
  `view_status` varchar(10) NOT NULL,
  PRIMARY KEY (`gender_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data for user or passenger Title informations';


CREATE TABLE `grm_menu_details` (
  `menu_id` int unsigned NOT NULL AUTO_INCREMENT,
  `menu_name` varchar(100) NOT NULL,
  `menu_link` varchar(100) NOT NULL DEFAULT 'NULL',
  `menu_status` enum('Y','N','D') NOT NULL DEFAULT 'Y',
  `created_date` date NOT NULL,
  `updated_date` date NOT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data for menu details';


CREATE TABLE `grm_menu_mapping_details` (
  `menu_mapping_id` int unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` int unsigned NOT NULL,
  `child_id` int unsigned NOT NULL,
  `display_order` tinyint unsigned NOT NULL,
  `display_status` enum('Y','N','D') NOT NULL,
  `group_id` int NOT NULL,
  `created_date` date NOT NULL,
  `updated_date` date NOT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`menu_mapping_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Map the menu for the group IDs';


CREATE TABLE `group_allocation_profile_details` (
  `profile_id` int NOT NULL AUTO_INCREMENT,
  `profile_name` varchar(100) DEFAULT NULL,
  `profile_type` char(2) DEFAULT NULL,
  `currency_type` char(3) DEFAULT NULL,
  `load_factor_type` char(5) DEFAULT NULL,
  `active_status` char(1) DEFAULT 'N',
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Primary matrix table for group passengers seat wise fare allocation';


CREATE TABLE `group_allocation_suggested_matrix` (
  `suggested_matrix_id` int NOT NULL AUTO_INCREMENT,
  `profile_id` int NOT NULL,
  `group_start_pax` int NOT NULL DEFAULT '0',
  `group_end_pax` int NOT NULL DEFAULT '0',
  `group_pax_fare` double NOT NULL DEFAULT '0',
  `days_to_departure` int NOT NULL DEFAULT '0',
  `booking_capacity` double NOT NULL DEFAULT '0',
  `forecast_load_factor` int NOT NULL,
  PRIMARY KEY (`suggested_matrix_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Matrix for group passengers seat wise fare allocation';


CREATE TABLE `group_category_list` (
  `group_category_id` int NOT NULL AUTO_INCREMENT,
  `group_category_name` varchar(30) DEFAULT NULL,
  `group_category_code` varchar(2) DEFAULT NULL,
  `category_type` enum('*','A','S','C','F','I') CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '*',
  `group_category_status` enum('Y','N') NOT NULL DEFAULT 'Y',
  `display_order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`group_category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for group category which will be display in the request page.';


CREATE TABLE `group_contract_details` (
  `group_contract_id` int NOT NULL AUTO_INCREMENT,
  `request_group_id` int NOT NULL,
  `contract_manager_master_id` int NOT NULL,
  `reference_id` int NOT NULL DEFAULT '0',
  `updated_contract` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  PRIMARY KEY (`group_contract_id`),
  KEY `request_group_id` (`request_group_id`),
  KEY `contract_manager_master_id` (`contract_manager_master_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `group_details` (
  `group_id` int NOT NULL AUTO_INCREMENT,
  `group_name` varchar(30) DEFAULT NULL,
  `group_alias_name` char(3) DEFAULT NULL,
  `corporate_type_id` int DEFAULT NULL,
  `active_status` enum('Y','N') NOT NULL DEFAULT 'Y',
  `access_group_id` varchar(50) NOT NULL,
  `default_module` varchar(150) NOT NULL,
  PRIMARY KEY (`group_id`),
  UNIQUE KEY `group_alias_name` (`group_alias_name`),
  KEY `corporate_type_id` (`corporate_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tool level group(i.e) user roles stored with group id';


CREATE TABLE `groupchange_request_details` (
  `groupchange_request_id` int NOT NULL AUTO_INCREMENT,
  `groupchange_master_id` int DEFAULT '0',
  `request_id` int DEFAULT '0',
  `series_request_id` int DEFAULT '0',
  `parent_series_request_id` int DEFAULT '0',
  `request_approved_flight_id` int NOT NULL DEFAULT '0',
  `current_no_of_adult` int DEFAULT NULL,
  `current_no_of_child` int DEFAULT NULL,
  `current_no_of_infant` int DEFAULT NULL,
  `current_no_of_foc` int DEFAULT NULL,
  `requested_no_of_adult` int DEFAULT NULL,
  `requested_no_of_child` int DEFAULT NULL,
  `requested_no_of_infant` int DEFAULT NULL,
  `requested_no_of_foc` int DEFAULT NULL,
  `approved_no_of_adult` int DEFAULT NULL,
  `approved_no_of_child` int DEFAULT NULL,
  `approved_no_of_infant` int DEFAULT NULL,
  `approved_no_of_foc` int DEFAULT NULL,
  `changed_no_of_adult` int DEFAULT NULL,
  `changed_no_of_child` int DEFAULT NULL,
  `changed_no_of_infant` int DEFAULT NULL,
  `changed_no_of_foc` int DEFAULT NULL,
  `infant_basefare` double NOT NULL DEFAULT (0),
  `infant_tax` double NOT NULL DEFAULT (0),
  `infant_taxbreakup` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`groupchange_request_id`),
  KEY `request_id` (`request_id`),
  KEY `series_request_id` (`series_request_id`),
  KEY `request_approved_flight_id` (`request_approved_flight_id`),
  KEY `groupchange_master_id` (`groupchange_master_id`),
  KEY `parent_series_request_id` (`parent_series_request_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Group downsize/ upsize passenget count is stored in details';


CREATE TABLE `groupchange_request_master` (
  `groupchange_master_id` int NOT NULL AUTO_INCREMENT,
  `request_master_id` int DEFAULT NULL,
  `parent_request_master_id` int DEFAULT '0',
  `resize_type_id` int NOT NULL DEFAULT '0',
  `trip_type` varchar(5) NOT NULL,
  `pnr` varchar(11) NOT NULL,
  `request_user_id` int DEFAULT '0',
  `request_status` char(1) DEFAULT NULL,
  `user_remarks` text,
  `admin_remarks` text,
  `requested_date` datetime DEFAULT NULL,
  `response_date` datetime DEFAULT NULL,
  `responded_user_id` int DEFAULT NULL,
  PRIMARY KEY (`groupchange_master_id`),
  KEY `request_master_id` (`request_master_id`),
  KEY `request_user_id` (`request_user_id`),
  KEY `responded_user_id` (`responded_user_id`),
  KEY `parent_request_master_id` (`parent_request_master_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for group level chnages(i.e) upsize and downsize';


CREATE TABLE `history_details` (
  `history_id` int NOT NULL AUTO_INCREMENT,
  `request_master_id` int NOT NULL,
  `child_id` int NOT NULL,
  `actioned_name` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `actioned_details` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'To store the current actioned data.',
  `actioned_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `actioned_by` int NOT NULL,
  PRIMARY KEY (`history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `holiday_list` (
  `holiday_list_id` int NOT NULL AUTO_INCREMENT,
  `holiday_list_name` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'To show the inter holiday list',
  `non_business_days_list` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'To list the non business days',
  `country_code` char(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Country code to select the country name ',
  `city_id` int DEFAULT NULL COMMENT 'City id to select the city name ',
  `country_year` year DEFAULT NULL COMMENT 'To show the country year ',
  `status` enum('Y','N','D') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'Y' COMMENT 'To identify active status',
  `updated_by` int DEFAULT NULL COMMENT 'User updated holiday list ',
  `updated_date` timestamp NULL DEFAULT NULL COMMENT 'To list the updated date',
  `enable_status` enum('Y','N') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `created_by` int NOT NULL,
  `created_date` timestamp NOT NULL ON UPDATE CURRENT_TIMESTAMP,
  `roll_on` enum('Y','N') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`holiday_list_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci COMMENT='To list the non business holiday days';


CREATE TABLE `holiday_mapping_list` (
  `holiday_mapping_id` int NOT NULL AUTO_INCREMENT,
  `holiday_list_id` int DEFAULT NULL COMMENT 'To show the holiday list id',
  `holiday_date` date DEFAULT NULL COMMENT 'To show the holiday date',
  `holiday_desc` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'To list the holiday description',
  `status` enum('Y','N','D') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'Y' COMMENT 'To identify active status',
  `created_by` int DEFAULT NULL COMMENT 'User saved holiday list',
  `created_date` timestamp NULL DEFAULT NULL COMMENT 'To list the created date',
  PRIMARY KEY (`holiday_mapping_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci COMMENT='To map the holiday list';


CREATE TABLE `hub_airport_details` (
  `hub_airport_id` int NOT NULL AUTO_INCREMENT,
  `airport_code` varchar(3) DEFAULT NULL,
  `mapped_airport_code` varchar(3) DEFAULT NULL,
  `status` char(1) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`hub_airport_id`),
  KEY `status` (`status`),
  KEY `airport_code` (`airport_code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Hub  details are stored ';


CREATE TABLE `ip_restriction_details` (
  `restriction_id` int NOT NULL AUTO_INCREMENT,
  `ip_address` varchar(40) DEFAULT NULL,
  `user_id` int DEFAULT '0',
  `group_id` int DEFAULT '0',
  `status` char(4) DEFAULT 'N',
  `created_by` int DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `updated_date` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `history_id` int DEFAULT NULL,
  PRIMARY KEY (`restriction_id`),
  KEY `user_id` (`user_id`),
  KEY `group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Product level restricted ip will be stored in this table';


CREATE TABLE `issue_category_details` (
  `issue_category_id` int NOT NULL AUTO_INCREMENT,
  `issue_category_name` varchar(200) DEFAULT NULL,
  `group_id` int DEFAULT NULL,
  `corporate_id` int DEFAULT NULL,
  `parent_category_id` int DEFAULT NULL,
  PRIMARY KEY (`issue_category_id`),
  KEY `corporate_id` (`corporate_id`),
  KEY `group_id` (`group_id`),
  KEY `parent_category_id` (`parent_category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for Issue category ';


CREATE TABLE `issue_cron_email_details` (
  `issue_cron_email_id` int NOT NULL AUTO_INCREMENT,
  `issue_id` int NOT NULL,
  `issue_type` int NOT NULL,
  `email_subject` varchar(50) NOT NULL,
  `sent_to` varchar(70) NOT NULL,
  `sent_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`issue_cron_email_id`),
  KEY `issue_id` (`issue_id`),
  KEY `issue_type` (`issue_type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='To send the remainder for created issues by sending the emails';


CREATE TABLE `issue_details` (
  `issue_details_id` int NOT NULL AUTO_INCREMENT,
  `issue_category_id` int DEFAULT NULL,
  `issue_subcategory_id` int DEFAULT NULL,
  `severity_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `issue_status_id` int DEFAULT NULL,
  `request_master_id` int DEFAULT '0',
  `pnr` varchar(25) DEFAULT '',
  `last_updated_date` datetime DEFAULT NULL,
  PRIMARY KEY (`issue_details_id`),
  KEY `issue_status_id` (`issue_status_id`),
  KEY `severity_id` (`severity_id`),
  KEY `issue_subcategory_id` (`issue_subcategory_id`),
  KEY `request_master_id` (`request_master_id`),
  KEY `issue_category_id` (`issue_category_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tracking table for issue';


CREATE TABLE `issue_severity_details` (
  `severity_id` int NOT NULL AUTO_INCREMENT,
  `severity_name` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`severity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for serviority category in issue management';


CREATE TABLE `issue_status_details` (
  `issue_status_id` int NOT NULL AUTO_INCREMENT,
  `issue_status_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`issue_status_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for Issue status';


CREATE TABLE `issue_subcategory_details` (
  `issue_subcategory_id` int NOT NULL AUTO_INCREMENT,
  `issue_subcategory_name` varchar(200) DEFAULT NULL,
  `issue_category_id` int DEFAULT NULL,
  `group_id` int DEFAULT NULL,
  `corporate_id` int DEFAULT NULL,
  `parent_category_id` int DEFAULT NULL,
  PRIMARY KEY (`issue_subcategory_id`),
  KEY `parent_category_id` (`parent_category_id`),
  KEY `issue_category_id` (`issue_category_id`),
  KEY `issue_subcategory_id` (`issue_subcategory_id`),
  KEY `corporate_id` (`corporate_id`),
  KEY `group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for issue sub category. Need to remove group id and corporate id';


CREATE TABLE `load_factor_type_details` (
  `load_factor_type_id` int NOT NULL AUTO_INCREMENT,
  `load_factor_type` varchar(5) DEFAULT NULL COMMENT 'Enable either Load Factor or Future Load Factor',
  `load_factor_type_name` varchar(100) DEFAULT NULL,
  `discount_status` char(1) DEFAULT 'Y',
  `static_fare_status` char(1) DEFAULT 'Y',
  `fare_type_status` char(1) DEFAULT 'Y',
  `surcharge_status` char(1) DEFAULT 'Y',
  `group_allocation_fare_matrix` char(1) NOT NULL DEFAULT 'N',
  `baggage_status` char(1) DEFAULT 'Y',
  PRIMARY KEY (`load_factor_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='To get load factor details.To enable the load factor for any policy give status as Y in the currensponding column.';


CREATE TABLE `login_verification` (
  `login_verification_id` int NOT NULL AUTO_INCREMENT,
  `ip_address` varchar(100) DEFAULT NULL,
  `email_id` varchar(100) DEFAULT NULL,
  `requested_date` datetime DEFAULT NULL,
  `verification_status` char(2) DEFAULT NULL,
  `additional_info` text NOT NULL COMMENT 'useragent and attempt count for validating login count from Database ',
  PRIMARY KEY (`login_verification_id`),
  KEY `verification_status` (`verification_status`),
  KEY `email_id` (`email_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='login verication details with date and status';


CREATE TABLE `manipulate_history` (
  `history_id` int NOT NULL AUTO_INCREMENT,
  `module_id` int NOT NULL,
  `history_type` varchar(50) NOT NULL,
  `history_type_id` int NOT NULL,
  `user_id` int NOT NULL,
  `ip_address` varchar(40) NOT NULL,
  `date` datetime NOT NULL,
  `history_value` longtext NOT NULL,
  `action_type` char(10) NOT NULL,
  PRIMARY KEY (`history_id`),
  KEY `user_id` (`user_id`),
  KEY `history_type_id` (`history_type_id`),
  KEY `module_id` (`module_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='All  modification history details ';


CREATE TABLE `meal_code_details` (
  `meal_id` int NOT NULL AUTO_INCREMENT,
  `meal_description` varchar(250) DEFAULT NULL,
  `meal_code` varchar(6) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  PRIMARY KEY (`meal_id`),
  KEY `meal_code` (`meal_code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for Meals, Which is displayed in request form';


CREATE TABLE `menu_m_app_details` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app_name` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `menu_m_components` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `component` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL,
  `r_app_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `menu_m_components_r_app_id_aa641f32_fk_menu_m_app_details_id` (`r_app_id`),
  CONSTRAINT `menu_m_components_r_app_id_aa641f32_fk_menu_m_app_details_id` FOREIGN KEY (`r_app_id`) REFERENCES `menu_m_app_details` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `menu_m_layouts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `layout` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL,
  `r_app_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `menu_m_layouts_r_app_id_c1b20b3d_fk_menu_m_app_details_id` (`r_app_id`),
  CONSTRAINT `menu_m_layouts_r_app_id_c1b20b3d_fk_menu_m_app_details_id` FOREIGN KEY (`r_app_id`) REFERENCES `menu_m_app_details` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `menu_m_menu` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `menu_code` varchar(50) COLLATE utf8mb3_unicode_ci NOT NULL,
  `path` varchar(200) COLLATE utf8mb3_unicode_ci NOT NULL,
  `icon_name` varchar(100) COLLATE utf8mb3_unicode_ci NOT NULL,
  `r_app_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `menu_m_menu_r_app_id_1646f509_fk_menu_m_app_details_id` (`r_app_id`),
  CONSTRAINT `menu_m_menu_r_app_id_1646f509_fk_menu_m_app_details_id` FOREIGN KEY (`r_app_id`) REFERENCES `menu_m_app_details` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `menu_m_route_mapping` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `default` int NOT NULL,
  `display_status` varchar(1) COLLATE utf8mb3_unicode_ci NOT NULL,
  `r_component_id` bigint NOT NULL,
  `r_group_id` int NOT NULL,
  `r_layout_id` bigint NOT NULL,
  `r_route_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `menu_m_route_mapping_r_component_id_b92ca3e0_fk_menu_m_co` (`r_component_id`),
  KEY `menu_m_route_mapping_r_group_id_48c6597e_fk_auth_group_id` (`r_group_id`),
  KEY `menu_m_route_mapping_r_layout_id_4475e77f_fk_menu_m_layouts_id` (`r_layout_id`),
  KEY `menu_m_route_mapping_r_route_id_337a16aa_fk_menu_m_routes_id` (`r_route_id`),
  CONSTRAINT `menu_m_route_mapping_r_component_id_b92ca3e0_fk_menu_m_co` FOREIGN KEY (`r_component_id`) REFERENCES `menu_m_components` (`id`),
  CONSTRAINT `menu_m_route_mapping_r_group_id_48c6597e_fk_auth_group_id` FOREIGN KEY (`r_group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `menu_m_route_mapping_r_layout_id_4475e77f_fk_menu_m_layouts_id` FOREIGN KEY (`r_layout_id`) REFERENCES `menu_m_layouts` (`id`),
  CONSTRAINT `menu_m_route_mapping_r_route_id_337a16aa_fk_menu_m_routes_id` FOREIGN KEY (`r_route_id`) REFERENCES `menu_m_routes` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `menu_m_routes` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `path` varchar(200) COLLATE utf8mb3_unicode_ci NOT NULL,
  `permission_id` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `r_app_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `menu_m_routes_r_app_id_7ef11fa3_fk_menu_m_app_details_id` (`r_app_id`),
  CONSTRAINT `menu_m_routes_r_app_id_7ef11fa3_fk_menu_m_app_details_id` FOREIGN KEY (`r_app_id`) REFERENCES `menu_m_app_details` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `menu_t_menu_mapping` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `display_order` int NOT NULL,
  `r_child_id` bigint DEFAULT NULL,
  `r_group_id` int NOT NULL,
  `r_parent_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `menu_t_menu_mapping_r_child_id_42d961bc_fk_menu_m_menu_id` (`r_child_id`),
  KEY `menu_t_menu_mapping_r_group_id_828fc4ad_fk_auth_group_id` (`r_group_id`),
  KEY `menu_t_menu_mapping_r_parent_id_c7f3f33e_fk_menu_m_menu_id` (`r_parent_id`),
  CONSTRAINT `menu_t_menu_mapping_r_child_id_42d961bc_fk_menu_m_menu_id` FOREIGN KEY (`r_child_id`) REFERENCES `menu_m_menu` (`id`),
  CONSTRAINT `menu_t_menu_mapping_r_group_id_828fc4ad_fk_auth_group_id` FOREIGN KEY (`r_group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `menu_t_menu_mapping_r_parent_id_c7f3f33e_fk_menu_m_menu_id` FOREIGN KEY (`r_parent_id`) REFERENCES `menu_m_menu` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `message_attachment` (
  `attachment_id` int NOT NULL AUTO_INCREMENT,
  `message_id` int DEFAULT NULL,
  `attachment_name` varchar(200) DEFAULT NULL,
  `attachment_path` varchar(200) DEFAULT NULL,
  `upload_date` datetime DEFAULT NULL,
  PRIMARY KEY (`attachment_id`),
  KEY `message_id` (`message_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Issue management attchement details';


CREATE TABLE `message_details` (
  `message_id` int NOT NULL AUTO_INCREMENT,
  `reference_id` int DEFAULT NULL,
  `support_type_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `status_id` int DEFAULT NULL,
  `message_subject` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `message_content` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `attachment` char(1) DEFAULT NULL,
  `base_message_id` int DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `satisfaction_status` char(1) DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`message_id`),
  KEY `satisfaction_status` (`satisfaction_status`),
  KEY `user_id` (`user_id`),
  KEY `reference_id` (`reference_id`),
  KEY `base_message_id` (`base_message_id`),
  KEY `support_type_id` (`support_type_id`),
  KEY `status_id` (`status_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Issue management, issue content details';


CREATE TABLE `module_details` (
  `module_id` int NOT NULL AUTO_INCREMENT,
  `module_name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`module_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='master module table';


CREATE TABLE `module_group_mapping` (
  `module_group_id` int NOT NULL AUTO_INCREMENT,
  `group_id` int DEFAULT NULL,
  `module_id` int DEFAULT NULL,
  `template_id` int DEFAULT NULL,
  `display_order` int DEFAULT NULL,
  `display_status` char(3) DEFAULT NULL,
  `display_name` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`module_group_id`),
  KEY `group_id` (`group_id`),
  KEY `module_id` (`module_id`),
  KEY `template_id` (`template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Mapping table for module, group and template details';


CREATE TABLE `module_group_stdtpl_mapping` (
  `module_id` int DEFAULT NULL,
  `std_tpl_id` int DEFAULT NULL,
  `group_id` int DEFAULT NULL,
  `class_name` varchar(30) DEFAULT NULL,
  KEY `std_tpl_id` (`std_tpl_id`),
  KEY `module_id` (`module_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Group based standard template mapping for the each module';


CREATE TABLE `negotiation_criteria_master` (
  `criteria_id` int NOT NULL AUTO_INCREMENT,
  `criteria_name` varchar(100) DEFAULT NULL,
  `criteria_type` char(3) DEFAULT NULL,
  `display_status` char(1) DEFAULT NULL,
  `criteria_logical_id` varchar(100) DEFAULT NULL,
  `create_date` datetime DEFAULT NULL,
  PRIMARY KEY (`criteria_id`),
  KEY `criteria_logical_id` (`criteria_logical_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for negotiation criteria';


CREATE TABLE `negotiation_policy_details` (
  `negotiation_policy_details_id` int NOT NULL AUTO_INCREMENT,
  `negotiation_policy_id` int DEFAULT NULL,
  `criteria_id` int DEFAULT NULL,
  `loop_value` int DEFAULT NULL,
  `operator_id` int DEFAULT NULL,
  `policy_value` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`negotiation_policy_details_id`),
  KEY `negotiation_policy_id` (`negotiation_policy_id`),
  KEY `criteria_id` (`criteria_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Negotiation policy criteria value details';


CREATE TABLE `negotiation_policy_master` (
  `negotiation_policy_id` int NOT NULL AUTO_INCREMENT,
  `negotiation_policy_name` varchar(100) DEFAULT NULL,
  `priority` int DEFAULT NULL,
  `active_status` char(1) DEFAULT NULL,
  `negotiation_status` varchar(1) DEFAULT NULL,
  `negotiation_limit` int DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `policy_dow` varchar(100) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`negotiation_policy_id`),
  KEY `negotiation_policy_name` (`negotiation_policy_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Negotiation policy name details';


CREATE TABLE `negotiation_request_details` (
  `negotiation_details_id` int NOT NULL AUTO_INCREMENT,
  `negotiation_fileupload_id` int DEFAULT NULL,
  `request_master_id` int NOT NULL,
  `transaction_id` int NOT NULL,
  `pax_count` int DEFAULT NULL,
  `total_base_fare` double DEFAULT NULL,
  `mr_rate` int DEFAULT NULL,
  `tandc_type` char(3) DEFAULT NULL,
  `analyst_comments` text,
  `fare_status` enum('A','R','S') DEFAULT NULL,
  `process_status` enum('U','P','C') DEFAULT NULL,
  `processed_date` datetime DEFAULT NULL,
  PRIMARY KEY (`negotiation_details_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `note_details` (
  `note_details_id` int NOT NULL AUTO_INCREMENT,
  `request_master_id` int NOT NULL,
  `message` text NOT NULL,
  `posted_by` int DEFAULT NULL,
  `posted_on` datetime NOT NULL,
  `status` enum('Y','N','D') NOT NULL COMMENT 'Y-Show,N-Hide,D-Delete',
  PRIMARY KEY (`note_details_id`),
  KEY `request_master_id` (`request_master_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Intial table in the note functionality';


CREATE TABLE `note_read_status_details` (
  `note_read_status_id` int NOT NULL AUTO_INCREMENT,
  `note_details_id` int NOT NULL,
  `note_user_mapping_id` int NOT NULL,
  `user_id` int NOT NULL,
  `read_status` enum('Y','N') NOT NULL DEFAULT 'N',
  PRIMARY KEY (`note_read_status_id`),
  KEY `note_user_mapping_id` (`note_user_mapping_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Details for who are all saw  note';


CREATE TABLE `note_user_mapping_details` (
  `note_user_mapping_id` int NOT NULL AUTO_INCREMENT,
  `note_details_id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `group_id` int DEFAULT NULL,
  `status` enum('Y','N','D') NOT NULL DEFAULT 'Y' COMMENT 'Y-Show,N-Disable,D-Delete',
  PRIMARY KEY (`note_user_mapping_id`),
  KEY `chat_details_id` (`note_details_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Details for, to whom the notes need to display';


CREATE TABLE `operator_master` (
  `operator_id` int NOT NULL AUTO_INCREMENT,
  `operator_name` varchar(15) DEFAULT NULL,
  `logical_value` varchar(15) DEFAULT NULL,
  `operator_type` char(3) DEFAULT NULL,
  `status` char(1) DEFAULT 'Y',
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`operator_id`),
  KEY `status` (`status`),
  KEY `logical_value` (`logical_value`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for all operators(+,-,* ...)';


CREATE TABLE `other_code_details` (
  `other_id` int NOT NULL AUTO_INCREMENT,
  `other_description` varchar(250) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `other_code` varchar(250) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  PRIMARY KEY (`other_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `package_details` (
  `package_id` int NOT NULL AUTO_INCREMENT,
  `pnr_blocking_id` int NOT NULL COMMENT 'Store the first pnr_blocking_id using request_master_id and PNR',
  `adult` tinyint NOT NULL DEFAULT '0' COMMENT 'Alloted adult count',
  `child` tinyint NOT NULL DEFAULT '0' COMMENT 'Alloted child count',
  `infant` tinyint NOT NULL DEFAULT '0' COMMENT 'Alloted infant count',
  `status` enum('Y','N','D') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'Y' COMMENT 'Y - Active, N - Inactive when modified the package, D - Delete when package deleted',
  `parent_package_id` int NOT NULL DEFAULT '0' COMMENT 'Store the package_id during package update and insert',
  `ref_package_id` int NOT NULL COMMENT 'Store the ADP front end package id',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created or Modified timestamp',
  `created_by` int NOT NULL COMMENT 'Created or Modifiied travel agent user_id',
  `passenger_mapping` json NOT NULL DEFAULT (json_object()) COMMENT 'Store the adp pax id to grm pax id',
  PRIMARY KEY (`package_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci COMMENT='To list the package details created by travelagent';


CREATE TABLE `passenger_details` (
  `passenger_id` int NOT NULL AUTO_INCREMENT,
  `airlines_request_id` int DEFAULT NULL,
  `request_approved_flight_id` int DEFAULT NULL,
  `series_request_id` int DEFAULT NULL,
  `name_number` varchar(10) DEFAULT '0',
  `pnr` varchar(20) DEFAULT NULL,
  `title` varchar(16) DEFAULT NULL,
  `first_name` text,
  `last_name` text,
  `middle_name` varchar(35) DEFAULT NULL,
  `age` varchar(16) DEFAULT NULL,
  `pax_email_id` varchar(32) DEFAULT NULL,
  `pax_mobile_number` varchar(16) DEFAULT NULL,
  `pax_employee_code` varchar(16) DEFAULT NULL,
  `pax_employee_id` varchar(16) DEFAULT NULL,
  `passenger_type` varchar(10) DEFAULT NULL,
  `id_proof` varchar(16) DEFAULT NULL,
  `id_proof_number` varchar(16) DEFAULT NULL,
  `sex` varchar(16) DEFAULT NULL,
  `dob` varchar(16) DEFAULT NULL,
  `citizenship` varchar(16) DEFAULT NULL,
  `passport_no` varchar(16) DEFAULT NULL,
  `date_of_issue` varbinary(256) DEFAULT NULL,
  `date_of_expiry` varbinary(256) DEFAULT NULL,
  `submitted_date` datetime DEFAULT NULL,
  `traveller_number` varchar(16) DEFAULT NULL,
  `frequent_flyer_number` varchar(16) DEFAULT NULL,
  `passport_issued_place` varchar(80) DEFAULT NULL,
  `meal_code` varchar(6) DEFAULT NULL,
  `place_of_birth` varchar(40) DEFAULT NULL,
  `address` varchar(200) DEFAULT NULL,
  `additional_details` text NOT NULL,
  `passenger_status` varchar(2) NOT NULL DEFAULT 'Y',
  `foc_status` enum('Y','N') NOT NULL DEFAULT 'N',
  `parent_pax_id` int DEFAULT NULL,
  PRIMARY KEY (`passenger_id`),
  KEY `airlines_request_id` (`airlines_request_id`),
  KEY `series_request_id` (`series_request_id`),
  KEY `request_approved_flight_id` (`request_approved_flight_id`),
  KEY `pnr` (`pnr`),
  KEY `passenger_type` (`passenger_type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='uploaded passenger details aginst request id and PNR';


CREATE TABLE `passenger_master` (
  `passenger_master_id` int NOT NULL AUTO_INCREMENT,
  `airlines_request_id` int DEFAULT NULL,
  `pnr` varchar(10) NOT NULL DEFAULT '' COMMENT 'holds segment wise pnr',
  `time_validity` datetime DEFAULT NULL,
  `passenger_status` int DEFAULT NULL,
  `requested_date` datetime DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `passenger_remarks` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`passenger_master_id`),
  KEY `time_validity` (`time_validity`),
  KEY `airlines_request_id` (`airlines_request_id`),
  KEY `idx_pnr` (`pnr`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='ticketing validity date details based on PNR';


CREATE TABLE `passenger_pnr_mapping` (
  `passenger_pnr_id` int NOT NULL AUTO_INCREMENT,
  `pnr_id` int DEFAULT NULL,
  `passenger_id` int DEFAULT NULL,
  `ticketing_id` int NOT NULL,
  `submitted_by` int DEFAULT NULL,
  PRIMARY KEY (`passenger_pnr_id`),
  KEY `passenger_id` (`passenger_id`),
  KEY `pnr_id` (`pnr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='ticket details against passenger details';


CREATE TABLE `passenger_template_condition_details` (
  `template_condition_id` int NOT NULL AUTO_INCREMENT,
  `condition_name` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `condition_type` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `display_status` varchar(5) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'Y',
  `condition_logical_name` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `created_date` datetime NOT NULL,
  PRIMARY KEY (`template_condition_id`),
  KEY `condition_logical_name` (`condition_logical_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Passenger template policy condition values';


CREATE TABLE `passenger_template_condition_mapping` (
  `passenger_template_condition_mapping_id` int NOT NULL AUTO_INCREMENT,
  `passenger_template_field_mapping_id` int NOT NULL,
  `template_condition_id` int NOT NULL,
  `template_condition_value` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`passenger_template_condition_mapping_id`),
  KEY `passenger_template_field_mapping_id` (`passenger_template_field_mapping_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='name upload template filed and condition mapping details with condition value';


CREATE TABLE `passenger_template_criteria_master` (
  `criteria_id` int NOT NULL AUTO_INCREMENT,
  `criteria_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `criteria_type` char(3) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `display_status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'Y',
  `criteria_logical_id` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`criteria_id`),
  KEY `criteria_logical_id` (`criteria_logical_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for name update creteria';


CREATE TABLE `passenger_template_details` (
  `passenger_template_id` int NOT NULL AUTO_INCREMENT,
  `passenger_template_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `status` varchar(5) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'Y',
  `created_by` int NOT NULL,
  `created_date` datetime NOT NULL,
  `updated_date` datetime NOT NULL,
  PRIMARY KEY (`passenger_template_id`),
  KEY `passenger_template_name` (`passenger_template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Name upload template policy name details';


CREATE TABLE `passenger_template_field_condition_mapping` (
  `passenger_template_field_condition_mapping_id` int NOT NULL AUTO_INCREMENT,
  `template_field_id` int NOT NULL,
  `template_condition_id` int NOT NULL,
  PRIMARY KEY (`passenger_template_field_condition_mapping_id`),
  KEY `template_field_id` (`template_field_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Name upload template policy condition and field mapping details';


CREATE TABLE `passenger_template_field_details` (
  `template_field_id` int NOT NULL AUTO_INCREMENT,
  `template_field_name` varchar(25) DEFAULT NULL,
  `template_field_type` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `display_status` varchar(5) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'Y',
  `template_logical_name` varchar(25) DEFAULT NULL,
  `created_date` datetime NOT NULL,
  PRIMARY KEY (`template_field_id`),
  KEY `template_logical_name` (`template_logical_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for name upload field details table';


CREATE TABLE `passenger_template_field_mapping` (
  `passenger_template_field_mapping_id` int NOT NULL AUTO_INCREMENT,
  `passenger_template_id` int NOT NULL,
  `template_field_id` int NOT NULL,
  PRIMARY KEY (`passenger_template_field_mapping_id`),
  KEY `passenger_template_id` (`passenger_template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Mapping table for template and field details';


CREATE TABLE `passenger_template_policy_details` (
  `policy_details_id` int NOT NULL AUTO_INCREMENT,
  `policy_id` int DEFAULT NULL,
  `criteria_id` int DEFAULT NULL,
  `loop_value` int DEFAULT '0',
  `operator_id` int DEFAULT NULL,
  `policy_value` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`policy_details_id`),
  KEY `policy_id` (`policy_id`),
  KEY `criteria_id` (`criteria_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Name upload policy criteria value details';


CREATE TABLE `passenger_template_policy_master` (
  `policy_id` int NOT NULL AUTO_INCREMENT,
  `policy_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `passenger_template_id` int DEFAULT NULL,
  `priority` int DEFAULT NULL,
  `active_status` char(1) NOT NULL DEFAULT 'Y',
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `policy_dow` varchar(100) DEFAULT NULL,
  `created_date` datetime NOT NULL,
  `created_by` int NOT NULL,
  PRIMARY KEY (`policy_id`),
  KEY `policy_name` (`policy_name`),
  KEY `passenger_template_id` (`passenger_template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='name upload policy details';


CREATE TABLE `pax_type_details` (
  `pax_type_id` int NOT NULL AUTO_INCREMENT,
  `pax_type_value` varchar(10) NOT NULL DEFAULT '' COMMENT 'PAX type values',
  `display_value` varchar(50) DEFAULT NULL,
  `view_status` enum('Y','N') NOT NULL DEFAULT 'Y' COMMENT 'Y -active, N-Deactive',
  PRIMARY KEY (`pax_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='All Pax types on PNR';


CREATE TABLE `payment_additional_charge_details` (
  `payment_charge_id` int NOT NULL AUTO_INCREMENT,
  `request_master_id` int NOT NULL DEFAULT '0',
  `ssr_list_id` int NOT NULL DEFAULT '0',
  `ssr_master_id` int DEFAULT '0',
  `pnr_blocking_id` int NOT NULL DEFAULT '0',
  `additional_amount` double NOT NULL DEFAULT '0',
  `pnr_payment_id` int DEFAULT NULL,
  `paid_status` varchar(20) DEFAULT NULL,
  `remarks` varchar(300) DEFAULT NULL,
  `modified_details` text,
  `series_group_id` int DEFAULT NULL,
  `ssr_status` varchar(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT 'N',
  PRIMARY KEY (`payment_charge_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='generic fee table against PNR';


CREATE TABLE `payment_details` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `response_code` int DEFAULT NULL,
  `response_message` varchar(64) DEFAULT NULL,
  `transaction_type_id` int DEFAULT NULL,
  `request_source` varchar(25) DEFAULT NULL,
  `request_source_id` int DEFAULT NULL,
  `payment_amount` double DEFAULT NULL,
  `payment_status` char(3) DEFAULT NULL,
  `payment_mode` varchar(25) DEFAULT NULL,
  `paid_by` int DEFAULT NULL,
  `payment_date` datetime DEFAULT NULL,
  PRIMARY KEY (`payment_id`),
  KEY `request_source_id` (`request_source_id`),
  KEY `paid_by` (`paid_by`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Payment details with mode of payment';


CREATE TABLE `payment_failed_history` (
  `payment_failed_id` int NOT NULL AUTO_INCREMENT,
  `payment_master_id` int DEFAULT NULL,
  `request_master_id` int DEFAULT NULL,
  `pnr` varchar(10) DEFAULT NULL,
  `amount_to_pay` double DEFAULT NULL,
  `paid_by` int DEFAULT NULL,
  `card_type` varchar(6) DEFAULT NULL,
  `card_number` varchar(200) DEFAULT NULL,
  `cvv_number` varchar(50) DEFAULT NULL,
  `card_name_holder` varchar(150) DEFAULT NULL,
  `expirydate_year` varchar(25) DEFAULT NULL,
  `expirydate_month` varchar(25) DEFAULT NULL,
  `pnr_status` varchar(20) DEFAULT NULL,
  `payment_status` varchar(20) DEFAULT NULL,
  `card_authorization` varchar(20) DEFAULT NULL,
  `error` varchar(300) DEFAULT NULL,
  `updated_date` datetime DEFAULT NULL,
  PRIMARY KEY (`payment_failed_id`),
  KEY `paid_by` (`paid_by`),
  KEY `request_master_id` (`request_master_id`),
  KEY `payment_master_id` (`payment_master_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Payment failed details table';


CREATE TABLE `payment_master` (
  `payment_master_id` int NOT NULL AUTO_INCREMENT,
  `airlines_request_id` int DEFAULT NULL,
  `payment_percentage` double DEFAULT '0',
  `percentage_amount` double DEFAULT NULL,
  `exchange_rate` double NOT NULL DEFAULT '0',
  `payment_validity_date` datetime DEFAULT NULL,
  `payment_requested_date` datetime DEFAULT NULL,
  `payment_remarks` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `payment_status` int DEFAULT NULL,
  `paid_date` datetime DEFAULT NULL,
  PRIMARY KEY (`payment_master_id`),
  KEY `airlines_request_id` (`airlines_request_id`),
  KEY `payment_validity_date` (`payment_validity_date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for the payment process';


CREATE TABLE `payment_pending_history` (
  `payment_pending_id` int NOT NULL AUTO_INCREMENT,
  `airlines_request_id` int DEFAULT NULL,
  `payment_master_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `pnr` varchar(10) DEFAULT NULL,
  `payment_requested_amount` double DEFAULT NULL,
  `card_type` varchar(10) DEFAULT NULL,
  `card_last_digit` varchar(6) DEFAULT NULL,
  `corn_count` int DEFAULT NULL,
  `paid_by` int DEFAULT NULL,
  `payment_status` varchar(15) DEFAULT NULL,
  `payment_date` datetime DEFAULT NULL,
  `last_updated_date` datetime DEFAULT NULL,
  PRIMARY KEY (`payment_pending_id`),
  KEY `user_id` (`user_id`),
  KEY `payment_master_id` (`payment_master_id`),
  KEY `airlines_request_id` (`airlines_request_id`),
  KEY `paid_by` (`paid_by`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Maintaing the payment pending details';


CREATE TABLE `payment_request_details` (
  `payment_request_id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` int NOT NULL DEFAULT '0',
  `payment_validity` int NOT NULL DEFAULT '0',
  `payment_validity_type` int NOT NULL DEFAULT '0',
  `payment_expiry_type` int NOT NULL DEFAULT '1',
  `payment_expiry_date` datetime NOT NULL,
  `payment_percentage` double NOT NULL DEFAULT '0',
  `paid_status` varchar(20) NOT NULL DEFAULT '',
  `payment_absolute_amount` double NOT NULL DEFAULT '0',
  PRIMARY KEY (`payment_request_id`),
  KEY `transaction_id` (`transaction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Approved request all validity details table';


CREATE TABLE `payment_request_details_history` (
  `payment_request_history_id` int NOT NULL AUTO_INCREMENT,
  `payment_request_id` int DEFAULT NULL,
  `transaction_id` int NOT NULL DEFAULT '0',
  `payment_validity` int NOT NULL DEFAULT '0',
  `payment_validity_type` int NOT NULL DEFAULT '0',
  `payment_expiry_type` int NOT NULL DEFAULT '1',
  `payment_expiry_date` datetime NOT NULL,
  `payment_percentage` double NOT NULL DEFAULT '0',
  `paid_status` varchar(20) NOT NULL DEFAULT '',
  `payment_absolute_amount` double NOT NULL DEFAULT '0',
  PRIMARY KEY (`payment_request_history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='History table for validity details';


CREATE TABLE `payment_transaction_details` (
  `payment_transaction_id` int NOT NULL AUTO_INCREMENT,
  `payment_master_id` int DEFAULT NULL,
  `payment_type_id` int DEFAULT NULL,
  `paid_amount` double DEFAULT '0',
  `receipt_number` varchar(100) DEFAULT NULL,
  `bank_name` int DEFAULT '0',
  `paid_date` date DEFAULT NULL,
  `payment_received_by` int DEFAULT NULL,
  `payment_transaction_date` datetime DEFAULT NULL,
  `remarks` text,
  `status` enum('Y','N','D') DEFAULT 'N',
  PRIMARY KEY (`payment_transaction_id`),
  KEY `payment_master_id` (`payment_master_id`),
  KEY `payment_received_by` (`payment_received_by`),
  KEY `payment_type_id` (`payment_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='This table for bank tranfer payment details';


CREATE TABLE `payment_type_details` (
  `payment_type_id` int NOT NULL AUTO_INCREMENT,
  `payment_type_code` varchar(10) DEFAULT NULL,
  `payment_type_description` varchar(25) DEFAULT NULL,
  `parent_payment_type_id` int NOT NULL DEFAULT '0',
  `display_status` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`payment_type_id`),
  KEY `payment_type_code` (`payment_type_code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for payment types';


CREATE TABLE `penality_type_master` (
  `penality_type_id` int NOT NULL AUTO_INCREMENT,
  `penality_type_code` varchar(5) DEFAULT NULL,
  `penality_type_name` varchar(20) DEFAULT NULL,
  `category` varchar(40) DEFAULT NULL,
  `config` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT 'Y',
  PRIMARY KEY (`penality_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `pnr_blocking_details` (
  `pnr_blocking_id` int NOT NULL AUTO_INCREMENT,
  `request_master_id` int NOT NULL DEFAULT '0',
  `request_approved_flight_id` int NOT NULL DEFAULT '0',
  `via_flight_id` int NOT NULL DEFAULT '0',
  `pnr` varchar(10) NOT NULL DEFAULT '',
  `no_of_adult` int NOT NULL DEFAULT '0',
  `no_of_child` int NOT NULL DEFAULT '0',
  `no_of_infant` int NOT NULL DEFAULT '0',
  `no_of_foc` int NOT NULL DEFAULT '0',
  `pnr_amount` double NOT NULL DEFAULT '0',
  `price_quote_at` text,
  `status` varchar(30) DEFAULT NULL,
  `created_date` datetime DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`pnr_blocking_id`),
  KEY `request_master_id` (`request_master_id`),
  KEY `request_approved_flight_id` (`request_approved_flight_id`),
  KEY `via_flight_id` (`via_flight_id`),
  KEY `pnr` (`pnr`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Pnr for ech request with passenger count';


CREATE TABLE `pnr_details` (
  `pnr_id` int NOT NULL AUTO_INCREMENT,
  `airlines_request_id` int DEFAULT NULL,
  `request_id` int DEFAULT NULL,
  `series_request_id` int DEFAULT '0',
  `pnr_number` varchar(50) DEFAULT NULL,
  `pnr_status` int DEFAULT NULL,
  `ticket_type` varchar(10) NOT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`pnr_id`),
  KEY `airlines_request_id` (`airlines_request_id`),
  KEY `series_request_id` (`series_request_id`),
  KEY `request_id` (`request_id`),
  KEY `idx_pnr_number` (`pnr_number`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Name updated PNR details';


CREATE TABLE `pnr_payment_details` (
  `pnr_payment_id` int NOT NULL AUTO_INCREMENT,
  `payment_master_id` int NOT NULL DEFAULT '0',
  `pnr` varchar(10) NOT NULL DEFAULT '',
  `paid_amount` double NOT NULL DEFAULT '0',
  `paid_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `group_pax_paid` varchar(100) DEFAULT '',
  `group_pax_percent` double DEFAULT NULL,
  `payment_status` varchar(20) NOT NULL DEFAULT '',
  `payment_service_id` varchar(100) NOT NULL DEFAULT '',
  `topup_id` int DEFAULT '0',
  `pnr_payment_validity_date` datetime DEFAULT NULL,
  `request_timeline_id` int DEFAULT NULL,
  `pnr_percentage_amount` double DEFAULT NULL,
  `convinence_charge` double DEFAULT '0',
  PRIMARY KEY (`pnr_payment_id`),
  KEY `payment_master_id` (`payment_master_id`),
  KEY `pnr_payment_validity_date` (`pnr_payment_validity_date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Paymenet details at PNR level';


CREATE TABLE `pnr_payment_transactions` (
  `pnr_payment_transaction_id` int unsigned NOT NULL AUTO_INCREMENT,
  `pnr_payment_id` int DEFAULT NULL,
  `payment_transaction_id` int DEFAULT NULL,
  `currency` varchar(3) DEFAULT NULL,
  `exchange_rate` double DEFAULT NULL,
  `paid_amount` double DEFAULT NULL,
  `original_requested_amount` double NOT NULL DEFAULT '0',
  `status` enum('Y','N') DEFAULT NULL,
  PRIMARY KEY (`pnr_payment_transaction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Mapping table for the pnr payment details and payment transaction details.Insertion process will done during request,approve,decline the payment';


CREATE TABLE `pnr_remainder_mail_details` (
  `pnr_remainder_mail_id` int NOT NULL AUTO_INCREMENT,
  `pnr` varchar(7) DEFAULT NULL,
  `pnr_action` varchar(10) DEFAULT NULL,
  `to_mail_id` varchar(400) DEFAULT NULL,
  `cc_mail_id` varchar(400) DEFAULT NULL,
  `from_queue_no` int NOT NULL,
  `to_queue_no` int NOT NULL,
  `user_remark` varchar(500) DEFAULT NULL,
  `pnr_remarks` varchar(200) DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `action_date` datetime DEFAULT NULL,
  `status` char(1) DEFAULT NULL,
  `action_by` int DEFAULT NULL,
  `pos` varchar(3) DEFAULT NULL,
  PRIMARY KEY (`pnr_remainder_mail_id`),
  KEY `action_date` (`action_date`),
  KEY `pnr` (`pnr`),
  KEY `pnr_action` (`pnr_action`),
  KEY `expiry_date` (`expiry_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='DTL/TTL queue mail process';


CREATE TABLE `policy_details` (
  `policy_details_id` int NOT NULL AUTO_INCREMENT,
  `policy_id` int DEFAULT NULL,
  `criteria_id` int DEFAULT NULL,
  `loop_value` int NOT NULL DEFAULT '0',
  `operator_id` int DEFAULT NULL,
  `policy_value` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`policy_details_id`),
  KEY `operator_id` (`operator_id`),
  KEY `criteria_id` (`criteria_id`),
  KEY `policy_id` (`policy_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Discount policy details table with criteria values';


CREATE TABLE `policy_group_mapping` (
  `policy_group_mapping_id` int NOT NULL AUTO_INCREMENT,
  `request_master_id` int DEFAULT NULL,
  `series_group_id` int DEFAULT NULL,
  `request_approved_flight_id` int DEFAULT NULL,
  `via_flight_id` int DEFAULT NULL,
  `request_master_history_id` int DEFAULT NULL,
  `policy_mapping_id` int DEFAULT NULL,
  `status` char(1) DEFAULT NULL,
  PRIMARY KEY (`policy_group_mapping_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `policy_mapping` (
  `policy_mapping_id` int NOT NULL AUTO_INCREMENT,
  `policy_type_id` int DEFAULT NULL,
  `policy_id` int DEFAULT NULL,
  `matrix_id` int DEFAULT NULL,
  `status` char(1) DEFAULT 'Y',
  PRIMARY KEY (`policy_mapping_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `policy_master` (
  `policy_id` int NOT NULL AUTO_INCREMENT,
  `policy_name` varchar(100) DEFAULT NULL,
  `discount_matrix_id` int DEFAULT NULL,
  `priority` int DEFAULT NULL,
  `active_status` char(1) DEFAULT 'Y',
  `active_date` datetime DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `policy_dow` varchar(100) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `updated_date` datetime DEFAULT NULL COMMENT 'Updated date of the policy',
  `updated_by` int DEFAULT NULL COMMENT 'Updated by this user',
  PRIMARY KEY (`policy_id`),
  KEY `active_status` (`active_status`),
  KEY `priority` (`priority`),
  KEY `discount_matrix_id` (`discount_matrix_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Discount policy details table';


CREATE TABLE `policy_type_details` (
  `policy_type_id` int NOT NULL AUTO_INCREMENT,
  `policy_type_code` varchar(5) DEFAULT NULL COMMENT 'Policy type code',
  `policy_type_name` varchar(100) DEFAULT NULL COMMENT 'Policy type name',
  `policy_type_value` varchar(100) DEFAULT NULL COMMENT 'Policy type value for all policies',
  `matrix_table_name` varchar(100) DEFAULT NULL COMMENT 'Matrix table name for all policies',
  `policy_type_status` enum('Y','N') NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`policy_type_id`),
  KEY `policy_type_code` (`policy_type_code`),
  KEY `policy_type_value` (`policy_type_value`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Policy type details for storing all type of policies to map with common_policy_master';


CREATE TABLE `pos_details` (
  `pos_id` int NOT NULL AUTO_INCREMENT,
  `pos_code` varchar(8) DEFAULT NULL,
  `pos_city` varchar(40) DEFAULT NULL,
  `pos_country` char(2) DEFAULT NULL,
  `pos_region` varchar(40) DEFAULT NULL,
  `pos_office_id` varchar(20) DEFAULT NULL,
  `station_number` varchar(20) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `status` enum('Y','N') DEFAULT 'Y',
  PRIMARY KEY (`pos_id`),
  KEY `pos_code` (`pos_code`),
  KEY `pos_country` (`pos_country`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for POS details';


CREATE TABLE `pos_user_mapping` (
  `pos_user_id` int NOT NULL AUTO_INCREMENT,
  `pos_code` varchar(8) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `active_status` enum('Y','N','D') NOT NULL DEFAULT 'Y' COMMENT '''Y'' activated user,''N'' deactivated user,''D''  deleted user',
  PRIMARY KEY (`pos_user_id`),
  KEY `user_id` (`user_id`),
  KEY `pos_code` (`pos_code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='POS management details table';


CREATE TABLE `product_details` (
  `product_id` int NOT NULL AUTO_INCREMENT,
  `booking_profile_id` int DEFAULT NULL,
  `airline_code` char(2) DEFAULT NULL,
  `origin_airport_code` char(3) DEFAULT NULL,
  `dest_airport_code` char(3) DEFAULT NULL,
  `flight_number` varchar(8) DEFAULT NULL,
  `time_departure` varchar(5) DEFAULT NULL,
  `time_arrival` varchar(5) DEFAULT NULL,
  `capacity` int DEFAULT NULL,
  `fare` double DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `day_preference` varchar(20) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`product_id`),
  KEY `booking_profile_id` (`booking_profile_id`),
  KEY `dest_airport_code` (`dest_airport_code`),
  KEY `origin_airport_code` (`origin_airport_code`),
  KEY `booking_profile_id_2` (`booking_profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Need to remove';


CREATE TABLE `proof_details` (
  `proof_id` int NOT NULL AUTO_INCREMENT,
  `proof_type` varchar(40) DEFAULT NULL,
  `adult_status` char(2) DEFAULT 'N',
  `child_status` char(2) DEFAULT 'N',
  `infant_status` char(2) DEFAULT 'N',
  `proof_code` char(3) DEFAULT NULL,
  PRIMARY KEY (`proof_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for ID Proof details';


CREATE TABLE `pwd_upgrade` (
  `pwd_upgrade_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `old_pwd` varchar(40) NOT NULL,
  `new_pwd` varchar(90) NOT NULL,
  `updated_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`pwd_upgrade_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `queue_batch_details` (
  `queue_batch_id` int NOT NULL AUTO_INCREMENT,
  `total_pnr_count` int DEFAULT '0',
  `processed_pnr_count` int DEFAULT '0',
  `batch_date` datetime DEFAULT NULL,
  `batch_status` enum('Y','N') DEFAULT 'Y',
  PRIMARY KEY (`queue_batch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Queue PNR read information';


CREATE TABLE `queue_pnr_details` (
  `queue_pnr_id` int NOT NULL AUTO_INCREMENT,
  `queue_batch_id` int DEFAULT '0',
  `pnr` varchar(10) DEFAULT NULL,
  `locator` varchar(5) DEFAULT NULL,
  `placed_by` varchar(5) DEFAULT NULL,
  `pnr_created_datetime` datetime DEFAULT NULL,
  `pnr_status` enum('Y','N') DEFAULT 'Y',
  `pnr_remarks` varchar(300) DEFAULT NULL,
  `request_status` int DEFAULT NULL,
  `request_master_id` int DEFAULT NULL,
  `queue_no` int DEFAULT '0',
  PRIMARY KEY (`queue_pnr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Map the queue PNR and request master ID.';


CREATE TABLE `registration_payment_details` (
  `registration_payment_id` int unsigned NOT NULL AUTO_INCREMENT,
  `corporate_id` int NOT NULL COMMENT 'Travel agent ID',
  `user_id` int NOT NULL COMMENT 'User Detail ID',
  `currency_id` int NOT NULL COMMENT 'Payment Currency',
  `amount` double NOT NULL COMMENT 'Payment amount',
  `payment_type_id` int NOT NULL DEFAULT '0' COMMENT 'Payment mode',
  `pnr_blocking_id` int NOT NULL DEFAULT '0' COMMENT 'Insert the dummy PNR in pnr_blockig details table',
  `emd_id` int NOT NULL DEFAULT '0' COMMENT 'EMD details ID',
  `status_id` int NOT NULL COMMENT '9 – Payment pending, 12- Payment completed, 19 – Fund verification',
  `paid_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Date of Payment',
  `approved_by` int NOT NULL DEFAULT '0' COMMENT 'Approved by person ID',
  `approved_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Date of approval',
  `other` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci COMMENT 'Wire transfer / Approved informations',
  PRIMARY KEY (`registration_payment_id`),
  KEY `corporate_id` (`corporate_id`),
  KEY `user_id` (`user_id`),
  KEY `currency_id` (`currency_id`),
  KEY `payment_type_id` (`payment_type_id`),
  KEY `pnr_blocking_id` (`pnr_blocking_id`),
  KEY `emd_id` (`emd_id`),
  KEY `status_id` (`status_id`),
  KEY `approved_by` (`approved_by`),
  CONSTRAINT `registration_payment_details_ibfk_1` FOREIGN KEY (`corporate_id`) REFERENCES `corporate_details` (`corporate_id`),
  CONSTRAINT `registration_payment_details_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user_details` (`user_id`),
  CONSTRAINT `registration_payment_details_ibfk_3` FOREIGN KEY (`currency_id`) REFERENCES `currency_details` (`currency_id`),
  CONSTRAINT `registration_payment_details_ibfk_7` FOREIGN KEY (`status_id`) REFERENCES `status_details` (`status_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci COMMENT='Registration fee details';


CREATE TABLE `remarks_details` (
  `remarks_id` int NOT NULL AUTO_INCREMENT,
  `remarks` varchar(255) DEFAULT NULL,
  `remarks_source` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`remarks_id`),
  KEY `remarks_source` (`remarks_source`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data for remarks while decline the request';


CREATE TABLE `report_navigation` (
  `menu_id` int NOT NULL AUTO_INCREMENT COMMENT 'Report id',
  `menu_type` varchar(30) NOT NULL COMMENT 'Report type ',
  `route` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `display_status` enum('Y','N') NOT NULL DEFAULT 'Y' COMMENT 'Menu is enable or disable',
  PRIMARY KEY (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Define various menu in reports';


CREATE TABLE `request_approved_fare_details` (
  `request_approved_fare_id` int unsigned NOT NULL AUTO_INCREMENT,
  `request_approved_flight_id` int DEFAULT '0' COMMENT 'request_approved_flight_id from request_approved_flight_details',
  `request_approved_flight_history_id` int DEFAULT '0',
  `approved_fare` varchar(60) NOT NULL COMMENT 'To store the total fare fare for adult, child and infant',
  `approved_tax` text,
  `approved_discount` varchar(120) DEFAULT NULL,
  `approved_fare_details` text,
  `approved_policy_details` text,
  `via_flight_details` text,
  `fare_filter_method` char(5) DEFAULT 'BF' COMMENT 'Fare type which is user accepted',
  `request_timeline_id` varchar(60) NOT NULL COMMENT 'store approved request timeline id corresponding fare type',
  `cancel_policy_id` varchar(60) NOT NULL COMMENT 'store approved cancel policy id corresponding fare type',
  `fare_accepted_status` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT 'set Y which fare type is accepted by user',
  PRIMARY KEY (`request_approved_fare_id`),
  KEY `request_approved_flight_id` (`request_approved_flight_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `request_approved_flight_details` (
  `request_approved_flight_id` int NOT NULL AUTO_INCREMENT,
  `airlines_request_id` int DEFAULT NULL,
  `transaction_master_id` int DEFAULT NULL,
  `request_id` int NOT NULL DEFAULT '0',
  `request_details_history_id` int DEFAULT '0',
  `series_request_id` int NOT NULL DEFAULT '0',
  `series_request_history_id` int DEFAULT '0',
  `request_option_id` int DEFAULT '0',
  `airline_code` varchar(5) DEFAULT NULL,
  `flight_code` varchar(10) DEFAULT NULL,
  `flight_number` varchar(20) DEFAULT NULL,
  `source` varchar(5) DEFAULT NULL,
  `destination` varchar(5) DEFAULT NULL,
  `departure_date` date NOT NULL,
  `arrival_date` date NOT NULL,
  `dep_time` varchar(6) NOT NULL DEFAULT '00:00',
  `arr_time` varchar(6) NOT NULL DEFAULT '00:00',
  `journey_time` varchar(6) NOT NULL DEFAULT '00:00',
  `fare_filter_method` varchar(30) DEFAULT '',
  `no_of_adult` int DEFAULT '0',
  `no_of_child` int DEFAULT '0',
  `no_of_infant` int DEFAULT '0',
  `displacement_cost` double NOT NULL DEFAULT '0',
  `base_fare` double NOT NULL DEFAULT '0',
  `tax` double NOT NULL DEFAULT '0',
  `fare_passenger` double NOT NULL DEFAULT '0',
  `tax_breakup` varchar(300) DEFAULT NULL,
  `child_base_fare` double NOT NULL DEFAULT '0',
  `child_tax` double NOT NULL DEFAULT '0',
  `child_tax_breakup` varchar(300) DEFAULT NULL,
  `infant_base_fare` double NOT NULL DEFAULT '0',
  `infant_tax` double NOT NULL DEFAULT '0',
  `infant_tax_breakup` varchar(300) DEFAULT NULL,
  `baggauge_fare` double DEFAULT '0',
  `meals_fare` double DEFAULT '0',
  `baggage_code` varchar(5) NOT NULL,
  `meals_code` varchar(6) DEFAULT NULL,
  `stops` int DEFAULT NULL,
  `capacity` int NOT NULL DEFAULT '0',
  `sold` int NOT NULL DEFAULT '0',
  `seat_availability` int NOT NULL DEFAULT '0',
  `discount_fare` double DEFAULT '0',
  `child_discount_fare` double DEFAULT '0',
  `sales_promo_discount_fare` double NOT NULL DEFAULT '0',
  `adjusted_amount` double DEFAULT '0',
  `accepted_flight_status` enum('Y','N') NOT NULL DEFAULT 'Y',
  `displacement_fare_remarks` text,
  `surcharge` double DEFAULT '0',
  `ancillary_fare` text,
  `free_cost_count` int NOT NULL DEFAULT '0',
  `foc_base_fare` double NOT NULL DEFAULT '0',
  `foc_tax` double NOT NULL DEFAULT '0',
  `foc_tax_breakup` varchar(300) DEFAULT NULL,
  `lfid` int DEFAULT NULL,
  PRIMARY KEY (`request_approved_flight_id`),
  KEY `airlines_request_id` (`airlines_request_id`),
  KEY `transaction_master_id` (`transaction_master_id`),
  KEY `request_id` (`request_id`),
  KEY `series_request_id` (`series_request_id`),
  KEY `departure_date` (`departure_date`,`arrival_date`),
  KEY `accepted_flight_status` (`accepted_flight_status`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Approved flight details for the transaction';


CREATE TABLE `request_approved_flight_history` (
  `request_approved_flight_history_id` int NOT NULL AUTO_INCREMENT,
  `airlines_request_id` int DEFAULT NULL,
  `transaction_history_id` int DEFAULT NULL,
  `request_id` int NOT NULL DEFAULT '0',
  `request_details_history_id` int DEFAULT '0',
  `series_request_history_id` int DEFAULT '0',
  `series_request_id` int NOT NULL DEFAULT '0',
  `request_option_id` int DEFAULT '0',
  `airline_code` varchar(5) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `flight_code` varchar(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `flight_number` varchar(20) DEFAULT NULL,
  `source` varchar(5) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `destination` varchar(5) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `departure_date` date NOT NULL,
  `arrival_date` date NOT NULL,
  `dep_time` varchar(6) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '00:00',
  `arr_time` varchar(6) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '00:00',
  `journey_time` varchar(6) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '00:00',
  `fare_filter_method` varchar(30) DEFAULT '',
  `no_of_adult` int DEFAULT '0',
  `no_of_child` int DEFAULT '0',
  `no_of_infant` int DEFAULT '0',
  `displacement_cost` double NOT NULL DEFAULT '0',
  `booking_profile_fare` double NOT NULL DEFAULT '0',
  `competetor_fare` double NOT NULL DEFAULT '0',
  `base_fare` double NOT NULL DEFAULT '0',
  `tax` double NOT NULL DEFAULT '0',
  `fare_passenger` double NOT NULL DEFAULT '0',
  `tax_breakup` varchar(150) NOT NULL DEFAULT '',
  `child_base_fare` double NOT NULL DEFAULT '0',
  `child_tax` double NOT NULL DEFAULT '0',
  `child_tax_breakup` varchar(150) NOT NULL DEFAULT '',
  `infant_base_fare` double NOT NULL DEFAULT '0',
  `infant_tax` double NOT NULL DEFAULT '0',
  `infant_tax_breakup` varchar(150) NOT NULL DEFAULT '',
  `baggauge_fare` double DEFAULT '0',
  `meals_fare` double DEFAULT '0',
  `tiger_connect_fare` double NOT NULL DEFAULT '0',
  `baggage_code` varchar(5) NOT NULL,
  `fare_type` char(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `fare_class` char(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `fare_basis_code` varchar(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `rule_number` varchar(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '0',
  `fare_sequence` varchar(5) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '0',
  `fare_application_type` varchar(15) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `stops` int DEFAULT NULL,
  `capacity` int NOT NULL DEFAULT '0',
  `sold` int NOT NULL DEFAULT '0',
  `seat_availability` int NOT NULL DEFAULT '0',
  `dep_terminal` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `arr_terminal` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `image_location` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `discount_fare` double DEFAULT '0',
  `child_discount_fare` double DEFAULT '0',
  `sales_promo_discount_fare` double NOT NULL DEFAULT '0',
  `adjusted_amount` double DEFAULT '0',
  `accepted_flight_status` enum('Y','N') NOT NULL DEFAULT 'Y',
  `displacement_fare_remarks` text,
  `surcharge` double DEFAULT '0',
  `ancillary_fare` text,
  `free_cost_count` int NOT NULL DEFAULT '0',
  `foc_base_fare` double NOT NULL DEFAULT '0',
  `foc_tax` double NOT NULL DEFAULT '0',
  `foc_tax_breakup` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`request_approved_flight_history_id`),
  KEY `airlines_request_id` (`airlines_request_id`),
  KEY `series_request_id` (`series_request_id`),
  KEY `transaction_history_id` (`transaction_history_id`),
  KEY `request_id` (`request_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='History table for the approved flight details';


CREATE TABLE `request_batch_details` (
  `request_batch_id` int NOT NULL AUTO_INCREMENT,
  `user_file_name` varchar(200) DEFAULT NULL,
  `backend_file_name` varchar(200) DEFAULT NULL,
  `total_request_count` int DEFAULT '0',
  `processed_request_count` int DEFAULT '0',
  `uploaded_date` datetime DEFAULT NULL,
  `processed_date` datetime DEFAULT NULL,
  `file_status` enum('U','P','C','D') DEFAULT 'U',
  `uploaded_by` int NOT NULL,
  PRIMARY KEY (`request_batch_id`),
  KEY `file_status` (`file_status`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Information about uploaded excel sheet of request details.';


CREATE TABLE `request_criteria_details` (
  `request_criteria_details_id` int NOT NULL AUTO_INCREMENT,
  `request_criteria_master_id` int NOT NULL,
  `request_criteria_field_id` int NOT NULL,
  `loop_value` int DEFAULT '0',
  `operator_id` int DEFAULT NULL,
  `criteria_value` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`request_criteria_details_id`),
  KEY `request_criteria_master_id` (`request_criteria_master_id`),
  KEY `request_criteria_field_id` (`request_criteria_field_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Mapping the value to the request criteria matrix';


CREATE TABLE `request_criteria_field_details` (
  `request_criteria_field_id` int NOT NULL AUTO_INCREMENT,
  `field_parent_id` int NOT NULL,
  `request_criteria_field_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `request_criteria_field_type` char(3) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `display_status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'Y',
  `ssr_display_status` enum('Y','N') NOT NULL DEFAULT 'N',
  `request_criteria_field_logical_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`request_criteria_field_id`),
  KEY `request_criteria_field_logical_name` (`request_criteria_field_logical_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Criteria master data for request criteria amtrix';


CREATE TABLE `request_criteria_master` (
  `request_criteria_master_id` int NOT NULL AUTO_INCREMENT,
  `request_criteria_master_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `status` varchar(5) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'Y',
  `created_by` int NOT NULL,
  `updated_by` int DEFAULT NULL,
  `created_date` datetime NOT NULL,
  `updated_date` datetime NOT NULL,
  `policy_type` varchar(20) DEFAULT NULL,
  `matrix_group_id` int DEFAULT NULL,
  PRIMARY KEY (`request_criteria_master_id`),
  KEY `request_criteria_master_name` (`request_criteria_master_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Matrix details for request criteria matrix';


CREATE TABLE `request_criteria_passengercount_details` (
  `criteria_passenger_count_id` int NOT NULL AUTO_INCREMENT,
  `request_criteria_master_id` int NOT NULL,
  `min_passenger` int NOT NULL,
  `max_passenger` int NOT NULL,
  `min_infant` int NOT NULL,
  `max_infant` int NOT NULL,
  `min_stops` int DEFAULT NULL,
  `foc` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`criteria_passenger_count_id`),
  KEY `request_criteria_master_id` (`request_criteria_master_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Mapping the limitation of passenger count for request criteria matrix';


CREATE TABLE `request_details` (
  `request_id` int NOT NULL AUTO_INCREMENT,
  `request_master_id` int DEFAULT NULL,
  `origin_airport_code` varchar(5) DEFAULT NULL,
  `dest_airport_code` varchar(5) DEFAULT NULL,
  `flight_number` varchar(200) DEFAULT NULL,
  `cabin` varchar(20) DEFAULT NULL,
  `from_date` date DEFAULT NULL,
  `to_date` date DEFAULT NULL,
  `start_time` varchar(5) DEFAULT NULL,
  `end_time` varchar(5) DEFAULT NULL,
  `series_weekdays` varchar(50) DEFAULT NULL,
  `baggage_allowance` varchar(250) DEFAULT '',
  `ancillary` varchar(50) DEFAULT NULL,
  `meals_code` char(6) DEFAULT NULL,
  `pnr` varchar(25) DEFAULT NULL,
  `trip_name` int NOT NULL,
  `trip_type` char(1) NOT NULL,
  PRIMARY KEY (`request_id`),
  KEY `request_master_id` (`request_master_id`),
  KEY `origin_airport_code` (`origin_airport_code`),
  KEY `dest_airport_code` (`dest_airport_code`),
  KEY `from_date` (`from_date`),
  KEY `pnr` (`pnr`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Requested itinerary details for the request';


CREATE TABLE `request_details_history` (
  `request_details_history_id` int NOT NULL AUTO_INCREMENT,
  `request_master_history_id` int NOT NULL,
  `request_master_id` int NOT NULL,
  `request_id` int DEFAULT '0',
  `origin_airport_code` varchar(5) DEFAULT NULL,
  `dest_airport_code` varchar(5) DEFAULT NULL,
  `from_date` date DEFAULT NULL,
  `to_date` date DEFAULT NULL,
  `flight_number` varchar(200) DEFAULT NULL,
  `baggage_allowance` varchar(250) DEFAULT '',
  `ancillary` char(5) DEFAULT NULL,
  `meals_code` char(5) NOT NULL,
  `cabin` varchar(20) DEFAULT NULL,
  `trip_type` char(1) NOT NULL,
  `trip_name` varchar(50) NOT NULL,
  PRIMARY KEY (`request_details_history_id`),
  KEY `request_master_id` (`request_master_id`),
  KEY `request_master_history_id` (`request_master_history_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='Requested modified itinerary details for the request';


CREATE TABLE `request_group_details` (
  `request_group_id` int NOT NULL AUTO_INCREMENT COMMENT 'request_group_id',
  `airlines_request_id` int DEFAULT NULL,
  `transaction_master_id` int DEFAULT NULL COMMENT 'transaction_master_id from transaction_master',
  `request_master_history_id` int NOT NULL DEFAULT '0' COMMENT 'From request_master_history',
  `series_group_id` int DEFAULT NULL COMMENT 'series_group_id from series_request_details',
  `materialization` varchar(3) DEFAULT NULL,
  `policy` varchar(2) DEFAULT NULL,
  `response_fare` varchar(30) DEFAULT NULL,
  `theshold_policy_id` varchar(30) DEFAULT NULL,
  `threshold_fare` varchar(30) DEFAULT NULL,
  `remarks` varchar(150) DEFAULT NULL,
  `group_status` tinyint DEFAULT NULL,
  `group_contract` text NOT NULL,
  PRIMARY KEY (`request_group_id`),
  KEY `airlines_request_id` (`airlines_request_id`),
  KEY `transaction_master_id` (`transaction_master_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `request_master` (
  `request_master_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `request_type` varchar(20) DEFAULT NULL,
  `request_type_id` int NOT NULL DEFAULT '0',
  `trip_type` char(1) DEFAULT '',
  `series_type` char(2) DEFAULT NULL,
  `user_currency` varchar(3) NOT NULL,
  `request_fare` double NOT NULL DEFAULT '0',
  `exchange_rate` double NOT NULL DEFAULT '0',
  `requested_date` datetime DEFAULT NULL,
  `number_of_passenger` int DEFAULT NULL,
  `number_of_adult` int DEFAULT '0',
  `number_of_child` int DEFAULT '0',
  `number_of_infant` int DEFAULT '0',
  `remarks` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `fare_acceptance_transaction_id` int DEFAULT NULL,
  `request_source` varchar(100) DEFAULT NULL,
  `requested_corporate` varchar(100) DEFAULT NULL,
  `opened_by` int NOT NULL,
  `opened_time` datetime NOT NULL,
  `view_status` varchar(10) NOT NULL,
  `request_raised_by` int DEFAULT '0',
  `priority` int DEFAULT '0',
  `auto_pilot_policy_id` int DEFAULT '0',
  `auto_pilot_status` varchar(10) DEFAULT 'NA' COMMENT 'TC-Take control,NA-Not applicable,NEW-Autopilot applicable,COMPLETED-Autopilot completed,NEGO-Negotiation autopilot,RUNNING-Autopilot is running,MODIFIED-Prevent the autopilot cron run from new request modify',
  `reference_request_master_id` int NOT NULL DEFAULT '0',
  `quote_type` varchar(2) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL COMMENT 'BK-bulkUpload',
  `request_group_name` varchar(100) NOT NULL DEFAULT '',
  `group_category_id` int DEFAULT NULL,
  `flexible_on_dates` enum('Y','N') DEFAULT 'N',
  `pnr_ignore_status` enum('Y','N') DEFAULT 'N',
  `queue_no` int DEFAULT '0',
  PRIMARY KEY (`request_master_id`),
  KEY `user_id` (`user_id`),
  KEY `fare_acceptance_transaction_id` (`fare_acceptance_transaction_id`),
  KEY `reference_request_master_id` (`reference_request_master_id`),
  KEY `request_raised_by` (`request_raised_by`),
  KEY `trip_type` (`trip_type`),
  KEY `requested_date` (`requested_date`),
  KEY `pnr_ignore_status` (`pnr_ignore_status`),
  KEY `series_type` (`series_type`),
  KEY `queue_no` (`queue_no`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='User raised group request master informations';


CREATE TABLE `request_master_history` (
  `request_master_history_id` int NOT NULL AUTO_INCREMENT,
  `request_master_id` int DEFAULT '0',
  `trip_type` char(1) DEFAULT '',
  `user_currency` varchar(3) NOT NULL,
  `request_fare` int DEFAULT NULL,
  `exchange_rate` double NOT NULL DEFAULT '0',
  `requested_date` datetime DEFAULT NULL,
  `remarks` varchar(300) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `request_raised_by` int DEFAULT '0',
  `cabin` varchar(20) DEFAULT NULL,
  `series_weekdays` varchar(50) DEFAULT NULL,
  `group_category_id` int DEFAULT '0',
  `flexible_on_dates` enum('Y','N') NOT NULL DEFAULT 'N',
  `modify_status` int DEFAULT '0',
  `actual_request_status` int DEFAULT '0',
  PRIMARY KEY (`request_master_history_id`),
  KEY `request_master_id` (`request_master_id`),
  KEY `modify_status` (`modify_status`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='Modify request information stored';


CREATE TABLE `request_open_history` (
  `request_open_id` int NOT NULL AUTO_INCREMENT,
  `request_master_id` int NOT NULL,
  `opened_by` int NOT NULL,
  `opened_time` datetime NOT NULL,
  `view_status` varchar(10) NOT NULL,
  PRIMARY KEY (`request_open_id`),
  KEY `request_master_id` (`request_master_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Group Request control taken tracking details';


CREATE TABLE `request_policy_criteria_master` (
  `request_policy_criteria_id` int NOT NULL AUTO_INCREMENT,
  `request_policy_criteria_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `request_policy_criteria_type` char(3) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `display_status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'Y',
  `request_policy_criteria_logical_id` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`request_policy_criteria_id`),
  KEY `request_policy_criteria_logical_id` (`request_policy_criteria_logical_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data for Request settings criteria''s';


CREATE TABLE `request_policy_details` (
  `request_policy_details_id` int NOT NULL AUTO_INCREMENT,
  `request_policy_id` int DEFAULT NULL,
  `request_criteria_id` int DEFAULT NULL,
  `loop_value` int DEFAULT '0',
  `operator_id` int DEFAULT NULL,
  `policy_value` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`request_policy_details_id`),
  KEY `request_policy_id` (`request_policy_id`),
  KEY `request_criteria_id` (`request_criteria_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Request settings criteria mapping to values';


CREATE TABLE `request_policy_master` (
  `request_policy_id` int NOT NULL AUTO_INCREMENT,
  `request_policy_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `request_criteria_id` int DEFAULT NULL,
  `priority` int DEFAULT NULL,
  `active_status` char(1) NOT NULL DEFAULT 'Y',
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `policy_dow` varchar(100) DEFAULT NULL,
  `created_date` datetime NOT NULL,
  `created_by` int NOT NULL,
  `policy_group_id` int DEFAULT NULL,
  `policy_string` text COMMENT 'String for the policy which is matched when policy applied to the request',
  PRIMARY KEY (`request_policy_id`),
  KEY `request_policy_name` (`request_policy_name`),
  KEY `request_criteria_id` (`request_criteria_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Request settings policy master table';


CREATE TABLE `request_probability_details` (
  `request_probability_details_id` int NOT NULL AUTO_INCREMENT,
  `request_probability_master_id` int NOT NULL,
  `ml_category` varchar(2) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL COMMENT 'ML type MR-Materialization rate,CR-Conversion rate,DP-dynamic pricing',
  `ml_response` text CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `ml_value` double NOT NULL,
  `status` enum('S','F') CHARACTER SET latin1 COLLATE latin1_bin NOT NULL COMMENT 'API response status(S-success,F-failure)',
  PRIMARY KEY (`request_probability_details_id`),
  KEY `request_probability_master_id` (`request_probability_master_id`),
  CONSTRAINT `request_probability_details_ibfk_1` FOREIGN KEY (`request_probability_master_id`) REFERENCES `request_probability_master` (`request_probability_master_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;


CREATE TABLE `request_probability_master` (
  `request_probability_master_id` int NOT NULL AUTO_INCREMENT,
  `request_master_id` int NOT NULL,
  `series_request_id` int NOT NULL,
  `flt_num` varchar(10) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL,
  `value` int NOT NULL COMMENT 'maintain values to call ML',
  `response_date` timestamp NOT NULL,
  PRIMARY KEY (`request_probability_master_id`),
  KEY `request_master_id` (`request_master_id`),
  KEY `series_request_id` (`series_request_id`),
  CONSTRAINT `request_probability_master_ibfk_1` FOREIGN KEY (`request_master_id`) REFERENCES `request_master` (`request_master_id`),
  CONSTRAINT `request_probability_master_ibfk_2` FOREIGN KEY (`series_request_id`) REFERENCES `series_request_details` (`series_request_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;


CREATE TABLE `request_quote_details` (
  `request_quote_id` int unsigned NOT NULL AUTO_INCREMENT,
  `request_master_id` int DEFAULT '0',
  `series_request_id` int DEFAULT '0',
  `series_request_history_id` int DEFAULT '0',
  `flight_searched_date` date DEFAULT NULL,
  `batch_start_date` date DEFAULT NULL,
  `quote_type` char(2) DEFAULT NULL,
  `status` varchar(10) DEFAULT 'NEW',
  `modify_status` enum('Y','N','P') DEFAULT 'Y',
  PRIMARY KEY (`request_quote_id`),
  KEY `request_master_id` (`request_master_id`),
  KEY `series_request_id` (`series_request_id`),
  KEY `modify_status` (`modify_status`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='To maintain and track the interline and out of horizon requests';


CREATE TABLE `request_timeline_details` (
  `request_timeline_id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` int NOT NULL DEFAULT '0',
  `pnr_blocking_id` int NOT NULL DEFAULT '0',
  `series_group_id` int NOT NULL DEFAULT '0',
  `policy_history_id` int DEFAULT '0',
  `time_line_id` int NOT NULL DEFAULT '0',
  `timeline_type` varchar(10) NOT NULL DEFAULT '',
  `validity` int NOT NULL DEFAULT '0',
  `validity_type` int NOT NULL DEFAULT '0',
  `expiry_type` int NOT NULL DEFAULT '1',
  `expiry_date` datetime NOT NULL,
  `percentage_value` double NOT NULL DEFAULT '0',
  `absolute_amount` double NOT NULL DEFAULT '0',
  `status` varchar(30) DEFAULT NULL,
  `materialization` int DEFAULT NULL,
  `policy` varchar(2) DEFAULT '0',
  PRIMARY KEY (`request_timeline_id`),
  KEY `transaction_id` (`transaction_id`),
  KEY `series_group_id` (`series_group_id`),
  KEY `timeline_type` (`timeline_type`),
  KEY `status` (`status`),
  KEY `policy_history_id` (`policy_history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Timeline information stored at each request group level';


CREATE TABLE `request_timeline_details_history` (
  `request_timeline_history_id` int NOT NULL AUTO_INCREMENT,
  `request_timeline_id` int NOT NULL DEFAULT '0',
  `transaction_id` int NOT NULL DEFAULT '0',
  `series_group_id` int NOT NULL DEFAULT '0',
  `policy_history_id` int NOT NULL DEFAULT '0',
  `time_line_id` int NOT NULL DEFAULT '0',
  `timeline_type` varchar(10) NOT NULL DEFAULT '',
  `validity` int NOT NULL DEFAULT '0',
  `validity_type` int NOT NULL DEFAULT '0',
  `expiry_type` int NOT NULL DEFAULT '1',
  `expiry_date` datetime NOT NULL,
  `percentage_value` double NOT NULL DEFAULT '0',
  `absolute_amount` double NOT NULL DEFAULT '0',
  `status` varchar(10) NOT NULL DEFAULT '',
  `materialization` int DEFAULT NULL,
  `policy` varchar(2) NOT NULL DEFAULT '',
  PRIMARY KEY (`request_timeline_history_id`),
  KEY `transaction_id` (`transaction_id`),
  KEY `series_group_id` (`series_group_id`),
  KEY `timeline_type` (`timeline_type`),
  KEY `status` (`status`),
  KEY `request_timeline_id` (`request_timeline_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='History table to store the Timeline information at each request group level. When give the sent for review, modify it will move to history table.';


CREATE TABLE `request_type_master` (
  `request_type_id` int NOT NULL AUTO_INCREMENT,
  `request_type_name` varchar(20) NOT NULL DEFAULT '',
  `request_type_status` enum('Y','N') NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`request_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data for request type and their status';


CREATE TABLE `request_via_flight_details` (
  `request_via_flight_id` int NOT NULL AUTO_INCREMENT,
  `request_master_id` int NOT NULL,
  `series_request_id` int DEFAULT '0',
  `request_details_history_id` int NOT NULL,
  `series_request_history_id` int NOT NULL,
  `origin` char(3) NOT NULL,
  `destination` char(3) NOT NULL,
  `airline_code` char(2) DEFAULT NULL,
  `flight_number` varchar(10) DEFAULT NULL,
  `departure_date` datetime DEFAULT '0000-00-00 00:00:00',
  `arrival_date` datetime DEFAULT '0000-00-00 00:00:00',
  `flight_status` enum('Y','P','N') NOT NULL,
  `option_id` tinyint(1) NOT NULL,
  `schedule_status` varchar(2) NOT NULL DEFAULT 'HK',
  PRIMARY KEY (`request_via_flight_id`),
  KEY `request_master_id` (`request_master_id`),
  KEY `origin` (`origin`),
  KEY `destination` (`destination`),
  KEY `series_request_id` (`series_request_id`),
  KEY `flight_status` (`flight_status`),
  KEY `departure_date` (`departure_date`),
  KEY `flight_number` (`flight_number`),
  KEY `series_request_history_id` (`series_request_history_id`),
  KEY `airline_code` (`airline_code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `reset_password` (
  `reset_token_id` int unsigned NOT NULL AUTO_INCREMENT COMMENT 'primary key',
  `user_id` int NOT NULL COMMENT 'mapping from user_details table',
  `url_token` varchar(200) NOT NULL COMMENT 'token which will be encrypted and sent through URL',
  `used_status` enum('Y','N','E') NOT NULL COMMENT 'status of token Y-used ,N-not used,E-expired',
  `reset_token_type` enum('RR','FR','PE','PC','GC','PL') CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'RR-Registration reset,FR-Forgot reset,PE-Password rxpiry,PC-Password change,PL-payment link',
  `initiated_time` datetime NOT NULL COMMENT 'created time',
  `expiry_time` datetime DEFAULT NULL COMMENT 'tokens expiry time',
  PRIMARY KEY (`reset_token_id`),
  UNIQUE KEY `url_token` (`url_token`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='This table  is for manage the reset password tokens against the user';


CREATE TABLE `response_details` (
  `response_id` int NOT NULL AUTO_INCREMENT,
  `airlines_request_id` int DEFAULT NULL,
  `transaction_master_id` int DEFAULT NULL,
  `response_fare` double DEFAULT NULL,
  `response_date` datetime DEFAULT NULL,
  `remarks` text,
  `response_status` int DEFAULT NULL,
  `response_user` int NOT NULL DEFAULT '0',
  `negotiation_autopilot_id` int DEFAULT '0',
  PRIMARY KEY (`response_id`),
  KEY `airlines_request_id` (`airlines_request_id`),
  KEY `transaction_master_id` (`transaction_master_id`),
  KEY `response_status` (`response_status`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Accept, Decline and Negotiate information stored here';


CREATE TABLE `review_status` (
  `review_status_id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` int DEFAULT NULL,
  `response_person_id` int DEFAULT NULL,
  `response_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `response_status` int DEFAULT NULL,
  PRIMARY KEY (`review_status_id`),
  KEY `transaction_id` (`transaction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Sent for review status details and it controls the group request who need to take an action';


CREATE TABLE `sales_promo_criteria_master` (
  `criteria_id` int NOT NULL AUTO_INCREMENT,
  `criteria_name` varchar(100) DEFAULT NULL,
  `criteria_type` char(3) DEFAULT NULL,
  `display_status` char(1) DEFAULT NULL,
  `criteria_logical_id` varchar(100) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`criteria_id`),
  KEY `criteria_logical_id` (`criteria_logical_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data for criteria of sales promotional fares setup';


CREATE TABLE `sales_promo_fare_mapping` (
  `sales_promo_fare_id` int NOT NULL AUTO_INCREMENT,
  `sales_promo_mapping_id` int DEFAULT NULL,
  `group_size` int DEFAULT NULL,
  `discount_fare` double DEFAULT NULL,
  PRIMARY KEY (`sales_promo_fare_id`),
  KEY `sales_promo_mapping_id` (`sales_promo_mapping_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Sales promotional fare for requested passenger group size';


CREATE TABLE `sales_promo_mapping_details` (
  `sales_promo_mapping_id` int NOT NULL AUTO_INCREMENT,
  `sales_promo_matrix_id` int DEFAULT NULL,
  `days_to_departure` int DEFAULT NULL,
  `booked_load_factor` int DEFAULT NULL,
  PRIMARY KEY (`sales_promo_mapping_id`),
  KEY `sales_promo_matrix_id` (`sales_promo_matrix_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Sales promotional fare days to departure for load factor';


CREATE TABLE `sales_promo_matrix` (
  `sales_promo_matrix_id` int NOT NULL AUTO_INCREMENT,
  `sales_promo_matrix_name` varchar(50) DEFAULT NULL,
  `sales_promo_matrix_type` char(5) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `status` enum('Y','N','D') DEFAULT 'Y',
  PRIMARY KEY (`sales_promo_matrix_id`),
  KEY `sales_promo_matrix_name` (`sales_promo_matrix_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Defining the matrix type of sales promotional fare';


CREATE TABLE `sales_promo_policy_details` (
  `sales_promo_policy_details_id` int NOT NULL AUTO_INCREMENT,
  `sales_promo_policy_id` int DEFAULT NULL,
  `criteria_id` int DEFAULT NULL,
  `loop_value` int DEFAULT NULL,
  `operator_id` int DEFAULT NULL,
  `policy_value` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`sales_promo_policy_details_id`),
  KEY `sales_promo_policy_id` (`sales_promo_policy_id`),
  KEY `criteria_id` (`criteria_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Map the criteria to values for Sales promotional fares';


CREATE TABLE `sales_promo_policy_master` (
  `sales_promo_policy_id` int NOT NULL AUTO_INCREMENT,
  `policy_name` varchar(100) DEFAULT NULL,
  `sales_promo_matrix_id` int DEFAULT NULL,
  `priority` int DEFAULT NULL,
  `active_status` char(1) DEFAULT 'Y',
  `active_date` datetime DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`sales_promo_policy_id`),
  KEY `policy_name` (`policy_name`),
  KEY `sales_promo_matrix_id` (`sales_promo_matrix_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Sales promotional fare for defining policy name and validities';


CREATE TABLE `save_search_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `process_type` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `value_type` enum('QB','AC') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'QB-Query Box,AC-Available Columns',
  `value` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `group_id` int NOT NULL DEFAULT '0',
  `user_id` int NOT NULL DEFAULT '0',
  `active_status` enum('Y','N','D') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL COMMENT 'Y-YES, N-NO, D-DELETE',
  `filter_name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT '',
  `default_status` enum('Y','N') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT 'N',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `saved_report_details` (
  `saved_report_id` int NOT NULL AUTO_INCREMENT COMMENT 'Saved Report id ',
  `report_name` varchar(25) NOT NULL COMMENT 'Report name as saved by user',
  `report_type_id` int NOT NULL COMMENT 'Type of report',
  `available_fields` varchar(150) NOT NULL COMMENT 'Selected fields for the saved report',
  `available_conditions` varchar(50) NOT NULL COMMENT 'Selected conditions for the saved report',
  `created_by` int NOT NULL COMMENT 'User saved the report',
  `created_date` datetime NOT NULL COMMENT 'Report saved date',
  `updated_by` int NOT NULL COMMENT 'Updated user id for the report',
  `updated_date` datetime NOT NULL COMMENT 'Updated date for the saved report',
  `deleted_by` int NOT NULL COMMENT 'User deleted the report',
  `deleted_date` datetime NOT NULL COMMENT 'Report deleted date',
  `status` enum('Y','D') NOT NULL COMMENT 'Report which are enables or deleted status',
  PRIMARY KEY (`saved_report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Saved report details are stored ';


CREATE TABLE `saved_reports` (
  `saved_report_id` int NOT NULL AUTO_INCREMENT,
  `saved_report_category` varchar(500) NOT NULL,
  `saved_report_name` varchar(50) NOT NULL,
  `report_additional_info` text NOT NULL,
  `schedule_status` char(1) NOT NULL DEFAULT 'N',
  `report_status` char(1) NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`saved_report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `saved_reports_mapping` (
  `saved_reports_mapping_id` int NOT NULL AUTO_INCREMENT,
  `saved_report_id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `group_id` int DEFAULT NULL,
  `status` char(1) NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`saved_reports_mapping_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `schedule_change_pnr_details` (
  `schedule_change_pnr_id` int NOT NULL AUTO_INCREMENT,
  `schedule_change_batch_id` int DEFAULT NULL,
  `pnr` varchar(10) DEFAULT NULL,
  `remarks` varchar(50) DEFAULT NULL,
  `pnr_status` enum('U','P','C') DEFAULT NULL,
  `processed_date` datetime DEFAULT NULL,
  PRIMARY KEY (`schedule_change_pnr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='To track the schedule changes status at PNR level';


CREATE TABLE `schedule_log_details` (
  `schedule_log_id` int NOT NULL AUTO_INCREMENT,
  `saved_report_id` int NOT NULL,
  `mail_recipients` varchar(500) NOT NULL,
  `schedule_actual_datetime` datetime NOT NULL,
  `schedule_sent_datetime` datetime DEFAULT NULL,
  `schedule_status` char(1) NOT NULL DEFAULT 'N',
  PRIMARY KEY (`schedule_log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `schedule_report_details` (
  `schedule_report_id` smallint unsigned NOT NULL AUTO_INCREMENT COMMENT 'schedule_report_id',
  `report_id` smallint unsigned DEFAULT NULL COMMENT 'report_id from corporate_extjs_reports',
  `email_id` varchar(256) NOT NULL COMMENT 'Email id for sending the email',
  `frequency` varchar(32) NOT NULL DEFAULT 'ALL',
  `start_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `end_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `run_at` time DEFAULT NULL,
  `created_by` int unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_by` int unsigned NOT NULL DEFAULT '0',
  `updated_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `batch_run_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Monitor the state of batch i.e(run or not)',
  `status` enum('1','0') DEFAULT '1',
  PRIMARY KEY (`schedule_report_id`),
  KEY `report_id` (`report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Corporate extjs details with the schedule values';


CREATE TABLE `schedule_report_mapping` (
  `schedule_report_mapping_id` smallint unsigned NOT NULL AUTO_INCREMENT COMMENT 'schedule_report_mapping_id',
  `schedule_report_id` smallint unsigned DEFAULT NULL COMMENT 'schedule_report_id from schedule_report_details',
  `condition_name` varchar(35) DEFAULT NULL,
  `condition_value` varchar(100) DEFAULT NULL COMMENT 'condition value which is given for respective condition in schedule report',
  `rolling` smallint unsigned NOT NULL DEFAULT '0' COMMENT 'count the day for the sending the mails when it is in rolling',
  PRIMARY KEY (`schedule_report_mapping_id`),
  KEY `schedule_report_id` (`schedule_report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='schedule report value with schedule report conditions';


CREATE TABLE `sector_management` (
  `sector_id` int NOT NULL AUTO_INCREMENT,
  `origin` char(3) DEFAULT NULL,
  `destination` char(3) DEFAULT NULL,
  `active_status` enum('Y','N','D') CHARACTER SET keybcs2 COLLATE keybcs2_bin DEFAULT 'Y',
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`sector_id`),
  KEY `destination` (`destination`),
  KEY `origin` (`origin`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Map the Origin and Destination to manage the request';


CREATE TABLE `sector_mapping` (
  `sector_mapping_id` int NOT NULL AUTO_INCREMENT,
  `origin` varchar(3) NOT NULL,
  `destination` varchar(3) NOT NULL,
  `operation_status` char(1) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  PRIMARY KEY (`sector_mapping_id`),
  KEY `origin` (`origin`),
  KEY `destination` (`destination`),
  KEY `operation_status` (`operation_status`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Mapping the Origin and destination with operation dates';


CREATE TABLE `sector_threshold_limit` (
  `sector_threshold_id` int NOT NULL AUTO_INCREMENT,
  `source` varchar(5) DEFAULT NULL,
  `destination` varchar(5) DEFAULT NULL,
  `threshold_limit` double DEFAULT NULL,
  `status` char(1) DEFAULT 'Y',
  PRIMARY KEY (`sector_threshold_id`),
  KEY `source` (`source`),
  KEY `destination` (`destination`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='To set the minimum threshold total fare to process the auto pilot';


CREATE TABLE `sector_user_mapping` (
  `sector_user_id` int NOT NULL AUTO_INCREMENT,
  `sector_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `group_id` int DEFAULT '0',
  `status` enum('Y','N') DEFAULT NULL,
  `primary_user` tinyint DEFAULT '0' COMMENT 'primary users =1',
  PRIMARY KEY (`sector_user_id`),
  KEY `user_id` (`user_id`),
  KEY `sector_id` (`sector_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Map the OD''s to an airline persons or groups based on that request shown to their work bench';


CREATE TABLE `selected_competitor_fare_history` (
  `selected_competitor_fare_id` int NOT NULL AUTO_INCREMENT,
  `airlines_request_id` int DEFAULT NULL,
  `transaction_id` int DEFAULT NULL,
  `transaction_history_id` int DEFAULT NULL,
  `request_approved_flight_id` int DEFAULT NULL,
  `request_approve_history_flight_id` int DEFAULT NULL,
  `competitor_flight_id` int DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`selected_competitor_fare_id`),
  KEY `airlines_request_id` (`airlines_request_id`),
  KEY `transaction_id` (`transaction_id`),
  KEY `transaction_history_id` (`transaction_history_id`),
  KEY `request_approved_flight_id` (`request_approved_flight_id`),
  KEY `request_approve_history_flight_id` (`request_approve_history_flight_id`),
  KEY `competitor_flight_id` (`competitor_flight_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Stored the Competitor fare applied on the request detail';


CREATE TABLE `series_flight_schedule_details` (
  `series_flight_schedule_id` int NOT NULL AUTO_INCREMENT,
  `series_request_id` int NOT NULL,
  `alternate_series_request_id` int DEFAULT '0',
  `request_id` int DEFAULT NULL,
  `request_details_history_id` int DEFAULT '0',
  `series_request_history_id` int DEFAULT NULL,
  `batch_id` int NOT NULL,
  `origin_airport_code` varchar(3) DEFAULT NULL,
  `dest_airport_code` varchar(3) DEFAULT NULL,
  `airlines_code` varchar(7) DEFAULT NULL,
  `cabin` varchar(10) DEFAULT NULL,
  `arrival_time` varchar(5) DEFAULT NULL,
  `departure_time` varchar(5) DEFAULT NULL,
  `flight_number` varchar(5) DEFAULT NULL,
  `flight_jounary_time` varchar(5) DEFAULT NULL,
  `leg_count` int DEFAULT NULL,
  `routing` varchar(11) DEFAULT NULL,
  `from_date` date DEFAULT NULL,
  `to_date` date DEFAULT NULL,
  `series_weekdays` varchar(13) DEFAULT NULL,
  `fare_filter_method` varchar(30) DEFAULT '',
  `displacement_fare` double DEFAULT NULL,
  `booking_profile_fare` int DEFAULT NULL,
  `competetor_fare` int DEFAULT NULL,
  `base_fare` double DEFAULT NULL,
  `child_base_fare` double DEFAULT '0',
  `tax` double DEFAULT NULL,
  `new_tax` double DEFAULT NULL,
  `child_tax` double DEFAULT '0',
  `new_child_tax` double NOT NULL DEFAULT '0',
  `currency_type` char(3) DEFAULT NULL,
  `capacity` int DEFAULT NULL,
  `sold` int DEFAULT NULL,
  `seat_availability` int DEFAULT NULL,
  `policy_id` int DEFAULT NULL,
  `policy_matrix_id` int DEFAULT NULL,
  `policy_matrix_type` char(5) DEFAULT NULL,
  `policy_currency_type` char(5) DEFAULT NULL,
  `policy_days_to_departure` int DEFAULT NULL,
  `booked_load_factor` int DEFAULT NULL,
  `policy_value` double DEFAULT NULL,
  `policy_display_value` varchar(10) DEFAULT NULL,
  `policy_discount_fare` double DEFAULT NULL,
  `policy_child_discount_fare` double DEFAULT '0',
  `existing_adult_base_fare` double DEFAULT NULL,
  `existing_adult_tax` double DEFAULT NULL,
  `existing_child_base_fare` double DEFAULT NULL,
  `existing_child_tax` double DEFAULT NULL,
  `competitor_status` enum('Y','N') DEFAULT 'N',
  `sales_promo_policy_matrix_type` varchar(5) DEFAULT NULL,
  `sales_promo_policy_value` double DEFAULT NULL,
  `sales_promo_policy_matrix_id` int DEFAULT NULL,
  `sales_promo_policy_id` int DEFAULT NULL,
  `sales_promo_policy_currency_type` varchar(5) DEFAULT NULL,
  `sales_promo_discount_fare` double DEFAULT NULL,
  `sales_promo_policy_display_value` varchar(10) DEFAULT NULL,
  `sales_promo_booked_factor` int DEFAULT NULL,
  `original_base_fare` double DEFAULT NULL,
  `sales_promo_policy_days_to_departure` int DEFAULT NULL,
  `surcharge` double DEFAULT '0',
  `surcharge_details` text,
  `load_factor_type` char(5) DEFAULT NULL,
  `forecast_load_factor` int DEFAULT '0',
  `ancillary_fare` text,
  `special_fare_type` text,
  `approved_fare_details` text,
  `approved_policy_details` text,
  `lfid` int DEFAULT NULL,
  PRIMARY KEY (`series_flight_schedule_id`),
  KEY `series_request_id` (`series_request_id`),
  KEY `request_id` (`request_id`),
  KEY `batch_id` (`batch_id`),
  KEY `dest_airport_code` (`dest_airport_code`),
  KEY `origin_airport_code` (`origin_airport_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Store the Series request batch flight details';


CREATE TABLE `series_request_details` (
  `series_request_id` int NOT NULL AUTO_INCREMENT,
  `request_id` int DEFAULT NULL,
  `departure_date` date DEFAULT NULL,
  `number_of_passenger` int DEFAULT '0',
  `number_of_adult` int DEFAULT '0',
  `number_of_child` int DEFAULT '0',
  `number_of_infant` int DEFAULT '0',
  `cabin` varchar(20) DEFAULT NULL,
  `start_time` varchar(5) DEFAULT NULL,
  `end_time` varchar(5) DEFAULT NULL,
  `baggage_allowance` varchar(250) DEFAULT NULL,
  `ancillary` varchar(50) DEFAULT NULL,
  `meals_code` char(6) DEFAULT NULL,
  `pnr` varchar(25) DEFAULT NULL,
  `expected_fare` double DEFAULT NULL,
  `flexible_on_dates` enum('Y','N') NOT NULL DEFAULT 'N',
  `group_category_id` int DEFAULT '0',
  `mapped_series_request_id` int DEFAULT '0',
  `series_group_id` int DEFAULT '1',
  `parent_series_group_id` int NOT NULL DEFAULT '0',
  `flight_number` varchar(200) DEFAULT NULL,
  `current_load_factor` varchar(100) DEFAULT NULL,
  `forecast_load_factor` varchar(100) DEFAULT NULL,
  `future_load_factor` varchar(100) DEFAULT NULL,
  `parent_series_request_id` int NOT NULL DEFAULT '0' COMMENT 'Map the series request id from parent request while divide/upsize',
  `flight_status` varchar(2) NOT NULL DEFAULT 'HK',
  `foc_pax` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`series_request_id`),
  KEY `request_id` (`request_id`),
  KEY `departure_date` (`departure_date`),
  KEY `mapped_series_request_id` (`mapped_series_request_id`),
  KEY `parent_series_request_id` (`parent_series_request_id`),
  KEY `parent_series_group_id` (`parent_series_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Series request departure date level informations';


CREATE TABLE `series_request_details_history` (
  `series_request_history_id` int NOT NULL AUTO_INCREMENT,
  `request_details_history_id` int NOT NULL,
  `series_request_id` int DEFAULT NULL,
  `request_id` int DEFAULT NULL,
  `departure_date` date DEFAULT NULL,
  `number_of_passenger` int DEFAULT '0',
  `number_of_adult` int DEFAULT '0',
  `number_of_child` int DEFAULT '0',
  `number_of_infant` int DEFAULT '0',
  `cabin` varchar(20) DEFAULT NULL,
  `baggage_allowance` varchar(250) DEFAULT NULL,
  `ancillary` char(5) DEFAULT NULL,
  `meals_code` char(5) DEFAULT NULL,
  `pnr` varchar(25) DEFAULT NULL,
  `expected_fare` double DEFAULT NULL,
  `flexible_on_date` enum('Y','N') NOT NULL DEFAULT 'N',
  `group_category_id` int DEFAULT '0',
  `mapped_series_request_id` int DEFAULT '0',
  `series_group_id` int DEFAULT '1',
  `parent_series_group_id` int NOT NULL DEFAULT '0',
  `flight_number` varchar(200) DEFAULT NULL,
  `current_load_factor` varchar(100) DEFAULT NULL,
  `forecast_load_factor` varchar(100) DEFAULT NULL,
  `future_load_factor` varchar(100) DEFAULT NULL,
  `parent_series_request_id` int NOT NULL DEFAULT '0',
  `modify_status` enum('Y','N') DEFAULT 'N',
  `flight_status` varchar(2) NOT NULL DEFAULT 'HK',
  `foc_pax` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`series_request_history_id`),
  KEY `request_details_history_id` (`request_details_history_id`),
  KEY `series_request_id` (`parent_series_request_id`),
  KEY `parent_series_group_id` (`parent_series_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `series_via_flight_details` (
  `series_via_flight_id` int NOT NULL AUTO_INCREMENT,
  `series_flight_schedule_id` int DEFAULT NULL,
  `origin_airport_code` varchar(3) NOT NULL,
  `dest_airport_code` varchar(3) NOT NULL,
  `airline_code` varchar(2) NOT NULL,
  `flight_number` varchar(5) NOT NULL DEFAULT '',
  `departure_date` date NOT NULL,
  `arrival_date` date NOT NULL,
  `time_departure` varchar(5) NOT NULL,
  `time_arrival` varchar(5) NOT NULL,
  `base_fare` double DEFAULT '0',
  `baggage_fare` double NOT NULL,
  `meals_fare` double NOT NULL,
  `ancillary_fare` text CHARACTER SET latin1 COLLATE latin1_swedish_ci,
  `capacity` int NOT NULL DEFAULT '0',
  `sold` int NOT NULL DEFAULT '0',
  `seat_availability` int NOT NULL DEFAULT '0',
  `forecast_load_factor` int DEFAULT '0',
  `surcharge` double DEFAULT '0',
  `discount_amount` double NOT NULL DEFAULT '0',
  `discount_details` text,
  `special_fare_type` text,
  PRIMARY KEY (`series_via_flight_id`),
  KEY `series_flight_schedule_id` (`series_flight_schedule_id`),
  KEY `origin_airport_code` (`origin_airport_code`),
  KEY `dest_airport_code` (`dest_airport_code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Series request batch via flight information';


CREATE TABLE `service_tax_details` (
  `service_tax_id` int unsigned NOT NULL AUTO_INCREMENT,
  `request_master_id` int DEFAULT '0',
  `corporate_id` int NOT NULL COMMENT 'Travel agent ID',
  `reference_number` varchar(16) NOT NULL COMMENT 'GST number',
  `agency_name` varchar(100) DEFAULT NULL,
  `agent_email_id` varchar(100) DEFAULT NULL,
  `Status` enum('Y','N') NOT NULL,
  `reference_type` varchar(2) NOT NULL,
  PRIMARY KEY (`service_tax_id`),
  UNIQUE KEY `reference_number_request_master_id` (`reference_number`,`request_master_id`),
  KEY `request_master_id` (`request_master_id`),
  KEY `corporate_id` (`corporate_id`),
  KEY `reference_number_2` (`reference_number`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='For GST registration number stored against the travel agency';


CREATE TABLE `session_details` (
  `session_details_id` int NOT NULL AUTO_INCREMENT,
  `session_id` varchar(40) NOT NULL,
  `user_id` int DEFAULT NULL,
  `last_active_time` int unsigned NOT NULL,
  `expiry_time` int unsigned NOT NULL,
  `useragent` text,
  `ipaddr` varchar(46) DEFAULT NULL,
  `login_time` datetime DEFAULT NULL,
  `active` enum('Y','N') DEFAULT 'Y',
  PRIMARY KEY (`session_details_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Check the user logged in session validation based on IP and broswers.';


CREATE TABLE `ssr_category_details` (
  `ssr_category_id` int NOT NULL AUTO_INCREMENT,
  `ssr_category_name` varchar(30) NOT NULL,
  `display_status` enum('Y','N','D') NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`ssr_category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data for Special service request category details';


CREATE TABLE `ssr_details` (
  `ssr_details_id` int NOT NULL AUTO_INCREMENT,
  `ssr_master_id` int NOT NULL COMMENT 'Mapping id from ssr_master',
  `ssr_pax_id` int NOT NULL DEFAULT '0' COMMENT 'Id for which passenger SSR has been added',
  `ssr_category_id` int NOT NULL COMMENT 'Category of SSR. 1-Meals, 2 – Baggage, 3- Others',
  `ssr_code` varchar(50) NOT NULL DEFAULT '' COMMENT 'SSR code of the selected SSR',
  `ssr_base_fare` double NOT NULL DEFAULT '0' COMMENT 'Base Fare for the selected SSR',
  `ssr_tax` double NOT NULL DEFAULT '0' COMMENT 'Tax for the selected SSR',
  `ssr_total_fare` double NOT NULL DEFAULT '0' COMMENT 'Total fare for the selected SSR',
  `emd_id` int DEFAULT '0',
  `ssr_status` varchar(32) NOT NULL DEFAULT '' COMMENT 'status of each ssr for each passenger. NEW, COMPLETED, ERROR',
  `remarks` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`ssr_details_id`),
  KEY `ssr_master_id` (`ssr_master_id`),
  KEY `ssr_pax_id` (`ssr_pax_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Passenger wise Special service request applied information';


CREATE TABLE `ssr_list` (
  `ssr_list_id` int NOT NULL AUTO_INCREMENT,
  `ssr_category_id` int NOT NULL,
  `ssr_subcategory_id` int DEFAULT NULL,
  `ssr_code` varchar(10) NOT NULL,
  `ssr_description` varchar(250) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `display_status` enum('Y','N','D') NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`ssr_list_id`),
  KEY `ssr_category_id` (`ssr_category_id`,`ssr_subcategory_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='List of special service request mapped to sub category and categories';


CREATE TABLE `ssr_master` (
  `ssr_master_id` int NOT NULL AUTO_INCREMENT,
  `request_master_id` int NOT NULL,
  `pnr` varchar(10) NOT NULL DEFAULT '' COMMENT 'SSR applied for the PNR',
  `ssr_amount` double NOT NULL DEFAULT '0' COMMENT 'Total amount of SSR for each transaction',
  `updated_by` int NOT NULL COMMENT 'User Id that who added the SSR for the request',
  `ssr_updated_date` datetime NOT NULL,
  `last_transaction` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT 'Y – Active last transaction of SSR, N – Previous entries of SSR',
  `status` varchar(32) NOT NULL DEFAULT '' COMMENT 'Status (New, Completed) of the SSR transaction',
  `ssr_category_id` int DEFAULT '0',
  PRIMARY KEY (`ssr_master_id`),
  KEY `request_master_id` (`request_master_id`),
  KEY `last_transaction` (`last_transaction`),
  KEY `pnr` (`pnr`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Special service request mapped to request master id and their transaction details';


CREATE TABLE `ssr_matrix_details` (
  `matrix_details_id` int NOT NULL AUTO_INCREMENT,
  `matrix_master_id` int NOT NULL,
  `request_criteria_field_id` int NOT NULL,
  `loop_value` int DEFAULT '0',
  `operator_id` int DEFAULT NULL,
  `criteria_value` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`matrix_details_id`),
  KEY `matrix_master_id` (`matrix_master_id`),
  KEY `request_criteria_field_id` (`request_criteria_field_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Matrix value details for ssr matrix';


CREATE TABLE `ssr_matrix_master` (
  `matrix_id` int NOT NULL AUTO_INCREMENT,
  `matrix_name` varchar(48) DEFAULT NULL,
  `status` char(1) DEFAULT 'Y',
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`matrix_id`),
  KEY `matrix_name` (`matrix_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for ssr matrix';


CREATE TABLE `ssr_pax_details` (
  `ssr_pax_id` int NOT NULL AUTO_INCREMENT,
  `pnr_blocking_id` int NOT NULL DEFAULT '0' COMMENT 'Mapping this id to add the SSR for the PNR',
  `via_flight_id` int NOT NULL DEFAULT '0',
  `pax_reference_id` varchar(200) DEFAULT NULL,
  `passenger_id` int NOT NULL DEFAULT '0' COMMENT 'Passenger id if the passenger name is updated',
  `status` enum('Y','N') NOT NULL DEFAULT 'Y' COMMENT 'Y -active, N-Deactive',
  PRIMARY KEY (`ssr_pax_id`),
  KEY `pnr_blocking_id` (`pnr_blocking_id`),
  KEY `pax_reference_id` (`pax_reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='All Pax details for SSR based on PNR';


CREATE TABLE `ssr_pax_grouping` (
  `ssr_pax_grouping_id` int NOT NULL AUTO_INCREMENT,
  `ssr_details_id` int NOT NULL DEFAULT '0',
  `ssr_id` varchar(200) DEFAULT NULL,
  `ssr_weight` varchar(15) NOT NULL DEFAULT '',
  PRIMARY KEY (`ssr_pax_grouping_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `ssr_policy_details` (
  `policy_details_id` int NOT NULL AUTO_INCREMENT,
  `policy_id` int DEFAULT NULL,
  `criteria_id` int DEFAULT NULL,
  `loop_value` int NOT NULL DEFAULT '0',
  `operator_id` int DEFAULT NULL,
  `policy_value` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`policy_details_id`),
  KEY `policy_id` (`policy_id`),
  KEY `criteria_id` (`criteria_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Policy value details for ssr policy';


CREATE TABLE `ssr_policy_master` (
  `policy_id` int NOT NULL AUTO_INCREMENT,
  `policy_name` varchar(100) DEFAULT NULL,
  `matrix_id` int DEFAULT NULL,
  `priority` int DEFAULT NULL,
  `active_status` char(1) DEFAULT 'Y',
  `active_date` datetime DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `policy_dow` varchar(100) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `policy_string` text NOT NULL COMMENT 'String for the policy which is matched when policy applied to the request',
  `updated_date` datetime DEFAULT NULL COMMENT 'Updated date of the policy',
  `updated_by` int DEFAULT NULL COMMENT 'Updated by this user',
  PRIMARY KEY (`policy_id`),
  KEY `policy_name` (`policy_name`),
  KEY `matrix_id` (`matrix_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for ssr policy';


CREATE TABLE `ssr_subcategory_details` (
  `ssr_subcategory_id` int NOT NULL AUTO_INCREMENT,
  `ssr_category_id` int NOT NULL,
  `ssr_subcategory_name` varchar(30) NOT NULL,
  `display_status` enum('Y','N','D') NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`ssr_subcategory_id`),
  KEY `ssr_category_id` (`ssr_category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data for Special service request sub category details for meals';


CREATE TABLE `ssr_temp` (
  `ssr_temp_id` int NOT NULL AUTO_INCREMENT,
  `request_master_id` int NOT NULL,
  `series_request_id` int NOT NULL,
  `passenger_id` varchar(15) NOT NULL,
  `pnr` varchar(15) NOT NULL,
  `name` varchar(50) NOT NULL,
  `value` varchar(25) NOT NULL,
  `fare` double NOT NULL,
  `amount_diff` double NOT NULL,
  `status` varchar(10) NOT NULL,
  PRIMARY KEY (`ssr_temp_id`),
  KEY `series_request_id` (`series_request_id`),
  KEY `request_master_id` (`request_master_id`),
  KEY `passenger_id` (`passenger_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Temporary table to store when submit the PNR special service request before send to web-service';


CREATE TABLE `ssr_temp_master` (
  `ssr_temp_master_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `request_master_id` int DEFAULT NULL,
  `series_request_id` int DEFAULT NULL,
  `current_status` varchar(15) DEFAULT NULL,
  `requested_date` datetime DEFAULT NULL,
  PRIMARY KEY (`ssr_temp_master_id`),
  KEY `user_id` (`user_id`),
  KEY `series_request_id` (`series_request_id`),
  KEY `request_master_id` (`request_master_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Temporary table to store when submit the PNR special service request master data before send to web-service';


CREATE TABLE `static_fare_criteria_master` (
  `criteria_id` int NOT NULL AUTO_INCREMENT,
  `criteria_name` varchar(100) DEFAULT NULL,
  `criteria_type` char(3) DEFAULT NULL,
  `display_status` char(1) DEFAULT NULL,
  `criteria_logical_id` varchar(100) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`criteria_id`),
  KEY `display_status` (`display_status`),
  KEY `criteria_logical_id` (`criteria_logical_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data for Static fare criteria details';


CREATE TABLE `static_fare_details` (
  `static_fare_id` int NOT NULL AUTO_INCREMENT,
  `request_approved_flight_id` int NOT NULL DEFAULT '0',
  `via_flight_id` int NOT NULL DEFAULT '0',
  `fare_type_policy_id` int NOT NULL DEFAULT '0',
  `fare_type_matrix_id` int NOT NULL DEFAULT '0',
  `fare_policy_id` int NOT NULL DEFAULT '0',
  `fare_matrix_id` int NOT NULL DEFAULT '0',
  `days_to_departure` int NOT NULL DEFAULT '0',
  `capacity` int NOT NULL DEFAULT '0',
  `sold` int NOT NULL DEFAULT '0',
  `seat_availability` int NOT NULL DEFAULT '0',
  `booked_load` int NOT NULL DEFAULT '0',
  `forecast_load` int DEFAULT '0',
  `current_group_count` int DEFAULT '0' COMMENT 'Current accepted passenger count in the system for the leg',
  `group_size` varchar(5) NOT NULL DEFAULT '',
  `quoted_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fare_policy_details` text NOT NULL,
  PRIMARY KEY (`static_fare_id`),
  KEY `request_approved_flight_id` (`request_approved_flight_id`),
  KEY `via_flight_id` (`via_flight_id`),
  KEY `fare_type_policy_id` (`fare_type_policy_id`),
  KEY `fare_type_matrix_id` (`fare_type_matrix_id`),
  KEY `fare_policy_id` (`fare_policy_id`),
  KEY `fare_matrix_id` (`fare_matrix_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Flight wise Static fare applied information';


CREATE TABLE `static_fare_policy_details` (
  `policy_details_id` int NOT NULL AUTO_INCREMENT,
  `policy_id` int DEFAULT NULL,
  `criteria_id` int DEFAULT NULL,
  `loop_value` int DEFAULT '0',
  `operator_id` int DEFAULT NULL,
  `policy_value` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`policy_details_id`),
  KEY `criteria_id` (`criteria_id`),
  KEY `operator_id` (`operator_id`),
  KEY `policy_id` (`policy_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Static fare policy criteria values mapping';


CREATE TABLE `static_fare_policy_master` (
  `policy_id` int NOT NULL AUTO_INCREMENT,
  `policy_name` varchar(100) DEFAULT NULL,
  `booking_profile_id` int DEFAULT NULL,
  `priority` int DEFAULT NULL,
  `active_status` char(1) DEFAULT 'Y',
  `matrix_type` varchar(5) DEFAULT 'BPF',
  `active_date` datetime DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `policy_dow` varchar(100) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `updated_date` datetime DEFAULT NULL COMMENT 'Updated date of the policy',
  `updated_by` int DEFAULT NULL COMMENT 'Updated by this user',
  PRIMARY KEY (`policy_id`),
  KEY `booking_profile_id` (`booking_profile_id`),
  KEY `active_status` (`active_status`),
  KEY `policy_name` (`policy_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Static fare master table for policy information';


CREATE TABLE `status_details` (
  `status_id` int NOT NULL AUTO_INCREMENT,
  `status_code` varchar(5) DEFAULT NULL,
  `status_name` varchar(150) DEFAULT NULL,
  `front_end` char(1) DEFAULT 'Y',
  `back_end` char(1) DEFAULT 'Y',
  PRIMARY KEY (`status_id`),
  KEY `back_end` (`back_end`),
  KEY `status_code` (`status_code`),
  KEY `front_end` (`front_end`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data for group action status';


CREATE TABLE `std_tpl_details` (
  `std_tpl_id` int NOT NULL AUTO_INCREMENT,
  `std_tpl_name` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`std_tpl_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Application framework table used for standard templates';


CREATE TABLE `sub_agency_mapping_details` (
  `sub_agency_mapping_id` int NOT NULL AUTO_INCREMENT COMMENT 'Sub agency id',
  `corporate_id` int NOT NULL COMMENT 'Travel agency corporate id',
  `mapped_corporate_id` int NOT NULL COMMENT 'Sub agency corporate id',
  `status` enum('New','Approve','Reject','Cancel') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'New' COMMENT 'Status of the Sub agency ',
  `requested_by` int NOT NULL COMMENT 'Requested user id',
  `requested_date` datetime NOT NULL COMMENT 'Requested date',
  `responded_by` int NOT NULL COMMENT 'Approved user id ',
  `responded_date` datetime NOT NULL COMMENT 'Approved date',
  `remarks` varchar(35) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'During Reject or cancel get the Remarks ',
  PRIMARY KEY (`sub_agency_mapping_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `support_type_master` (
  `support_type_id` int NOT NULL AUTO_INCREMENT,
  `support_type_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`support_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master table for Help desk support type (Issues, clarifications,..)';


CREATE TABLE `surcharge_mapping_details` (
  `surcharge_mapping_id` int NOT NULL AUTO_INCREMENT,
  `surcharge_details_id` int DEFAULT NULL,
  `group_size` int DEFAULT NULL,
  `surcharge` double DEFAULT NULL,
  PRIMARY KEY (`surcharge_mapping_id`),
  KEY `surcharge_details_id` (`surcharge_details_id`),
  KEY `group_size` (`group_size`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Surcharge requested group pax and fare mapping';


CREATE TABLE `surcharge_matrix` (
  `surcharge_matrix_id` int NOT NULL AUTO_INCREMENT,
  `surcharge_matrix_name` varchar(50) DEFAULT NULL,
  `load_factor_type` char(5) DEFAULT 'BOTH',
  `surcharge_matrix_type` char(5) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `currency_type` char(5) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `status` enum('Y','N','D') DEFAULT 'Y',
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`surcharge_matrix_id`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Surcharge matrix master table which contain matrix name';


CREATE TABLE `surcharge_matrix_details` (
  `surcharge_details_id` int NOT NULL AUTO_INCREMENT,
  `surcharge_matrix_id` int DEFAULT NULL,
  `days_to_departure` int DEFAULT NULL,
  `booked_load_factor` int DEFAULT NULL,
  `forecast_load_factor` int DEFAULT '0',
  PRIMARY KEY (`surcharge_details_id`),
  KEY `surcharge_matrix_id` (`surcharge_matrix_id`),
  KEY `days_to_departure` (`days_to_departure`),
  KEY `booked_load_factor` (`booked_load_factor`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Surcharge load factor and days to departure mapping';


CREATE TABLE `surcharge_policy_details` (
  `surcharge_policy_details_id` int NOT NULL AUTO_INCREMENT,
  `surcharge_policy_id` int DEFAULT NULL,
  `criteria_id` int DEFAULT NULL,
  `loop_value` int DEFAULT '0',
  `operator_id` int DEFAULT NULL,
  `policy_value` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`surcharge_policy_details_id`),
  KEY `surcharge_policy_id` (`surcharge_policy_id`),
  KEY `criteria_id` (`criteria_id`),
  KEY `operator_id` (`operator_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Surcharge policy criteria mapped to values';


CREATE TABLE `surcharge_policy_master` (
  `surcharge_policy_id` int NOT NULL AUTO_INCREMENT,
  `surcharge_policy_name` varchar(100) DEFAULT NULL,
  `surcharge_matrix_id` int DEFAULT NULL,
  `priority` int DEFAULT NULL,
  `active_status` char(1) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `policy_dow` varchar(100) NOT NULL,
  `created_date` datetime DEFAULT NULL,
  `updated_date` datetime DEFAULT NULL COMMENT 'Updated date of the policy',
  `updated_by` int DEFAULT NULL COMMENT 'Updated by this user',
  PRIMARY KEY (`surcharge_policy_id`),
  KEY `surcharge_matrix_id` (`surcharge_matrix_id`),
  KEY `priority` (`priority`),
  KEY `active_status` (`active_status`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Surcharge policy master table which contain start date and end date for an policy name';


CREATE TABLE `system_m_status` (
  `id` smallint NOT NULL AUTO_INCREMENT,
  `status_name` varchar(50) NOT NULL,
  `status_code` varchar(10) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `status_name` (`status_name`),
  UNIQUE KEY `status_code` (`status_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `system_m_user_types` (
  `id` smallint NOT NULL AUTO_INCREMENT,
  `user_type` varchar(30) NOT NULL,
  `r_status_id` smallint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `system_m_user_types_r_status_id_c22e7f1b_fk_system_m_status_id` (`r_status_id`),
  CONSTRAINT `system_m_user_types_r_status_id_c22e7f1b_fk_system_m_status_id` FOREIGN KEY (`r_status_id`) REFERENCES `system_m_status` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `system_settings` (
  `key_id` int NOT NULL AUTO_INCREMENT,
  `key_index` varchar(100) DEFAULT NULL,
  `key_name` varchar(100) DEFAULT NULL,
  `extra_key_name` varchar(100) DEFAULT NULL,
  `key_value` text,
  `value_type` char(1) DEFAULT NULL,
  `description` varchar(200) DEFAULT NULL,
  `status` enum('Y','N') DEFAULT NULL,
  `backend_status` enum('Y','N') DEFAULT 'N',
  `last_updated_by` int DEFAULT NULL,
  `last_updated_date` datetime DEFAULT NULL,
  PRIMARY KEY (`key_id`),
  KEY `value_type` (`value_type`),
  KEY `key_name` (`key_name`),
  KEY `key_index` (`key_index`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Application configuration details';


CREATE TABLE `system_t_reset_password` (
  `id` int NOT NULL AUTO_INCREMENT,
  `url_token` varchar(200) NOT NULL,
  `used_status` varchar(1) NOT NULL,
  `reset_token_type` varchar(2) NOT NULL,
  `initiated_time` datetime(6) NOT NULL,
  `expiry_time` datetime(6) DEFAULT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `url_token` (`url_token`),
  KEY `system_t_reset_password_user_id_3caf1fa1_fk` (`user_id`),
  CONSTRAINT `system_t_reset_password_user_id_3caf1fa1_fk` FOREIGN KEY (`user_id`) REFERENCES `system_t_users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `system_t_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `password` varchar(128) NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `first_name` varchar(150) NOT NULL,
  `last_name` varchar(150) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  `email_id` varchar(254) NOT NULL,
  `title` varchar(16) NOT NULL,
  `phone_number` varchar(32) NOT NULL,
  `last_login_ip` varchar(40) DEFAULT NULL,
  `r_status_id` smallint NOT NULL,
  `r_user_type_id` smallint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_id` (`email_id`),
  KEY `system_t_users_r_status_id_c5573358_fk_system_m_status_id` (`r_status_id`),
  KEY `system_t_users_r_user_type_id_c7c700a2_fk_system_m_user_types_id` (`r_user_type_id`),
  CONSTRAINT `system_t_users_r_status_id_c5573358_fk_system_m_status_id` FOREIGN KEY (`r_status_id`) REFERENCES `system_m_status` (`id`),
  CONSTRAINT `system_t_users_r_user_type_id_c7c700a2_fk_system_m_user_types_id` FOREIGN KEY (`r_user_type_id`) REFERENCES `system_m_user_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `system_t_users_groups` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `system_t_users_groups_user_id_group_id_7871a2f9_uniq` (`user_id`,`group_id`),
  KEY `system_t_users_groups_group_id_ec4b0518_fk_auth_group_id` (`group_id`),
  CONSTRAINT `system_t_users_groups_group_id_ec4b0518_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `system_t_users_groups_user_id_4d0b0a5a_fk` FOREIGN KEY (`user_id`) REFERENCES `system_t_users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `system_t_users_user_permissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `system_t_users_user_perm_user_id_permission_id_202a7989_uniq` (`user_id`,`permission_id`),
  KEY `system_t_users_user__permission_id_362200a8_fk_auth_perm` (`permission_id`),
  CONSTRAINT `system_t_users_user__permission_id_362200a8_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `system_t_users_user_permissions_user_id_467d30b0_fk` FOREIGN KEY (`user_id`) REFERENCES `system_t_users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `take_control_details` (
  `take_control_id` int NOT NULL AUTO_INCREMENT,
  `request_master_id` int NOT NULL,
  `reference_id` int NOT NULL,
  `process_type` varchar(25) DEFAULT NULL,
  `opened_by` int NOT NULL,
  `opened_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `control_status` varchar(15) NOT NULL,
  `unique_status` varchar(11) DEFAULT NULL,
  `action_pnr` text,
  PRIMARY KEY (`take_control_id`),
  UNIQUE KEY `process_type` (`process_type`,`unique_status`),
  KEY `request_master_id` (`request_master_id`),
  KEY `opened_by` (`opened_by`),
  KEY `reference_id` (`reference_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Request control logs for user acceptance, sent for review and payment transactions';


CREATE TABLE `tax_breakup_details` (
  `tax_breakup_id` int NOT NULL AUTO_INCREMENT,
  `series_flight_schedule_id` int DEFAULT NULL,
  `pax_type` varchar(10) DEFAULT NULL,
  `tax_index` varchar(10) DEFAULT NULL,
  `tax_code` varchar(30) DEFAULT NULL,
  `charge_code` varchar(10) DEFAULT NULL,
  `amount` double DEFAULT NULL,
  `tax_description` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`tax_breakup_id`),
  KEY `series_flight_schedule_id` (`series_flight_schedule_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Series request batch flight tax break up details';


CREATE TABLE `template_details` (
  `template_id` int NOT NULL AUTO_INCREMENT,
  `template_name` varchar(50) DEFAULT NULL,
  `class_tpl_name` varchar(50) DEFAULT NULL,
  `template_type` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`template_id`),
  KEY `template_name` (`template_name`),
  KEY `class_tpl_name` (`class_tpl_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='GRM framework smarty templates details';


CREATE TABLE `tender_details` (
  `tender_id` int NOT NULL AUTO_INCREMENT,
  `tender_name` varchar(60) NOT NULL,
  `organisation_name` varchar(60) NOT NULL,
  `source_information` varchar(60) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `remarks` text,
  `status` enum('NT','AT','RT','DT','CT','TA') NOT NULL DEFAULT 'NT',
  `created_on` datetime NOT NULL,
  `created_by` int NOT NULL,
  `responded_on` datetime NOT NULL,
  `responded_by` int NOT NULL,
  `last_updated_on` datetime NOT NULL,
  `last_updated_by` int NOT NULL,
  PRIMARY KEY (`tender_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tender information';


CREATE TABLE `tender_option_details` (
  `tender_option_id` int NOT NULL AUTO_INCREMENT,
  `tender_id` int NOT NULL,
  `request_master_id` int NOT NULL,
  `status` enum('OC','OM','DO','CO','RO','OA') NOT NULL DEFAULT 'OC',
  `created_on` datetime NOT NULL,
  `created_by` int NOT NULL,
  `created_for` int NOT NULL,
  PRIMARY KEY (`tender_option_id`),
  KEY `tender_id` (`tender_id`),
  KEY `request_master_id` (`request_master_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tender option details';


CREATE TABLE `tender_participant_details` (
  `tender_participant_id` int NOT NULL AUTO_INCREMENT,
  `tender_id` int NOT NULL,
  `user_id` int NOT NULL,
  `participated_date` datetime NOT NULL,
  `participation_status` enum('PP','UP','AP','CP') NOT NULL DEFAULT 'PP',
  `participant_remarks` text NOT NULL,
  `actioned_by` int NOT NULL,
  PRIMARY KEY (`tender_participant_id`),
  KEY `tender_id` (`tender_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tender participant details';


CREATE TABLE `tender_pnr_details` (
  `tender_pnr_id` int NOT NULL AUTO_INCREMENT,
  `tender_id` int NOT NULL,
  `pnr` varchar(6) NOT NULL,
  `request_master_id` int NOT NULL,
  `request_approved_flight_id` int NOT NULL,
  `via_flight_id` int NOT NULL,
  `status` varchar(10) NOT NULL,
  `created_date` datetime NOT NULL,
  `created_by` int NOT NULL,
  `awarded_on` datetime NOT NULL,
  `awarded_by` int NOT NULL,
  `awarded_participant_id` int NOT NULL,
  PRIMARY KEY (`tender_pnr_id`),
  KEY `request_master_id` (`request_master_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tender PNR information';


CREATE TABLE `tender_status_details` (
  `tender_status_id` tinyint NOT NULL AUTO_INCREMENT,
  `status_code` char(2) NOT NULL,
  `status_name` varchar(32) NOT NULL,
  `type` varchar(10) NOT NULL,
  `display_status` enum('Y','N','D') NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`tender_status_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Tender status information';


CREATE TABLE `test1_jobprogress` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `job_id` varchar(150) COLLATE utf8mb3_unicode_ci NOT NULL,
  `status` varchar(20) COLLATE utf8mb3_unicode_ci NOT NULL,
  `task_id` varchar(150) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `progress_percent` int NOT NULL,
  `last_processed_line` int NOT NULL,
  `total_lines` int NOT NULL,
  `last_step` varchar(50) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `checkpoint_data` json DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `job_id` (`job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `test1_scheduledtask` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `task_path` varchar(200) COLLATE utf8mb3_unicode_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL,
  `crontab_id` int DEFAULT NULL,
  `interval_id` int DEFAULT NULL,
  `job_id` bigint NOT NULL,
  `periodic_task_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `job_id` (`job_id`),
  UNIQUE KEY `periodic_task_id` (`periodic_task_id`),
  KEY `test1_scheduledtask_crontab_id_b0352c1b_fk_django_ce` (`crontab_id`),
  KEY `test1_scheduledtask_interval_id_2fe11079_fk_django_ce` (`interval_id`),
  CONSTRAINT `test1_scheduledtask_crontab_id_b0352c1b_fk_django_ce` FOREIGN KEY (`crontab_id`) REFERENCES `django_celery_beat_crontabschedule` (`id`),
  CONSTRAINT `test1_scheduledtask_interval_id_2fe11079_fk_django_ce` FOREIGN KEY (`interval_id`) REFERENCES `django_celery_beat_intervalschedule` (`id`),
  CONSTRAINT `test1_scheduledtask_job_id_18a69f1d_fk_test1_jobprogress_id` FOREIGN KEY (`job_id`) REFERENCES `test1_jobprogress` (`id`),
  CONSTRAINT `test1_scheduledtask_periodic_task_id_fe3dd2c8_fk_django_ce` FOREIGN KEY (`periodic_task_id`) REFERENCES `django_celery_beat_periodictask` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `test1_tasklog` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `task_id` varchar(150) COLLATE utf8mb3_unicode_ci NOT NULL,
  `message` longtext COLLATE utf8mb3_unicode_ci NOT NULL,
  `status` varchar(20) COLLATE utf8mb3_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `job_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `test1_tasklog_job_id_274ae1df_fk_test1_jobprogress_id` (`job_id`),
  CONSTRAINT `test1_tasklog_job_id_274ae1df_fk_test1_jobprogress_id` FOREIGN KEY (`job_id`) REFERENCES `test1_jobprogress` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


CREATE TABLE `ticketing_details` (
  `ticketing_id` int NOT NULL AUTO_INCREMENT,
  `travel_bank_id` int DEFAULT NULL,
  `ticket_number` varchar(100) DEFAULT NULL,
  `fare_basis_code` varchar(20) DEFAULT NULL,
  `promo_code` varchar(20) DEFAULT NULL,
  `ticketed_date` timestamp NULL DEFAULT NULL,
  `ticketed_by` int DEFAULT NULL,
  `ticket_status` enum('Y','N','D') NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`ticketing_id`),
  KEY `travel_bank_id` (`travel_bank_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Ticket number and its related information stored';


CREATE TABLE `time_line_matrix` (
  `time_line_id` int NOT NULL AUTO_INCREMENT,
  `corporate_id` int DEFAULT NULL,
  `days_to_departure` int DEFAULT NULL,
  `payment_validity` int DEFAULT NULL,
  `payment_type_id` int DEFAULT NULL,
  `passenger_validity` int DEFAULT NULL,
  `passenger_type_id` int DEFAULT NULL,
  `fare_validity` int DEFAULT NULL,
  `fare_type_id` int DEFAULT NULL,
  `time_line_matrix_list_id` int NOT NULL,
  `expiry_type_id` int DEFAULT '1',
  `payment_expiry_type_id` int DEFAULT '1',
  `passenger_expiry_type_id` int DEFAULT '1',
  `payment_percentage` double DEFAULT '100',
  `payment_in_percent` varchar(3) NOT NULL DEFAULT 'Y',
  `payment_currency` varchar(5) DEFAULT '',
  `materialization` int DEFAULT NULL COMMENT 'materialization rate for time limit matrix interface',
  `policy` varchar(5) DEFAULT NULL COMMENT 'NC:Non-cancellaton,NR:Non-refundable,NP:Normal Policy',
  `penalty_value` int DEFAULT NULL,
  `penalty_type_id` int DEFAULT NULL,
  `penalty_expiry_id` int DEFAULT '1',
  PRIMARY KEY (`time_line_id`),
  KEY `time_line_matrix_list_id` (`time_line_matrix_list_id`),
  KEY `payment_type_id` (`payment_type_id`),
  KEY `passenger_type_id` (`passenger_type_id`),
  KEY `fare_type_id` (`fare_type_id`),
  KEY `days_to_departure` (`days_to_departure`),
  KEY `corporate_id` (`corporate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Fare, payemnt and passeger name list submission validities maintained';


CREATE TABLE `time_line_matrix_criteria_master` (
  `time_line_matrix_criteria_id` int NOT NULL AUTO_INCREMENT,
  `time_line_matrix_criteria_name` varchar(100) DEFAULT NULL,
  `time_line_matrix_criteria_type` char(3) DEFAULT NULL,
  `display_status` char(1) DEFAULT 'Y',
  `time_line_matrix_criteria_logical_id` varchar(100) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  PRIMARY KEY (`time_line_matrix_criteria_id`),
  KEY `display_status` (`display_status`),
  KEY `time_line_matrix_criteria_logical_id` (`time_line_matrix_criteria_logical_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Master data criteria details for Time line';


CREATE TABLE `time_line_matrix_details` (
  `time_line_matrix_details_id` int NOT NULL AUTO_INCREMENT,
  `time_line_matrix_master_id` int DEFAULT NULL,
  `time_line_matrix_criteria_id` int DEFAULT NULL,
  `loop_value` int DEFAULT '0',
  `operator_id` int DEFAULT NULL,
  `policy_value` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`time_line_matrix_details_id`),
  KEY `time_line_matrix_criteria_id` (`time_line_matrix_criteria_id`),
  KEY `operator_id` (`operator_id`),
  KEY `time_line_matrix_master_id` (`time_line_matrix_master_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Time line policy criteria value details';


CREATE TABLE `time_line_matrix_list` (
  `time_line_matrix_list_id` int NOT NULL AUTO_INCREMENT,
  `time_line_matrix_name` varchar(48) DEFAULT NULL,
  `activation_status` char(1) DEFAULT 'Y',
  `default_status` char(1) DEFAULT 'N',
  `create_date` datetime DEFAULT NULL,
  PRIMARY KEY (`time_line_matrix_list_id`),
  KEY `default_status` (`default_status`),
  KEY `activation_status` (`activation_status`),
  KEY `time_line_matrix_name` (`time_line_matrix_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Time line matrix name and status maintained';


CREATE TABLE `time_line_matrix_master` (
  `time_line_matrix_master_id` int NOT NULL AUTO_INCREMENT,
  `time_line_matrix_list_id` int DEFAULT NULL,
  `time_line_policy_name` varchar(48) DEFAULT NULL,
  `priority` int DEFAULT NULL,
  `activation_status` char(1) DEFAULT 'Y',
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `policy_dow` varchar(100) DEFAULT NULL,
  `create_date` datetime DEFAULT NULL,
  PRIMARY KEY (`time_line_matrix_master_id`),
  KEY `activation_status` (`activation_status`),
  KEY `time_line_matrix_list_id` (`time_line_matrix_list_id`),
  KEY `priority` (`priority`),
  KEY `time_line_policy_name` (`time_line_policy_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Time line policy master details';


CREATE TABLE `time_line_payment_details` (
  `time_line_payment_id` int NOT NULL AUTO_INCREMENT,
  `time_line_id` int DEFAULT NULL,
  `payment_validity` int DEFAULT NULL,
  `payment_validity_type` int DEFAULT NULL,
  `payment_expiry_type` int DEFAULT NULL,
  `payment_percentage` double DEFAULT NULL,
  PRIMARY KEY (`time_line_payment_id`),
  KEY `payment_validity_type` (`payment_validity_type`),
  KEY `time_line_id` (`time_line_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Time line for Payment validities';


CREATE TABLE `transaction_history` (
  `transaction_history_id` int NOT NULL AUTO_INCREMENT,
  `review_status_id` int NOT NULL DEFAULT '0',
  `airlines_request_id` int DEFAULT NULL,
  `transaction_id` int DEFAULT NULL,
  `request_master_history_id` int DEFAULT '0',
  `fare_advised` double NOT NULL DEFAULT '0',
  `child_fare` double NOT NULL DEFAULT '0',
  `infant_fare` double NOT NULL DEFAULT '0',
  `discount` double DEFAULT NULL,
  `child_discount` double DEFAULT NULL,
  `infant_discount` double DEFAULT NULL,
  `evaluated_fare` double NOT NULL DEFAULT '0',
  `exchange_rate` double NOT NULL DEFAULT '0',
  `fare_negotiable` varchar(20) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `auto_approval` enum('Y','N') NOT NULL DEFAULT 'Y',
  `fare_validity` int DEFAULT NULL,
  `fare_validity_type_id` int DEFAULT NULL,
  `fare_expiry_type` int NOT NULL DEFAULT '1',
  `payment_validity` int NOT NULL DEFAULT '0',
  `payment_validity_type` int NOT NULL DEFAULT '0',
  `payment_expiry_type` int NOT NULL DEFAULT '1',
  `passenger_validity` int NOT NULL DEFAULT '0',
  `passenger_validity_type` int NOT NULL DEFAULT '0',
  `passenger_expiry_date` datetime NOT NULL,
  `passenger_expiry_type` int NOT NULL DEFAULT '1',
  `transaction_date` datetime DEFAULT NULL,
  `fare_expiry_date` varchar(25) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `payment_expiry_date` datetime NOT NULL,
  `active_status` int DEFAULT NULL,
  `remarks` text,
  `response_source` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `cancel_policy_id` int NOT NULL DEFAULT '0',
  `time_line_id` int NOT NULL DEFAULT '0',
  `negotiation_policy_id` int NOT NULL DEFAULT '0',
  `sales_promo_status` enum('Y','N') NOT NULL DEFAULT 'N',
  `payment_in_percent` varchar(3) NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`transaction_history_id`),
  KEY `airlines_request_id` (`airlines_request_id`),
  KEY `review_status_id` (`review_status_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Airline response on sent for review, modification transactions';


CREATE TABLE `transaction_master` (
  `transaction_id` int NOT NULL AUTO_INCREMENT,
  `airlines_request_id` int DEFAULT NULL,
  `request_master_history_id` int DEFAULT '0',
  `fare_advised` double NOT NULL DEFAULT '0',
  `child_fare` double NOT NULL DEFAULT '0',
  `infant_fare` double NOT NULL DEFAULT '0',
  `exchange_rate` double NOT NULL DEFAULT '0',
  `fare_negotiable` varchar(20) DEFAULT NULL,
  `auto_approval` enum('Y','N') NOT NULL DEFAULT 'Y',
  `transaction_fee` enum('Y','N') DEFAULT 'N',
  `fare_validity` int DEFAULT NULL,
  `fare_validity_type_id` int DEFAULT NULL,
  `fare_expiry_type` int NOT NULL DEFAULT '1',
  `payment_validity` int NOT NULL DEFAULT '0',
  `payment_validity_type` int NOT NULL DEFAULT '0',
  `payment_expiry_type` int NOT NULL DEFAULT '1',
  `passenger_validity` int NOT NULL DEFAULT '0',
  `passenger_validity_type` int NOT NULL DEFAULT '0',
  `passenger_expiry_type` int NOT NULL DEFAULT '1',
  `transaction_date` datetime DEFAULT NULL,
  `fare_expiry_date` datetime NOT NULL,
  `payment_expiry_date` datetime NOT NULL,
  `passenger_expiry_date` datetime NOT NULL,
  `active_status` int DEFAULT NULL,
  `remarks` text,
  `alternate_flight_remarks` text,
  `timelimit_remarks` text,
  `response_source` varchar(50) DEFAULT NULL,
  `cancel_policy_id` int NOT NULL DEFAULT '0',
  `time_line_id` int NOT NULL DEFAULT '0',
  `negotiation_policy_id` int NOT NULL DEFAULT '0',
  `sales_promo_status` enum('Y','N') NOT NULL DEFAULT 'N',
  `payment_in_percent` varchar(3) NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`transaction_id`),
  KEY `airlines_request_id` (`airlines_request_id`),
  KEY `fare_expiry_date` (`fare_expiry_date`),
  KEY `transaction_date` (`transaction_date`),
  KEY `response_source` (`response_source`),
  KEY `active_status` (`active_status`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Airline response transactions';


CREATE TABLE `travel_bank_master` (
  `travel_bank_id` int NOT NULL AUTO_INCREMENT,
  `customer_insight_id` int DEFAULT NULL,
  `account_number` varchar(100) DEFAULT NULL,
  `expiry_date` varchar(100) DEFAULT NULL,
  `account_balance` double DEFAULT NULL,
  `created_date` timestamp NULL DEFAULT NULL,
  `status` enum('10','12') DEFAULT '10',
  PRIMARY KEY (`travel_bank_id`),
  KEY `customer_insight_id` (`customer_insight_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Creating the travel bank account';


CREATE TABLE `travel_bank_transaction_details` (
  `travel_bank_transaction_id` int NOT NULL AUTO_INCREMENT,
  `travel_bank_id` int DEFAULT NULL,
  `emd_id` int DEFAULT NULL,
  `payment_type` varchar(5) DEFAULT NULL,
  `total_amount` double DEFAULT NULL,
  `transaction_date` timestamp NULL DEFAULT NULL,
  `status` enum('10','12') DEFAULT '10',
  PRIMARY KEY (`travel_bank_transaction_id`),
  KEY `travel_bank_id` (`travel_bank_id`),
  KEY `emd_id` (`emd_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='EMD transfer to Travel bank account details';


CREATE TABLE `user_details` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `group_id` int DEFAULT NULL,
  `corporate_id` int DEFAULT NULL,
  `title` varchar(16) DEFAULT NULL,
  `first_name` varchar(32) DEFAULT NULL,
  `last_name` varchar(32) DEFAULT NULL,
  `email_id` varchar(100) DEFAULT NULL,
  `user_password` varchar(90) DEFAULT NULL,
  `user_address` varchar(256) DEFAULT NULL,
  `phone_number` varchar(32) DEFAULT NULL,
  `approved_status` enum('Y','N','P','D') NOT NULL DEFAULT 'N',
  `email_verification_status` enum('Y','N') NOT NULL DEFAULT 'N',
  `confirm_code` varchar(100) DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `time_zone_interval` varchar(40) DEFAULT '',
  `time_zone_key` varchar(352) DEFAULT '',
  `ip_address` varchar(40) NOT NULL DEFAULT '',
  `country_code` varchar(16) DEFAULT NULL,
  `last_login_ip_address` varchar(40) NOT NULL DEFAULT '',
  `last_login_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `country_number` varchar(15) DEFAULT NULL,
  `city_id` int DEFAULT NULL,
  `user_zip_code` varchar(36) DEFAULT NULL,
  `user_name` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  KEY `corporate_id` (`corporate_id`),
  KEY `country_code` (`country_code`),
  KEY `email_id` (`email_id`),
  KEY `email_verification_status` (`email_verification_status`),
  KEY `group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Store the Travel agent, Airline users and Retail users';


CREATE TABLE `user_email_mapping` (
  `user_email_mapping_id` int NOT NULL AUTO_INCREMENT,
  `email_setting_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `language` varchar(10) DEFAULT NULL,
  `email_status` char(1) DEFAULT NULL,
  PRIMARY KEY (`user_email_mapping_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Map an email language to an user';


CREATE TABLE `user_guide_history` (
  `user_guide_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `ip_address` varchar(50) DEFAULT NULL,
  `user_guide_date` datetime NOT NULL,
  PRIMARY KEY (`user_guide_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Details about user guide download persons, IP address and date';


CREATE TABLE `user_level_settings` (
  `key_id` int NOT NULL AUTO_INCREMENT,
  `group_id` int DEFAULT NULL,
  `user_id` int DEFAULT '0',
  `key_name` varchar(100) DEFAULT NULL,
  `key_value` int DEFAULT NULL,
  `description` varchar(200) DEFAULT NULL,
  `status` enum('Y','N','D','R') DEFAULT NULL,
  `last_updated_by` int DEFAULT NULL,
  `last_updated_date` datetime DEFAULT NULL,
  PRIMARY KEY (`key_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Group level user access restriction for create, edit and delete options';


CREATE TABLE `user_password_mapping` (
  `password_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `last_updated_password` varchar(40) NOT NULL,
  `last_updated_date` datetime NOT NULL,
  PRIMARY KEY (`password_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='To store the old password transactions for 3 consecutive checks';


CREATE TABLE `user_type_details` (
  `user_type_id` int NOT NULL AUTO_INCREMENT,
  `user_type_name` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`user_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Defining the user type (Need to delete)';


CREATE TABLE `via_flight_details` (
  `via_flight_id` int NOT NULL AUTO_INCREMENT,
  `request_approved_flight_id` int DEFAULT NULL,
  `origin` char(4) DEFAULT NULL,
  `destination` char(4) DEFAULT NULL,
  `airline_code` char(3) DEFAULT NULL,
  `flight_number` varchar(5) DEFAULT NULL,
  `departure_date` date DEFAULT NULL,
  `departure_time` time DEFAULT NULL,
  `arrival_date` date DEFAULT NULL,
  `arrival_time` time DEFAULT NULL,
  `displacement_fare` double NOT NULL DEFAULT '0',
  `discount_amount` double NOT NULL DEFAULT '0',
  `base_fare` double NOT NULL DEFAULT '0',
  `baggauge_fare` double NOT NULL DEFAULT '0',
  `meals_fare` double NOT NULL DEFAULT '0',
  `capacity` int NOT NULL DEFAULT '0',
  `sold` int NOT NULL DEFAULT '0',
  `seat_availability` int NOT NULL DEFAULT '0',
  `surcharge` double DEFAULT '0',
  `ancillary_fare` text CHARACTER SET latin1 COLLATE latin1_swedish_ci,
  PRIMARY KEY (`via_flight_id`),
  KEY `request_approved_flight_id` (`request_approved_flight_id`),
  KEY `origin` (`origin`),
  KEY `destination` (`destination`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Store the via filght details when an stops exists';


CREATE TABLE `via_flight_history` (
  `via_flight_history_id` int NOT NULL AUTO_INCREMENT,
  `request_approved_flight_history_id` int DEFAULT NULL,
  `origin` char(4) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `destination` char(4) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `airline_code` char(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `flight_number` varchar(5) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `departure_date` date DEFAULT NULL,
  `departure_time` time DEFAULT NULL,
  `arrival_date` date DEFAULT NULL,
  `arrival_time` time DEFAULT NULL,
  `baggauge_fare` double NOT NULL DEFAULT '0',
  `meals_fare` double NOT NULL DEFAULT '0',
  `tiger_connect_fare` double NOT NULL DEFAULT '0',
  `capacity` int NOT NULL DEFAULT '0',
  `sold` int NOT NULL DEFAULT '0',
  `seat_availability` int NOT NULL DEFAULT '0',
  `fare_type` varchar(15) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `fare_class` char(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `rule_number` varchar(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '0',
  `fare_sequence` varchar(5) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '0',
  `fare_application_type` varchar(15) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `origin_airport_name` varchar(200) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `dest_airport_name` varchar(200) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `surcharge` double DEFAULT '0',
  PRIMARY KEY (`via_flight_history_id`),
  KEY `request_approved_flight_history_id` (`request_approved_flight_history_id`),
  KEY `origin` (`origin`),
  KEY `destination` (`destination`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='Sent for review via flight details and modify history via flight details stored';


-- 2025-09-17 09:55:45 UTC
