-----------------------------------------------------------------------------------
----------------------  SQL - exercises - similar to exam  ------------------------
-----------------------------------------------------------------------------------
--- Schema: cooking_club
--- Tables: cooking_workshop , dish , dish_fits_in_theme , dish_in_workshop
--- Tables: ingredient, ingredient_in_dish, member, municipality, participation, theme
-----------------------------------------------------------------------------------

SET SEARCH_PATH TO cooking_club;
SELECT *
FROM cooking_workshop;
-- it shows all the workshops, their id's and their themes

-----------------------------------------------------------------------------------

SET SEARCH_PATH TO cooking_club;
SELECT *
FROM dish;
-- it shows all the dishes, their description and their preparation time

-----------------------------------------------------------------------------------

SET SEARCH_PATH TO cooking_club;
SELECT *
FROM member;
-- it shows all the members and all of their details

-----------------------------------------------------------------------------------

SET SEARCH_PATH TO cooking_club;
SELECT *
FROM municipality;

-----------------------------------------------------------------------------------
--check in the database that strawberries have 32 kcal of energy per 100 g and that one apricot has an energy content of 27 kcal.
SELECT *
FROM cooking_club.ingredient -- or use the search_path …
WHERE name IN ('Strawberry','Apricot');

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
------------   2 Questions where you just have to give the answer   --------------------
-----------------------------------------------------------------------------------

-- 2.1

--Suppose you eat one of each ingredient counted by piece, how much energy (kcal) have you ingested?
--Answer: 7071 kcal. A possible query for this is:
SET SEARCH_PATH TO cooking_club;
SELECT sum(energy)
FROM ingredient
WHERE unit = 'piece';

-----------------------------------------------------------------------------------

-- 2.2

--For example, it is obviously not possible for a registration date to fall after the cooking workshop itself. 
--So this error has to be be corrected manually. How many such erroneous registrations are there?

--Answer: 57, possible query:

SET SEARCH_PATH TO cooking_club;
SELECT COUNT(*)
FROM participation D INNER JOIN cooking_workshop K ON D.workshop = K.workshop_id
WHERE D.registration_date > K.start_time;


-----------------------------------------------------------------------------------

-- 2.3

-- Check out all the main dishes ever made in a cooking workshop. This required a lot of ingredients. If you delete them from the long list of all ingredients and you organize the remaining list alphabetically, which ingredient, that was not used for any main course, is in row 81?

--Answer: Meatball, solution found e.g. via:
SET SEARCH_PATH TO cooking_club;
SELECT name, IG.dish
FROM dish_in_workshop GW
  INNER JOIN ingredient_in_dish IG on GW.dish = IG.dish AND role_in_menu = 'Main Dish'
  RIGHT OUTER JOIN ingredient I ON IG.ingredient = I.name
WHERE IG.dish is NULL
ORDER BY 1;

-----------------------------------------------------------------------------------

--Answer: Ramiro Bell, with e.g. the following query:

SELECT first_name, name, birth_date, feedback
FROM participation D INNER JOIN member L ON D.member = L.member_number
WHERE feedback LIKE '%awesome%' OR feedback LIKE '%fantastic%'
ORDER BY 3 DESC;

-----------------------------------------------------------------------------------
----------    3 Model question
-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------

CREATE  TABLE cooking_club.order (
  ingredient_name          varchar(30)  NOT NULL ,
  workshop_id              smallint  NOT NULL ,
  order_date               date NOT NULL ,
  number                   smallint  NOT NULL ,
  CONSTRAINT pk_order PRIMARY KEY ( ingredient_name, workshop_id, order_date ),
  CONSTRAINT fk_order_ingredient FOREIGN KEY ( ingredient_name )
      REFERENCES cooking_club.ingredient( name )   ,
  CONSTRAINT fk_order_cooking_workshop FOREIGN KEY ( workshop_id )
       REFERENCES cooking_club.cooking_workshop( workshop_id )   ,
  CONSTRAINT cns_order CHECK ( number > 0 )
);


-----------------------------------------------------------------------------------

INSERT INTO ingredient VALUES ('Wasabi', 'g', 241);
INSERT INTO order VALUES ('Ginger', 7, '2020-08-18', 600);
INSERT INTO order VALUES ('Wasabi', 7, '2020-08-18', 180);
INSERT INTO order VALUES ('Salmon', 7, '2020-08-18', 6000);
INSERT INTO order VALUES ('Broccoli', 7, '2020-08-18', 7);

