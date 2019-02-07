psql -U postgres

Select 'ФИО: Федотенкова Полина Сергеевна';

drop table if exists keywords;

create table if not exists keywords (movieid int, tags text);

\q

psql -U postgres -c "\copy keywords FROM '/usr/local/share/netology/raw_data/keywords.csv' DELIMITER ',' CSV HEADER"

psql -U postgres

drop table if exists top_rated_tags;

WITH top_rated as (
Select movieid as top_rated_movieid,
	avg (rating) as avg_rating
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

\q


psql -c "\copy (select * from top_rated_tags) to 'top_rated_tags.csv' with csv header delimiter as E'\t';"