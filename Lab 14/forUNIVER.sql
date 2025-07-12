use UNIVER;
go
-- 1 --
Drop FUNCTION if EXISTS COUNT_STUDENTS
go
CREATE FUNCTION COUNT_STUDENTS(@faculty varchar(20)) returns int
as 
begin
	declare @count int = (select count(*) from FACULTY f inner join GROUPS g on g.FACULTY = f.FACULTY inner join STUDENT s on s.IDGROUP = g.IDGROUP where f.FACULTY = @faculty)
	return @count;
end
go

declare @faculty varchar(20) = 'ИТ'
declare @count int = dbo.Count_Students(@faculty)
print 'Количество студентов на факультете ' + @faculty + ' = ' + cast(@count as varchar(10))
go


Alter FUNCTION COUNT_STUDENTS(@faculty varchar(20), @prof varchar(20)) returns int
as 
begin
	declare @count int = (select count(*) from FACULTY f inner join GROUPS g on g.FACULTY = f.FACULTY inner join STUDENT s on s.IDGROUP = g.IDGROUP where f.FACULTY = @faculty and g.PROFESSION = @prof)
	return @count;
end
go

declare @faculty varchar(20) = 'ИТ', @prof varchar(20) = '1-36 06 01'
declare @count int = dbo.Count_Students(@faculty, @prof)
print 'Количество студентов на факультете ' + @faculty + ', количество студентов с номером специальности' + @prof + ' = ' + cast(@count as varchar(10))
select distinct f.FACULTY, g.PROFESSION, dbo.COUNT_STUDENTS(f.FACULTY, g.PROFESSION) as Counts from FACULTY f inner join GROUPS g on g.FACULTY = f.FACULTY
go

-- 2 --

DROP FUNCTION IF EXISTS FSUBJECTS
go
CREATE FUNCTION FSUBJECTS(@p varchar(20)) returns varchar(300)
as 
begin
	declare @subjects varchar(300) = '', @buf varchar(20)
	declare curs CURSOR LOCAL STATIC for select s.SUBJECT from SUBJECT s where s.PULPIT = @p
	OPEN curs
		fetch curs into @buf
		while @@FETCH_STATUS = 0
		begin
			set @subjects = RTRIM(@buf) + ', ' + @subjects
			fetch curs into @buf
		end
		if (@subjects is null or @subjects = '') set @subjects = 'Дисциплины.'
		else
		begin
			set @subjects = 'Дисциплины: ' + substring(@subjects, 1, len(@subjects) - 1)
		end
	Close curs
	return @subjects;
end
go

select p.PULPIT, dbo.FSUBJECTS(p.PULPIT) as Subjects from PULPIT p;
go

-- 3 --

DROP FUNCTION IF EXISTS FFACPUL
go
CREATE FUNCTION FFACPUL(@faculty varchar(20), @pulpit varchar(20)) returns table
as return
select f.FACULTY, p.PULPIT from Faculty f left outer join PULPIT p on f.FACULTY = p.FACULTY 
where f.FACULTY = isnull(@faculty, f.FACULTY) and p.PULPIT = isnull(@pulpit, p.PULPIT)
go

select * from dbo.FFACPUL(null, null)
select * from dbo.FFACPUL('ИТ', null)
select * from dbo.FFACPUL(null, 'ИСиТ')
select * from dbo.FFACPUL('ИТ', 'ИСиТ')
select * from dbo.FFACPUL('ТОВ', 'ОХ')
go

-- 4 --

DROP FUNCTION IF EXISTS FCTEACHER
go
CREATE FUNCTION FCTEACHER(@pulpit varchar(20)) returns int
as
begin
	declare @count int = (select count(*) from TEACHER t where t.PULPIT = isnull(@pulpit, t.PULPIT))
	return @count
end
go

select p.PULPIT, dbo.FCTEACHER(p.PULPIT) as [количество преподавателей] from PULPIT p

select dbo.FCTEACHER(NULL)[Всего преподавателей]
go
-- 6 --
CREATE FUNCTION COUNT_PULPITS(@faculty varchar(30))
RETURNS int
AS
BEGIN
    DECLARE @count int;
    SELECT @count = COUNT(*) FROM PULPIT WHERE FACULTY = @faculty;
    RETURN @count;
END;
go
CREATE FUNCTION COUNT_GROUPS(@faculty varchar(50)) returns int
as
begin
declare @count int;
select @count = COUNT(*) from GROUPS where FACULTY= @faculty;
return @count;
end;
go
CREATE FUNCTION COUNT_PROFESSIONS(@faculty varchar(30))
RETURNS int
AS
BEGIN
    DECLARE @count int;
    SELECT @count = COUNT(*) FROM PROFESSION WHERE FACULTY = @faculty;
    RETURN @count;
END
go
DROP FUNCTION IF EXISTS FACULTY_REPORT;
GO
CREATE FUNCTION FACULTY_REPORT(@c int) 
RETURNS @fr TABLE (
    [Факультет] varchar(50),
    [Количество кафедр] int,
    [Количество групп] int,
    [Количество студентов] int,
    [Количество специальностей] int
)
AS 
BEGIN 
    DECLARE cc CURSOR STATIC FOR 
        SELECT FACULTY FROM FACULTY 
        WHERE dbo.COUNT_STUDENTS(FACULTY) > @c;
    
    DECLARE @f varchar(30);
    OPEN cc;  
    FETCH cc INTO @f;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT @fr VALUES(
            @f,
            dbo.COUNT_PULPITS(@f),          
            dbo.COUNT_GROUPS(@f),           
            dbo.COUNT_STUDENTS(@f),
            dbo.COUNT_PROFESSIONS(@f)     );
        FETCH cc INTO @f;  
    END;
    
    CLOSE cc;
    DEALLOCATE cc;
    RETURN; 
END;
go
select * from dbo.FACULTY_REPORT(10);