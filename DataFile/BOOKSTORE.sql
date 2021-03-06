/* Create AUTHOR Table */
CREATE TABLE AUTHOR(
AuthorID INT not null,
FName varchar(45) not null,
        LName varchar(45) not null,
        Mname varchar(45) default "NoMiddle",
PRIMARY KEY(AuthorID)
        );
      
/* Create WAREHOUSE Table */
CREATE TABLE WAREHOUSE(
WareID INT not null,
WarAddress varchar(100) not null UNIQUE,
        Rent  DOUBLE not null,
Zipcode  char(5)  not null,
        Space DOUBLE not null,
PRIMARY KEY(WareID)
       );

/* Create  PUBLISHER Table */
CREATE TABLE PUBLISHER(
PubID INT not null,
        PubAddress varchar(100) not null UNIQUE,
        PName  varchar(45) not null,
PRIMARY KEY(PubID)
       );

/* Create  BOOK Table */
CREATE TABLE BOOK(
ISBN char(10) not null,
        PubID INT not null,
        Price DOUBLE not null,
        Title varchar(45) not null,
        BKLanguage varchar(15) not null,
PRIMARY KEY (ISBN),
        FOREIGN KEY (PubID) REFERENCES PUBLISHER (PubID)
        );
        
/* Create CUSTOMER Table */
CREATE TABLE CUSTOMER(
CustomerID INT not null,
CFName varchar(45) not null,
        CLName varchar(45) not null,
        CMName varchar(45) default "NoMiddle",
        CPhNum char(10) not null,
        Email varchar(45) not null,
PRIMARY KEY (CustomerID)
       );

/* Create TRANSACTS Table */
CREATE TABLE TRANSACTS(
OrderNum char(15) not null,
        CustomerID INT not null,
        ISBN char(10) not null,
        Quantity INT not null,
        Amount INT not null,
        BDate TIMESTAMP not null,
        TraAddress varchar(100) not null,
        CCType varchar(45) not null,
PRIMARY KEY (OrderNum),
FOREIGN KEY (ISBN) REFERENCES BOOK (ISBN),
        FOREIGN KEY (CustomerID) REFERENCES CUSTOMER (CustomerID)
       );

/* Create WRITTENBY Table */
CREATE TABLE WRITTENBY(
ISBN  char(10) not null,
        AuthorID INT not null,
PRIMARY KEY(ISBN, AuthorID),
        FOREIGN KEY (ISBN) REFERENCES BOOK (ISBN),
        FOREIGN KEY (AuthorID) REFERENCES Author (AuthorID)
       );

/* Create STORES Table */
CREATE TABLE STORES(
ISBN  char(10) not null,
        WareID  INT not null,
        BKCondition varchar(45) not null,
        StockNum INT not null,
PRIMARY KEY(ISBN, WareID),
        FOREIGN KEY (ISBN) REFERENCES BOOK (ISBN),
        FOREIGN KEY (WareID) REFERENCES WAREHOUSE (WareID)
       );

/* Create indexing*/

/* Searching for books for a certain price */
CREATE INDEX i_Price ON BOOK (Price);

/*Seprating books into different stock conditions*/
CREATE INDEX i_StockNum ON STORES (StockNum);

/*Seprating books into different using conditions*/
CREATE INDEX i_BKCondition ON STORES (BKCondition);

/*Deriving how many books customers brought*/
CREATE INDEX i_Quantity ON TRANSACTS (Quantity);

/*Deriving how much customers spent*/
CREATE INDEX i_Amount ON TRANSACTS (Amount);

/*This view displays a list of most popular book(sold most money) 
ISBN of each author with the book ISBN, Title, sold amount, sold quantity, price*/
CREATE VIEW Best_BOOK_EachAuthor AS SELECT AuthorID, ISBN, Title, MAX(AmountSold) AS AmountSold, QuantitySold, SinglePrice
FROM (SELECT A.AuthorID,A.FName,A.LName,B.ISBN,B.Title,SUM(T.Amount) AS AmountSold, SUM(T.Quantity) AS QuantitySold,B.Price AS SinglePrice
  from BOOK B, AUTHOR A, WRITTENBY W,TRANSACTS T
  WHERE B.ISBN = W.ISBN AND A.AuthorID = W.AuthorID AND B.ISBN= T.ISBN
  GROUP BY B.ISBN) AS Author_sold
GROUP BY AuthorID;

/*This view displays the total amount paid by each customer 
include all the transactions in the system.*/
CREATE VIEW Total_Consume_EachCustomer
AS SELECT C.CustomerID,C.CFName,C.CLName,SUM(T.Amount) AS TotalConsume 
   FROM CUSTOMER C, TRANSACTS T
   WHERE C.CustomerID = T.CustomerID
   GROUP BY C.CustomerID
   ORDER BY C.CustomerID;