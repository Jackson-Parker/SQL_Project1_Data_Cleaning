# SQL Data Cleaning Project: 
Data.Cleaning.Jackson.Parker.sql

## Project Overview
This project focuses on applying SQL skills to clean a raw dataset.

## Dataset
The dataset includes various companies and their layoffs as well as other information about the company such as location.

## Tools Used
* **SQL (MySQL Workbench):** For all data cleaning and analysis queries.

## Key Steps & SQL Concepts Applied
* **Data Cleaning:**
    * # 1. Remove duplicates using `ROW_NUMBER() OVER(PARTITION BY...)`
    * # 2. Standardize the data using `TRIM ()` and `STR_TO_DATE`
    * # 3. Remove null values or blank values using `IS NULL` and `JOIN`
    * # 4. Remove any columns or rows that are unneded using `DELETE` and `DROP COLUMN`


## Future Work
* Next, I will use this raw data to perform exploratory data analysis to uncover insights.

---
*This project was completed as part of the Alex The Analyst SQL Bootcamp.*
