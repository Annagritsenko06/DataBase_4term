-- 1--
USE G_MyBase;
GO
DROP PROCEDURE IF EXISTS P_OTDELY
GO
CREATE PROCEDURE P_OTDELY
AS
BEGIN
    DECLARE @count INT = (SELECT COUNT(*) FROM ������);
    SELECT 
        ��������_������ AS [�������� ������],
        ����������_����������� AS [���������� �����������],
        ����������_����� AS [���������� �����]
    FROM ������;
    RETURN @count;
END;
GO

DECLARE @c INT;
EXEC @c = P_OTDELY;
PRINT '���������� ������� = ' + CAST(@c AS VARCHAR(5));
-- 2 --
GO
USE G_MyBase;
GO
ALTER PROCEDURE [dbo].[P_OTDELY] @min_sum DECIMAL(18,0) = NULL, @c INT OUTPUT
AS
BEGIN
    DECLARE @count INT = (SELECT COUNT(*) FROM ������);
    SELECT 
        ��������_������ AS [�������� ������],
        ����������_����������� AS [���������� �����������],
        ����������_����� AS [���������� �����]
    FROM ������
    WHERE @min_sum IS NULL OR ����������_����� >= @min_sum;
    SET @c = @@ROWCOUNT;
    RETURN @count;
END;
GO

DECLARE @k INT = 0, @rc INT = 0, @min DECIMAL(18,0) = 100000;
EXEC @k = P_OTDELY @min_sum = @min, @c = @rc OUTPUT;
PRINT '����� ���������� ������� = ' + CAST(@k AS VARCHAR(5));
PRINT '���������� ������� � ���������� ������ >= ' + CAST(@min AS VARCHAR(20)) + ' = ' + CAST(@rc AS VARCHAR(5));
-- 3 --
USE G_MyBase;
GO
ALTER PROCEDURE [dbo].[P_OTDELY] @min_employees INT
AS
BEGIN
    SELECT 
        ��������_������ AS [��������_������],
        ����������_����������� AS [����������_�����������],
        ����������_����� AS [����������_�����]
    FROM ������
    WHERE  ����������_����������� >= @min_employees;
END;
GO

DROP TABLE IF EXISTS #OTDELY_FILTERED;
GO
CREATE TABLE #OTDELY_FILTERED(
    ��������_������ NVARCHAR(50) PRIMARY KEY,
    ����������_����������� INT,
    ����������_����� DECIMAL(18,0));
GO
INSERT #OTDELY_FILTERED EXEC P_OTDELY @min_employees = 5;
SELECT * FROM #OTDELY_FILTERED;
-- 4 --
SELECT * FROM ����������;

GO
DROP PROCEDURE IF EXISTS P_SOTRUDNIKI_INSERT;
GO
CREATE PROCEDURE P_SOTRUDNIKI_INSERT 
    @id NVARCHAR(20), 
    @name NVARCHAR(20) = NULL, 
    @surname NVARCHAR(50) = NULL, 
    @otdel NVARCHAR(50) = NULL
AS
BEGIN TRY
    INSERT INTO ���������� VALUES(@id, @name, @surname, @otdel);
    RETURN 1;
END TRY
BEGIN CATCH
    PRINT '����� ������ = ' + CAST(ERROR_NUMBER() AS VARCHAR(5));
    PRINT '������� = ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
    PRINT '���������: ' + ERROR_MESSAGE();
    RETURN -1;
END CATCH;
GO

DECLARE @rc INT;
EXEC @rc = P_SOTRUDNIKI_INSERT @id = 'EMP100', @name = '����', @surname = '������', @otdel = 'IT';
PRINT '��������� ��������: ' + CAST(@rc AS VARCHAR(2));
-- 5 --
GO 
DROP PROCEDURE IF EXISTS RASHODY_REPORT;
GO
CREATE PROCEDURE RASHODY_REPORT @employee_id NVARCHAR(20)
AS
BEGIN TRY
    DECLARE @buf VARCHAR(MAX) = '', @cur_chek INT = 0, @count INT = 0;
    DECLARE cheks CURSOR LOCAL FOR 
        SELECT �����_���� FROM ������� WHERE ID_���������� = @employee_id;
    
    IF NOT EXISTS(SELECT 1 FROM ������� WHERE ID_���������� = @employee_id) 
        RAISERROR('��� ������� ���������� �������� �� �������', 11, 1);
    ELSE
    BEGIN
        OPEN cheks;
        FETCH cheks INTO @cur_chek;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @buf = CAST(@cur_chek AS VARCHAR(20)) + ', ' + @buf;
            SET @count += 1;
            FETCH cheks INTO @cur_chek;
        END;
        SET @buf = SUBSTRING(@buf, 1, LEN(@buf) - 2);
        PRINT '���� ���������� ' + @employee_id + ': ' + @buf;
        CLOSE cheks;
        RETURN @count;
    END;
END TRY
BEGIN CATCH
    PRINT '������: ' + ERROR_MESSAGE();
    RETURN @count;
END CATCH;

GO

DECLARE @rc INT;
EXEC @rc = RASHODY_REPORT @employee_id = 'EMP001';
PRINT '���������� ����� = ' + CAST(@rc AS VARCHAR(5));
-- 6 --
GO
DROP PROCEDURE IF EXISTS P_OTDEL_INSERTX;
GO
CREATE PROCEDURE P_OTDEL_INSERTX 
    @name NVARCHAR(50), 
    @employees INT, 
    @max_sum DECIMAL(18,0),
    @sotrudnik_id NVARCHAR(20),
    @sotrudnik_name NVARCHAR(20),
    @sotrudnik_surname NVARCHAR(50)
AS
BEGIN TRY
    DECLARE @rc INT = 1;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    BEGIN TRAN;
        INSERT INTO ������ VALUES(@name, @employees, @max_sum);
        EXEC @rc = P_SOTRUDNIKI_INSERT 
            @id = @sotrudnik_id, 
            @name = @sotrudnik_name, 
            @surname = @sotrudnik_surname, 
            @otdel = @name;
        COMMIT TRAN;
    RETURN @rc;
END TRY
BEGIN CATCH
    PRINT '����� ������ = ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT '���������: ' + ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    RETURN -1;
END CATCH;

GO

DECLARE @rc INT;
EXEC @rc = P_OTDEL_INSERTX 
    @name = '���������', 
    @employees = 10, 
    @max_sum = 500000,
    @sotrudnik_id = 'EMP200',
    @sotrudnik_name = '����',
    @sotrudnik_surname = '�������';

SELECT * FROM ������;
SELECT * FROM ���������� WHERE ��������_������ = '���������';