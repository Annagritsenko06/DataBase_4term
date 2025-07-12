/*1*/
use G_MyBase;
set nocount on
if exists (select * from sys.objects where object_id = object_id(N'Начальники_отдела')) drop table Начальники_отдела;
declare @c int, @flag char = 'c';
set implicit_transactions on
create table Начальники_отдела(age int, fio nvarchar(30));
insert Начальники_отдела values (18, 'Сергеева У.С.'), (19, 'Авчинникова Е.С.'), (19, 'Гриц Е.Е.'), (19, 'Ларченко В.В.');
set @c = (select count(*) from Начальники_отдела);
print 'количество строк в таблице ' + cast(@c as varchar(2));
if @flag = 'c' commit;
else rollback;
set implicit_transactions off

if exists (select * from Начальники_отдела) print 'таблица Начальники_отдела есть'
else print 'таблицы Начальники_отдела нет';

/*2*/
use UNIVER;
begin try
begin tran
delete AUDITORIUM where AUDITORIUM_TYPE = 'лк';
insert AUDITORIUM values ('206-1', 'ЛБ-К', 15, '206-1');
commit tran;
end try
begin catch
print 'ошибка: ' + case
when error_number() = 2627 and patindex('%AUDITORIUM%', error_message()) > 0 then 'дублирование АУДИТОРИИ'
else 'неизвестная ошибка: ' + cast(error_number() as varchar(5)) + error_message()
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
 insert AUDITORIUM values ('206-1', 'ЛБ-К', 15, '206-1');
set @point = 'p2'; save tran p2;
insert AUDITORIUM values ('200-3', 'ЛБ-К', 45, '200-3');
commit tran;
end try
begin catch
print 'ошибка: ' + case
when error_number() = 2627 and patindex('%AUDITORIUM%', error_message()) > 0 then 'дублирование аудитории'
else 'неизвестная ошибка: ' + cast(error_number() as varchar(5)) + error_message()
end;
if @@TRANCOUNT > 0
begin 
print 'контрольная точка: ' + @point;
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
 insert AUDITORIUM values ('203-2', 'ЛБ-К', 40, '206-1');
set @point1 = 'p4';
save tran p4;
update AUDITORIUM
set AUDITORIUM_CAPACITY = AUDITORIUM_CAPACITY + 10 where AUDITORIUM_TYPE like '%ЛК%';
set @point1 = 'p5';
save tran p5;
commit tran;
print 'все изменения сохранены';
end try
begin catch
print 'ошибка: ' + case
when error_number() = 2627 and patindex('%AUDITORIUM%', error_message()) > 0 then 'дублирование аудитории'
else 'неизвестная ошибка: ' + cast(error_number() as varchar(5)) + ' ' + error_message()
end;
if @@TRANCOUNT > 0
begin
print 'контрольная точка: ' + @point1;
rollback tran;
print 'вск изменения отменены';
end
end catch;

/*4*/
use UNIVER;
set transaction isolation level READ UNCOMMITTED 
begin transaction 
select @@SPID, 'insert AUDITORIUM' 'результат', * from AUDITORIUM 
                                                          where AUDITORIUM_CAPACITY = 15;
select @@SPID, 'update AUDITORIUM'  'результат',  AUDITORIUM_TYPE, 
                      AUDITORIUM_CAPACITY from AUDITORIUM   where AUDITORIUM_TYPE like '%ЛК%';
commit;
begin transaction 
select @@SPID
insert AUDITORIUM values ('207-1','ЛК', 98, 207-1); 
update AUDITORIUM set AUDITORIUM_TYPE = '%ЛАБОРАТОРНАЯ%' 
                       where AUDITORIUM_TYPE= '%ЛК%' 
rollback;

/*5*/
USE UNIVER;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
SELECT 'Первое чтение', COUNT(*) AS 'Количество оценок > 5' FROM PROGRESS WHERE NOTE > 5;
SELECT 'Второе чтение', COUNT(*) AS 'Количество оценок > 5' FROM PROGRESS WHERE NOTE > 5;
SELECT 'Третье чтение', COUNT(*) AS 'Количество оценок > 5' FROM PROGRESS WHERE NOTE > 5;
COMMIT TRANSACTION;

USE UNIVER;
BEGIN TRANSACTION;
UPDATE PROGRESS SET NOTE = NOTE + 1 WHERE NOTE = 5;
SELECT 'UPDATE выполнен', COUNT(*) FROM PROGRESS WHERE NOTE > 5;
INSERT INTO PROGRESS VALUES('КГ', 1000, '2013-01-10', 6);
SELECT 'INSERT выполнен', COUNT(*) FROM PROGRESS WHERE NOTE > 5;
COMMIT TRANSACTION;
/*6*/
USE UNIVER;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;
SELECT 'REPEATABLE READ - Первое чтение', COUNT(*) AS 'Количество оценок > 5' 
FROM PROGRESS WHERE NOTE > 5;
SELECT 'REPEATABLE READ - Второе чтение', COUNT(*) AS 'Количество оценок > 5' 
FROM PROGRESS WHERE NOTE > 5;
SELECT 'REPEATABLE READ - Проверка фантомов', * 
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
SELECT 'READ COMMITTED - UPDATE выполнен', COUNT(*) 
FROM PROGRESS WHERE NOTE > 5;
INSERT INTO PROGRESS VALUES('КГ', 9999, GETDATE(), 6);
SELECT 'READ COMMITTED - INSERT выполнен', COUNT(*) 
FROM PROGRESS WHERE NOTE > 5;
COMMIT TRANSACTION;

/*7*/
USE UNIVER;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
SELECT 'SERIALIZABLE - Начало транзакции', COUNT(*) AS 'Оценок > 5' 
FROM PROGRESS WHERE NOTE > 5;

SELECT 'SERIALIZABLE - Повторное чтение', COUNT(*) AS 'Оценок > 5' 
FROM PROGRESS WHERE NOTE > 5;

SELECT 'SERIALIZABLE - Поиск фантомов', * 
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
SELECT 'READ COMMITTED - Обновил записи', @@ROWCOUNT;

INSERT INTO PROGRESS VALUES('КГ', 9999, GETDATE(), 6);
SELECT 'READ COMMITTED - Вставил новую запись', @@ROWCOUNT;

SELECT 'READ COMMITTED - Мои данные', COUNT(*) 
FROM PROGRESS WHERE NOTE > 5;

COMMIT TRANSACTION;
/*8*/
USE UNIVER;
GO

BEGIN TRANSACTION;
PRINT 'Начало. Уровень: ' + CAST(@@TRANCOUNT AS VARCHAR);

INSERT INTO PROGRESS VALUES ('Физ', 200, GETDATE(), 7);
PRINT 'Запись добавлена';

BEGIN TRANSACTION;
PRINT 'Вложенная. Уровень: ' + CAST(@@TRANCOUNT AS VARCHAR);

UPDATE PROGRESS SET NOTE = 10 WHERE IDSTUDENT = 200;
PRINT 'Оценка изменена';

ROLLBACK TRANSACTION;
PRINT 'Откат. Уровень: ' + CAST(@@TRANCOUNT AS VARCHAR);

SELECT * FROM PROGRESS WHERE IDSTUDENT = 200;
GO