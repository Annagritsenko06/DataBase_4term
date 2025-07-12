/*1*/
use UNIVER;
declare @tv nvarchar(30), @t char(300) ='';
declare zkTovar cursor for select SUBJECT_NAME from SUBJECT where PULPIT Like '%ИСиТ%';
open zkTovar;
fetch zkTovar into @tv;
print 'Список дисциплин на кафедре ИСИТ';
while @@FETCH_STATUS = 0
begin
set @t = RTRIM(@tv) + ', ' + @t;
fetch zkTovar into @tv;
end;
print @t;
close zkTovar;
deallocate zkTovar;

/*2*/
/*local*/
use UNIVER;
declare Subjects cursor local for select SUBJECT_NAME,PULPIT from SUBJECT;
declare @sub char(30), @count int;
open Subjects;
fetch Subjects into @sub , @count;
print '1.' + @sub  + ' ' + cast(@count as varchar(3));
go
declare @sub char(30), @count int;
open Subjects;
fetch Subjects into @sub , @count;
print '2.' + @sub  + ' ' + cast(@count as varchar(3));
go
deallocate Subjects;

/*global*/
use UNIVER;
declare Subjects1 cursor global for select SUBJECT_NAME,PULPIT from SUBJECT;
declare @sub1 char(30), @count int;
open Subjects1;
fetch Subjects1 into @sub1 , @count;
print '1.' + @sub1  + ' ' + cast(@count as varchar(3));
go
declare @sub1 char(30), @count int;
open Subjects1;
fetch Subjects1 into @sub1 , @count;
print '2.' + @sub1 + ' ' + cast(@count as varchar(3));
close Subjects1;
deallocate Subjects1;
go

/*3*/
use UNIVER;
declare @name nvarchar(30), @sum int;
declare SubjectName cursor local static
for select SUBJECT,NOTE from PROGRESS where NOTE = 6;
open SubjectName;
fetch next from SubjectName into @name, @mark;
while @@FETCH_STATUS = 0
begin
print 'До изменений: ' + @name + ' ' + cast(@mark as nvarchar(10));
fetch next from SubjectName into @name, @mark;
end;

update dbo.PROGRESS set NOTE = 8 where SUBJECT Like '%КГ%';
close SubjectName;

open SubjectName ;
fetch next from SubjectName  into @name, @mark;
print 'Данные остаюся неизменными';
while @@FETCH_STATUS = 0
begin
print 'После изменений: ' + @name + ' ' + cast(@mark as nvarchar(10));
fetch next from SubjectName  into @name, @mark;
end;
close SubjectName ;
deallocate SubjectName ;
/*4*/
use UNIVER;
declare @tc int, @rn char(50);
declare Primer1 cursor local dynamic scroll
for select row_number() over (order by  SUBJECT) N, SUBJECT
from dbo.PROGRESS  where PDATE = '2013-12-01';
open Primer1;
fetch Primer1 into @tc, @rn;
print 'следующая строка : ' + cast(@tc as varchar(3)) + rtrim(@rn);
fetch last from Primer1 into @tc, @rn;
print 'последняя строка : ' + cast(@tc as varchar(3)) + rtrim(@rn);
fetch first from Primer1 into @tc, @rn;
print 'первая строка : ' + cast(@tc as varchar(3)) + rtrim(@rn);
fetch next from Primer1 into @tc, @rn;
print 'следующая строка за текущей : ' + cast(@tc as varchar(3)) + rtrim(@rn);
fetch prior from Primer1 into @tc, @rn;
print 'предыдущая строка от текущей : ' + cast(@tc as varchar(3)) + rtrim(@rn);
fetch absolute 2 from Primer1 into @tc, @rn;
print 'вторая строка от начала : ' + cast(@tc as varchar(3)) + rtrim(@rn);
fetch absolute -1 from Primer1 into @tc, @rn;
print 'первая строка от конца : ' + cast(@tc as varchar(3)) + rtrim(@rn);
fetch relative 2 from Primer1 into @tc, @rn;
print 'вторая строка вперед от текущей : ' + cast(@tc as varchar(3)) + rtrim(@rn);
fetch relative -1 from Primer1 into @tc, @rn;
print 'первая строка назад от текущей : ' + cast(@tc as varchar(3)) + rtrim(@rn);
close Primer1;
deallocate Primer1;
/*5*/
use UNIVER;
declare progress_cursor cursor for
select SUBJECT, NOTE from dbo.PROGRESS where SUBJECT = 'КГ' for update;
open progress_cursor;
declare @subject nvarchar(100);
declare @note int;
fetch next from progress_cursor into @subject, @note;
while @@FETCH_STATUS = 0
begin
    if @note < 5
    begin
        update dbo.PROGRESS set NOTE = 7 where current of progress_cursor;
    end
    else
    begin
        delete from dbo.PROGRESS where current of progress_cursor;
    end
    fetch next from progress_cursor into @subject, @note;
end;
close progress_cursor;
deallocate progress_cursor;
select * from dbo.PROGRESS; 
/*6.1*/
use UNIVER;
DECLARE delete_cursor CURSOR LOCAL FOR SELECT p.IDSTUDENT
FROM dbo.PROGRESS p
JOIN dbo.STUDENT s ON p.IDSTUDENT = s.IDSTUDENT
WHERE p.NOTE < 4 for update;
OPEN delete_cursor;
DECLARE @IDSTUDENT INT;
FETCH NEXT FROM delete_cursor INTO @IDSTUDENT;
WHILE @@FETCH_STATUS = 0
BEGIN
    DELETE FROM dbo.PROGRESS WHERE IDSTUDENT = @IDSTUDENT;
    FETCH NEXT FROM delete_cursor INTO @IDSTUDENT;
END;
CLOSE delete_cursor;
DEALLOCATE delete_cursor;
/*6.2*/
USE UNIVER;
DECLARE update_cursor CURSOR LOCAL 
FOR SELECT IDSTUDENT FROM dbo.PROGRESS WHERE IDSTUDENT = 1009 for update;  
OPEN update_cursor;
DECLARE @IDSTUDENT2 INT;
FETCH NEXT FROM update_cursor INTO @IDSTUDENT2;
WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE dbo.PROGRESS
    SET NOTE =NOTE + 1
    WHERE CURRENT OF update_cursor;
    FETCH NEXT FROM update_cursor INTO @IDSTUDENT2;
END;
CLOSE update_cursor;
DEALLOCATE update_cursor;