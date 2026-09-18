# Messy Crime Incident Dataset for Data Cleaning Practice

## Overview

This dataset contains simulated crime incident records designed specifically for **data cleaning and preprocessing practice**.
The data intentionally includes inconsistencies, missing values, duplicates, and formatting issues to mimic real-world messy datasets.

This makes it ideal for beginners and intermediate learners who want to practice **data cleaning, preprocessing, and exploratory data analysis (EDA)** using tools such as **Python, Pandas, SQL, or Excel**.

---

## Dataset Characteristics

* Number of rows: ~5,000+
* Number of columns: 30+
* Format: CSV
* Data type: Structured tabular data

The dataset represents crime incidents reported across different districts and cities. Each row corresponds to a single incident with details about the crime, suspect information, reporting method, and investigation status.

---

## Column Description

| Column            | Description                                                  |
| ----------------- | ------------------------------------------------------------ |
| incident_id       | Unique identifier for each crime incident                    |
| crime_type        | Type of crime (e.g., Theft, Assault, Fraud)                  |
| district          | District where the incident occurred                         |
| city              | City of the reported crime                                   |
| state             | State where the incident took place                          |
| incident_datetime | Date and time when the incident occurred                     |
| report_datetime   | Date and time when the incident was reported                 |
| location_type     | Location category such as street, residence, commercial area |
| weapon_used       | Type of weapon used if applicable                            |
| suspect_age       | Age of the suspect                                           |
| suspect_gender    | Gender of the suspect                                        |
| victim_age        | Age of the victim                                            |
| victim_gender     | Gender of the victim                                         |
| severity          | Crime severity level                                         |
| property_loss_usd | Estimated financial loss from the incident                   |
| injuries_reported | Indicates if injuries were reported                          |
| reported_online   | Whether the crime was reported online                        |
| case_status       | Current investigation status                                 |
| officer_assigned  | Officer responsible for the case                             |
| notes             | Additional incident notes                                    |

Some columns may contain missing or inconsistent values intentionally.

---

## Intentional Data Issues

This dataset intentionally includes common real-world data problems such as:

* Missing values
* Duplicate rows
* Inconsistent text formatting
* Mixed capitalization
* Incorrect spellings
* Inconsistent categorical values
* Mixed date/time formats
* Numeric fields stored as text
* Outliers in numeric columns

These issues make the dataset useful for practicing realistic data cleaning workflows.

---

## Example Data Cleaning Tasks

Learners can practice the following tasks:

* Detecting and handling missing values
* Removing duplicate records
* Standardizing categorical values
* Fixing inconsistent capitalization
* Converting columns to correct data types
* Parsing date and time columns
* Identifying outliers
* Feature engineering
* Data validation checks

---

## Suggested Learning Exercises

### Beginner Tasks

* Load the dataset using Pandas
* Explore the dataset structure
* Identify missing values
* Remove duplicate rows
* Clean categorical columns

### Intermediate Tasks

* Convert date columns into proper datetime format
* Handle missing numerical values
* Standardize inconsistent categories
* Detect and handle outliers
* Create summary statistics

### Advanced Tasks

* Perform exploratory data analysis
* Identify crime patterns by district or city
* Analyze trends over time
* Build predictive models

---

## Tools You Can Use

This dataset works well with:

* Python
* Pandas
* NumPy
* SQL
* Excel
* Power BI
* Tableau
* Data visualization libraries such as Matplotlib and Seaborn

---

## Potential Analysis Questions

Some questions learners can explore:

* Which districts report the highest number of incidents?
* What crime types are most common?
* Are certain crimes more likely to involve weapons?
* Is there a relationship between crime severity and property loss?
* How long do cases typically remain open?

---

## Who This Dataset Is For

This dataset is ideal for:

* Data science beginners
* Data analyst learners
* Students learning data preprocessing
* Anyone practicing data cleaning techniques
* Portfolio project practice

---

## License

This dataset is released under the **CC0 Public Domain License**, allowing free use for learning, research, and projects.

---

## Disclaimer

This dataset is **synthetic and created for educational purposes only**.
It does not represent real crime records.

---

## Contributions

Suggestions for improvements or additional datasets are welcome.

If you found this dataset useful for learning data cleaning or analysis, feel free to use it in your projects or notebooks.
