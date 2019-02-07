<pre>
Select 'ФИО: Федотенкова Полина Сергеевна';
</pre>

<pre>
-- Оконные функции
select
  userid, movieid,
  -- normed_rating=(r - r_min)/(r_max - r_min)
  (rating - MIN(rating) OVER (PARTITION BY userId))/((MAX(rating) OVER (PARTITION BY userId)) - MIN(rating) OVER (PARTITION BY userId)) as normed_rating,
  AVG(rating) OVER (PARTITION BY userId) as avg_rating
from ratings
limit 30;
</pre>

Результат:

<pre>
userid | movieid |   normed_rating   |    avg_rating
--------+---------+-------------------+------------------
      1 |     110 | 0.111111111111111 | 4.27777777777778
      1 |     147 | 0.888888888888889 | 4.27777777777778
      1 |    1221 |                 1 | 4.27777777777778
      1 |    2918 |                 1 | 4.27777777777778
      1 |   59315 |                 1 | 4.27777777777778
      1 |   68358 |                 1 | 4.27777777777778
      1 |    2959 | 0.777777777777778 | 4.27777777777778
      1 |   69844 |                 1 | 4.27777777777778
      1 |   73017 |                 1 | 4.27777777777778
      1 |    1246 |                 1 | 4.27777777777778
      1 |    4226 | 0.777777777777778 | 4.27777777777778
      1 |   81834 |                 1 | 4.27777777777778
      1 |   91500 | 0.444444444444444 | 4.27777777777778
      1 |    4878 |                 1 | 4.27777777777778
      1 |   91542 |                 1 | 4.27777777777778
      1 |   92439 |                 1 | 4.27777777777778
      1 |     858 |                 1 | 4.27777777777778
      1 |    1968 | 0.777777777777778 | 4.27777777777778
      1 |    5577 |                 1 | 4.27777777777778
      1 |   96821 |                 1 | 4.27777777777778
      1 |   98809 |                 0 | 4.27777777777778
      1 |   33794 | 0.777777777777778 | 4.27777777777778
      1 |   99114 | 0.777777777777778 | 4.27777777777778
      1 |  112552 |                 1 | 4.27777777777778
      1 |    2762 | 0.888888888888889 | 4.27777777777778
      1 |   54503 | 0.666666666666667 | 4.27777777777778
      1 |   58559 | 0.777777777777778 | 4.27777777777778
      2 |      64 |              0.75 | 3.31818181818182
      2 |      79 |              0.75 | 3.31818181818182
      2 |     141 |               0.5 | 3.31818181818182
(30 rows)

</pre>

*Проверьте, что в директории data присутствует файл с ключевыми словами по фильмам*

Определяем наличие файла в директории:

<pre>
cd /usr/local/share/netology
ls ./raw_data | grep keywords
</pre>

Результат:

<pre>
postgres@ubuntu1804:~$ cd /usr/local/share/netology
postgres@ubuntu1804:/usr/local/share/netology$ ls ./raw_data | grep keywords
keywords1.csv
keywords.csv
</pre>

*Напишите команду создания таблички keywords у неё должно быть 2 поля - id(числовой) и tags (текстовое).*

<pre>
psql -U postgres -c ' create table if not exists keywords (movieid int, tags text);'
</pre>


Результат:

<pre>
postgres@ubuntu1804:~$ psql -U postgres -c ' create table if not exists keywords (movieid int, tags text);'
CREATE TABLE
postgres@ubuntu1804:~$
</pre>

*Напишите команду копирования данных из файла в созданную вами таблицу*

<pre>
psql -U postgres -c "\copy keywords FROM '/usr/local/share/netology/raw_data/keywords.csv' DELIMITER ',' CSV HEADER"
</pre>

Результат:

<pre>
postgres@ubuntu1804:~$ psql -U postgres -c "\copy keywords FROM '/usr/local/share/netology/raw_data/keywords.csv' DELIMITER ',' CSV HEADER"
COPY 46419
postgres@ubuntu1804:~$
</pre>

*Проверьте, что в таблице есть записи*

<pre>
select count (*) from keywords;
</pre>

Результат:

<pre>
 count
-------
 46419
(1 row)

postgres=#

</pre>

*Transform*

Запрос 1
<pre>
-- Запрос 1
Select movieid,
	avg (rating) as avg_rating
	--count(rating) as r_quant
	from ratings
	group by movieid
	having count(rating) > 50
	Order by
	avg_rating desc,
	movieid asc	
	limit 150);
</pre>

Запрос 2
<pre>
-- Запрос 1-Запрос 2
WITH top_rated as (
	Select movieid as top_rated_movieid,
	avg (rating) as avg_rating
	--count(rating) as r_quant
	from ratings
	group by movieid
	having count(rating) > 50
	Order by
	avg_rating desc,
	movieid asc	
	limit 150)
Select top_rated_movieid, tags
from top_rated
join keywords
on top_rated.top_rated_movieid=keywords.movieid
;
</pre>

Запрос 3
<pre>
-- Запрос 3
WITH top_rated as (
Select movieid as top_rated_movieid,
	avg (rating) as avg_rating
	--count(rating) as r_quant
	from ratings
	group by movieid
	having count(rating) > 50
	Order by
	avg_rating desc,
	movieid asc	
	limit 150)
SELECT movieid, tags AS top_rated_tags into top_rated_tags FROM top_rated
join keywords
on top_rated.top_rated_movieid=keywords.movieid
;
</pre>

Результат запроса 3:

<pre>

SELECT 63
postgres=#

</pre>

*Выгрузка данных в csv file*

<pre>
psql -c "\copy (select * from top_rated_tags) to 'top_rated_tags.csv' with csv header delimiter as E'\t';"
</pre>

Результат:

<pre>
COPY 63
postgres@ubuntu1804:~$
</pre>

