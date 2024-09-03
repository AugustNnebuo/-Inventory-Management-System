--Portfolio Project 2: Creating and Querying Retail Company's Inventory DB using SQL
--Description: This SQL Project carried out involves the Creation and manpiulation of a ReatilInventory Database containing 4 tables,
-- populating the tables, and querying the data in the tables to provide insights for the compay and help them make 
--informed decisions.

-- Creating database

CREATE DATABASE RetailInventoryDb
 GO
 USE RetailInventoryDb

 --Creating 1st table: Product
 CREATE TABLE Product (
    ProductID NVARCHAR(50) PRIMARY KEY,      
    ProductName NVARCHAR(100) NOT NULL,      
    CategoryID INT NOT NULL,                  
    Price DECIMAL(10, 2) NOT NULL,            
    Quantity INT NOT NULL,                    
    SupplierID INT NOT NULL                   
);

INSERT INTO Product (ProductID, ProductName, CategoryID, Price, Quantity, SupplierID)
VALUES
    ('P01', 'Laptop', 1, 1200, 50, 101),
    ('P02', 'Smartphone', 1, 800, 100, 102),
    ('P03', 'TV', 2, 1500, 30, 103),
    ('P04', 'Refrigerator', 2, 900, 25, 104),
    ('P05', 'Microwave', 3, 200, 60, 105),
    ('P06', 'Washing Machine', 2, 1100, 20, 106),
    ('P07', 'Headphones', 4, 100, 200, 107),
    ('P08', 'Camera', 1, 700, 15, 108),
    ('P09', 'Air Conditioner', 2, 1300, 10, 109),
    ('P10', 'Blender', 3, 150, 80, 110);

--Creating 2nd table: Caategory
CREATE TABLE Category (
    CategoryID INT PRIMARY KEY,           -- Primary key for the Category table
    CategoryName NVARCHAR(100) NOT NULL   -- Name of the category, up to 100 characters
);
INSERT INTO Category (CategoryID, CategoryName)
VALUES
    (1, 'Electronics'),
    (2, 'Appliances'),
    (3, 'Kitchenware'),
    (4, 'Accessories');

--Creating table 3: Supplier
CREATE TABLE Supplier (
    SupplierID INT PRIMARY KEY,           
    SupplierName NVARCHAR(100) NOT NULL,  
    ContactNumber NVARCHAR(15) NOT NULL   
);
INSERT INTO Supplier (SupplierID, SupplierName, ContactNumber)
VALUES
    (101, 'SupplierA', '123-456-7890'),
    (102, 'SupplierB', '234-567-8901'),
    (103, 'SupplierC', '345-678-9012'),
    (104, 'SupplierD', '456-789-0123'),
    (105, 'SupplierE', '567-890-1234'),
    (106, 'SupplierF', '678-901-2345'),
    (107, 'SupplierG', '789-012-3456'),
    (108, 'SupplierH', '890-123-4567'),
    (109, 'SupplierI', '901-234-5678'),
    (110, 'SupplierJ', '012-345-6789');

--Creating 4th table : Warehouse

CREATE TABLE Warehouse (
    WarehouseID NVARCHAR(10) PRIMARY KEY,  
    WarehouseName NVARCHAR(100) NOT NULL,  
    Location NVARCHAR(100) NOT NULL        
);
INSERT INTO Warehouse (WarehouseID, WarehouseName, Location)
VALUES
    ('W01', 'MainWarehouse', 'New York'),
    ('W02', 'EastWarehouse', 'Boston'),
    ('W03', 'WestWarehouse', 'San Diego'),
    ('W04', 'NorthWarehouse', 'Chicago'),
    ('W05', 'SouthWarehouse', 'Miami'),
    ('W06', 'CentralWarehouse', 'Dallas'),
    ('W07', 'PacificWarehouse', 'San Francisco'),
    ('W08', 'MountainWarehouse', 'Denver'),
    ('W09', 'SouthernWarehouse', 'Atlanta'),
    ('W10', 'GulfWarehouse', 'Houston');

