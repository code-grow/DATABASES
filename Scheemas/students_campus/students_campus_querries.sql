-----------------------------------------------------------------------------------
------------  SQL subquerries - exercises - schema students_campus  ---------------
-----------------------------------------------------------------------------------
--- Schema: students_campus
--- Tables: campus  ,  student
-----------------------------------------------------------------------------------

SET SEARCH_PATH TO students_campus;
SELECT *
FROM student;
-- Here we can see the all the students from any campus 

-----------------------------------------------------------------------------------

SET SEARCH_PATH TO students_campus;
SELECT *
FROM campus;
-- Here we can see all the campuses from our university

-----------------------------------------------------------------------------------

SET SEARCH_PATH TO students_campus;
SELECT AVG(distance_to_campus)
FROM student;
-- returns the average distance to campus - 52.01658

-----------------------------------------------------------------------------------

SELECT AVG(distance_to_campus)
FROM students_campus.student;
--   students_campus.student   is the same as   SET SEARCH_PATH TO students_campus;

-----------------------------------------------------------------------------------

SET SEARCH_PATH TO students_campus;
SELECT count(*)
FROM student
WHERE distance_to_campus > 52.01658;
-- returns the number of all the students for which the distance to the campus is bigger than the average
-- returns 401, which means that 401 students travel more than the average

-----------------------------------------------------------------------------------

SET SEARCH_PATH TO students_campus;
SELECT COUNT(*)
FROM student
WHERE distance_to_campus > (
  SELECT AVG(distance_to_campus)
  FROM student
);
-- exactly the same like the querry above, but this time with a subquerry
-- returns the number of all the students for which the distance to the campus is bigger than the average
-- returns 401, which means that 401 students travel more than the average

-----------------------------------------------------------------------------------

SET SEARCH_PATH TO students_campus;
SELECT avg(distance_to_campus)
FROM student
WHERE campus_id = (
  SELECT id
  FROM campus
  WHERE name = 'Campus Proximus'
);
-- with a subquerry

-----------------------------------------------------------------------------------

SET SEARCH_PATH TO students_campus;
SELECT avg(distance_to_campus)
FROM student S INNER JOIN campus C on S.campus_id = C.id
WHERE C.name = 'Campus Proximus';
--with a JOIN

-----------------------------------------------------------------------------------

SET SEARCH_PATH TO students_campus;
SELECT first_name || ' ' || last_name AS name, birth_date
FROM student
WHERE campus_id IN (
  SELECT id
  FROM campus
  WHERE location = 'Heverlee'
)
ORDER BY birth_date
LIMIT 5;
-- with a subquerry

-----------------------------------------------------------------------------------

SET SEARCH_PATH TO students_campus;
SELECT first_name || ' ' || last_name AS name, birth_date
FROM student S INNER JOIN campus C ON S.campus_id = C.id
WHERE location = 'Heverlee'
ORDER BY birth_date
LIMIT 5;
-- with a JOIN

-----------------------------------------------------------------------------------

SET SEARCH_PATH TO students_campus;
SELECT *
FROM student
WHERE birth_date > '2004-02-27'
ORDER BY birth_date DESC;

-----------------------------------------------------------------------------------

SELECT *
FROM students_campus.student
WHERE birth_date > ALL (
  SELECT birth_date
  FROM students_campus.student
  WHERE first_name LIKE 'Al%'
)
ORDER BY birth_date DESC;

-----------------------------------------------------------------------------------

SET SEARCH_PATH TO students_campus;
SELECT *
FROM student
WHERE birth_date > '2004-02-27'
ORDER BY birth_date DESC;

-----------------------------------------------------------------------------------

SET SEARCH_PATH TO students_campus;
SELECT *
FROM student
WHERE birth_date < '2004-02-27'
ORDER BY birth_date DESC;

-----------------------------------------------------------------------------------

SET SEARCH_PATH TO students_campus;
SELECT *
FROM student
WHERE birth_date < '2004-02-27' AND birth_date > '2002-04-23'
ORDER BY birth_date DESC;
-- turns to be Ty Gates, born in 2004
-----------------------------------------------------------------------------------

SET SEARCH_PATH TO students_campus;
SELECT id
FROM campus
WHERE location = 'Diest';
-- returns 2
-----------------------------------------------------------------------------------

SET SEARCH_PATH TO students_campus;
SELECT *
FROM student
WHERE lower(last_name) LIKE '%a%a%' AND campus_id = 2
ORDER BY distance_to_campus ASC;
-- turns to be Cornelius Zavala, born in 1993

-----------------------------------------------------------------------------------

SET SEARCH_PATH TO students_campus;
SELECT *
FROM student
WHERE distance_to_campus < 15
ORDER BY campus_id ASC, distance_to_campus DESC;
-- turns to be Jacob Hawkins, born in 1983
-----------------------------------------------------------------------------------

SET SEARCH_PATH TO students_campus;
SELECT *
from student
WHERE distance_to_campus < ALL (
  SELECT distance_to_campus
  FROM student
  WHERE lower(last_name) LIKE '%a%a%'
    AND distance_to_campus IS NOT null --in order to avoid null in the result
    AND campus_id IN (
      SELECT id
      FROM campus
      WHERE location = 'Diest'
    )
)
ORDER BY campus_id ASC, distance_to_campus DESC;

-----------------------------------------------------------------------------------
------- Subquery with the ANY operator ----------------
-----------------------------------------------------------------------------------

SET SEARCH_PATH TO students_campus;
SELECT *
FROM student
WHERE campus_id = 7 AND birth_date < ANY(
  SELECT birth_date
  FROM student
  WHERE campus_id = 4
);
-- turns out to be Gretchen Proctor, born in 1999
-----------------------------------------------------------------------------------

SET SEARCH_PATH TO students_campus;
SELECT *
FROM student
WHERE campus_id = 7;
-- turns out to be Laura Washington, born in 1983
-----------------------------------------------------------------------------------

SET SEARCH_PATH TO students_campus;
SELECT *
FROM student
WHERE campus_id = 4
ORDER BY 4 DESC;
-- turns out to be Lisa Vargas, born 2004
-----------------------------------------------------------------------------------