-- DATA CLEANING
-- Check If it's been populated
SELECT * 
FROM layoffs
;
-- Create a staging table
CREATE TABLE layoffs_staging
LIKE layoffs
;
-- Insert into new table
INSERT layoffs_staging
SELECT *
FROM layoffs
;

-- 1. REMOVING DUPLICATES
-- Create Temporary CTE to check for duplicates
WITH duplicate_CTE AS(
SELECT * ,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) 
AS row_num
FROM layoffs
)
SELECT * FROM duplicate_CTE
WHERE row_num > 1
;
-- Check if they are actual duplicates
SELECT *
FROM layoffs_staging
WHERE company LIKE '%Casper%'
;
-- 
DELETE 
FROM layoffs_staging
WHERE row_num > 1
;

-- Create New Table to perform deletions
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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert data from layoffs_staging table into layoffs_staging2 table
INSERT INTO layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) 
AS row_num
FROM layoffs_staging
;
-- Delete duplicate data in layoffs_stage2
DELETE
FROM layoffs_staging2
WHERE row_num > 1
;
-- Check if they are still duplicates
SELECT *
FROM layoffs_staging2
WHERE company LIKE '%Casper%'
;

-- 2. STANDARDIZING DATA
SELECT *
FROM layoffs_staging2
;
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country ASC
;

-- Correcting spellings
UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%'
;
-- Removing spaces
UPDATE layoffs_staging2
SET company=TRIM(company)
;
-- Combining similar industries
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'
;
-- Changing date data type to date
UPDATE layoffs_staging2
SET `date` = str_to_date(`date`,'%m/%d/%Y')
;
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` date
;

-- 3. REMOVE NULL AND BLANK VALUES
	SELECT * 
    FROM layoffs_staging2
    WHERE (total_laid_off IS NULL OR total_laid_off=' ') AND (percentage_laid_off IS NULL OR percentage_laid_off = ' ')
;

-- 4. DROP COLUMN
ALTER TABLE layoffs_staging2
DROP COLUMN row_num
;

-- DATA EXPLORATION
SELECT SUBSTRING(`date`,1, 7) AS `year-month`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1, 7) IS NOT NULL
GROUP BY SUBSTRING(`date`,1, 7)
ORDER BY 1
;

-- ROLLING TOTAL
WITH rolling_total AS(
SELECT SUBSTRING(`date`,1, 7) AS `year-month`, SUM(total_laid_off) AS total
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1, 7) IS NOT NULL
GROUP BY `year-month` -- adding the total_laid_off per month
ORDER BY 1
)
SELECT `year-month`, total, SUM(total) OVER (ORDER BY `year-month`) AS rolling_total
FROM rolling_total
;

-- Get the top 5 companies with highest layoffs from each year
-- 1. Sum up the total laid off for each company in each year
WITH yearly_total (years, Company, Total_laid_off) AS(
SELECT YEAR(`date`), company, SUM(total_laid_off)
FROM layoffs_staging2 
WHERE (total_laid_off IS NOT NULL) AND (YEAR(`date`) IS NOT NULL)
group by company, YEAR(`date`) 
ORDER BY 3 DESC
), 
-- 2. Give a dense_ranking to the yearly_total for each company
Ranking AS(
SELECT *, dense_rank() OVER(partition by years ORDER BY total_laid_off desc) AS ranking
FROM yearly_total
)
-- 3. Get the top 5 rankings
SELECT * 
FROM Ranking
WHERE ranking <= 5
;

SELECT Columns(1,2,3)
FROM layoffs_staging2
;