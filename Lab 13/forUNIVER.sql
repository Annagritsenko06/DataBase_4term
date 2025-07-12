--  1 --
use UNIVER;
go
DROP PROCEDURE IF EXISTS PSUBJECT
go
Create PROCEDURE PSUBJECT
as
begin
declare @count int = (select count(*) from SUBJECT);
select s.SUBJECT[код], s.SUBJECT_NAME[дисциплина], s.PULPIT[кафедра] from SUBJECT s;
return @count;
end;

declare @c int;
exec @c = PSUBJECT;
print 'Количество предметов = ' + cast(@c as varchar(5))


-- 2 --
go
USE UNIVER;
GO
ALTER PROCEDURE [dbo].[PSUBJECT] @p varchar(20) = null, @c int output
as
begin
declare @count int = (select count(*) from SUBJECT);
select s.SUBJECT[код], s.SUBJECT_NAME[дисциплина], s.PULPIT[кафедра] from SUBJECT s where s.PULPIT = @p;
set @c = @@ROWCOUNT
return @count;
end;
go
declare @k int = 0, @rc int = 0, @p varchar(20) = 'ИСиТ'
exec @k = PSUBJECT @p = @p, @c = @rc output;
print 'Общее количество предметов = ' + cast(@k as varchar(5))
print 'Количесвто предметов на кафедре ' + @p + ' = ' + cast(@rc as varchar(5))

-- 3 --
USE UNIVER;
GO
ALTER PROCEDURE [dbo].[PSUBJECT] @p varchar(20)
as
begin
declare @count int = (select count(*) from SUBJECT);
select s.SUBJECT[код], s.SUBJECT_NAME[дисциплина], s.PULPIT[кафедра] from SUBJECT s where s.PULPIT = @p;
end;
go

DROP TABLE IF EXISTS #SUBJECT
go
Create table #SUBJECT(
КОД char(10) primary key,
ДИСЦИПЛИНА varchar(100),
КАФЕДРА char(20)
)
go
insert #SUBJECT exec PSUBJECT @p = 'ИСиТ'
select * from #SUBJECT

-- 4 --
select * from AUDITORIUM; 

go
drop procedure if exists PAUDITORIUM_INSERT
go
Create PROCEDURE PAUDITORIUM_INSERT @a char(20), @n varchar(50), @c int = 0, @t char(10)
as
begin try
	insert into AUDITORIUM values(@a, @t, @c, @n);
	return 1;
end try
begin catch
	print 'НОМЕР ОШИБКИ = ' + cast(error_number() as varchar(5));
	print 'УРОВЕНЬ = ' + cast(error_severity() as varchar(10));
	print 'СООБЩЕНИЕ: ' + error_message();
	return -1;
end catch
go

declare @rc int;
exec @rc = PAUDITORIUM_INSERT @a = '308-1', @n = '309-1', @c = 15, @t = 'ЛК'
delete from AUDITORIUM where AUDITORIUM = '308-1'

-- 5 --
go 
DROP PROCEDURE IF EXISTS SUBJECT_REPORT
go
CREATE PROCEDURE SUBJECT_REPORT @p char(10)
as
begin try
	declare @buf varchar(100) = '', @curSubj varchar(10) = '', @count int = 0
	declare subjects CURSOR LOCAL for select s.SUBJECT from SUBJECT s where s.PULPIT = @p;
	if not exists(select s.SUBJECT from SUBJECT s where s.PULPIT = @p) raiserror('НИЧЕГО НЕ НАЙДЕНО', 11, 1)
	else
		begin
			OPEN subjects
			fetch subjects into @curSubj
			while @@FETCH_STATUS = 0
			begin
				set @buf = RTRIM(@curSubj) + ',' + @buf;
				set @count += 1;
				fetch subjects into @curSubj
			end
			set @buf = SUBSTRING(@buf, 1, LEN(@buf) - 1)
			print @buf
			close subjects
			return @count
		end
end try
begin catch
	print 'ОШИБКА: ' + error_message()
	return @count
end catch

go

declare @rc int
exec @rc = SUBJECT_REPORT @p = 'ИСиТ';
print 'КОЛИЧЕСТВО ПРЕДМЕТОВ = ' + cast(@rc as varchar(5))

-- 6 ---

go
DROP PROCEDURE IF EXISTS PAUDITORIUM_INSERTX
go
CREATE PROCEDURE PAUDITORIUM_INSERTX @a char(20), @n varchar(50), @c int = 0, @t char(10), @tn varchar(50)
as
begin try
	declare @rc int = 1
	set transaction isolation level SERIALIZABLE
	begin tran
		insert into AUDITORIUM_TYPE values(@t, @tn)
		exec @rc = PAUDITORIUM_INSERT @a, @n, @c, @t
		commit tran
		return @rc
end try
begin catch
	print 'НОМЕР ОШИБКИ = ' + cast(error_number() as varchar(10));
	print 'СООБЩЕНИЕ: ' + error_message()
	if @@TRANCOUNT > 0 rollback tran;
	return -1
end catch

go

declare @rc int
exec @rc = PAUDITORIUM_INSERTX @a = '308-1', @n = '308-1', @c = 15, @t = 'ЛБ', @tn = 'ЛАБОРАТОРИЯ'

select * from AUDITORIUM_TYPE

select * from AUDITORIUM

delete from AUDITORIUM where AUDITORIUM_TYPE = 'ЛБ'
delete from AUDITORIUM_TYPE where AUDITORIUM_TYPE = 'ЛБ'
