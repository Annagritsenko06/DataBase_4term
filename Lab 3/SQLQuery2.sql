use master;
CREATE database G_MyBase on primary
(name=N'G_MyBase_mdf',filename = N'D:\BD\G_MyBase_mdf.mdf',
size = 10240Kb, maxsize=UNLIMITED, filegrowth=1024Kb),
(name = N'G_MyBase_ndf', filename = N'D:\BD\G_MyBase_ndf.ndf', 
   size = 10240KB, maxsize=1Gb, filegrowth=25%),
   filegroup FG1
   (name = N'G_MyBase_fg1_1', filename = N'D:\BD\G_MyBase_fgq-1.ndf', 
   size = 10240Kb, maxsize=1Gb, filegrowth=25%),
( name = N'G_MyBase_fg1_2', filename = N'D:\BD\G_MyBase_fgq-2.ndf', 
   size = 10240Kb, maxsize=1Gb, filegrowth=25%)
log on
( name = N'G_MyBase_log', filename=N'D:\BD\G_MyBase_log.ldf',       
   size=10240Kb,  maxsize=2048Gb, filegrowth=10%)
use G_MyBase;
CREATE table ОТДЕЛЫ
(Название_отдела nvarchar(50) primary key,
Количество_сотрудников int,
Предельная_сумма decimal not null) on FG1;
CREATE table СОТРУДНИКИ
(ID_сотрудника nvarchar(20) primary key,
Имя nvarchar(20),
Фамилия nvarchar(50),
Название_отдела nvarchar(50) foreign key references ОТДЕЛЫ(Название_отдела)
);
CREATE table РАСХОДЫ
(Номер_чека int primary key,
ID_сотрудника nvarchar(20) foreign key references СОТРУДНИКИ(ID_сотрудника) ,
Название_товара nvarchar(50) ,
Описание text,
Потраченная_сумма decimal,
Дата date
);
--Go
ALTER Table СОТРУДНИКИ ADD Пол nchar(1);
--GO
ALTER Table СОТРУДНИКИ DROP Column  Пол;
INSERT into ОТДЕЛЫ(Название_отдела,Количество_сотрудников,Предельная_сумма)
Values('one',6,88),
('Отдел продаж', 10, 50000.00),
('Отдел маркетинга', 8, 30000.00),
('Отдел разработки', 15, 100000.00);
INSERT into СОТРУДНИКИ (ID_сотрудника, Имя, Фамилия, Название_отдела) Values
('001', 'Иван', 'Иванов', 'Отдел продаж'),
('002', 'Петр', 'Петров', 'Отдел маркетинга'),
('003', 'Сергей', 'Сергеев', 'Отдел разработки');
INSERT into РАСХОДЫ (Номер_чека, ID_сотрудника, Название_товара, Описание, Потраченная_сумма, Дата) Values
(1, '001', 'Канцелярские товары', 'Ручки и блокноты', 1500.00, '2025-01-10'),
(2, '002', 'Реклама', 'Рекламные материалы', 2000.00, '2025-01-15'),
(3, '003', 'Программное обеспечение', 'Лицензия на ПО', 30000.00, '2025-01-20');
SELECT * From СОТРУДНИКИ;
SELECT ID_сотрудника, Имя From СОТРУДНИКИ;
SELECT COUNT(*) From СОТРУДНИКИ;
UPDATE  ОТДЕЛЫ set Количество_сотрудников = Количество_сотрудников+2 Where Название_отдела = 'Отдел продаж';
SELECT * From  ОТДЕЛЫ;
   
  
   