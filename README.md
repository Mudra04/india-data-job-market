# India Data Job Market Intelligence

**What skills, cities and salaries do Indian data analyst and data science job postings ask for, and what should a fresher learn first?**

An end-to-end analytics project: Python data cleaning, skill extraction from job descriptions, SQL analysis in SQLite, and a 4-page interactive Tableau dashboard.

**Live dashboard:** [View on Tableau Public](https://public.tableau.com/app/profile/mudra.berde/vizzes)
**Case study:** [docs/CASE_STUDY.md](docs/CASE_STUDY.md)

## Dashboard preview

| Market overview | Skills |
|---|---|
| ![Market overview](dashboard/screenshots/01_market_overview.png) | ![Skills](dashboard/screenshots/02_skills.png) |

| Pay | Skill pairs and recommendations |
|---|---|
| ![Pay](dashboard/screenshots/03_pay.png) | ![Recommendations](dashboard/screenshots/04_recommendations.png) |

## Business questions and short answers

| # | Question | Short answer |
|---|---|---|
| 1 | Which cities hire the most? | Bengaluru has 45% of postings that name a city, then Delhi NCR (15%), Hyderabad (9%) and Pune (8.5%). |
| 2 | Which skills are most demanded? | Across core data roles: SQL 59%, Python 57%, Statistics 45%, Data Visualization 41%. For Data Analyst roles: SQL 55%, Excel 45%, Power BI 33%. |
| 3 | Which skills appear together? | Python + SQL is the most common pair (43% of postings). About 4 in 5 Power BI postings also ask for SQL. |
| 4 | How do requirements and pay change with experience? | In analyst-type roles, SQL goes from 45% (fresher) to 64% (mid/senior), Power BI from 23% to 42%, Tableau from 20% to 39%. Median estimated pay rises from 5.1 to 6.0 to 6.9 LPA. |
| 5 | What should a fresher learn first? | SQL, Excel and basic statistics, then one BI tool (Power BI or Tableau), then Python. |

## Key findings

### Skill demand by role (% of postings in that role that mention the skill)

| Data Analyst (n=306) | Data Scientist (n=234) | Data Engineer (n=143) |
|---|---|---|
| SQL 55% | Python 80% | SQL 77% |
| Data Visualization 49% | Machine Learning 77% | ETL / Pipelines 70% |
| Excel 45% | Statistics 76% | Python 64% |
| Statistics 39% | SQL 54% | Spark / Big Data 55% |
| Python 38% | Data Visualization 44% | Data Warehousing / Modeling 50% |
| Power BI 33%, Tableau 29% | Deep Learning 37% | Azure 35%, AWS 33% |

Power BI and Tableau are close in demand for analyst roles (33% vs 29%). Excel is mentioned more often than either.

### Fresher vs experienced (analyst-type roles: Data Analyst, BI Analyst, Business Analyst)

| Skill | Fresher (n=64) | Mid / senior (n=156) |
|---|---|---|
| SQL | 45% | 64% |
| Data Visualization | 45% | 60% |
| Excel | 42% | 46% |
| Python | 34% | 46% |
| Power BI | 23% | 42% |
| Tableau | 20% | 39% |
| Statistics | 45% | 41% |

Excel and Statistics are expected at every level. SQL and the BI tools become much more important with experience. The fresher group is small, so small differences should not be over-read.

### Pay (Glassdoor estimates, LPA = lakhs per annum)

| Role | Median | Postings with a salary |
|---|---|---|
| Data Engineer | 6.9 | 109 |
| Data Scientist | 6.1 | 159 |
| Data Analyst | 5.0 | 224 |

| Experience (interns excluded) | Median | Postings with a salary |
|---|---|---|
| Fresher | 5.1 | 88 |
| Mid (2-4 yrs) | 6.0 | 173 |
| Senior (5+ yrs) | 6.9 | 81 |

### Cities (core roles that name a city, 566 postings)

Bengaluru 253 (45%), Delhi NCR 86 (15%), Hyderabad 52 (9%), Pune 48 (8.5%), Chennai 34 (6%), Mumbai 31 (5.5%). Another 21% of core-role postings name no city (this includes remote roles).

## Recommendations for a fresher

1. **Learn SQL first.** It appears in 45% of fresher analyst postings and 64% of mid/senior ones.
2. **Make Excel and basic statistics your baseline.** About 42% and 45% of fresher postings ask for them.
3. **Add one BI tool.** Power BI demand grows from 23% to 42% with experience, Tableau from 20% to 39%. Pick one and build projects with it.
4. **Add Python after that.** It is in 34% of fresher analyst postings, against 80% of data scientist postings.
5. **Start with the biggest hiring cities** (Bengaluru, Delhi NCR, Hyderabad, Pune) and treat remote as another market.

## How it was built

```
Kaggle dataset (900 Glassdoor India postings)
   -> 01 explore raw data
   -> 02 clean data            (pandas: roles, cities, salary, experience level)
   -> 03 extract skills        (26 skills found with regex patterns)
   -> 04 SQL analysis          (SQLite, 10 queries)
   -> 05 export for Tableau    (3 tidy files)
   -> Tableau Public dashboard (4 pages)
```

| Notebook | What it does |
|---|---|
| `01_explore_raw_data.ipynb` | Shape, columns, missing values and duplicates in the raw file |
| `02_clean_data.ipynb` | Removes duplicates, groups job titles into roles, standardises cities, converts salary to annual INR and LPA, estimates experience level, flags suspicious salaries |
| `03_extract_skills.ipynb` | Finds 26 skills in each description; computes skill demand by role, fresher vs experienced, and skill pairs |
| `04_sql_analysis.ipynb` | Loads the data into SQLite and runs 10 queries (joins, CTEs, `CASE WHEN`, self-join, window functions) |
| `05_export_for_tableau.ipynb` | Builds the job table, a job x skill grid and a skill-pair table for the dashboard |

The SQL queries are saved in [`sql/analysis_queries.sql`](sql/analysis_queries.sql).

## Repository structure

```
india-data-job-market/
├── README.md
├── requirements.txt
├── docs/CASE_STUDY.md
├── notebooks/            01 to 05
├── sql/analysis_queries.sql
├── data/
│   ├── clean/            jobs_final.csv, job_skills.csv
│   └── tableau/          jobs_tableau.csv, skill_grid.csv, skill_pairs.csv
└── dashboard/screenshots/
```

## How to reproduce

1. Clone the repo and create an environment:
   ```
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```
2. Download the dataset from Kaggle ("Glassdoor Data Science Jobs" by kuralamuthan300, India listings, Dec 2023 to Jan 2024) and put the CSV in `data/raw/`.
3. Run notebooks `01` to `05` in order. Each one writes the files the next one needs.
4. Open the files in `data/tableau/` in Tableau to rebuild the dashboard.

## Data cleaning decisions

- 900 raw rows reduced to 831: 5 exact duplicates removed, rows with no job description dropped, and non-analyst jobs (data entry, annotation, labeling) removed.
- Job titles grouped by keyword rules into Data Analyst, BI Analyst, Business Analyst, Data Scientist, Data Engineer and ML/AI Engineer (the **core roles**, 717 postings). Clinical/operations roles are labelled Data Operations and kept out of the core analysis.
- City names standardised (for example Hyderabad with accents, Gurgaon/Noida/Delhi grouped as Delhi NCR).
- Salary text such as `₹3,25,236` converted to numbers; monthly figures multiplied by 12; hourly figures dropped. Suspicious salaries are flagged, not deleted.
- Experience level estimated from the job title (Intern, Junior, Senior...) and from text such as "0-2 years of experience". Years above 15 are ignored because they usually describe company history.
- Skill extraction was checked by reading sample postings. This caught a bug where "2.5 years" was read as 5, which was fixed and retested.

## Limitations

- **Snapshot, not a trend.** The data covers Dec 2023 to Jan 2024 only.
- **Search bias.** Postings came from "data science" searches, so Python and ML are probably over-represented compared with the whole market.
- **Small groups.** BI Analyst (15), Business Analyst (8) and ML/AI Engineer (11) are too small for conclusions. The fresher analyst group (64) has a margin of error of roughly 12 percentage points.
- **Salaries are Glassdoor estimates**, not confirmed pay.
- **Keyword-based skill extraction.** Soft skills such as "Communication" are over-counted, and the letter "R" is only counted in clear phrases like "R programming" or "Python/R".
- **Experience is partly inferred**, and about a third of postings state no experience at all.
- 21% of core-role postings name no city.

## Next steps

- Add newer postings from other sources to check whether the findings still hold.
- Collect enough BI and Business Analyst postings to analyse them properly.
- Compare skill demand across industries and company sizes.

## Data and license note

The raw dataset is not included in this repository. Please download it from Kaggle and check its license. This repository contains derived features only (no job description text).

## Tools

Python (pandas, NumPy, matplotlib), SQLite, Tableau Public, Git and GitHub.

## Author

**Mudra Berde**, final-year Data Science student. [LinkedIn](PASTE-YOUR-LINKEDIN-LINK-HERE)
