--1
declare @c char = 'd', @va varchar='ttt', @dt datetime, @t time, @i int, @si smallint, @ti tinyint, @n numeric(12,5);
set @dt=GETDATE(); set @t='15:30:45:123';
set @i=1;
set @si=9; set @ti=0; 
set @n = 1234.6789;
select @dt=GETDATE(),  @t='15:30:45:123', @i=1,@si=9, @ti=0, @n = 1234.6789;
select @dt as dt,  @t as t, @i as i,@si as si, @ti as ti, @n as n;
print 'datetime=' +cast(@dt as varchar(50));
print 'time=' +cast(@t as varchar(50));
print 'int=' +cast(@i as varchar(50));
--2
declare @y1 numeric(8,3) = (select cast(sum(AUDITORIUM_CAPACITY) as numeric(8,3)) from AUDITORIUM),
@y2 real, @y3 numeric(8,3), @y4 real
if @y1>200
begin
select @y2 = (select cast(count(*) as numeric(8, 3)) from AUDITORIUM),
@y3 = (select cast(avg(AUDITORIUM_CAPACITY) as numeric(8,3)) from AUDITORIUM)
set @y4 = (select cast(count(*) as numeric(8,3)) from AUDITORIUM where AUDITORIUM_CAPACITY < @y3)
select @y1 'Общая вместимость', @y2 'Количество', @y3 'Средняя вместимость', @y4 'Кол-во аудиторий с вместимостью, выше средней'
end
else if @y1 < 200 print 'Общая вместимость аудиторий меньше 200'
--3
print 'количество обработанных строк: ' + cast(@@rowcount as varchar);
print 'версия SQL Server: ' + cast(@@version as varchar);
print 'системный идентификатор процесса, назначенный сервером текущему подключению: ' + cast (@@spid as varchar);
print 'код последней ошибки: ' + cast (@@error as varchar);
print 'имя сервера: ' + cast (@@servername as varchar);
print 'уровень вложенности транзакции: ' + cast (@@trancount as varchar);
print 'проверка результата считывания строк результирующего набора: ' + cast (@@fetch_status as varchar);
print 'уровень вложенности текущей процедуры: ' + cast (@@nestlevel as varchar);
--4
declare @z float, @t1 int, @x int;
set @t1 = 15;
set @x = 27;
if @t1>@x
begin
select @z = power(sin(@t1), 2);
print 'z = ' + cast(@z as varchar(20));
end
else if @t1<@x
begin
select @z = 4*(@t1 + @x);
print 'z = ' + cast(@z as varchar(20));
end
else if @t1=@x
begin
select 1-power(exp(4.96981), @x-2);
print 'z = ' + cast(@z as varchar(20));
end

declare @fullname nvarchar(50) = 'Гриценко Анна Александровна';
declare @fspace int = CHARINDEX(' ',@fullname);
declare @secspace int = CHARINDEX(' ',@fullname,@fspace + 1);
declare @surname nvarchar(20) = substring(@fullname, 1, @fspace -1);
declare @firstname nvarchar(20) = substring(@fullname, @fspace+1, 1);
declare @secondname nvarchar(20) = substring(@fullname, @secspace+1, 1);
declare @fio nvarchar(50) = @surname + ' ' + @firstname + '. ' + @secondname + '.';
print @fio;

DECLARE @studentdate int = MONTH(GETDATE()) + 1;
DECLARE @currentdate date = GETDATE();

SELECT 
    NAME as Student, 
    BDAY, 
    DATEDIFF(YEAR, BDAY, @currentdate) - 
    CASE 
        WHEN DATEADD(YEAR, DATEDIFF(YEAR, BDAY, @currentdate), BDAY) > @currentdate 
        THEN 1 
        ELSE 0 
    END as AGE
FROM STUDENT
WHERE MONTH(BDAY) = @studentdate;
select SUBJECT, day(PDATE) as DayOfExam
from PROGRESS
where SUBJECT Like'%БД%';
--5
declare @COUNT int = (select count(*) from STUDENT);
if (select count(*) from STUDENT) > 90
begin
print 'Количество студентов больше 90';
print 'Количество = ' + cast(@COUNT as varchar(10));
end
else
begin
print 'Количество студентов меньше 90';
print 'Количество = ' + cast(@COUNT as varchar(10));
end;
--6
select case 
when NOTE between 8 and 10 then 'ОТЛИЧНО'
when NOTE  between 6 and 7 then 'ХОРОШО'
when NOTE  between 4 and 5 then 'УДВЛ'
else 'НЕУД'
end ОЦЕНКИ, count(*) [Количество]
from dbo.PROGRESS
group by case 
when NOTE between 8 and 10 then 'ОТЛИЧНО'
when NOTE  between 6 and 7 then 'ХОРОШО'
when NOTE  between 4 and 5 then 'УДВЛ'
else 'НЕУД'
end;

--7
create table #explre
( tind int,
tfield varchar(100)
);

set nocount on;
declare @ii int = 0;
while @ii < 1000
begin
insert #explre(tind, tfield)
values(floor(30000*rand()), REPLICATE('строка', 10));
if (@ii % 100 = 0)
print @ii;
set @ii = @ii + 1;
end;

--8
declare @xx int = 1;
print @xx+1;
print @xx+2;
return
print @xx+3;

--9
begin try
update dbo.PROGRESS set NOTE = 'U'
where NOTE = 7
end try
begin catch
print error_number();
print error_message();
print error_line();
print error_procedure();
print error_severity();
print error_state();
end catch;