/*1*/
use G_MyBase;
declare @tv nvarchar(30), @t char(300) ='';
declare zkTovar cursor for select ��������_������ from ������� where �����������_����� >200;
open zkTovar;
fetch zkTovar into @tv;
print '������ �������';
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
use G_MyBase;
declare Subjects cursor local for select ��������_������, �������� from ������� ;
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
use G_MyBase;
declare Subjects1 cursor global for select ��������_������, �������� from ������� ;
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
use G_MyBase;
declare @name nvarchar(30), @sum int;
declare SubjectName cursor local static
for select ��������_������, ����������_����������� from ������ where ����������_����������� >5;
open SubjectName;
fetch next from SubjectName into @name, @mark;
while @@FETCH_STATUS = 0
begin
print '�� ���������: ' + @name + ' ' + cast(@mark as nvarchar(10));
fetch next from SubjectName into @name, @mark;
end;

update dbo.������ set ����������_����������� =15 where ��������_������ Like '%����� ������%';
close SubjectName;

open SubjectName ;
fetch next from SubjectName  into @name, @mark;
print '������ ������� �����������';
while @@FETCH_STATUS = 0
begin
print '����� ���������: ' + @name + ' ' + cast(@mark as nvarchar(10));
fetch next from SubjectName  into @name, @mark;
end;
close SubjectName ;
deallocate SubjectName ;
/*4*/
use G_MyBase;
declare @tc int, @rn char(50);
declare Primer1 cursor local dynamic scroll
for select row_number() over (order by  ��������_������) N, ����������_�����
from dbo.������  where ����������_�����>100;
open Primer1;
fetch Primer1 into @tc, @rn;
print '��������� ������ : ' + cast(@tc as varchar(3)) + rtrim(@rn);
fetch last from Primer1 into @tc, @rn;
print '��������� ������ : ' + cast(@tc as varchar(3)) + rtrim(@rn);
fetch first from Primer1 into @tc, @rn;
print '������ ������ : ' + cast(@tc as varchar(3)) + rtrim(@rn);
fetch next from Primer1 into @tc, @rn;
print '��������� ������ �� ������� : ' + cast(@tc as varchar(3)) + rtrim(@rn);
fetch prior from Primer1 into @tc, @rn;
print '���������� ������ �� ������� : ' + cast(@tc as varchar(3)) + rtrim(@rn);
fetch absolute 2 from Primer1 into @tc, @rn;
print '������ ������ �� ������ : ' + cast(@tc as varchar(3)) + rtrim(@rn);
fetch absolute -1 from Primer1 into @tc, @rn;
print '������ ������ �� ����� : ' + cast(@tc as varchar(3)) + rtrim(@rn);
fetch relative 2 from Primer1 into @tc, @rn;
print '������ ������ ������ �� ������� : ' + cast(@tc as varchar(3)) + rtrim(@rn);
fetch relative -1 from Primer1 into @tc, @rn;
print '������ ������ ����� �� ������� : ' + cast(@tc as varchar(3)) + rtrim(@rn);
close Primer1;
deallocate Primer1;
/*5*/
use G_MyBase;
declare progress_cursor cursor for
select ��������_������,  ����������_����������� from dbo.������ where ����������_�����������>9 for update;
open progress_cursor;
declare @subject nvarchar(100);
declare @note int;
fetch next from progress_cursor into @subject, @note;
while @@FETCH_STATUS = 0
begin
    if @note < 5
    begin
        update dbo.������ set ����������_�����������=29 where current of progress_cursor;
    end
    else
    begin
        delete from dbo.������ where current of progress_cursor;
    end
    fetch next from progress_cursor into @subject, @note;
end;
close progress_cursor;
deallocate progress_cursor;
select * from dbo.������; 
/*6.1*/
use G_MyBase;
DECLARE delete_cursor CURSOR LOCAL FOR SELECT p.ID_����������
FROM dbo.���������� p
JOIN dbo.������� s ON p.ID_���������� = s.ID_����������
WHERE p.��������_������ Like '%one%' for update;
OPEN delete_cursor;
DECLARE @IDSTUDENT INT;
FETCH NEXT FROM delete_cursor INTO @IDSTUDENT;
WHILE @@FETCH_STATUS = 0
BEGIN
    DELETE FROM dbo.���������� WHERE ID_���������� = @IDSTUDENT;
    FETCH NEXT FROM delete_cursor INTO @IDSTUDENT;
END;
CLOSE delete_cursor;
DEALLOCATE delete_cursor;
/*6.2*/
use G_MyBase;
DECLARE update_cursor CURSOR LOCAL 
FOR SELECT ID_���������� FROM dbo.���������� WHERE ID_���������� = 004 for update;  
OPEN update_cursor;
DECLARE @IDSTUDENT2 INT;
FETCH NEXT FROM update_cursor INTO @IDSTUDENT2;
WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE dbo.����������
    SET ��������_������ = '%����� �������� ��������%'
    WHERE CURRENT OF update_cursor;
    FETCH NEXT FROM update_cursor INTO @IDSTUDENT2;
END;
CLOSE update_cursor;
DEALLOCATE update_cursor;