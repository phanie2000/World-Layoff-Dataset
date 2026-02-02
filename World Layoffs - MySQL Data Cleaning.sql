# DATA CLEANING
#Steps for this data cleaning excerise
-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove Any Unrequired Colums and Rows 

# To effectively work on the data without changing the original version, we will create another table

CREATE TABLE layoffs_data
LIKE layoffs;

SELECT * FROM layoffs_data;

# Insert all values from layoffs into the layoffs_data
INSERT layoffs_data
SELECT *
FROM layoffs;

-- 1. Remove Duplicates
SELECT *,
ROW_NUMBER () OVER (
PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_data;

#CREATE A CTE to hold the query and name it 
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER () OVER (
PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_data
)
SELECT * 
FROM duplicate_cte
WHERE row_num >1;

-- To delete rows with row_num more than 2 we need to create another table 
-- with those tags so we can properly inspect and remove duplicates
CREATE TABLE `layoffs_data2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO layoffs_data2
SELECT *,
ROW_NUMBER () OVER (
PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_data; 

SELECT *
FROM layoffs_data2
WHERE row_num >1;

DELETE
FROM layoffs_data2
WHERE row_num >1;

SELECT *
FROM layoffs_data2;


# STANDARDIZING DATA
-- company
SELECT company, TRIM(company) 
FROM layoffs_data2;

UPDATE layoffs_data2
SET company = TRIM(company);

-- industry
SELECT DISTINCT industry
FROM layoffs_data2
ORDER BY industry;
-- Found issues with the entry of Crypto
SELECT *
FROM layoffs_data2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_data2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT *
FROM layoffs_data2
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry
FROM layoffs_data2;

-- location 
SELECT DISTINCT location 
FROM layoffs_data2
ORDER BY location;

-- country
SELECT DISTINCT country
FROM layoffs_data2
ORDER BY country;
-- Found issues with the entry of United States
SELECT *
FROM layoffs_data2
WHERE country LIKE 'United States%';

UPDATE layoffs_data2
SET country ='United States'
WHERE country = 'United States.';

SELECT country, COUNT(country)
FROM layoffs_data2
GROUP BY country
ORDER BY country;

-- Date
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_data2;

UPDATE layoffs_data2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date` FROM layoffs_data2;
-- Now the table content has been converted to date, the data type still remains as a tes
-- We fix this by altering 

ALTER TABLE layoffs_data2
MODIFY COLUMN `date` DATE;

SELECT `date` FROM layoffs_data2;

-- 3. Null Values or Blank Values
-- We see blanks in industry, total laid off and percentage laid off
SELECT *
FROM layoffs_data2
WHERE industry IS NULL
OR industry = '';

-- lets check data to see if the industry Airbnb was filled somewhere
SELECT company, industry FROM layoffs_data2
WHERE company = 'Airbnb'; 
-- so we know that the industry for Airbnb is TRAVEL, and this could be the case for most
-- unfilled industry rows. To fix this we can join the same  tables to see 

SELECT *
FROM layoffs_data2 AS t1
JOIN layoffs_data2 AS t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Now we update, but first lets get all blanks to null so it doesnt affect the execution of the update code
UPDATE layoffs_data2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_data2 AS t1
JOIN layoffs_data2 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Now lets look at total and percentage laid off
-- The problem is that we don't have the total number of employees to calculate percentage laid off and know the
-- the total number laid off . 
SELECT *
FROM layoffs_data2
WHERE total_laid_off IS NULL and percentage_laid_off IS NULL;

-- Since we do not know how to replace these, we can delete them
DELETE 
FROM layoffs_data2
WHERE total_laid_off  IS NULL AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_data2

-- Lets take out the row_num column
ALTER TABLE layoffs_data2 DROP COLUMN row_num;
SELECT * FROM layoffs_data2;


