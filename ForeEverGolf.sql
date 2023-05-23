rem ForeEver Golf
rem
rem creating tables and adding constraints for ForeEver Golf using the provided physical ERD


-- To rerun script multiple times, the script starts by dropping the tables

spool c:/cprg250s/ForeEver_Golf_Grp8.txt

--put your sql commands below


set echo on


--drop all tables, child tables first, then parent tables
DROP TABLE ForeEver_Customer_Course;
DROP TABLE ForeEver_Rewards;
DROP TABLE fg_customerReview;
DROP TABLE ForeEver_Reservation;
DROP TABLE ForeEver_Credit_Cards;
drop table fg_teeTimes; 

DROP TABLE ForeEver_Customer;
DROP TABLE ForeEver_Course_Information;



--create table ForeEver_Course_Information
CREATE TABLE ForeEver_Course_Information
(
CourseName VARCHAR2(50) CONSTRAINT FE_CINFO_NAME_PK PRIMARY KEY,
city VARCHAR2(50) CONSTRAINT FE_CINFO_CITY_NN NOT NULL,
Prov VARCHAR2(50) CONSTRAINT FE_CINFO_PROV_NN NOT NULL,
PostalCode VARCHAR2(50) CONSTRAINT FE_CINFO_PCODE_NN NOT NULL, 
country VARCHAR2(50) CONSTRAINT FE_CINFO_COUNTRY_NN NOT NULL,
AverageReviewRating Number(1) CONSTRAINT FE_CINFO_AVGREV_NN NOT NULL,
Description VARCHAR2(50) CONSTRAINT FE_CINFO_DESC_NN NOT NULL,
YearBuild number(4) CONSTRAINT FE_CINFO_YB_NN NOT NULL,
LengthInYards number CONSTRAINT FE_CINFO_LIY_NN NOT NULL,
CONSTRAINT FE_CINFO_AVGREV_CK CHECK(AverageReviewRating >=1 AND AverageReviewRating <= 5),
CONSTRAINT FE_CINFO_PCODE_CK CHECK(REGEXP_LIKE(PostalCode,'[A-Z]{1}[0-9]{1}[A-Z]{1}[0-9]{1}[A-Z]{1}[0-9]{1}'))
);
DESC ForeEver_Course_Information;



--create table ForeEver_Customer
CREATE TABLE ForeEver_Customer
(
customerNumber NUMBER CONSTRAINT FE_customerNumber_PK PRIMARY KEY, 
firstName VARCHAR2(25) CONSTRAINT Customer_firstName_NN NOT NULL, 
lastName VARCHAR2(25) CONSTRAINT Customer_lastName_NN NOT NULL,
Email VARCHAR2(60) CONSTRAINT Customer_email_NN NOT NULL,  
creditAmount  NUMBER CONSTRAINT Customer_creditAmount_NN NOT NULL,  
CONSTRAINT Customer_email_CK CHECK (Email like '%_@__%.__%'),
CONSTRAINT Customer_creditAmount_CK CHECK (creditAmount >= 0)
);

DESC ForeEver_Customer;

--create table ForeEver_Customer_Course
CREATE TABLE ForeEver_Customer_Course
(
CustomerNumber NUMBER CONSTRAINT FE_CC_CNUM_NN NOT NULL,
CourseName VARCHAR2(50) CONSTRAINT FE_CC_CNAME_NN NOT NULL, 
CustomerNumber_CourseName VARCHAR2(52) CONSTRAINT FE_CC_CNCN_PK PRIMARY KEY,
CONSTRAINT FE_CC_CNUM_FK1 FOREIGN KEY(CustomerNumber) REFERENCES ForeEver_Customer(CustomerNumber), 
CONSTRAINT FE_CC_CNUM_CK CHECK(CustomerNumber >= 0),
CONSTRAINT FE_CC_CNAME_FK2 FOREIGN KEY(CourseName) REFERENCES ForeEver_Course_Information(CourseName)
);


DESC ForeEver_Customer_Course;


--create table for tee Times, use alter table commands to add constraints 

CREATE TABLE fg_teeTimes 
(
teeTimeId NUMBER CONSTRAINT Tee_Times_Id_PK PRIMARY KEY,
teeTimes DATE CONSTRAINT Tee_Times_Duration_NN NOT NULL, 
pricePerPlayer NUMBER(6,2) CONSTRAINT Tee_Times_Price_NN NOT NULL, 
cartFlag NUMBER(1) CONSTRAINT Tee_Times_Cart_Flag_NN NOT NULL, 
numberOfHoles NUMBER CONSTRAINT Tee_Times_Holes_NN NOT NULL,
availableSpace NUMBER CONSTRAINT Tee_Times_Spaces_NN NOT NULL,
cartIncluded char(1) CONSTRAINT Tee_Times_Cart_Included_NN NOT NULL,  
Course_ID VARCHAR2(50)
);

