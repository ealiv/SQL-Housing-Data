
-- Getting an idea of the data
SELECT TOP 25 *
FROM PortfolioProject2..NashHous

----------------------------------------------------------
-- Updating the date format
SELECT SaleDate, CONVERT(DATE, SaleDate) AS yyyy_mm__dd
FROM PortfolioProject2..NashHous

UPDATE NashHous
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE NashHous
ADD SaleDateConverted DATE

UPDATE NashHous
SET SaleDateConverted = CONVERT(DATE, SaleDate)

-- Checking if it worked
SELECT SaleDateConverted
FROM PortfolioProject2..NashHous

----------------------------------------------------------
-- Populating Property Address Data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject2..NashHous a
JOIN PortfolioProject2..NashHous b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject2..NashHous a
JOIN PortfolioProject2..NashHous b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

----------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject2..NashHous

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City

ALTER TABLE NashHous
ADD StAddress NVARCHAR(255)

UPDATE NashHous
SET StAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashHous
ADD City NVARCHAR(255)

UPDATE NashHous
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

-- Checking if it worked
SELECT TOP 25 *
FROM PortfolioProject2..NashHous
 
-- Alternative method (PARSENAME)
SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM PortfolioProject2..NashHous

ALTER TABLE PortfolioProject2..NashHous
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE PortfolioProject2..NashHous
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE PortfolioProject2..NashHous
ADD OwnerCity NVARCHAR(255)

UPDATE PortfolioProject2..NashHous
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE PortfolioProject2..NashHous
ADD OwnerState NVARCHAR(255)

UPDATE PortfolioProject2..NashHous
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

----------------------------------------------------------
-- Changing the names of some SoldAVacant (from Y/N to Yes/No)
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject2..NashHous
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM PortfolioProject2..NashHous

UPDATE PortfolioProject2..NashHous
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant	
						END

----------------------------------------------------------
-- Removing Dublicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate, 
				 LegalReference 
				 ORDER BY 
					UniqueID
					) row_num

FROM PortfolioProject2..NashHous
--ORDER BY ParcelID
)
DELETE -- Changed to DELETE from SELECT
FROM RowNumCTE
WHERE row_num > 1

----------------------------------------------------------
--Drop the last two digits of the parcelID since they are unnecessary

SELECT ParcelID, 
PARSENAME(REPLACE(ParcelID, '.','.'), 2)
FROM PortfolioProject2..NashHous

ALTER TABLE PortfolioProject2..NashHous
ADD ParcelIDSplit NVARCHAR(255);

UPDATE PortfolioProject2..NashHous
SET ParcelIDSplit = PARSENAME(REPLACE(ParcelID, '.','.'), 2)

----------------------------------------------------------
-- Removing Unnecessary Columns
 
 ALTER TABLE PortfolioProject2..NashHous
 DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertySplitAddress, PropertySplitCity, OwnerSplitAddress, OwnerCity, OwnerSplitState

 ALTER TABLE PortfolioProject2..NashHous
 DROP COLUMN PropertyAddress

 ALTER TABLE PortfolioProject2..NashHous
 DROP COLUMN ParcelID
 
-- Checking if it worked
 SELECT *
 FROM PortfolioProject2..NashHous