/*SQL Tasks:
1.	Fetch products with the same price.
2.	Find the second highest priced product and its category.
3.	Get the maximum price per category and the product name.
4.	Supplier-wise count of products sorted by count in descending order.
5.	Fetch only the first word from the ProductName and append the price.
6.	Fetch products with odd prices.
7.	Create a view to fetch products with a price greater than $500.
8.	Create a procedure to update product prices by 15% where the category is 'Electronics' and the supplier is not 'SupplierA'.
9.	Create a stored procedure to fetch product details along with their category, supplier, and warehouse location, including error handling.
*/

--Queries
-- Ques 1.	Fetch products with the same price.

select * from Product
where price in (
select Price from Product
group by Price
having count(Price)>1 
)
-- No Output received, meaning that all prices are unique.

--Ques 2.	Find the second highest priced product and its category.
Select ProductName, Price
from Product
order by Price desc
offset 1 row
Fetch next 1 row only

--Air Coditioner is the 2nd highest priced goods after TV, going for a price of 1300.

--3.	Get the maximum price per category and the product name.
Select C.CategoryID,C.CategoryName, P.ProductName, P.Price
from Product P
Join Category C on P.CategoryID = C.CategoryID
Join ( Select CategoryID, Max(Price) as MaxPrice
	from Product 
	group by CategoryID) I
	on P.CategoryID =I.CategoryID
	and P.Price = I.MaxPrice

order by P.Price

--Ques 4.Supplier-wise count of products sorted by count in descending order.
-- in simple english, this means count how many products each supplier supplied, starting from the most number.

select S.SupplierName, count(distinct ProductName) Typecount_of_Product_supplied, sum(P.Quantity) Qtycount_of_product_supplied
from Product P
join Supplier S on S.SupplierID = P.SupplierID
group by S.SupplierName
order by sum(P.Quantity)

--Ques 5.	Fetch only the first word from the ProductName and append the price.

--select * from Product

select CONCAT(left(ProductName, 19 ), '_' , Price) ProductnamewithPrice
From Product

-- Ques 6.	Fetch products with odd prices.
select ProductName from Product
where price%2 = 1

--Ques 7: Create a view to fetch products with a price greater than $500.
create view vw_mid_prices as
select ProductName, Price from Product
where Price > 500

select * from [dbo].[vw_mid_prices]

--Ques 8:Create a procedure to update product prices by 15% where the category is 'Electronics' and the supplier is not 'SupplierA'

create procedure sp_price_update
as
begin
update P
set P.Price = P.Price * 1.15
from Product P
join Category C on C.CategoryID=P.CategoryID
Join Supplier S on S.SupplierID = P.SupplierID
where CategoryName = 'Electronics' and SupplierName != 'SupplierA'
end
go

exec [dbo].[sp_price_update]

--Ques 9. Create a stored procedure to fetch product details along with their category, and supplier details including error handling.
Create procedure SP_merge_all_tables
as
begin 
	begin try
		select
		* from Product P
		join Category C on C.CategoryID=P.CategoryID
		Join Supplier S on S.SupplierID = P.SupplierID
	end try
	begin catch
		Declare @ErrorMessage NVARCHAR(4000);
		Set @ErrorMessage =ERROR_MESSAGE();
		RaisError (@ErrorMessage, 16,1 );
	End catch 
end
go

exec [dbo].[SP_merge_all_tables]

--End of project

--Project achievement: With this project, i have been able to demonstrate my sound ability to not only create a database, but to create and 
--populate coherent tables,  and use sql to efficiently query the databae and provide answers to the Companies' questions.

--Project objective: To design a database that manages the inventory data of a Retail Company, and with the database, provide solutions
-- to critical questions the Company stakeholder's needed answers to, using my resourceful sql knowlege, in that way, guiding the Company to
-- make more data informed decisions that would boost productivity. 