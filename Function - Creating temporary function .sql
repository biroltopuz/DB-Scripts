CREATE TEMP TABLE users
AS SELECT 1 id, 10 age
UNION ALL SELECT 2, 30
UNION ALL SELECT 3, 10;

CREATE TEMP FUNCTION countUserByAge(userAge INT64)
AS (
  (SELECT COUNT(1) FROM users WHERE age = userAge)
);

SELECT countUserByAge(10) AS count_user_age_10,
       countUserByAge(20) AS count_user_age_20,
       countUserByAge(30) AS count_user_age_30;
