--  DATA CLEANING

-----------------------------------------------------------------------------------------------
-- Outline --
# 1. Remove duplicates 
# 2. Standardize the data
# 3. Null values or blank values
# 4. Remove any columns or rows that are unneded
-----------------------------------------------------------------------------------------------


---------------------------------------------------
 -- 1. REMOVE DUPLICATES
---------------------------------------------------
SELECT *
FROM layoffs;
-- Below we get the raw data into a new table, that we can work with
CREATE TABLE layoffs_staging 
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- ROW_NUMBER below is used to show us the amount of unique instances for that row based on the PARTITION
	-- This helps in spotting duplicates. If we see anything above a 1, in this column, that means that partition has occured more than once. 

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- We want to see where row num is greater than 1, signaling there is a duplicate
	-- In order to do that, we will perform a cte. This will take our code right above and do an analaysis of it where row_num>1
    
WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num >1;


-- Checking work with a company that has duplicates: 'Casper' 

SELECT *
FROM layoffs_staging
WHERE company = 'Casper'
;

-- I then created a copy of the layoffs_staging by right clicking the table under 'SCHEMAS' and I then typed a '2' to signal a new table
	-- The only other addition to the code after pasting, is to add a `row_num` column to show the row_numbers
		-- This new table will show us the rows that have a row_number above 1 and we can delete from this table with no problems.

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

-- We are then inserting the code we did earlier, into the table 2

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num>1;

-- Now we will delete all those rows with duplicates aka row_num greater than 1

DELETE 
FROM layoffs_staging2
WHERE row_num>1;

-- Checking our work to make sure the row_num >1 rows are all deleted.
SELECT *
FROM layoffs_staging2
;

-- REMOVE DUPLICATES COMPLETED 

-------------------------------------
-- #2. STANDARDIZING DATA
-------------------------------------
-- Here we create a side-by-side view of the company names and the company names trimmed, to visualize the difference
SELECT company, (TRIM(company))
FROM layoffs_staging2;

-- Here we update the table to make the company names become the trimmed company names

UPDATE layoffs_staging2
SET company = TRIM(company);

-- United States was seen to have a period after one of its entries, we need to delete that
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
WHERE country LIKE 'United States%';

-- Now we will set all the United States values to have no period at the end
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'
;

-- Here we change the dates into date format, as they were provided to us in 'text' format 
	-- To do this we use a STR_TO_DATE function that we can change the text to 'date'
			-- To do this you enter the column name and then the date format in the function
SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2;

-- Updating table
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y')
;
-- Checking work
SELECT `date`
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- STANDARDIZING DATA COMPLETE


-------------------------------------
-- #3. NULL AND BLANKS
-------------------------------------

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;
-- Here if we see the two main columns we need data, on to be blank, then we can probably delete those rows. 



SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';


-- Our mission now, would be to see if there is a company with blank entries that has been entered another time WITH the information
	-- We are hoping that a blank entry for -say AIRBNB- will be able to be manually populated if we find another entry from AIRBNB that does have the info
			-- While my data had blanks for both total and percent laid off, I was not able to find the real values from that company's second entry (if it had more than one)
					-- So we are going to put the table on top of itself making the company and location equal

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company 
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Below we update the table so that the industry updates if theres a company that has a blank and then a popualted version.
	-- My data set doesnt have this problem, but this is the code to do this. 
		-- Note: The t1 is the blank cell and the t.2 is populated so we set the t1 equal to the t2
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL )
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Additionally (shown above) you can set all blanks to NULL at the beginning, for potentially smoother results, some blanks can cause issues


-- REMOVING BLANKS AND NULLS COMPLETE


-------------------------------------
-- #4. REMOVE COLUMNS AND ROWS NOT NEEDED
-------------------------------------


SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

-- Above, these rows had blanks for all of the information we needed in this project, so (for this project) we can delete the rows.

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

-- Finally we will delete that "row_num" column we made earlier, as this was only needed for our purposes
SELECT * 
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
-- REMOVE COLUMNS AND ROWS NOT NEEDED COMPLETE

	-- PROJECT COMPLETE