-----------------------------------------------------------------------------------
------------   4 Given the SQL query, what was the question?   --------------------
-----------------------------------------------------------------------------------

SET SEARCH_PATH TO cooking_club;
SELECT distinct municipality
FROM municipality LEFT OUTER JOIN member using(postal_code)
  INNER JOIN participation ON member.member_number = participation.member
  INNER JOIN dish_in_workshop using(workshop)
  INNER JOIN ingredient_in_dish using(dish)
GROUP BY municipality, participation.member
HAVING COUNT(distinct ingredient) > 30
ORDER BY 1 ASC;

-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
-------------------   5 SQL queries   -----------------------------------------
-----------------------------------------------------------------------------------

-- 5.1

--Provide an overview that shows by ingredient in which themes that ingredient is used. 
--There is an additional column that shows the energy of an ingredient in one word: 
--lower than 100 (kcal) is ‘low’ , between 100 and 300 is ‘medium’ and higher than 300 is ‘high’. 
--Avoid repetition of rows. Put ingredients in alphabetical order. Write the query.

SELECT distinct I.name AS ingredient, GT.theme AS "name theme", 
  CASE
    WHEN energy < 100 THEN 'low'
    WHEN energy > 300 THEN 'high'
    ELSE 'medium'
  END AS energy
FROM ingredient I
    INNER JOIN ingredient_in_dish IG ON (I.name = IG.ingredient)
    INNER JOIN dish_fits_in_theme GT using(dish)
ORDER BY 1;


-----------------------------------------------------------------------------------

-- 5.2

--For each theme, please list (see figure) by municipality how many participants are from that municipality. 
--Rank alphabetically by theme and within one theme according to decreasing number of members. Write the query.

SELECT theme, municipality, COUNT (member_number) AS "number of members per municipality"
FROM member
  INNER JOIN municipality USING (postal_code)
  INNER JOIN participation ON (member = member_number)
  INNER JOIN cooking_workshop ON (workshop = workshop_id)
GROUP BY theme, postal_code, municipality
ORDER BY theme, COUNT(member_number) DESC;


-----------------------------------------------------------------------------------

--An alternative where municipality in the GROUP BY may be omitted because of not using USING:

SELECT theme, municipality, COUNT (member_number) AS "number of members per municipality"
FROM member
  INNER JOIN municipality ON municipality.postal_code = member.postal_code
  INNER JOIN participation ON (member = member_number)
  INNER JOIN cooking_workshop ON (workshop = workshop_id)
GROUP BY theme, municipality.postal_code
ORDER BY theme, COUNT(member_number) DESC;

-----------------------------------------------------------------------------------

-- 5.3

--How many kcal are in the dish ‘Tiramisu with chocolate and banana’ per ingredient? 
--Please note that where the unit is ‘g’ or ‘ml’, the energy content is the number of kcal per 100 g or 100 ml. 
--For all other units, the number in kcal is simply the energy per unit (piece, tablespoon, etc.). 
--So keep in mind the units. 
--The ingredient that makes the largest energy contribution to this dish is at the top, then the second, etc. See figure. Write the query.

SELECT IG.ingredient, quantity, unit,energy,
  CASE
    WHEN unit in ('g','ml') THEN energy * quantity / 100
    ELSE energy * quantity
  END AS titak
FROM ingredient_in_dish IG INNER JOIN ingredient I ON IG.ingredient = I.name
WHERE dish = 'Tiramisu with chocolate and banana'
ORDER BY 5 DESC;

-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
-------------------  6 Questions where you just have to give the answer, part 2   -----------------------------------------
-----------------------------------------------------------------------------------

-- 6.1

-- List alphabetically all ingredients that are not yet used in a dish. 
--Which ingredient is in position 100 and what is the energy value of this ingredient? 
--So your answer contains two parts as e.g., ‘Cauliflower with 25 kcal’.

-- Answer: ‘Red Whine’ with 82 kcal. Possible query:
SELECT ingredient.name, ingredient.energy
FROM ingredient LEFT OUTER JOIN ingredient_in_dish ON (ingredient.name = ingredient_in_dish.ingredient)
WHERE ingredient_in_dish.dish IS NULL
ORDER BY ingredient.name;

-----------------------------------------------------------------------------------

-- 6.2

-- View all participations in cooking workshops by people from a community that begins with an ‘N’ or ends with an ‘n’. 
-- How many participants from these communities gave a score of at least 7?

-- Answer: 10. Possible query:

