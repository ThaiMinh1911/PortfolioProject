SELECT *
FROM PortfolioProject.dbo.Housing

--- Standardize Date Format

SELECT SaleDate, CONVERT (Date, SaleDate)
FROM PortfolioProject.dbo.Housing

UPDATE PortfolioProject.dbo.Housing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE PortfolioProject.dbo.Housing
ADD SaleDateConverted Date;

UPDATE PortfolioProject.dbo.Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject.dbo.Housing

--- Populate property Address Data

SELECT PropertyAddress
FROM PortfolioProject.dbo.Housing
WHERE PropertyAddress is null

--- ParcelID and Address are usually the same so we can use the ParcelID to fill the addresses that are currently blank

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.Housing AS a
JOIN PortfolioProject.dbo.Housing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.Housing AS a
JOIN PortfolioProject.dbo.Housing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

SELECT PropertyAddress
FROM PortfolioProject.dbo.Housing
WHERE PropertyAddress is null

---> No null value in the PropertyAddress Column in the dataset

--- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject.dbo.Housing
--- The , is the delimeter between the address and the state name

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)) AS Address
FROM PortfolioProject.dbo.Housing
--- Delete the comma from the address and create the city name column
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City 
FROM PortfolioProject.dbo.Housing

ALTER TABLE PortfolioProject.dbo.Housing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProject.dbo.Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE Housing
ADD PropertySplitCity NVARCHAR(255);

UPDATE PortfolioProject.dbo.Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.Housing

--- Split owner address
SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.Housing


ALTER TABLE PortfolioProject.dbo.Housing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE PortfolioProject.dbo.Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE PortfolioProject.dbo.Housing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE PortfolioProject.dbo.Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE PortfolioProject.dbo.Housing
ADD OwnerSplitState NVARCHAR(255);

UPDATE PortfolioProject.dbo.Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject.dbo.Housing

--- Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.Housing
GROUP BY SoldAsVacant
ORDER BY 2 ASC

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.Housing

UPDATE PortfolioProject.dbo.Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

--- Remove Duplicates
--- Create Temporary Table to work on
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) AS row_num
FROM PortfolioProject.dbo.Housing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1


SELECT *
FROM PortfolioProject.dbo.Housing

--- Delete Unused Columns
SELECT *
FROM PortfolioProject.dbo.Housing

ALTER TABLE PortfolioProject.dbo.Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.Housing
DROP COLUMN SaleDate