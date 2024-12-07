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

--Suppose you eat one of each ingredient counted by piece, how much energy (kcal) have you ingested?
--Answer: 7071 kcal. A possible query for this is:
SET SEARCH_PATH TO cooking_club;
SELECT sum(energy)
FROM ingredient
WHERE unit = 'piece';

-----------------------------------------------------------------------------------
--For example, it is obviously not possible for a registration date to fall after the cooking workshop itself. So this error has to be be corrected manually. How many such erroneous registrations are there?
--Answer: 57, possible query:
SET SEARCH_PATH TO cooking_club;
SELECT COUNT(*)
FROM participation D INNER JOIN cooking_workshop K ON D.workshop = K.workshop_id
WHERE D.registration_date > K.start_time;


-----------------------------------------------------------------------------------

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
------------   4 Given the SQL query, what was the question?
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



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------