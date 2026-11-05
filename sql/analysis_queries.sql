-- India Data Job Market Intelligence: analysis queries (SQLite)

-- Query 1 - Top cities for core data roles
SELECT city,
       COUNT(*) AS jobs,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM jobs WHERE is_core_role = 1 AND city <> 'Not specified'), 1) AS pct_of_located_jobs
FROM jobs
WHERE is_core_role = 1
  AND city <> 'Not specified'
GROUP BY city
ORDER BY jobs DESC
LIMIT 10;

-- Query 2 - Most demanded skills for Data Analyst jobs
SELECT s.skill,
       s.category,
       COUNT(DISTINCT s.job_id) AS jobs,
       ROUND(100.0 * COUNT(DISTINCT s.job_id) / (SELECT COUNT(*) FROM jobs WHERE role_group = 'Data Analyst'), 1) AS pct_of_role_jobs
FROM job_skills s
JOIN jobs j ON j.job_id = s.job_id
WHERE j.role_group = 'Data Analyst'
GROUP BY s.skill, s.category
ORDER BY jobs DESC
LIMIT 15;

-- Query 3 - Skills to learn first for fresher analyst jobs
WITH fresher AS (
    SELECT job_id
    FROM jobs
    WHERE role_group IN ('Data Analyst', 'BI Analyst', 'Business Analyst')
      AND experience_level = 'Entry/Fresher'
)
SELECT s.skill,
       s.category,
       COUNT(*) AS jobs,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM fresher), 1) AS pct_of_fresher_jobs
FROM job_skills s
JOIN fresher f ON f.job_id = s.job_id
WHERE s.category <> 'Soft Skill'
GROUP BY s.skill, s.category
ORDER BY jobs DESC
LIMIT 12;

-- Query 4 - Fresher vs mid/senior skill demand (analyst-type roles)
WITH base AS (
    SELECT job_id,
           CASE WHEN experience_level = 'Entry/Fresher' THEN 'Fresher' ELSE 'Mid/Senior' END AS grp
    FROM jobs
    WHERE role_group IN ('Data Analyst', 'BI Analyst', 'Business Analyst')
      AND experience_level IN ('Entry/Fresher', 'Mid (2-4 yrs)', 'Senior (5+ yrs)')
),
totals AS (
    SELECT grp, COUNT(*) AS n FROM base GROUP BY grp
)
SELECT s.skill,
       ROUND(100.0 * SUM(CASE WHEN b.grp = 'Fresher' THEN 1 ELSE 0 END)
             / (SELECT n FROM totals WHERE grp = 'Fresher'), 1) AS fresher_pct,
       ROUND(100.0 * SUM(CASE WHEN b.grp = 'Mid/Senior' THEN 1 ELSE 0 END)
             / (SELECT n FROM totals WHERE grp = 'Mid/Senior'), 1) AS mid_senior_pct,
       ROUND(100.0 * SUM(CASE WHEN b.grp = 'Mid/Senior' THEN 1 ELSE 0 END)
             / (SELECT n FROM totals WHERE grp = 'Mid/Senior')
           - 100.0 * SUM(CASE WHEN b.grp = 'Fresher' THEN 1 ELSE 0 END)
             / (SELECT n FROM totals WHERE grp = 'Fresher'), 1) AS gap_points
FROM base b
JOIN job_skills s ON s.job_id = b.job_id
WHERE s.category <> 'Soft Skill'
GROUP BY s.skill
ORDER BY mid_senior_pct DESC
LIMIT 15;

-- Query 5 - Most common skill pairs (core roles)
SELECT a.skill AS skill_1,
       b.skill AS skill_2,
       COUNT(*) AS jobs
FROM job_skills a
JOIN job_skills b ON a.job_id = b.job_id AND a.skill < b.skill
JOIN jobs j ON j.job_id = a.job_id
WHERE j.is_core_role = 1
GROUP BY a.skill, b.skill
ORDER BY jobs DESC
LIMIT 15;

-- Query 6 - Skills requested together with Power BI
WITH pbi AS (
    SELECT s.job_id
    FROM job_skills s
    JOIN jobs j ON j.job_id = s.job_id
    WHERE s.skill = 'Power BI' AND j.is_core_role = 1
)
SELECT s.skill,
       COUNT(*) AS jobs_with_powerbi,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM pbi), 1) AS pct_of_powerbi_jobs
FROM job_skills s
JOIN pbi ON pbi.job_id = s.job_id
WHERE s.skill <> 'Power BI'
GROUP BY s.skill
ORDER BY jobs_with_powerbi DESC
LIMIT 12;

-- Query 7 - Median salary (LPA) by role
WITH ranked AS (
    SELECT role_group,
           salary_lpa_clean,
           ROW_NUMBER() OVER (PARTITION BY role_group ORDER BY salary_lpa_clean) AS rn,
           COUNT(*) OVER (PARTITION BY role_group) AS cnt
    FROM jobs
    WHERE is_core_role = 1 AND salary_lpa_clean IS NOT NULL
)
SELECT role_group,
       MAX(cnt) AS jobs_with_salary,
       ROUND(AVG(salary_lpa_clean), 2) AS median_lpa
FROM ranked
WHERE rn IN ((cnt + 1) / 2, (cnt + 2) / 2)
GROUP BY role_group
ORDER BY median_lpa DESC;

-- Query 8 - Median salary (LPA) by experience level, excluding interns
WITH ranked AS (
    SELECT experience_level,
           salary_lpa_clean,
           ROW_NUMBER() OVER (PARTITION BY experience_level ORDER BY salary_lpa_clean) AS rn,
           COUNT(*) OVER (PARTITION BY experience_level) AS cnt
    FROM jobs
    WHERE is_core_role = 1
      AND is_intern = 0
      AND salary_lpa_clean IS NOT NULL
      AND experience_level <> 'Not specified'
)
SELECT experience_level,
       MAX(cnt) AS jobs_with_salary,
       ROUND(AVG(salary_lpa_clean), 2) AS median_lpa
FROM ranked
WHERE rn IN ((cnt + 1) / 2, (cnt + 2) / 2)
GROUP BY experience_level
ORDER BY median_lpa;

-- Query 9 - Remote share by role
SELECT role_group,
       COUNT(*) AS jobs,
       SUM(work_mode = 'Remote') AS remote_jobs,
       ROUND(100.0 * SUM(work_mode = 'Remote') / COUNT(*), 1) AS remote_pct
FROM jobs
WHERE is_core_role = 1
GROUP BY role_group
ORDER BY jobs DESC;

-- Query 10 - Power BI demand by city
SELECT j.city,
       COUNT(*) AS core_jobs,
       SUM(CASE WHEN s.job_id IS NOT NULL THEN 1 ELSE 0 END) AS powerbi_jobs,
       ROUND(100.0 * SUM(CASE WHEN s.job_id IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS powerbi_pct
FROM jobs j
LEFT JOIN job_skills s ON s.job_id = j.job_id AND s.skill = 'Power BI'
WHERE j.is_core_role = 1 AND j.city <> 'Not specified'
GROUP BY j.city
HAVING COUNT(*) >= 10
ORDER BY powerbi_pct DESC;
