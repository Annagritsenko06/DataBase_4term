--1
use	G_MyBase
exec SP_HELPINDEX'������'
exec SP_HELPINDEX'�������'
exec SP_HELPINDEX'����������'
--2

create index #tempTable_cl on ������(����������_�����������,����������_�����);
select * from ������ where ����������_����������� > 2 order by ����������_�����������;

--3
create index #temptb_tind_x on ������(����������_�����������) include (����������_�����);
select * from ������ where ����������_�����>100;


/*4*/

create index #tempT_where on �������(�����������_�����) where (�����������_����� >= 1000 and �����������_����� <= 50000);;
select * from ������� where �����������_����� between 1000 and 50000;

