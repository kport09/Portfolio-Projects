SELECT *
FROM PortfolioProject..NashvilleHousingData
ORDER BY [UniqueID ];

/*
Cleaning Data in SQL Queries
*/


-----------------------------------------Standardize Date Format-------------------------------------------

SELECT SaleDate, CONVERT(DATE, SaleDate) AS Standard_Date
FROM PortfolioProject..NashvilleHousingData;

UPDATE NashvilleHousingData
SET SaleDate = CONVERT(DATE, SaleDate);

ALTER TABLE NashvilleHousingData
ADD SaleDateConverted Date;

UPDATE NashvilleHousingData
SET SaleDateConverted = CONVERT(DATE, SaleDate);

SELECT SaleDateConverted 
FROM PortfolioProject..NashvilleHousingData;

--Drop an altered column

ALTER TABLE NashvilleHousingData
DROP COLUMN SalesDateConverted

--Check if updated

SELECT *
FROM PortfolioProject..NashvilleHousingData



--------------------------------Populate Property Address Data---------------------------------

SELECT *
FROM PortfolioProject..NashvilleHousingData
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT NHD_1.[UniqueID ], NHD_1.ParcelID, NHD_1.PropertyAddress, NHD_2.[UniqueID ], NHD_2.ParcelID, NHD_2.PropertyAddress, ISNULL(NHD_1.PropertyAddress, NHD_2.PropertyAddress) AS Updated_PropertyAddress
FROM PortfolioProject..NashvilleHousingData AS NHD_1
INNER JOIN PortfolioProject..NashvilleHousingData AS NHD_2
	ON NHD_1.ParcelID = NHD_2.ParcelID
	AND NHD_1.[UniqueID ] <> NHD_2.[UniqueID ]
WHERE NHD_1.PropertyAddress IS NULL
ORDER BY NHD_1.[UniqueID ];

UPDATE NHD_1
SET PropertyAddress = ISNULL(NHD_1.PropertyAddress, NHD_2.PropertyAddress)
FROM PortfolioProject..NashvilleHousingData AS NHD_1
INNER JOIN PortfolioProject..NashvilleHousingData AS NHD_2
	ON NHD_1.ParcelID = NHD_2.ParcelID
	AND NHD_1.[UniqueID ] <> NHD_2.[UniqueID ]
WHERE NHD_1.PropertyAddress IS NULL;



------------------------------------Breaking Out Address Into Individual Columns (Address, City, State)---------------------------------

SELECT *
FROM PortfolioProject..NashvilleHousingData;

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousingData;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousingData;

ALTER TABLE PortfolioProject..NashvilleHousingData
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE PortfolioProject..NashvilleHousingData
ADD PropertySplitCityAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousingData
SET PropertySplitCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

--Using another way with "PARSENAME"

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousingData;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address
FROM PortfolioProject..NashvilleHousingData;

ALTER TABLE PortfolioProject..NashvilleHousingData
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE PortfolioProject..NashvilleHousingData
ADD OwnerSplitCityAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousingData
SET OwnerSplitCityAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE PortfolioProject..NashvilleHousingData
ADD OwnerSplitStateAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousingData
SET OwnerSplitStateAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);



----------------------------Change Y and N to Yes and No in "SoldAsVacant" column-------------------------------------

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldASVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM PortfolioProject..NashvilleHousingData;

UPDATE PortfolioProject..NashvilleHousingData
SET SoldAsVacant = 	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						 WHEN SoldASVacant = 'N' THEN 'No'
						 ELSE SoldAsVacant
						 END;



---------------------------------------Remove Duplicates------------------------------------
--Not Standard Practice to Remove Duplicates in Data

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
	ORDER BY UniqueID) AS row_num
FROM PortfolioProject..NashvilleHousingData)
DELETE
FROM RowNumCTE
WHERE row_num > 1;

--Check if process was successful

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
	ORDER BY UniqueID) AS row_num
FROM PortfolioProject..NashvilleHousingData)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;



---------------------------Delete Unused Columns------------------------
--Not advisable to use over raw data

ALTER TABLE PortfolioProject..NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE PortfolioProject..NashvilleHousingData
DROP COLUMN SaleDate;

SELECT *
FROM PortfolioProject..NashvilleHousingData