SELECT score, member_number, municipality, postal_code
FROM participation D
    INNER JOIN member L ON D.member = L.member_number
    INNER JOIN municipality using(postal_code)
WHERE (municipality LIKE 'N%' OR municipality LIKE '%n') AND score >= 7;

-----------------------------------------------------------------------------------

-- 6.3

-- Review the long list of ingredients, but limit yourself to those ingredients that are measured in grams (‘g’). 
--Calculate the average energy of these ingredients (which is measured per 100 g, but for this question, this is not important). 
--Which ingredient that is measured per g has an energy content closest to this average?


--Answer: Advocaat (240 Kcal per 100 g, is closest to average 226,5). 
-- You can obtain this most easily with two small queries, but of course it can be done more elegantly with one query (which contains a subquery).

SELECT name,energy -- but first you ask avg(energy)
FROM ingredient
WHERE unit = 'g'
ORDER BY 2;

-----------------------------------------------------------------------------------

-- 6.4

-- Provide first name and name of the member with most participations. 
--If there are multiple members with the same maximum number of participations, give all names (first name followed by last name).

--Answer: Benny Nielsenn, Casey Valentine, Shelley Vincent

SELECT name, first_name, COUNT(*)
FROM participation D INNER JOIN member L ON D.member = L.member_number
GROUP BY member_number
ORDER BY 3 DESC, 1;

-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
-------------------  7 Given the SQL query, what was the question, part 2?   -----------------------------------------
-----------------------------------------------------------------------------------

-- For this exercise, you get a query that is the answer to a particular question. 
--What was this question? Give your answer as completely as possible. 
--Feel free to use several sentences to clearly describe that question.

SELECT G.name
FROM theme T
    INNER JOIN dish_fits_in_theme GT ON T.name = GT.theme
    RIGHT OUTER JOIN dish G ON GT.dish = G.name AND
        T.name IN ('mediterranean','italian','fish')
WHERE T.name is NULL AND G.description NOT LIKE '%summer%'
ORDER BY preparation_time DESC;

-- List all dishes in the database that do not have as a theme Mediterranean, Italian or fish 
--      and where the description of the dish does not include the word summer, sorted by decreasing duration to prepare the dish.



-----------------------------------------------------------------------------------
-------------------  8 SQL query's, part 2   -----------------------------------------
-----------------------------------------------------------------------------------

-- 8.1

-- Write a query that, for all dishes that have an ingredient list, calculates the total energy content in kcal. 
--Attention: for ingredients whose unit is ‘g’ or ‘ml’, the energy content per 100 g or 100 ml is given. 
--For all other units the energy content is given per unit (‘piece’, ‘dl’, ‘teaspoon’, ...). 
--We would like to use this overview to get a list of only ‘light’ dishes that in total contain less than 4000 kcal. 
--The dish with the least number of kcal is at the top, then the second etc. The screenshot shows only the first two rows.

SELECT IG.dish,
  sum(CASE
    WHEN unit in ('g','ml') THEN energy * quantity / 100
    ELSE energy * quantity
  END) AS "total kcal"
FROM ingredient_in_dish IG INNER JOIN ingredient I ON IG.ingredient = I.name
GROUP BY IG.dish
HAVING sum(CASE
    WHEN unit in ('g','ml') THEN energy * quantity / 100
    ELSE energy * quantity
  END) < 4000
ORDER BY 2;

-----------------------------------------------------------------------------------

-- 8.2

--In signing up, we did not consider the maximum number of participants of each cooking workshop. 
--This is stupid, of course, because the people who registered after the maximum number of participants reached should be notified that the workshop is already fully booked. 
--Write a query that generates the list of all workshops that are are overbooked. 
--The most overbooked workshop is at the top, below that the one with the second largest overbooking and so on. 
--The screenshot in the figure below shows only the first three rows.

SELECT workshop_id, max_participants, COUNT(*) AS "number of participants"
FROM cooking_workshop KW INNER JOIN participation D ON D.workshop = KW.workshop_id
GROUP BY workshop_id
HAVING COUNT(*) > max_participants
ORDER BY (COUNT(*) - max_participants) DESC;

-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
-------------------  9 Questions where you just have to give the answer, part 3 (+ video)   -----------------------------------------
-----------------------------------------------------------------------------------

-- 9.1 

-- Make a list of all members who have not yet participated in any workshop and live on a street ending in ‘pad’. 
--Rank this list from old to young. What is the first name of the person who is in position 7 in this list?

-- Answer: Angelica. Possible query:

