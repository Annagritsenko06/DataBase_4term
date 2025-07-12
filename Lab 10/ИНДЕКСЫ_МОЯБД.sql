--1
use	G_MyBase
exec SP_HELPINDEX'ОТДЕЛЫ'
exec SP_HELPINDEX'РАСХОДЫ'
exec SP_HELPINDEX'СОТРУДНИКИ'
--2

create index #tempTable_cl on ОТДЕЛЫ(Количество_сотрудников,Предельная_сумма);
select * from ОТДЕЛЫ where Количество_сотрудников > 2 order by Количество_сотрудников;

--3
create index #temptb_tind_x on ОТДЕЛЫ(Количество_сотрудников) include (Предельная_сумма);
select * from ОТДЕЛЫ where Предельная_сумма>100;


/*4*/

create index #tempT_where on РАСХОДЫ(Потраченная_сумма) where (Потраченная_сумма >= 1000 and Потраченная_сумма <= 50000);;
select * from РАСХОДЫ where Потраченная_сумма between 1000 and 50000;

