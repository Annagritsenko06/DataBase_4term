-- 1 --
USE G_MyBase;
GO
DROP TABLE IF EXISTS TR_AUDIT;
GO
CREATE TABLE TR_AUDIT(
    ID INT IDENTITY,
    STMT VARCHAR(20) CHECK(STMT IN('INS', 'DEL', 'UPD')),
    TRNAME VARCHAR(50),
    CC VARCHAR(500),
    CHANGE_DATE DATETIME DEFAULT GETDATE()
);
GO

DROP TRIGGER IF EXISTS TR_SOTRUDNIKI_INS;
GO
CREATE TRIGGER TR_SOTRUDNIKI_INS ON ���������� AFTER INSERT
AS
BEGIN
    DECLARE @id NVARCHAR(20), @name NVARCHAR(20), @surname NVARCHAR(50), @otdel NVARCHAR(50), @cc VARCHAR(500);
    
    SELECT 
        @id = ID_����������,
        @name = ���,
        @surname = �������,
        @otdel = ��������_������
    FROM inserted;
    
    SET @cc = RTRIM(RTRIM(@id) + ', ' + RTRIM(ISNULL(@name, 'NULL')) + ', ' + 
              RTRIM(ISNULL(@surname, 'NULL')) + ', ' + RTRIM(ISNULL(@otdel, 'NULL'));
    
    INSERT INTO TR_AUDIT(STMT, TRNAME, CC) 
    VALUES ('INS', 'TR_SOTRUDNIKI_INS', @cc);
END;
GO

INSERT INTO ���������� VALUES('EMP100', '����', '������', 'IT');
SELECT * FROM TR_AUDIT;
DELETE FROM ���������� WHERE ID_���������� = 'EMP100';
DELETE FROM TR_AUDIT WHERE STMT = 'INS';
GO
-- 2 --
DROP TRIGGER IF EXISTS TR_SOTRUDNIKI_DEL;
GO
CREATE TRIGGER TR_SOTRUDNIKI_DEL ON ���������� AFTER DELETE
AS
BEGIN
    DECLARE @id NVARCHAR(20), @name NVARCHAR(20), @surname NVARCHAR(50), @otdel NVARCHAR(50), @cc VARCHAR(500);
    
    SELECT 
        @id = ID_����������,
        @name = ���,
        @surname = �������,
        @otdel = ��������_������
    FROM deleted;
    
    SET @cc = RTRIM(RTRIM(@id) + ', ' + RTRIM(ISNULL(@name, 'NULL')) + ', ' + 
              RTRIM(ISNULL(@surname, 'NULL')) + ', ' + RTRIM(ISNULL(@otdel, 'NULL')));
    
    INSERT INTO TR_AUDIT(STMT, TRNAME, CC) 
    VALUES ('DEL', 'TR_SOTRUDNIKI_DEL', @cc);
END;
GO

INSERT INTO ���������� VALUES('EMP100', '����', '������', 'IT');
DELETE FROM ���������� WHERE ID_���������� = 'EMP100';
SELECT * FROM TR_AUDIT;
DELETE FROM TR_AUDIT WHERE STMT = 'DEL';
GO
-- 3 --
DROP TRIGGER IF EXISTS TR_SOTRUDNIKI_UPD;
GO
CREATE TRIGGER TR_SOTRUDNIKI_UPD ON ���������� AFTER UPDATE
AS
BEGIN
    DECLARE @old_id NVARCHAR(20), @old_name NVARCHAR(20), @old_surname NVARCHAR(50), @old_otdel NVARCHAR(50),
            @new_id NVARCHAR(20), @new_name NVARCHAR(20), @new_surname NVARCHAR(50), @new_otdel NVARCHAR(50),
            @cc VARCHAR(500);
    
    SELECT 
        @old_id = ID_����������,
        @old_name = ���,
        @old_surname = �������,
        @old_otdel = ��������_������
    FROM deleted;
    
    SELECT 
        @new_id = ID_����������,
        @new_name = ���,
        @new_surname = �������,
        @new_otdel = ��������_������
    FROM inserted;
    
    SET @cc = '��: ' + RTRIM(RTRIM(@old_id) + ', ' + RTRIM(ISNULL(@old_name, 'NULL')) + ', ' + 
              RTRIM(ISNULL(@old_surname, 'NULL')) + ', ' + RTRIM(ISNULL(@old_otdel, 'NULL'))) + 
              CHAR(10) + '�����: ' + RTRIM(RTRIM(@new_id) + ', ' + RTRIM(ISNULL(@new_name, 'NULL')) + ', ' + 
              RTRIM(ISNULL(@new_surname, 'NULL')) + ', ' + RTRIM(ISNULL(@new_otdel, 'NULL')));
    
    INSERT INTO TR_AUDIT(STMT, TRNAME, CC) 
    VALUES ('UPD', 'TR_SOTRUDNIKI_UPD', @cc);
END;
GO

INSERT INTO ���������� VALUES('EMP100', '����', '������', 'IT');
UPDATE ���������� SET ������� = '������' WHERE ID_corp������ = 'EMP100';
SELECT * FROM TR_AUDIT;
DELETE FROM ���������� WHERE ID_���������� = 'EMP100';
DELETE FROM TR_AUDIT;
GO
-- 4 --
DROP TRIGGER IF EXISTS TR_SOTRUDNIKI;
GO
CREATE TRIGGER TR_SOTRUDNIKI ON ���������� AFTER INSERT, DELETE, UPDATE
AS
BEGIN
    DECLARE @old_id NVARCHAR(20), @old_name NVARCHAR(20), @old_surname NVARCHAR(50), @old_otdel NVARCHAR(50),
            @new_id NVARCHAR(20), @new_name NVARCHAR(20), @new_surname NVARCHAR(50), @new_otdel NVARCHAR(50),
            @cc VARCHAR(500);
    
    DECLARE @inserted_count INT = (SELECT COUNT(*) FROM inserted),
            @deleted_count INT = (SELECT COUNT(*) FROM deleted);
    
    IF @inserted_count > 0 AND @deleted_count = 0 -- INSERT
    BEGIN
        SELECT 
            @new_id = ID_����������,
            @new_name = ���,
            @new_surname = �������,
            @new_otdel = ��������_������
        FROM inserted;
        
        SET @cc = RTRIM(RTRIM(@new_id) + ', ' + RTRIM(ISNULL(@new_name, 'NULL')) + ', ' + 
                  RTRIM(ISNULL(@new_surname, 'NULL')) + ', ' + RTRIM(ISNULL(@new_otdel, 'NULL')));
        
        INSERT INTO TR_AUDIT(STMT, TRNAME, CC) 
        VALUES ('INS', 'TR_SOTRUDNIKI', @cc);
    END
    ELSE IF @inserted_count = 0 AND @deleted_count > 0 -- DELETE
    BEGIN
        SELECT 
            @old_id = ID_����������,
            @old_name = ���,
            @old_surname = �������,
            @old_otdel = ��������_������
        FROM deleted;
        
        SET @cc = RTRIM(RTRIM(@old_id) + ', ' + RTRIM(ISNULL(@old_name, 'NULL')) + ', ' + 
                  RTRIM(ISNULL(@old_surname, 'NULL')) + ', ' + RTRIM(ISNULL(@old_otdel, 'NULL')));
        
        INSERT INTO TR_AUDIT(STMT, TRNAME, CC) 
        VALUES ('DEL', 'TR_SOTRUDNIKI', @cc);
    END
    ELSE 
    BEGIN
        SELECT 
            @old_id = ID_����������,
            @old_name = ���,
            @old_surname = �������,
            @old_otdel = ��������_������
        FROM deleted;
        
        SELECT 
            @new_id = ID_����������,
            @new_name = ���,
            @new_surname = �������,
            @new_otdel = ��������_������
        FROM inserted;
        
        SET @cc = '��: ' + RTRIM(RTRIM(@old_id) + ', ' + RTRIM(ISNULL(@old_name, 'NULL')) + ', ' + 
                  RTRIM(ISNULL(@old_surname, 'NULL')) + ', ' + RTRIM(ISNULL(@old_otdel, 'NULL'))) + 
                  CHAR(10) + '�����: ' + RTRIM(RTRIM(@new_id) + ', ' + RTRIM(ISNULL(@new_name, 'NULL')) + ', ' + 
                  RTRIM(ISNULL(@new_surname, 'NULL')) + ', ' + RTRIM(ISNULL(@new_otdel, 'NULL')));
        
        INSERT INTO TR_AUDIT(STMT, TRNAME, CC) 
        VALUES ('UPD', 'TR_SOTRUDNIKI', @cc);
    END;
END;
GO

INSERT INTO ���������� VALUES('EMP100', '����', '������', 'IT');
UPDATE ���������� SET ������� = '������' WHERE ID_���������� = 'EMP100';
DELETE FROM ���������� WHERE ID_���������� = 'EMP100';
SELECT * FROM TR_AUDIT;
DELETE FROM TR_AUDIT;
GO
-- 5 --
select * from ������
update ������ set ����������_����������� = '�����'
select * from TR_AUDIT
-- 6 --
DROP TRIGGER IF EXISTS TR_SOTRUDNIKI_DEL1;
GO
CREATE TRIGGER TR_SOTRUDNIKI_DEL1 ON ���������� AFTER DELETE
AS 
BEGIN
    PRINT 'TR_SOTRUDNIKI_DEL1 - ������ �������';
    INSERT INTO TR_AUDIT(STMT, TRNAME, CC) 
    VALUES ('DEL', 'TR_SOTRUDNIKI_DEL1', '������ ������� �� ��������');
END;
GO

DROP TRIGGER IF EXISTS TR_SOTRUDNIKI_DEL2;
GO
CREATE TRIGGER TR_SOTRUDNIKI_DEL2 ON ���������� AFTER DELETE
AS 
BEGIN
    PRINT 'TR_SOTRUDNIKI_DEL2 - ������ �������';
    INSERT INTO TR_AUDIT(STMT, TRNAME, CC) 
    VALUES ('DEL', 'TR_SOTRUDNIKI_DEL2', '������ ������� �� ��������');
END;
GO

DROP TRIGGER IF EXISTS TR_SOTRUDNIKI_DEL3;
GO
CREATE TRIGGER TR_SOTRUDNIKI_DEL3 ON ���������� AFTER DELETE
AS 
BEGIN
    PRINT 'TR_SOTRUDNIKI_DEL3 - ������ �������';
    INSERT INTO TR_AUDIT(STMT, TRNAME, CC) 
    VALUES ('DEL', 'TR_SOTRUDNIKI_DEL3', '������ ������� �� ��������');
END;
GO

EXEC sp_settriggerorder 
    @triggername = 'TR_SOTRUDNIKI_DEL3',
    @order = 'First', 
    @stmttype = 'DELETE';

EXEC sp_settriggerorder 
    @triggername = 'TR_SOTRUDNIKI_DEL1',
    @order = 'Last', 
    @stmttype = 'DELETE';

select * from sys.triggers

select * from sys.trigger_event_types

select tr.name, tr_e.type_desc from 
sys.triggers tr inner join sys.trigger_events tr_e
on tr.object_id = tr_e.object_id 
WHERE 
    OBJECT_NAME(tr.parent_id) = 'COT�������' 
    AND tr_e.type_desc = 'DELETE';
GO

INSERT INTO ���������� VALUES('EMP100', '����', '������', 'IT');
DELETE FROM ���������� WHERE ID_���������� = 'EMP100';
SELECT * FROM TR_AUDIT;
DELETE FROM TR_AUDIT;
GO
DROP TRIGGER IF EXISTS TR_SOTRUDNIKI_LIMIT;
GO
-- 7 --
CREATE TRIGGER TR_SOTRUDNIKI_LIMIT ON ���������� AFTER INSERT
AS 
BEGIN
    DECLARE @otdel NVARCHAR(50), @current_count INT, @max_count INT;
    SELECT @otdel = ��������_������ FROM inserted;
    IF @otdel IS NULL RETURN;
    SELECT @current_count = COUNT(*) 
    FROM ���������� 
    WHERE ��������_������ = @otdel;
    SELECT @max_count = ����������_�����������
    FROM ������ 
    WHERE ��������_������ = @otdel;
    
    IF @current_count > @max_count
    BEGIN
        RAISERROR('���������� ����������� � ������ �� ����� ��������� ������������� �����', 16, 1);
        ROLLBACK;
    END;
END;
GO
INSERT INTO ���������� VALUES('EMP101', '���������1', '�������1', 'IT');
INSERT INTO ���������� VALUES('EMP102', '���������2', '�������2', 'IT');
INSERT INTO ���������� VALUES('EMP103', '���������3', '�������3', 'IT');
INSERT INTO ���������� VALUES('EMP104', '���������4', '�������4', 'IT');
INSERT INTO ���������� VALUES('EMP105', '���������5', '�������5', 'IT');
INSERT INTO ���������� VALUES('EMP106', '���������6', '�������6', 'IT');
GO
-- 8 --
DROP TRIGGER IF EXISTS TR_OTDELY_DELETE;
GO
CREATE TRIGGER TR_OTDELY_DELETE ON ������ INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('��������� �������� ������� �� ������� OT����', 16, 1);
    ROLLBACK;
END;
GO
DELETE FROM ������ WHERE ��������_������ = 'IT';
GO
DROP TRIGGER IF EXISTS TR_SOTRUDNIKI_INS;
DROP TRIGGER IF EXISTS TR_SOTRUDNIKI_DEL;
DROP TRIGGER IF EXISTS TR_SOTRUDNIKI_UPD;
DROP TRIGGER IF EXISTS TR_SOTRUDNIKI;
DROP TRIGGER IF EXISTS TR_SOTRUDNIKI_LIMIT;
DROP TRIGGER IF EXISTS TR_OTDELY_DELETE;
DROP TRIGGER IF EXISTS TR_SOTRUDNIKI_DEL1;
DROP TRIGGER IF EXISTS TR_SOTRUDNIKI_DEL2;
DROP TRIGGER IF EXISTS TR_SOTRUDNIKI_DEL3;
DROP TRIGGER IF EXISTS DDL_G_MyBase ON DATABASE;
GO
-- 9 --
DROP TRIGGER IF EXISTS DDL_G_MyBase ON DATABASE;
GO
CREATE TRIGGER DDL_G_MyBase ON DATABASE
FOR CREATE_TABLE, DROP_TABLE, ALTER_TABLE AS
BEGIN
    DECLARE @event_type VARCHAR(50) = EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(50)');
    DECLARE @object_name VARCHAR(50) = EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(50)');
    DECLARE @object_type VARCHAR(50) = EVENTDATA().value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(50)');
    
    PRINT '��� �������: ' + @event_type;
    PRINT '��� �������: ' + @object_name;
    PRINT '��� �������: ' + @object_type;
    
    RAISERROR('�������� ��������� ��������� ���� ������ G_MyBase ���������', 16, 1);  
    ROLLBACK;    
END;
GO

CREATE TABLE TEST_TABLE(ID INT);
GO
DELETE FROM ���������� WHERE ID_���������� LIKE 'EMP%';
DELETE FROM TR_AUDIT;

