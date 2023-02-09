USE WideWorldImporters
/*
1. ��� ������, � �������� ������� ���� "urgent" ��� �������� ���������� � "Animal".
�������: �� ������ (StockItemID), ������������ ������ (StockItemName).
�������: Warehouse.StockItems.
*/
select StockItemID,
StockItemName
from Warehouse.StockItems
where StockItemName like '%urgent%' or StockItemName like 'Animal%'


/*
2. ����������� (Suppliers), � ������� �� ���� ������� �� ������ ������ (PurchaseOrders).
������� ����� JOIN, � ����������� ������� ������� �� �����.
�������: �� ���������� (SupplierID), ������������ ���������� (SupplierName).
�������: Purchasing.Suppliers, Purchasing.PurchaseOrders.
�� ����� �������� ������ JOIN ��������� ��������������.
*/

select s.SupplierID,s.SupplierName
from Purchasing.Suppliers s
join Purchasing.PurchaseOrders p 
on p.SupplierID = s.SupplierID
where p.IsOrderFinalized < 1



/*
3. ������ (Orders) � ����� ������ (UnitPrice) ����� 100$ 
���� ����������� ������ (Quantity) ������ ����� 20 ����
� �������������� ����� ������������ ����� ������ (PickingCompletedWhen).
�������:
* OrderID
* ���� ������ (OrderDate) � ������� ��.��.����
* �������� ������, � ������� ��� ������ �����
* ����� ��������, � ������� ��� ������ �����
* ����� ����, � ������� ��������� ���� ������ (������ ����� �� 4 ������)
* ��� ��������� (Customer)
�������� ������� ����� ������� � ������������ ��������,
��������� ������ 1000 � ��������� ��������� 100 �������.

���������� ������ ���� �� ������ ��������, ����� ����, ���� ������ (����� �� �����������).

�������: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

select o.OrderID,
	FORMAT(o.orderdate, 'd', 'ru') Orderdate,
	datename(MONTH,o.orderdate) Month,
	DATEPART(quarter,o.OrderDate) Quarter,
	(MONTH(o.OrderDate)/5+1) Dekada ,
	c.CustomerName
from Sales.Orders o
join Sales.OrderLines ol
on o.OrderID = ol.OrderID
join Sales.Customers c
on o.CustomerID = c.CustomerID
where (ol.UnitPrice > '100' or ol.Quantity > '20') and ol.PickingCompletedWhen is not null
order by Quarter,dekada,Orderdate


select o.OrderID,
	FORMAT(o.orderdate, 'd', 'ru') Orderdate,
	datename(MONTH,o.orderdate) Month,
	DATEPART(quarter,o.OrderDate) Quarter,
	(MONTH(o.OrderDate)/5+1) Dekada,
	sc.CustomerName
from Sales.Orders o
join Sales.OrderLines ol
on o.OrderID = ol.OrderID
join Sales.Customers sc
on o.CustomerID = sc.CustomerID
where (ol.UnitPrice > '100' or ol.Quantity > '20') and ol.PickingCompletedWhen is not null
order by Quarter,dekada,Orderdate
offset 1000 rows fetch first 100 rows only

/*
4. ������ ����������� (Purchasing.Suppliers),
������� ������ ���� ��������� (ExpectedDeliveryDate) � ������ 2013 ����
� ��������� "Air Freight" ��� "Refrigerated Air Freight" (DeliveryMethodName)
� ������� ��������� (IsOrderFinalized).
�������:
* ������ �������� (DeliveryMethodName)
* ���� �������� (ExpectedDeliveryDate)
* ��� ����������
* ��� ����������� ���� ������������ ����� (ContactPerson)

�������: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

select dm.DeliveryMethodName,po.ExpectedDeliveryDate, s.SupplierName, p.FullName
from Purchasing.Suppliers s
	join Purchasing.PurchaseOrders po
		on po.SupplierID = s.SupplierID
	join Application.DeliveryMethods dm
		on dm.DeliveryMethodID = po.DeliveryMethodID
	join Application.People p
		on p.PersonID = po.ContactPersonID
where (po.ExpectedDeliveryDate between '20130101' and '20130201')
		and (dm.DeliveryMethodName = 'Air Freight' or dm.DeliveryMethodName = 'Refrigerated Air Freight') 
		and po.IsOrderFinalized > 0

/*
5. ������ ��������� ������ (�� ���� �������) � ������ ������� � ������ ����������,
������� ������� ����� (SalespersonPerson).
������� ��� �����������.
*/

select top 10 c.CustomerName, p.FullName 
from Sales.Orders o
	join sales.Customers c
	on c.CustomerID = o.CustomerID
	join Application.People p 
	on p.PersonID = o.SalespersonPersonID
order by o.OrderID desc


/*
6. ��� �� � ����� �������� � �� ���������� ��������,
������� �������� ����� "Chocolate frogs 250g".
��� ������ �������� � ������� Warehouse.StockItems.
*/

select c.CustomerID, c.CustomerName, c.PhoneNumber
from Sales.OrderLines ol
	join Warehouse.StockItems s
	on s.StockItemID = ol.StockItemID
	join Sales.Orders o
	on o.OrderID = ol.OrderID
	join Sales.Customers c
	on c.CustomerID = o.CustomerID
where s.StockItemName = 'Chocolate frogs 250g'