SELECT *
FROM member L LEFT OUTER JOIN participation D ON L.member_number = D.member
WHERE street LIKE '%pad' AND member is NULL
ORDER BY 4;

-----------------------------------------------------------------------------------

-- 9.2 

-- List by municipality the average score that people from that municipality gave to a cooking workshop. 
--Sort this list so that the highest average scores are at the top. Within the same average score sort alphabetically. 
--Municipalities where no one gave a score are not included in this list. Which municipality (name) is at the top?

-- Answer: Barvaux-Condrox. Possible query:

SELECT L.postal_code, avg(score), municipality
FROM participation D
  INNER JOIN member L ON D.member = L.member_number
  INNER JOIN municipality G ON G.postal_code = L.postal_code
WHERE score IS NOT NULL
GROUP BY L.postal_code, municipality
ORDER BY 2 DESC, 3 ASC;

-----------------------------------------------------------------------------------

-- 9.3

-- Calculate the percentage of participants who received a positive evaluation. 
--By ‘positive’ we mean that the evaluation should contain at least one of the following words: ‘good’, ‘great’ or ‘fantastic’. 
--Tip: you can write two fairly short queries that each return a number and then use your calculator to calculate the percentage yourself. 
--It can of course also be done in one query.

-- Answer: 23.5%. There are 94 good participations:

SELECT COUNT(*)
FROM participation
WHERE feedback LIKE '%good%' or feedback LIKE '%great%' or feedback LIKE '%fantastic%';

-----------------------------------------------------------------------------------

--In all, there are 400 participations:

SELECT COUNT(*)
FROM participation;

-----------------------------------------------------------------------------------

-- 9.4 

-- Make a list of all the ingredients that contain exactly twice the letter ‘a’. We don't consider upper/lower case. 
-- Sort according to decreasing energy content. Which ingredient is in place 21?

-- Answer: Low-fat cottage cheese. Possible query:

SELECT *
FROM ingredient
WHERE (lower(name) LIKE '%a%a%') AND NOT(lower(name) LIKE '%a%a%a%')
ORDER BY 3 DESC;

-----------------------------------------------------------------------------------

-- 9.5 

--Generate an overview of all registrations for workshops for which the participant wrote feedback and with a registration date before January 1 2019. 
--Sort this list alphabetically by name. Enter the first name and last name of the person listed in position 100.

-- Answer: Sonya Osborne. Query:

SELECT name, first_name, member, registration_date, feedback
FROM participation D INNER JOIN member L ON D.member = L.member_number
WHERE feedback IS NOT NULL AND registration_date < '2019-01-01'
ORDER BY 1;

-----------------------------------------------------------------------------------

-- 9.6 

-- Rank all themes by decreasing number of entries so that the theme to which the most people subscribed is at the top. 
-- How many entries did the theme that ranks fifth in this list have?

-- Answer: 41

SELECT theme, COUNT(*)
FROM participation D INNER JOIN cooking_workshop KW ON workshop = workshop_id
GROUP BY theme
ORDER BY 2 DESC;

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-------------------   10 Modifying database data   -----------------------------------------
-----------------------------------------------------------------------------------

-- The municipalities of ‘Overpelt’ and ‘Neerpelt’ have recently merged. 
-- Both together now form the municipality of ‘Pelt’. 
-- The site of the municipality of Pelt states: ‘3900 Overpelt becomes 3900 Pelt and 3910 Neerpelt becomes 3910 Pelt’. 
-- You, as the database administrator for the cooking club, have to make sure that this information is correctly updated in the database.
-- Write one query that does this. Caution: because you only have SELECT privilege to the database, you will not be able to test the query.

UPDATE cooking_club.municipality
SET municipality = 'Pelt'
WHERE postal_code = '3900' OR postal_code = '3910';



-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-------------------   11 Given the query, what was the question, part 3   -----------------------------------------
-----------------------------------------------------------------------------------

-- Given the following query. Describe accurately and briefly (one sentence) what the question is to which the query provides the answer.
-- Begin your answer with “List all the ... ”. This exercise is more difficult than you would expect at first glance.

SELECT name
FROM theme T LEFT OUTER JOIN cooking_workshop K ON T.name = K.theme AND max_participants > 35
WHERE theme IS null;

-- “Please list all topics (name will suffice) that not are covered in a cooking workshop with a maximum capacity of more than 35 participants.” 

-- Alternative: “Please list all themes that have not yet been covered in a cooking workshop or have only been covered in a cooking workshop with at most 35 participants.”




