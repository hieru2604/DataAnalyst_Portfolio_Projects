-- Data cleaning

Select * 
From  layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

WITH duplicate_CTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num 
FROM layoffs_staging
)
SELECT *
FROM duplicate_CTE 
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging
where company = 'Oracle';

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


SELECT * 
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num 
FROM layoffs_staging;

-- SET SQL_SAFE_UPDATES = 0;
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Standardizing data
-- Changing industry name to same industry
SELECT company, TRIM(company)
FROM  layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT industry
FROM layoffs_staging2
WHERE industry like 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Fixing country typos
SELECT distinct country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Changing `date` column datatype from text to date
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y%')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y%');

SELECT date
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Replacing null and blank VALUES
SELECT *
FROM layoffs_staging2
WHERE industry is null
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
	AND t1.location = t2.location
WHERE (t1.industry is null or t1.industry = '')
AND (t2.industry is not null and t2.industry <> '');

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
	AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE (t1.industry is null or t1.industry = '')
AND (t2.industry is not null and t2.industry <> '');

SELECT *
FROM layoffs_staging2
WHERE total_laid_off is null
and percentage_laid_off is null;

-- Remove row_num column
SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
