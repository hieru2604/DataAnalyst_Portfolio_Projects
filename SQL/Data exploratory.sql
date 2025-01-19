-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;


WITH Rolling_total as 
(
SELECT substring(`date`,1,7) as `Month`, SUM(total_laid_off) as total_off
FROM layoffs_staging2
WHERE substring(`date`,1,7) is not null
GROUP BY `Month`
ORDER BY 1 ASC
)
SELECT `Month`, total_off
, SUM(total_off) OVER(ORDER BY `Month`) as Rolling_total
FROM Rolling_total;


WITH Company_Year(company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
), Company_Year_Rank as
(
SELECT *,
 DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
WHERE years is not null
)
SELECT *
FROM Company_Year_Rank
WHERE ranking <= 5