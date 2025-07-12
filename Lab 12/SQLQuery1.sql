/*1*/
use G_MyBase;
set nocount on
if exists (select * from sys.objects where object_id = object_id(N'����������_������')) drop table ����������_������;
declare @c int, @flag char = 'c';
set implicit_transactions on
create table ����������_������(age int, fio nvarchar(30));
insert ����������_������ values (18, '�������� �.�.'), (19, '����������� �.�.'), (19, '���� �.�.'), (19, '�������� �.�.');
set @c = (select count(*) from ����������_������);
print '���������� ����� � ������� ' + cast(@c as varchar(2));
if @flag = 'c' commit;
else rollback;
set implicit_transactions off

if exists (select * from ����������_������) print '������� ����������_������ ����'
else print '������� ����������_������ ���';

/*2*/
use UNIVER;
begin try
begin tran
delete AUDITORIUM where AUDITORIUM_TYPE = '��';
insert AUDITORIUM values ('206-1', '��-�', 15, '206-1');
commit tran;
end try
begin catch
print '������: ' + case
when error_number() = 2627 and patindex('%AUDITORIUM%', error_message()) > 0 then '������������ ���������'
else '����������� ������: ' + cast(error_number() as varchar(5)) + error_message()
end;
if @@TRANCOUNT > 0 rollback tran;
end catch;

/*3*/
use UNIVER;
declare @point varchar(30);
begin try
begin tran
delete AUDITORIUM where AUDITORIUM_CAPACITY = 1;
set @point = 'p1'; save tran p1;
 insert AUDITORIUM values ('206-1', '��-�', 15, '206-1');
set @point = 'p2'; save tran p2;
insert AUDITORIUM values ('200-3', '��-�', 45, '200-3');
commit tran;
end try
begin catch
print '������: ' + case
when error_number() = 2627 and patindex('%AUDITORIUM%', error_message()) > 0 then '������������ ���������'
else '����������� ������: ' + cast(error_number() as varchar(5)) + error_message()
end;
if @@TRANCOUNT > 0
begin 
print '����������� �����: ' + @point;
rollback tran @point;
commit tran;
end;
end catch;

use UNIVER;
declare @point1 varchar(30);
begin try
begin tran
delete AUDITORIUM where AUDITORIUM_CAPACITY = 50;
set @point1 = 'p3';
save tran p3;
 insert AUDITORIUM values ('203-2', '��-�', 40, '206-1');
set @point1 = 'p4';
save tran p4;
update AUDITORIUM
set AUDITORIUM_CAPACITY = AUDITORIUM_CAPACITY + 10 where AUDITORIUM_TYPE like '%��%';
set @point1 = 'p5';
save tran p5;
commit tran;
print '��� ��������� ���������';
end try
begin catch
print '������: ' + case
when error_number() = 2627 and patindex('%AUDITORIUM%', error_message()) > 0 then '������������ ���������'
else '����������� ������: ' + cast(error_number() as varchar(5)) + ' ' + error_message()
end;
if @@TRANCOUNT > 0
begin
print '����������� �����: ' + @point1;
rollback tran;
print '��� ��������� ��������';
end
end catch;

/*4*/
use UNIVER;
set transaction isolation level READ UNCOMMITTED 
begin transaction 
select @@SPID, 'insert AUDITORIUM' '���������', * from AUDITORIUM 
                                                          where AUDITORIUM_CAPACITY = 15;
select @@SPID, 'update AUDITORIUM'  '���������',  AUDITORIUM_TYPE, 
                      AUDITORIUM_CAPACITY from AUDITORIUM   where AUDITORIUM_TYPE like '%��%';
commit;
begin transaction 
select @@SPID
insert AUDITORIUM values ('207-1','��', 98, 207-1); 
update AUDITORIUM set AUDITORIUM_TYPE = '%������������%' 
                       where AUDITORIUM_TYPE= '%��%' 
rollback;

/*5*/
USE UNIVER;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
SELECT '������ ������', COUNT(*) AS '���������� ������ > 5' FROM PROGRESS WHERE NOTE > 5;
SELECT '������ ������', COUNT(*) AS '���������� ������ > 5' FROM PROGRESS WHERE NOTE > 5;
SELECT '������ ������', COUNT(*) AS '���������� ������ > 5' FROM PROGRESS WHERE NOTE > 5;
COMMIT TRANSACTION;

