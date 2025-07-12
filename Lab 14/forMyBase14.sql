-- 1 --
USE G_MyBase;
GO
DROP FUNCTION IF EXISTS COUNT_SOTRUDNIKI;
GO
CREATE FUNCTION COUNT_SOTRUDNIKI(@otdel NVARCHAR(50)) RETURNS INT
AS 
BEGIN
    DECLARE @count INT = (SELECT COUNT(*) FROM СОТРУДНИКИ WHERE Название_отдела = @otdel);
    RETURN @count;
END;
GO
DECLARE @otdel NVARCHAR(50) = 'отдел маркетинга';
DECLARE @count INT = dbo.COUNT_SOTRUDNIKI(@otdel);
PRINT 'Количество сотрудников в отделе ' + @otdel + ' = ' + CAST(@count AS VARCHAR(10));
GO

ALTER FUNCTION COUNT_SOTRUDNIKI(
    @otdel NVARCHAR(50), 
    @min_sum DECIMAL(18,0) = NULL
) RETURNS INT
AS 
BEGIN
    DECLARE @count INT = (SELECT COUNT(*) 
                          FROM СОТРУДНИКИ c
                          INNER JOIN ОТДЕЛЫ o ON c.Название_отдела = o.Название_отдела
                          WHERE c.Название_отдела = @otdel
                          AND (@min_sum IS NULL OR o.Предельная_сумма >= @min_sum));
    RETURN @count;
END;
GO
DECLARE @otdel NVARCHAR(50) = 'IT', @min_sum DECIMAL(18,0) = 100000;
DECLARE @count INT = dbo.COUNT_SOTRUDNIKI(@otdel, @min_sum);
PRINT 'Количество сотрудников в отделе ' + @otdel + ' с предельной суммой >= ' + 
      CAST(@min_sum AS VARCHAR(20)) + ' = ' + CAST(@count AS VARCHAR(10));

SELECT DISTINCT 
    o.Название_отдела, 
    o.Предельная_сумма,
    dbo.COUNT_SOTRUDNIKI(o.Название_отдела, o.Предельная_сумма) AS Counts 
FROM ОТДЕЛЫ o;
--2 --
GO
DROP FUNCTION IF EXISTS F_RASHODY;
GO
CREATE FUNCTION F_RASHODY(@employee_id NVARCHAR(20)) RETURNS NVARCHAR(500)
AS 
BEGIN
    DECLARE @cheks NVARCHAR(500) = '', @buf NVARCHAR(20);
    DECLARE curs CURSOR LOCAL STATIC FOR 
        SELECT Потраченная_сумма 
        FROM РАСХОДЫ 
        WHERE ID_сотрудника = @employee_id;
    
    OPEN curs;
    FETCH curs INTO @buf;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @cheks = RTRIM(@buf) + ', ' + @cheks;
        FETCH curs INTO @buf;
    END;
    
    IF (@cheks IS NULL OR @cheks = '') 
        SET @cheks = 'Информация о потраченной сумме не найдены.';
    ELSE
        SET @cheks = 'Потраченная сумма сотрадника: ' + SUBSTRING(@cheks, 1, LEN(@cheks) - 1);
    
    CLOSE curs;
    RETURN @cheks;
END;
GO
SELECT 
    c.ID_сотрудника, 
    c.Имя + ' ' + c.Фамилия AS ФИО,
    dbo.F_RASHODY(c.ID_сотрудника) AS Чеки
FROM СОТРУДНИКИ c;
GO
-- 3 --
DROP FUNCTION IF EXISTS F_OTDEL_SOTRUD;
GO
CREATE FUNCTION F_OTDEL_SOTRUD( @otdel NVARCHAR(50) = NULL,  @min_employees INT = NULL) RETURNS TABLE
AS RETURN
    SELECT 
        o.Название_отдела,
        o.Количество_сотрудников,
        o.Предельная_сумма
    FROM ОТДЕЛЫ o
    WHERE (@otdel IS NULL OR o.Название_отдела = @otdel)
    AND (@min_employees IS NULL OR o.Количество_сотрудников >= @min_employees);
GO
SELECT * FROM dbo.F_OTDEL_SOTRUD(NULL, NULL);
SELECT * FROM dbo.F_OTDEL_SOTRUD('IT', NULL);
SELECT * FROM dbo.F_OTDEL_SOTRUD(NULL, 5);
SELECT * FROM dbo.F_OTDEL_SOTRUD('IT', 5);
GO
-- 4 --
DROP FUNCTION IF EXISTS F_COUNT_RASHODY;
GO
CREATE FUNCTION F_COUNT_RASHODY(@employee_id NVARCHAR(20)) RETURNS INT
AS
BEGIN
    DECLARE @count INT = (SELECT COUNT(*) 
                         FROM РАСХОДЫ 
                         WHERE ID_сотрудника = ISNULL(@employee_id, ID_сотрудника));
    RETURN @count;
END;
GO

SELECT 
    o.Название_отдела,
    dbo.F_COUNT_RASHODY(NULL) AS [Всего расходов],
    dbo.F_COUNT_RASHODY(c.ID_сотрудника) AS [Расходов сотрудника]
FROM ОТДЕЛЫ o
LEFT JOIN СОТРУДНИКИ c ON o.Название_отдела = c.Название_отдела;
GO
-- 6 --
CREATE FUNCTION COUNT_OTDELY()
RETURNS INT
AS
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(*) FROM ОТДЕЛЫ;
    RETURN @count;
END;
GO

CREATE FUNCTION COUNT_SOTRUDNIKI_ALL()
RETURNS INT
AS
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(*) FROM СОТРУДНИКИ;
    RETURN @count;
END;
GO

CREATE FUNCTION COUNT_RASHODY()
RETURNS INT
AS
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(*) FROM РАСХОДЫ;
    RETURN @count;
END;
GO

DROP FUNCTION IF EXISTS OTDEL_REPORT;
GO
CREATE FUNCTION OTDEL_REPORT(@min_employees INT) 
RETURNS @report TABLE (
    [Отдел] NVARCHAR(50),
    [Количество сотрудников] INT,
    [Предельная сумма] DECIMAL(18,0),
    [Фактические расходы] DECIMAL(18,0),
    [Разница] DECIMAL(18,0)
)
AS 
BEGIN 
    DECLARE @otdel NVARCHAR(50);
    DECLARE @employees INT;
    DECLARE @max_sum DECIMAL(18,0);
    DECLARE @expenses DECIMAL(18,0);
    
    DECLARE ot_cursor CURSOR STATIC FOR 
        SELECT o.Название_отдела
        FROM ОТДЕЛЫ o
        WHERE o.Количество_сотрудников > @min_employees;
    
    OPEN ot_cursor;  
    FETCH ot_cursor INTO @otdel;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @employees = Количество_сотрудников,
               @max_sum = Предельная_сумма
        FROM ОТДЕЛЫ
        WHERE Название_отдела = @otdel;
        
        SELECT @expenses = ISNULL(SUM(Потраченная_сумма), 0)
        FROM РАСХОДЫ p
        INNER JOIN СОТРУДНИКИ c ON p.ID_сотрудника = c.ID_сотрудника
        WHERE c.Название_отдела = @otdel;
        
        INSERT @report VALUES(
            @otdel,
            @employees,
            @max_sum,
            @expenses,
            @max_sum - @expenses);
            
        FETCH ot_cursor INTO @otdel;  
    END;
    
    CLOSE ot_cursor;
    DEALLOCATE ot_cursor;
    RETURN; 
END;
GO

SELECT * FROM dbo.OTDEL_REPORT(3);