-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-------------------   12 Adding information to the database   -----------------------------------------
-----------------------------------------------------------------------------------
-- Jeroen Meus recently made in his cooking program ‘dagelijkse kost’ (english: ‘daily food’) ‘Cheese Croquette with ham and asparagus’. 
--That looked particularly delicious. You so want to add this dish to the database. We give below the full description. 
--You need to add the appropriate lines. Information that is already in the database should not be added again, because then the database server responds with an error message. 
--If there is information missing that is needed, then make up something appropriate. Beware: because you only have SELECT privilege to the database, you will not be able to test the queries.


-- We add ‘Cheese Croquette with ham and asparagus’. This dish is described as ‘Asparagus in a croquette, together with ham and Flandrien cheese’. 
--It takes an hour to prepare this dish. You will need the following ingredients:
'''
10 asparagus (each one provides an energy of 18 kcal)
150 g butter (100 g butter provides 737 kcal)
one lemon (1 lemon has 35 kcal energy)
200 g of ham (100 g of ham provides 335 kcal)
0.3 kg of Flandrien Cheese (100 g provides 365 kcal energy)
This dish fits the theme of ‘belgian’. Write all the necessary queries to add all this information to the database.
'''
-- In terms of ingredients, you just need to add the Flandrien cheese:

INSERT INTO cooking_club.ingredient VALUES ('Flandrien Cheese', 'g', 365);

-----------------------------------------------------------------------------------

-- Then add the new dish:

INSERT INTO cooking_club.dish VALUES 
  ('Cheese Croquette with ham and asparagus','Asparagus in a croquette, together with ham and Flandrien cheese', 60);

-----------------------------------------------------------------------------------

-- Next, the intermediate table between the two:

INSERT INTO cooking_club.ingredient_in_dish VALUES ('Cheese Croquette with ham and asparagus','Asparagus',10);
INSERT INTO cooking_club.ingredient_in_dish VALUES ('Cheese Croquette with ham and asparagus','Butter',150);
INSERT INTO cooking_club.ingredient_in_dish VALUES ('Cheese Croquette with ham and asparagus','Lemon',1);
INSERT INTO cooking_club.ingredient_in_dish VALUES ('Cheese Croquette with ham and asparagus','Ham',200);
INSERT INTO cooking_club.ingredient_in_dish VALUES ('Cheese Croquette with ham and asparagus','Flandrien Cheese',300);

-----------------------------------------------------------------------------------

-- Finally pair the dish with the belgian theme:

INSERT INTO cooking_club.dish_fits_in_theme VALUES ('Cheese Croquette with ham and asparagus','belgian');

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-------------------   13 SQL queries, part 3   -----------------------------------------
-----------------------------------------------------------------------------------
-- Write the SQL query that generates the following summary: a list of all municipalities with a total of three cooking workshop registrations. 
--We want only those municipalities that contain at least three times the lowercase ‘e’ in the name. Arrange the results in reverse alphabetical order.

-- Alternative: grouping by municipality and postal code is also allowed, postal code is more specific.

SELECT G.postal_code, COUNT(*) AS "number of participations", G.municipality
FROM municipality G
  INNER JOIN member L ON G.postal_code = L.postal_code
  INNER JOIN participation D ON L.member_number = D.member
WHERE municipality LIKE '%e%e%e%'
GROUP BY G.postal_code
HAVING COUNT(*) = 3
ORDER BY 3 DESC;

-----------------------------------------------------------------------------------

-- Suppose you make all dishes that are themed ‘italian’ or ‘BBQ’ (or both together).
-- Now make an overview per ingredient with per line the name, amount of energy (in kcal per piece, 100 g, 100 ml, ...), 
-- the unit in which it is counted, the total amount of this ingredient you need to prepare all of these dishes and the amount of energy in kcal that this represents. 
-- Order so that the ingredient with the largest amount of kcal is at the top. Write the query.

SELECT ingredient, energy, unit, sum(quantity) AS "total quantity",
  CASE
    WHEN unit = 'g' or unit = 'ml' THEN energy*sum(quantity)/100
    ELSE energy*sum(quantity)
  END AS "total energy"
FROM ingredient_in_dish IG
  INNER JOIN dish_fits_in_theme GT ON IG.dish = GT.dish
  INNER JOIN ingredient I ON I.name = IG.ingredient
WHERE theme IN ('italian','BBQ')
GROUP BY ingredient, energy, unit
ORDER BY 5 DESC;

-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------