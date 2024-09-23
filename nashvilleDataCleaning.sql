-- working data
SELECT *
FROM nash_ville;

-- Date Standardization
SELECT
	SaleDate
	,CONVERT(DATE,SaleDate) standardized_sale_date
FROM nash_ville


ALTER TABLE nash_ville
ADD standardized_sale_date DATE;

UPDATE nash_ville
SET standardized_sale_date = CONVERT(DATE,SaleDate);

--
--SELECT 
	--SaleDate
	--,standardized_sale_date
--FROM nash_ville;

-- Converting Y and N into Yes And No in SoldasVaccant Column
SELECT
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM nash_ville

UPDATE nash_ville
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	
-- confirm
SELECT DISTINCT(SoldAsVacant)
FROM nash_ville;

--- SPLIT property_address
-- Address
ALTER TABLE nash_ville
ADD split_property_address VARCHAR(100);

UPDATE nash_ville
SET split_property_address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

-- City
ALTER TABLE nash_ville
ADD split_property_city VARCHAR(100);

UPDATE nash_ville
SET split_property_city = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

----------------------- 
SELECT
	PropertyAddress
	,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
	,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
FROM nash_ville

---- Splitting the Owner Address
SELECT
	OwnerAddress
	,PARSENAME(REPLACE(OwnerAddress,',','.'),3) OwnerAddress
	,PARSENAME(REPLACE(OwnerAddress,',','.'),2) OwnerCity
	,PARSENAME(REPLACE(OwnerAddress,',','.'),1) OwnerState
FROM nash_ville
--Address
ALTER TABLE nash_ville
ADD owner_Address VARCHAR(100);

UPDATE nash_ville
SET owner_Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3);
-- City
ALTER TABLE nash_ville
ADD ownerCity VARCHAR(100);

UPDATE nash_ville
SET ownerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);
-- State
ALTER TABLE nash_ville
ADD owner_State VARCHAR(100);

UPDATE nash_ville
SET owner_State = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

---------- Populating Property Address for the null values
SELECT
	*
FROM nash_ville
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.PropertyAddress,b.ParcelID,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM nash_ville a
JOIN nash_ville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET	a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM nash_ville a
JOIN nash_ville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]







-----
--------- REMOVING DUPLICATES
-- USING ROW NUMBER(WINDOW FUNCTION)

SELECT
	ROW_NUMBER() OVER (PARTITION BY 
	ParcelID,
	PropertyAddress,
	SaleDate,SalePrice,
	LegalReference
	ORDER BY [UniqueID ])
FROM nash_ville

-----
-- STORING THE DUPLICATES INTO A TEMP TABLE
DROP TABLE IF EXISTS #duplicates
CREATE TABLE #duplicates
(
[UniqueID ] float,
ParcelID varchar(100),
LandUse varchar(100),
--SaleDate datetime,
SalePrice float,
LegalReference varchar(100),
SoldAsVacant varchar(100),
ownerName varchar(100),
-- ownerAddress varchar(100),
Acreage float,
TaxDistrict varchar(100),
LandValue float,
buildingValue float,
totalValue float,
yearBuilt float,
Bedrooms float,
fullBath float,
halfBath float,
standardized_sale_date date,
property_address varchar(50),
property_city varchar(50),
owner_address varchar(50),
owner_city varchar(50),
owner_state varchar(50),
row_num float
)


--INSERT INTO #duplicates
--SELECT *
--FROM duplicate_rows 
--WHERE row_num > 1
INSERT INTO #duplicates
SELECT
	*
	,ROW_NUMBER() OVER (PARTITION BY 
	ParcelID
	--,PropertyAddress
	--,SaleDate
	,SalePrice
	,LegalReference
	ORDER BY [UniqueID ]) as row_num
FROM nash_ville

-- Gives us 123 duplicates
SELECT *
FROM #duplicates
WHERE  row_num > 1

--- Creating a table to store duplicates
DROP TABLE IF EXISTS #duplicates_store
CREATE TABLE #duplicates_store
(
[UniqueID ] float,
ParcelID varchar(100),
LandUse varchar(100),
--SaleDate datetime,
SalePrice float,
LegalReference varchar(100),
SoldAsVacant varchar(100),
ownerName varchar(100),
-- ownerAddress varchar(100),
Acreage float,
TaxDistrict varchar(100),
LandValue float,
buildingValue float,
totalValue float,
yearBuilt float,
Bedrooms float,
fullBath float,
halfBath float,
standardized_sale_date date,
property_address varchar(50),
property_city varchar(50),
owner_address varchar(50),
owner_city varchar(50),
owner_state varchar(50),
row_num float
)
INSERT INTO #duplicates_store
SELECT *
FROM #duplicates
WHERE  row_num > 1

--- Deleting the duplicates from the main table
WITH duplicates AS 
(
SELECT
	*
	,ROW_NUMBER() OVER (PARTITION BY 
	ParcelID
	--,PropertyAddress
	--,SaleDate
	,SalePrice
	,LegalReference
	ORDER BY [UniqueID ]) row_num
FROM nash_ville
)
DELETE 
FROM duplicates
WHERE row_num > 1





------- USING CTEs to detect Duplicates
WITH duplicates AS 
(
SELECT
	*
	,ROW_NUMBER() OVER (PARTITION BY 
	ParcelID
	--,PropertyAddress
	--,SaleDate
	,SalePrice
	,LegalReference
	ORDER BY [UniqueID ]) row_num
FROM nash_ville
)
--INSERT INTO #duplicates
--SELECT *
--FROM duplicate_rows 
--WHERE row_num > 1;
SELECT *
FROM duplicates 
--WHERE row_num > 1




---- Delete Invalid Columns
ALTER TABLE nash_ville
DROP COLUMN saleDate,OwnerAddress,PropertyAddress




--------- ---------
SELECT
	*
FROM nash_ville
-- WHERE PropertyAddress IS NULL