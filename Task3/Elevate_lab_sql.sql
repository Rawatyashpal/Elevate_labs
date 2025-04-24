create database ecommerce
use ecommerce

-- (Create table1) Customers table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Country VARCHAR(50)
);


-- (Create table2) Products table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Price DECIMAL(10, 2),
    Category VARCHAR(50)
);


-- (Create table3) Orders table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- (Create table4) OrderDetails table
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);


--Insert data on table1 Customers
INSERT INTO Customers VALUES
(1, 'Alice', 'alice@example.com', 'USA'),
(2, 'Bob', 'bob@example.com', 'India'),
(3, 'Charlie', 'charlie@example.com', 'UK');


--Insert data on table2  Products
INSERT INTO Products VALUES
(1, 'Laptop', 1000, 'Electronics'),
(2, 'Phone', 500, 'Electronics'),
(3, 'Shoes', 100, 'Apparel');


-- Insert data on table3 Orders
INSERT INTO Orders VALUES
(1, 1, '2025-04-01'),
(2, 2, '2025-04-03'),
(3, 1, '2025-04-07');

-- Insert data on table4 OrderDetails
INSERT INTO OrderDetails VALUES
(1, 1, 1, 1),
(2, 1, 2, 2),
(3, 2, 3, 1),
(4, 3, 2, 1);

--(a) Get customers from USA, ordered by name
SELECT * FROM Customers
WHERE Country = 'USA'
ORDER BY Name;

-- Total quantity of products ordered grouped by ProductID
SELECT ProductID, SUM(Quantity) AS TotalSold
FROM OrderDetails
GROUP BY ProductID;




--(b) INNER JOIN to get order details with product names
SELECT o.OrderID, p.ProductName, od.Quantity
FROM Orders o
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID;

-- LEFT JOIN: Show all customers with their orders (if any)
SELECT c.Name, o.OrderID
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID;

-- RIGHT JOIN: Show all orders and corresponding customers
SELECT o.OrderID, c.Name
FROM Customers c
RIGHT JOIN Orders o ON c.CustomerID = o.CustomerID;




-- (c) Customers who ordered more than 1 product in a single order
SELECT DISTINCT CustomerID
FROM Orders
WHERE OrderID IN (
    SELECT OrderID
    FROM OrderDetails
    GROUP BY OrderID
    HAVING SUM(Quantity) > 1
);

-- Total revenue generated
SELECT SUM(p.Price * od.Quantity) AS TotalRevenue
FROM OrderDetails od
JOIN Products p ON od.ProductID = p.ProductID;




--(d) Average order value
SELECT AVG(OrderValue) AS AvgOrderValue
FROM (
    SELECT o.OrderID, SUM(p.Price * od.Quantity) AS OrderValue
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    GROUP BY o.OrderID
) AS OrderValues;





-- (e) View for product sales
IF OBJECT_ID('ProductSales', 'V') IS NOT NULL
    DROP VIEW ProductSales;
GO

CREATE VIEW ProductSales AS
SELECT p.ProductName, SUM(od.Quantity) AS TotalSold
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY p.ProductName;
GO

IF OBJECT_ID('CustomerOrderSummary', 'V') IS NOT NULL
    DROP VIEW CustomerOrderSummary;
GO

CREATE VIEW CustomerOrderSummary AS
SELECT c.Name, COUNT(o.OrderID) AS TotalOrders
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.Name;
GO

