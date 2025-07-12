--  1 --
use UNIVER
go
Drop table if exists TR_AUDIT
go
CREATE table TR_AUDIT(
	ID int identity,
	STMT varchar(20) check(STMT in('INS', 'DEL', 'UPD')),
	TRNAME varchar(50),
	CC varchar(300)
)
go

select * from TEACHER
go

DROP TRIGGER IF EXISTS TR_TEACHER_INS
go
CREATE TRIGGER TR_TEACHER_INS on TEACHER after INSERT
as
declare @a1 varchar(10), @a2 varchar(100), @a3 char(1), @a4 varchar(20), @cc varchar(300)
set @a1 = (select TEACHER from inserted)
set @a2 = (select TEACHER_NAME from inserted)
set @a3 = (select GENDER from inserted)
set @a4 = (select PULPIT from inserted)
set @cc = rtrim(rtrim(@a1) + ', ' + rtrim(@a2) + ', ' + @a3 + ', ' + rtrim(@a4))
insert into TR_AUDIT(STMT, TRNAME, CC) values ('INS', 'TR_TEACHER_INS', @cc)
return
go

insert into TEACHER values('БНИ', 'Белодед Николай Ивановия', 'м', 'ПИ')
go

select * from TR_AUDIT

delete from TEACHER where TEACHER = 'БНИ'
delete from TR_AUDIT where STMT = 'INS'
go

-- 2 --

DROP TRIGGER IF EXISTS TR_TEACHER_DEL
go
CREATE TRIGGER TR_TEACHER_DEL on TEACHER after DELETE
as
declare @a1 varchar(10), @a2 varchar(100), @a3 char(1), @a4 varchar(20), @cc varchar(300)
set @a1 = (select TEACHER from deleted)
set @a2 = (select TEACHER_NAME from deleted)
set @a3 = (select GENDER from deleted)
set @a4 = (select PULPIT from deleted)
set @cc = rtrim(rtrim(@a1) + ', ' + rtrim(@a2) + ', ' + @a3 + ', ' + rtrim(@a4))
insert into TR_AUDIT(STMT, TRNAME, CC) values ('DEL', 'TR_TEACHER_DEL', @cc)
return
go

delete from TEACHER where TEACHER = 'БНИ'

select * from TR_AUDIT

delete from TR_AUDIT where STMT = 'DEL'
go

-- 3 --

DROP TRIGGER IF EXISTS TR_TEACHER_UPD
go
CREATE TRIGGER TR_TEACHER_UPD on TEACHER after UPDATE
as
declare @a1 varchar(10), @a2 varchar(100), @a3 char(1), @a4 varchar(20), @cc varchar(300),
 @a5 varchar(10), @a6 varchar(100), @a7 char(1), @a8 varchar(20)
set @a1 = (select TEACHER from deleted)
set @a2 = (select TEACHER_NAME from deleted)
set @a3 = (select GENDER from deleted)
set @a4 = (select PULPIT from deleted)
set @a5 = (select TEACHER from inserted)
set @a6 = (select TEACHER_NAME from inserted)
set @a7 = (select GENDER from inserted)
set @a8 = (select PULPIT from inserted)
set @cc = rtrim('ДО: ' + rtrim(@a1) + ', ' + rtrim(@a2) + ', ' + @a3 + ', ' + rtrim(@a4) + char(10) + 'ПОСЛЕ: ' + rtrim(@a5) + ', ' + rtrim(@a6) + ', ' + @a7 + ', ' + rtrim(@a8))
insert into TR_AUDIT(STMT, TRNAME, CC) values ('UPD', 'TR_TEACHER_UPD', @cc)
return
go

update TEACHER set TEACHER = 'БНИ_UPD' where TEACHER = 'БНИ'

select * from TR_AUDIT

delete from TR_AUDIT

-- 4 --

DROP TRIGGER IF EXISTS TR_TEACHER
go
CREATE TRIGGER TR_TEACHER on TEACHER after INSERT, DELETE, UPDATE
as
declare @a1 varchar(10), @a2 varchar(100), @a3 char(1), @a4 varchar(20), @cc varchar(300),
 @a5 varchar(10), @a6 varchar(100), @a7 char(1), @a8 varchar(20),
@inserted_count int = (select count(*) from inserted),
@deleted_count int = (select count(*) from deleted)
if @inserted_count > 0 and @deleted_count = 0
begin
	set @a1 = (select TEACHER from inserted)
	set @a2 = (select TEACHER_NAME from inserted)
	set @a3 = (select GENDER from inserted)
	set @a4 = (select PULPIT from inserted)
	set @cc = rtrim(rtrim(@a1) + ', ' + rtrim(@a2) + ', ' + @a3 + ', ' + rtrim(@a4))
	insert into TR_AUDIT(STMT, TRNAME, CC) values ('INS', 'TR_TEACHER', @cc)
end
else if @inserted_count = 0 and @deleted_count > 0
begin
	set @a1 = (select TEACHER from deleted)
	set @a2 = (select TEACHER_NAME from deleted)
	set @a3 = (select GENDER from deleted)
	set @a4 = (select PULPIT from deleted)
	set @cc = rtrim(rtrim(@a1) + ', ' + rtrim(@a2) + ', ' + @a3 + ', ' + rtrim(@a4))
	insert into TR_AUDIT(STMT, TRNAME, CC) values ('DEL', 'TR_TEACHER', @cc)
