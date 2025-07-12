--1
use	UNIVER
exec SP_HELPINDEX'AUDITORIUM_TYPE'
exec SP_HELPINDEX'AUDITORIUM'
exec SP_HELPINDEX'FACULTY'
exec SP_HELPINDEX'GROUPS'
exec SP_HELPINDEX'PROFESSION'
exec SP_HELPINDEX'PROGRESS'
exec SP_HELPINDEX'PULPIT'
exec SP_HELPINDEX'STUDENT'
exec SP_HELPINDEX'SUBJECT'
exec SP_HELPINDEX'TEACHER'
create table #tempTable (num int);
declare @i int =1;
while @i <= 1000
begin
insert into #tempTable (num)
values (abs(checksum(newid()))%1000);
set @i = @i+1;
end;
select * from #tempTable;
create clustered index #tempTable_cl on #tempTable(num asc);
select * from #tempTable order by num;
drop table #tempTable;

--2
CREATE TABLE #EXTABLE (TKEY int, xx int identity(1,1), TR varchar(100));
set nocount on;
declare @r int = 0;
while @r <10000
begin
insert into #EXTABLE(TKEY,TR) values(floor(10000*rand()),REPLICATE('строка',1));
set @r = @r +1;
end;
select count(*) [количество строк] from #EX;
select * from #EXTABLE;
create index #EX_NINCLU ON #EXTABLE(TKEY, TR);
select * from #EXTABLE where TKEY > 3000 and TKEY < 4500 order by TKEY;
drop table #EXTABLE;
--3
create table #temptb (tind int, tvalue nvarchar(10));
set nocount on;
declare @x int = 0;
while @x<100000
begin
insert into #temptb(tind, tvalue) values (floor(1000*rand()), replicate('строка', 1));
set @x = @x + 1;
end;
select * from #temptb;
create index #temptb_tind_x on #temptb(tind) include (tvalue)
select * from #temptb where tind > 9000;
drop table #temptb;

/*4*/
create table #tempT (id int, name nvarchar(10));
set nocount on;
declare @xx int = 0;
while @xx < 1000000
begin
insert into #tempT(id, name) values (floor(1000*rand()), replicate('строка', 1));
set @xx = @xx + 1;
end;
select * from #tempT;
create index #tempT_where on #tempT(id) where (id >= 1000 and id <= 50000);
select * from #tempT where id between 1000 and 50000;
drop table #tempT;

/*5*/
create table #ex_temp (years int, sname nvarchar(10));

set nocount on;
declare @y int = 0;
while @y < 1000
begin
insert into #ex_temp(years, sname) values (floor(1000 * rand()), replicate('строка  ', 1));
set @y = @y + 1;
end;

select * from  #ex_temp;

create index #ex_temp_years on #ex_temp(years);

select index_id, 
avg_fragmentation_in_percent [fragmentation (%)] 
from sys.dm_db_index_physical_stats(
db_id('tempdb'),
object_id('tempdb..#ex_temp'),
null, null, 'detailed')
order by index_id asc;

declare @yy int = 0;
while @yy < 1000
begin
update #ex_temp
set years = years + 1
where years % 2 = 0;

delete from #ex_temp
where years % 3 = 0;

insert into #ex_temp (years, sname) 
values (floor(1000 * rand()), replicate('x', 5));

set @yy = @yy + 1;
end;

select * from #ex_temp;

select 
index_id, 
avg_fragmentation_in_percent [fragmentation (%)]
from sys.dm_db_index_physical_stats(
db_id('tempdb'),
object_id('tempdb..#ex_temp'),
null, null, 'detailed')
order by index_id asc;

alter index #ex_temp_years on #ex_temp reorganize;

select 
index_id, 
avg_fragmentation_in_percent [fragmentation (%)]
from sys.dm_db_index_physical_stats(
db_id('tempdb'),
object_id('tempdb..#ex_temp'),
null, null, 'detailed')
order by index_id asc;

alter index #ex_temp_years on #ex_temp rebuild with (online = off);

select 
index_id, 
avg_fragmentation_in_percent [fragmentation (%)]
from sys.dm_db_index_physical_stats(
db_id('tempdb'),
object_id('tempdb..#ex_temp'),
null, null, 'detailed')
order by index_id asc;

drop table #ex_temp;

/*6*/
create table #temp(tind int, tval nvarchar(10));
set nocount on;

declare @t int = 0;
while @t < 1000000
begin
insert into #temp(tind, tval) values (floor(1000*rand()), replicate('value', 1));
set @t = @t + 1;
end;

select * from #temp;

create nonclustered index #temp_tind on #temp(tind) with (fillfactor = 70)

select ii.name as [index], ss.avg_fragmentation_in_percent as [fragmentation (%)]
from sys.dm_db_index_physical_stats(db_id('tempdb'), object_id('#temp'), null, null, 'detailed') ss join sys.indexes ii
on ss.object_id = ii.object_id and ss.index_id = ii.index_id
where ii.name is not null;

select * from #temp;

drop table #temp;