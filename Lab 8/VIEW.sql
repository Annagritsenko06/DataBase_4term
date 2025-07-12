
CREATE VIEW [Преподаватель] 
as select TEACHER[код],
TEACHER_NAME[имя преподавателя],
GENDER[пол],
PULPIT[код кафедры] from TEACHER

CREATE VIEW [Количество кафедр] 
as select FACULTY_NAME as [факультет],
COUNT (*) as [количество кафедр ]
from FACULTY INNER JOIN PULPIT
ON FACULTY.FACULTY= PULPIT.FACULTY
group by FACULTY.FACULTY_NAME


CREATE VIEW [Аудитории] 
as select AUDITORIUM as [код],
AUDITORIUM_TYPE as [наименование аудитории]
from AUDITORIUM 
WHERE AUDITORIUM_TYPE like '%ЛК%'
INSERT Аудитории values(9986,'ЛК')


CREATE VIEW [Лекционные_аудитории] 
as select AUDITORIUM as [код],
AUDITORIUM_TYPE as [наименование аудитории]
from AUDITORIUM 
WHERE AUDITORIUM_TYPE like '%ЛК%' WITH CHECK OPTION
INSERT Аудитории values(8766-1,'ЛБ')


CREATE VIEW Дисциплины (код, наименование_дисциплины , код_кафедры)
as select TOP 150 SUBJECT, SUBJECT_NAME,PULPIT	
from SUBJECT
order by SUBJECT_NAME

ALTER VIEW [Количество кафедр] WITH SCHEMABINDING AS
SELECT 
    F.FACULTY_NAME AS [факультет],
    COUNT(*) AS [количество кафедр]
FROM 
    dbo.FACULTY AS F
INNER JOIN 
    dbo.PULPIT AS P ON F.FACULTY = P.FACULTY
GROUP BY 
    F.FACULTY_NAME;