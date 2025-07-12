-- 1 --
USE G_MyBase;
GO
DROP FUNCTION IF EXISTS COUNT_SOTRUDNIKI;
GO
CREATE FUNCTION COUNT_SOTRUDNIKI(@otdel NVARCHAR(50)) RETURNS INT
AS 
BEGIN
    DECLARE @count INT = (SELECT COUNT(*) FROM ���������� WHERE ��������_������ = @otdel);
    RETURN @count;
END;
GO
DECLARE @otdel NVARCHAR(50) = '����� ����������';
DECLARE @count INT = dbo.COUNT_SOTRUDNIKI(@otdel);
PRINT '���������� ����������� � ������ ' + @otdel + ' = ' + CAST(@count AS VARCHAR(10));
GO

ALTER FUNCTION COUNT_SOTRUDNIKI(
    @otdel NVARCHAR(50), 
    @min_sum DECIMAL(18,0) = NULL
) RETURNS INT
AS 
BEGIN
    DECLARE @count INT = (SELECT COUNT(*) 
                          FROM ���������� c
                          INNER JOIN ������ o ON c.��������_������ = o.��������_������
                          WHERE c.��������_������ = @otdel
                          AND (@min_sum IS NULL OR o.����������_����� >= @min_sum));
    RETURN @count;
END;
GO
DECLARE @otdel NVARCHAR(50) = 'IT', @min_sum DECIMAL(18,0) = 100000;
DECLARE @count INT = dbo.COUNT_SOTRUDNIKI(@otdel, @min_sum);
PRINT '���������� ����������� � ������ ' + @otdel + ' � ���������� ������ >= ' + 
      CAST(@min_sum AS VARCHAR(20)) + ' = ' + CAST(@count AS VARCHAR(10));

SELECT DISTINCT 
    o.��������_������, 
    o.����������_�����,
    dbo.COUNT_SOTRUDNIKI(o.��������_������, o.����������_�����) AS Counts 
FROM ������ o;
--2 --
GO
DROP FUNCTION IF EXISTS F_RASHODY;
GO
CREATE FUNCTION F_RASHODY(@employee_id NVARCHAR(20)) RETURNS NVARCHAR(500)
AS 
BEGIN
    DECLARE @cheks NVARCHAR(500) = '', @buf NVARCHAR(20);
    DECLARE curs CURSOR LOCAL STATIC FOR 
        SELECT �����������_����� 
        FROM ������� 
        WHERE ID_���������� = @employee_id;
    
    OPEN curs;
    FETCH curs INTO @buf;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @cheks = RTRIM(@buf) + ', ' + @cheks;
        FETCH curs INTO @buf;
    END;
    
    IF (@cheks IS NULL OR @cheks = '') 
        SET @cheks = '���������� � ����������� ����� �� �������.';
    ELSE
        SET @cheks = '����������� ����� ����������: ' + SUBSTRING(@cheks, 1, LEN(@cheks) - 1);
    
    CLOSE curs;
    RETURN @cheks;
END;
GO
SELECT 
    c.ID_����������, 
    c.��� + ' ' + c.������� AS ���,
    dbo.F_RASHODY(c.ID_����������) AS ����
FROM ���������� c;
GO
-- 3 --
DROP FUNCTION IF EXISTS F_OTDEL_SOTRUD;
GO
CREATE FUNCTION F_OTDEL_SOTRUD( @otdel NVARCHAR(50) = NULL,  @min_employees INT = NULL) RETURNS TABLE
AS RETURN
    SELECT 
        o.��������_������,
        o.����������_�����������,
        o.����������_�����
    FROM ������ o
    WHERE (@otdel IS NULL OR o.��������_������ = @otdel)
    AND (@min_employees IS NULL OR o.����������_����������� >= @min_employees);
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
                         FROM ������� 
                         WHERE ID_���������� = ISNULL(@employee_id, ID_����������));
    RETURN @count;
END;
GO

SELECT 
    o.��������_������,
    dbo.F_COUNT_RASHODY(NULL) AS [����� ��������],
    dbo.F_COUNT_RASHODY(c.ID_����������) AS [�������� ����������]
FROM ������ o
LEFT JOIN ���������� c ON o.��������_������ = c.��������_������;
GO
-- 6 --
CREATE FUNCTION COUNT_OTDELY()
RETURNS INT
AS
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(*) FROM ������;
    RETURN @count;
END;
GO

CREATE FUNCTION COUNT_SOTRUDNIKI_ALL()
RETURNS INT
AS
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(*) FROM ����������;
    RETURN @count;
END;
GO

CREATE FUNCTION COUNT_RASHODY()
RETURNS INT
AS
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(*) FROM �������;
    RETURN @count;
END;
GO

DROP FUNCTION IF EXISTS OTDEL_REPORT;
GO
CREATE FUNCTION OTDEL_REPORT(@min_employees INT) 
RETURNS @report TABLE (
    [�����] NVARCHAR(50),
    [���������� �����������] INT,
    [���������� �����] DECIMAL(18,0),
    [����������� �������] DECIMAL(18,0),
    [�������] DECIMAL(18,0)
)
AS 
BEGIN 
    DECLARE @otdel NVARCHAR(50);
    DECLARE @employees INT;
    DECLARE @max_sum DECIMAL(18,0);
    DECLARE @expenses DECIMAL(18,0);
    
    DECLARE ot_cursor CURSOR STATIC FOR 
        SELECT o.��������_������
        FROM ������ o
        WHERE o.����������_����������� > @min_employees;
    
    OPEN ot_cursor;  
    FETCH ot_cursor INTO @otdel;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @employees = ����������_�����������,
               @max_sum = ����������_�����
        FROM ������
        WHERE ��������_������ = @otdel;
        
        SELECT @expenses = ISNULL(SUM(�����������_�����), 0)
        FROM ������� p
        INNER JOIN ���������� c ON p.ID_���������� = c.ID_����������
        WHERE c.��������_������ = @otdel;
        
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