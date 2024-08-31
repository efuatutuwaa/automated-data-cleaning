# automated-data-cleaning

Overview

- This repository contains a MySQL stored procedure, event scheduler, and trigger designed to automate the process of copying, cleaning, and standardizing data from the us_household_income_backup table into a new table called us_household_income_cleaned. The goal of this process is to maintain a clean and standardized dataset for analysis by removing duplicates and correcting inconsistencies in the data.

Files in the Repository 
- automated_data_cleaning.sql : This SQL script includes the following components:
- The copy_and_clean_data stored procedure, which performs the data copying and cleaning operations.
- An event scheduler (run_data_cleaning) that automatically triggers the cleaning process every 30 days.
- An optional trigger (transfer_cleaned_data) that calls the copy_and_clean_data procedure after every new insert into the us_household_income_backup table.


Description of the Components

1. Stored Procedure: `copy_and_clean_data`
   - Table Creation: Creates the us_household_income_cleaned table if it doesn't already exist, ensuring a suitable schema to receive the cleaned data.
   - Data Insertion: Copies all the data from the `us_household_income_backup` table into `us_household_income_cleaned`, appending a timestamp column with the current timestamp.
   - Duplicate Removal: Identifies and removes duplicate records based on the `id` and `timestamp` columns using a ROW_NUMBER() window function.
   - Data Standardization:
   - Corrects inconsistencies in `state_name` (e.g., changing 'alabama' to 'Alabama' and 'georia' to 'Georgia').
   - Standardizes the type column (e.g., converting 'CPD' to 'CDP' and 'Boroughs' to 'Borough').

2. Event Scheduler : `run_data_cleaning`
   - Runs the copy_and_clean_data procedure automatically every 30 days to ensure the us_household_income_cleaned table remains up-to-date and free from duplicates or inconsistencies.

3. Trigger : `transfer_cleaned_data` (Optional)
   - This trigger is optional and is designed to automatically call the `copy_and_clean_data procedure` after every insert operation on the `us_household_income_backup` table, ensuring that the cleaned table is updated in real-time.


How to Use

1. Setup:
   - Run the `automated_data_cleaning.sql` script in your MySQL environment.
   - The script will create the necessary stored procedure, event, and trigger.

2. Manual Execution:
   - If you need to manually clean and copy data, you can execute the stored procedure with the following command:
     CALL copy_and_clean_data();

3. Automated Cleaning:
   - The event scheduler will automatically execute the cleaning process every 30 days. If the optional trigger is enabled, data cleaning will also occur automatically after each new data insertion.


  
