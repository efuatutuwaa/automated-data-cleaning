USE projects;


-- created the procedure --
DROP PROCEDURE IF EXISTS copy_and_clean_data;

DELIMITER $$
-- procedure to create a copy of a table
CREATE PROCEDURE copy_and_clean_data()
BEGIN
    --
    CREATE TABLE IF  NOT EXISTS `us_household_income_cleaned` (
  `row_id` int NOT NULL,
  `id` int DEFAULT NULL,
  `state_code` int DEFAULT NULL,
  `state_name` text,
  `state_ab` text,
  `county` text,
  `city` text,
  `place` text,
  `type` text,
  `primary` text,
  `zip_code` text,
  `area_code` int DEFAULT NULL,
  `a_land` text,
  `a_water` text,
  `lat` text,
  `lon` text,
  `timestamp` timestamp DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- Copying data into the created table --
    INSERT INTO us_household_income_cleaned
        SELECT *, CURRENT_TIMESTAMP()
            FROM us_household_income_backup;

    -- 1. Remove Duplicates --

    DELETE FROM us_household_income_cleaned
WHERE row_id IN (
    SELECT row_id
FROM (SELECT row_id,
       id,
       ROW_NUMBER() OVER (PARTITION BY id,timestamp ORDER BY id,timestamp) AS row_num
FROM us_household_income_cleaned
ORDER BY row_num DESC) AS duplicates
WHERE row_num > 1
     );
    -- 2. standardization -- state_name

    -- I used the query below because of the inconsistencies I found in the state names of Georgia and Alabama --

    UPDATE us_household_income_cleaned
    SET state_name = 'Alabama'
    WHERE state_name = 'alabama';

    UPDATE us_household_income_cleaned
    SET state_name = 'Georgia'
    WHERE state_name = 'georia';

     -- 3. standardization -- type
    UPDATE us_household_income_cleaned
    SET type = 'CDP'
    WHERE type = 'CPD';

    UPDATE us_household_income_cleaned
    SET type = 'Borough'
    WHERE type = 'Boroughs';

END $$
DELIMITER ;


CALL copy_and_clean_data();

-- creating an event to clean the table --

DROP EVENT IF EXISTS run_data_cleaning;

CREATE EVENT run_data_cleaning
ON SCHEDULE EVERY 30 DAY
DO CALL copy_and_clean_data();

SELECT DISTINCT timestamp
FROM us_household_income_cleaned;


-- Creating a trigger --
-- this query is optional --

DELIMITER $$
CREATE TRIGGER transfer_cleaned_data
    AFTER INSERT ON us_household_income_backup
    FOR EACH ROW
    BEGIN
       CALL copy_and_clean_data();
    END $$
DELIMITER ;

