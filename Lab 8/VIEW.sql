
CREATE VIEW [�������������] 
as select TEACHER[���],
TEACHER_NAME[��� �������������],
GENDER[���],
PULPIT[��� �������] from TEACHER

CREATE VIEW [���������� ������] 
as select FACULTY_NAME as [���������],
COUNT (*) as [���������� ������ ]
from FACULTY INNER JOIN PULPIT
ON FACULTY.FACULTY= PULPIT.FACULTY
group by FACULTY.FACULTY_NAME


CREATE VIEW [���������] 
as select AUDITORIUM as [���],
AUDITORIUM_TYPE as [������������ ���������]
from AUDITORIUM 
WHERE AUDITORIUM_TYPE like '%��%'
INSERT ��������� values(9986,'��')


CREATE VIEW [����������_���������] 
as select AUDITORIUM as [���],
AUDITORIUM_TYPE as [������������ ���������]
from AUDITORIUM 
WHERE AUDITORIUM_TYPE like '%��%' WITH CHECK OPTION
INSERT ��������� values(8766-1,'��')


CREATE VIEW ���������� (���, ������������_���������� , ���_�������)
as select TOP 150 SUBJECT, SUBJECT_NAME,PULPIT	
from SUBJECT
order by SUBJECT_NAME

ALTER VIEW [���������� ������] WITH SCHEMABINDING AS
SELECT 
    F.FACULTY_NAME AS [���������],
    COUNT(*) AS [���������� ������]
FROM 
    dbo.FACULTY AS F
INNER JOIN 
    dbo.PULPIT AS P ON F.FACULTY = P.FACULTY
GROUP BY 
    F.FACULTY_NAME;