USE UNIVER;
BEGIN TRANSACTION;
UPDATE PROGRESS SET NOTE = NOTE + 1 WHERE NOTE = 5;
SELECT 'UPDATE ��������', COUNT(*) FROM PROGRESS WHERE NOTE > 5;
INSERT INTO PROGRESS VALUES('��', 1000, '2013-01-10', 6);
SELECT 'INSERT ��������', COUNT(*) FROM PROGRESS WHERE NOTE > 5;
COMMIT TRANSACTION;
/*6*/
USE UNIVER;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;
SELECT 'REPEATABLE READ - ������ ������', COUNT(*) AS '���������� ������ > 5' 
FROM PROGRESS WHERE NOTE > 5;
SELECT 'REPEATABLE READ - ������ ������', COUNT(*) AS '���������� ������ > 5' 
FROM PROGRESS WHERE NOTE > 5;
SELECT 'REPEATABLE READ - �������� ��������', * 
FROM PROGRESS WHERE NOTE > 5 AND NOT EXISTS (
    SELECT 1 FROM PROGRESS p WHERE p.NOTE > 5 
    AND p.IDSTUDENT = PROGRESS.IDSTUDENT 
    AND p.SUBJECT = PROGRESS.SUBJECT
);
COMMIT TRANSACTION;

USE UNIVER;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
UPDATE PROGRESS SET NOTE = 6 WHERE NOTE = 5 AND IDSTUDENT = 101;
SELECT 'READ COMMITTED - UPDATE ��������', COUNT(*) 
FROM PROGRESS WHERE NOTE > 5;
INSERT INTO PROGRESS VALUES('��', 9999, GETDATE(), 6);
SELECT 'READ COMMITTED - INSERT ��������', COUNT(*) 
FROM PROGRESS WHERE NOTE > 5;
COMMIT TRANSACTION;

/*7*/
USE UNIVER;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
SELECT 'SERIALIZABLE - ������ ����������', COUNT(*) AS '������ > 5' 
FROM PROGRESS WHERE NOTE > 5;

SELECT 'SERIALIZABLE - ��������� ������', COUNT(*) AS '������ > 5' 
FROM PROGRESS WHERE NOTE > 5;

SELECT 'SERIALIZABLE - ����� ��������', * 
FROM PROGRESS 
WHERE NOTE > 5 
AND NOT EXISTS (
    SELECT 1 FROM PROGRESS p 
    WHERE p.IDSTUDENT = PROGRESS.IDSTUDENT 
    AND p.SUBJECT = PROGRESS.SUBJECT
    AND p.NOTE > 5
);

COMMIT TRANSACTION;
USE UNIVER;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;

UPDATE PROGRESS SET NOTE = 6 
WHERE NOTE = 5 AND IDSTUDENT = 101;
SELECT 'READ COMMITTED - ������� ������', @@ROWCOUNT;

INSERT INTO PROGRESS VALUES('��', 9999, GETDATE(), 6);
SELECT 'READ COMMITTED - ������� ����� ������', @@ROWCOUNT;

SELECT 'READ COMMITTED - ��� ������', COUNT(*) 
FROM PROGRESS WHERE NOTE > 5;

COMMIT TRANSACTION;
/*8*/
USE UNIVER;
GO

BEGIN TRANSACTION;
PRINT '������. �������: ' + CAST(@@TRANCOUNT AS VARCHAR);

INSERT INTO PROGRESS VALUES ('���', 200, GETDATE(), 7);
PRINT '������ ���������';

BEGIN TRANSACTION;
PRINT '���������. �������: ' + CAST(@@TRANCOUNT AS VARCHAR);

UPDATE PROGRESS SET NOTE = 10 WHERE IDSTUDENT = 200;
PRINT '������ ��������';

ROLLBACK TRANSACTION;
PRINT '�����. �������: ' + CAST(@@TRANCOUNT AS VARCHAR);

SELECT * FROM PROGRESS WHERE IDSTUDENT = 200;
GO