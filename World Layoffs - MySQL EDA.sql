-- EXPLORATORY DATA ANALYSIS

SELECT * 
FROM layoffs_data2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off) #results of 1 means that all employees in that specific company were laid-offf
FROM layoffs_data2;

-- lets look at those companies 
SELECT company, industry, location, percentage_laid_off
FROM layoffs_data2
WHERE percentage_laid_off = 1;

-- lets look at all laid off companies with the highest total lay offs
SELECT company, industry, location, total_laid_off, percentage_laid_off, `date`
FROM layoffs_data2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Companies with entire staff laid off but also recieved a lot of funding 
SELECT company, industry, location, total_laid_off,
 percentage_laid_off, funds_raised_millions, `date`
FROM layoffs_data2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Total number of individuals laid off from highest to lowest
SELECT company, SUM(total_laid_off)
FROM layoffs_data2
GROUP BY company
ORDER BY SUM(total_laid_off) DESC;

-- Time periods of lay-offs
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_data2;

-- Industries that had the most layoffs
SELECT industry, SUM(total_laid_off)
FROM layoffs_data2
GROUP BY industry
ORDER BY SUM(total_laid_off)DESC;

-- Countries with the highest layoffs
SELECT country, SUM(total_laid_off)
FROM layoffs_data2
GROUP BY country
ORDER BY 2 DESC;

-- Layoffs by years
SELECT YEAR (`date`), SUM(total_laid_off)
FROM layoffs_data2
GROUP BY YEAR (`date`)
ORDER BY  1 DESC;

-- Progression on the layoffs 
SELECT SUBSTRING(`date`, 1,7) AS `Period`, SUM(total_laid_off) AS Total_off
FROM layoffs_data2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `Period` 
ORDER BY `Period` ASC;

-- Creating the Rolling Sum
 WITH Rolling_Total AS
 (
 SELECT SUBSTRING(`date`, 1,7) AS `Period`, SUM(total_laid_off) AS Total_off
FROM layoffs_data2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `Period` 
ORDER BY `Period` ASC
 )
 SELECT `Period`, Total_off, SUM(Total_off) OVER (order by `Period`) AS rollingtotal
 FROM Rolling_Total;
 
 -- Company total laid off in a rolling calender
 SELECT company, YEAR(`date`), SUM(total_laid_off)
 FROM layoffs_data2
 GROUP BY company, YEAR(`date`)
 ORDER BY SUM(total_laid_off) DESC;
 
 WITH Company_Year(company, years, total_laid_off) AS
 (
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_data2
GROUP BY company, YEAR(`date`)
ORDER BY SUM(total_laid_off) DESC
 ), Company_Year_Ranking AS
 (
 SELECT * , DENSE_RANK () OVER (PARTITION BY years) AS Ranking
 FROM Company_Year
 WHERE years IS NOT NULL
 )
 SELECT *
 FROM Company_Year_Ranking
 WHERE Ranking <= 5;