end
else
begin
	set @a1 = (select TEACHER from deleted)
	set @a2 = (select TEACHER_NAME from deleted)
	set @a3 = (select GENDER from deleted)
	set @a4 = (select PULPIT from deleted)
	set @a5 = (select TEACHER from inserted)
	set @a6 = (select TEACHER_NAME from inserted)
	set @a7 = (select GENDER from inserted)
	set @a8 = (select PULPIT from inserted)
	set @cc = rtrim('ДО: ' + rtrim(@a1) + ', ' + rtrim(@a2) + ', ' + @a3 + ', ' + rtrim(@a4) + char(10) + 'ПОСЛЕ: ' + rtrim(@a5) + ', ' + rtrim(@a6) + ', ' + @a7 + ', ' + rtrim(@a8))
	insert into TR_AUDIT(STMT, TRNAME, CC) values ('UPD', 'TR_TEACHER', @cc)
end
return;
go

insert into TEACHER values('БНИ', 'Белодед Николай Ивановия', 'м', 'ПИ')

update TEACHER set TEACHER = 'БНИ_UPD' where TEACHER = 'БНИ'

delete from TEACHER where TEACHER = 'БНИ_UPD'

select * from TR_AUDIT

delete from TR_AUDIT


-- 5 --
select * from TEACHER

update TEACHER set GENDER = '0'

select * from TR_AUDIT


-- 6 --

DROP TRIGGER IF EXISTS TR_TEACHER_DEL1
go
CREATE TRIGGER TR_TEACHER_DEL1 on TEACHER after DELETE
as 
print 'TR_TEACHER_DEL1'
return
go

DROP TRIGGER IF EXISTS TR_TEACHER_DEL2
go
CREATE TRIGGER TR_TEACHER_DEL2 on TEACHER after DELETE
as 
print 'TR_TEACHER_DEL2'
return
go

DROP TRIGGER IF EXISTS TR_TEACHER_DEL3
go
CREATE TRIGGER TR_TEACHER_DEL3 on TEACHER after DELETE
as 
print 'TR_TEACHER_DEL3'
return
go


select tr.name, tr_e.type_desc from 
sys.triggers tr inner join sys.trigger_events tr_e
on tr.object_id = tr_e.object_id 
where OBJECT_NAME(tr.parent_id) = 'TEACHER' and tr_e.type_desc = 'DELETE'
go

DROP TRIGGER IF EXISTS TR_TEACHER_DEL 
DROP TRIGGER IF EXISTS TR_TEACHER

exec sp_settriggerorder @triggername = 'TR_TEACHER_DEL3',
	@order = 'First', @stmttype = 'DELETE'
exec sp_settriggerorder @triggername = 'TR_TEACHER_DEL2',
	@order = 'Last', @stmttype = 'DELETE'
go

select * from sys.triggers

select * from sys.trigger_event_types

select tr.name, tr_e.type_desc from 
sys.triggers tr inner join sys.trigger_events tr_e
on tr.object_id = tr_e.object_id 
where OBJECT_NAME(tr.parent_id) = 'TEACHER' and tr_e.type_desc = 'DELETE'
go

-- 7 --

select * from TEACHER

DROP TRIGGER IF EXISTS TR_TEACHER_TEST
go
CREATE TRIGGER TR_TEACHER_TEST on TEACHER AFTER INSERT
as 
declare @count int = (select count(*) from TEACHER)
if @count >= 20
begin
	raiserror('КОЛИЧЕСТВО УЧИТЕЛЕЙ НЕ МОЖЕТ БЫТЬ БОЛЬШЕ 19', 10, 1)
	rollback;
end
return

insert into TEACHER values('БНИ', 'Белодед Николай Ивановия', 'м', 'ПИ')
go

-- 8 --

select * from TEACHER

DROP TRIGGER IF EXISTS TR_FACULTY 
go
CREATE TRIGGER TR_FACULTY on FACULTY INSTEAD OF DELETE
as
raiserror('Запрещено удаление строк в таблице FACULTY', 10, 1)
return
go

DROP TRIGGER IF EXISTS TR_FACULTY_CHECK_CONST 
go
CREATE TRIGGER TR_FACULTY_CHECK_CONST on TEACHER INSTEAD OF INSERT
as
print 'Проверка ограничения целостности выполнена'
return


insert into TEACHER values('ооо', 'аааа', '0', '5')

select * from sys.triggers

DROP TRIGGER IF EXISTS TR_TEACHER_INS
go
DROP TRIGGER IF EXISTS TR_TEACHER_DEL
go
DROP TRIGGER IF EXISTS TR_TEACHER_UPD
go
DROP TRIGGER IF EXISTS TR_TEACHER_DEL1
go
DROP TRIGGER IF EXISTS TR_TEACHER_DEL2
go
DROP TRIGGER IF EXISTS TR_TEACHER_DEL3
go
DROP TRIGGER IF EXISTS TR_FACULTY
go
DROP TRIGGER IF EXISTS TR_FACULTY_CHECK_CONST
go

-- 9 --

DROP TRIGGER IF EXISTS DDL_UNIVER
go
CREATE TRIGGER DDL_UNIVER on database
for CREATE_TABLE, DROP_TABLE as
declare @t varchar(max) = EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(50)');
declare @t1 varchar(max) = EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(50)');
declare @t2 varchar(max) = EVENTDATA().value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(50)');
       print 'Тип события: '+@t;
       print 'Имя объекта: '+@t1;
       print 'Тип объекта: '+@t2;
       raiserror( N'Операции удаления и добавления таблиц в бд UNIVER запрещены', 16, 1);  
       rollback;    
 
return
CREATE TABLE TEST2(ID int primary key)
DROP TABLE TEST2