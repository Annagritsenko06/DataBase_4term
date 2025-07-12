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
CREATE table ������
(��������_������ nvarchar(50) primary key,
����������_����������� int,
����������_����� decimal not null) on FG1;
CREATE table ����������
(ID_���������� nvarchar(20) primary key,
��� nvarchar(20),
������� nvarchar(50),
��������_������ nvarchar(50) foreign key references ������(��������_������)
);
CREATE table �������
(�����_���� int primary key,
ID_���������� nvarchar(20) foreign key references ����������(ID_����������) ,
��������_������ nvarchar(50) ,
�������� text,
�����������_����� decimal,
���� date
);
--Go
ALTER Table ���������� ADD ��� nchar(1);
--GO
ALTER Table ���������� DROP Column  ���;
INSERT into ������(��������_������,����������_�����������,����������_�����)
Values('one',6,88),
('����� ������', 10, 50000.00),
('����� ����������', 8, 30000.00),
('����� ����������', 15, 100000.00);
INSERT into ���������� (ID_����������, ���, �������, ��������_������) Values
('001', '����', '������', '����� ������'),
('002', '����', '������', '����� ����������'),
('003', '������', '�������', '����� ����������');
INSERT into ������� (�����_����, ID_����������, ��������_������, ��������, �����������_�����, ����) Values
(1, '001', '������������ ������', '����� � ��������', 1500.00, '2025-01-10'),
(2, '002', '�������', '��������� ���������', 2000.00, '2025-01-15'),
(3, '003', '����������� �����������', '�������� �� ��', 30000.00, '2025-01-20');
SELECT * From ����������;
SELECT ID_����������, ��� From ����������;
SELECT COUNT(*) From ����������;
UPDATE  ������ set ����������_����������� = ����������_�����������+2 Where ��������_������ = '����� ������';
SELECT * From  ������;
   
  
   