ALTER TABLE fg_teeTimes
add CONSTRAINT Tee_Times_Course_ID_FK FOREIGN KEY(Course_ID) REFERENCES ForeEver_Course_Information(CourseName)
add CONSTRAINT Tee_Times_Holes_CK CHECK(numberOfHoles == 9 or numberOfHoles == 18),
add CONSTRAINT Tee_Times_Price_CK CHECK(pricePerPlayer >= 0),
add CONSTRAINT Tee_Times_Cart_Included_CK CHECK(SUBSTR(Product_id,1,1) = 'Y' OR SUBSTR(Product_id,1,1) = 'N'),
add CONSTRAINT Tee_Times_Cart_Flag_CK CHECK(cartFlag == 0 OR cartFlag == 1),
add CONSTRAINT Tee_Times_Spaces_CK CHECK(availableSpace <= 4)


DESC fg_teeTimes

--create table ForeEver_Rewards
CREATE TABLE ForeEver_Rewards
(
promoCode VARCHAR2(18) CONSTRAINT FE_promoCode_PK PRIMARY KEY,
isUsed NUMBER(1) CONSTRAINT Reward_Is_Used_NN NOT NULL,
issuedDate DATE CONSTRAINT Reward_Date_Issued_NN NOT NULL, 
promocodeValue NUMBER(6,2) CONSTRAINT Reward_value_NN NOT NULL,
expiryDate NUMBER CONSTRAINT Reward_Expiry_Date_NN NOT NULL,
CONSTRAINT Reward_Is_Used_CK CHECK(isUsed >= 0 AND isUsed <= 1),
CONSTRAINT Reward_Expiry_Date_CK CHECK(REGEXP_LIKE(expiryDate,'[0-9]{4}') AND (expiryDate >= 1000 AND expiryDate < 1300))
);

DESC ForeEver_Rewards;

--create table ForeEver_Credit_Cards
CREATE TABLE ForeEver_Credit_Cards 
( 
cardNumber NUMBER CONSTRAINT Credit_Card_Number_PK PRIMARY KEY, 
cardName VARCHAR2(25) CONSTRAINT Credit_Card_Name_NN NOT NULL, 
expiryDate NUMBER CONSTRAINT Credit_Card_EXP_NN NOT NULL,
default_card NUMBER(1) CONSTRAINT Credit_Card_Default_NN NOT NULL,  
Customer_ID NUMBER,
CONSTRAINT Credit_Card_Default_CK CHECK(default_card >= 0 AND default_card <= 1),
CONSTRAINT Credit_Card_EXP_CK CHECK(REGEXP_LIKE(expiryDate,'[0-9]{4}')),
CONSTRAINT Credit_Card_Customer_Id_FK FOREIGN KEY(Customer_ID) REFERENCES ForeEver_Customer(customerNumber)
); 

DESC ForeEver_Credit_Cards;

--create table ForeEver_Reservation
CREATE TABLE ForeEver_Reservation
(
reservationId NUMBER CONSTRAINT Reservation_ID_PK PRIMARY KEY, 
greenFees NUMBER(6,2) CONSTRAINT Reservation_Green_Fees_NN NOT NULL, 
taxes NUMBER(6,2) CONSTRAINT Reservation_Tax_NN NOT NULL, 
amountCharged NUMBER(6,2) CONSTRAINT Reservation_Amount_NN NOT NULL, 
numberOfPlayer NUMBER CONSTRAINT Reservation_Number_Of_Player_NN NOT NULL, 
Customer_ID NUMBER,  
Tee_Time_ID NUMBER,
Credit_Card_ID NUMBER,
CONSTRAINT Reservation_Customer_Id_FK FOREIGN KEY(Customer_ID) REFERENCES ForeEver_Customer(customerNumber),
CONSTRAINT Reservation_Tee_Time_Id_FK FOREIGN KEY(Tee_Time_ID) REFERENCES fg_teeTimes(teeTimeId),
CONSTRAINT Reservation_Credit_Card_Id_FK FOREIGN KEY(Credit_Card_ID) REFERENCES ForeEver_Credit_Cards(cardNumber)
); 

DESC ForeEver_Reservation; 




--create table fg_customerReview; 
CREATE TABLE fg_customerReview 
(
reviewTitle VARCHAR2(25) CONSTRAINT customerReview_Title_PK PRIMARY KEY,
starRating NUMBER CONSTRAINT customerReview_Rating_NN NOT NULL,
reviewComments VARCHAR2(255) CONSTRAINT customerReview_Comments_NN NOT NULL,
Reservation_Id NUMBER,
CONSTRAINT customerReview_Rating_CK CHECK(REGEXP_LIKE(starRating,'[1-5]{1}')),
CONSTRAINT customerReview_Reservation_Id_FK FOREIGN KEY(Reservation_Id) REFERENCES ForeEver_Reservation(reservationId)
); 

DESC fg_customerReview; 


  




--sql code above
spool off
