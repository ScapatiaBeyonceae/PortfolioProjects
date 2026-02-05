/*

Cleaning Data in SQL Queries

*/

SELECT * 
FROM [dbo].[Housing]

----------------------------------------------------------------------------------------------------------

--- Standardize Date Format

SELECT * 
FROM [dbo].[Housing]

SELECT SaleDateCoverted, CONVERT(Date, SaleDate)
FROM [dbo].[Housing]

Update [dbo].[Housing]
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE [dbo].[Housing]
Add SaleDateCoverted Date;

Update [dbo].[Housing]
SET SaleDateCoverted = CONVERT(Date, SaleDate)
----------------------------------------------------------------------------------------------------------

--- Populating property address data

SELECT *
FROM [dbo].[Housing]
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.PropertyAddress, b.PropertyAddress, a.UniqueID, b.UniqueID, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[Housing] a
JOIN [dbo].[Housing] b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[Housing] a
JOIN [dbo].[Housing] b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------

--- Separating Address by Address lines

SELECT PropertyAddress
FROM [dbo].[Housing]

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM [dbo].[Housing]

ALTER TABLE [dbo].[Housing]
Add AddressLine1 Nvarchar(255);

Update [dbo].[Housing]
SET  AddressLine1 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [dbo].[Housing]
Add AddressLine2 Nvarchar(255);

Update [dbo].[Housing]
SET  AddressLine2 = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

---------------------
SELECT *
FROM [dbo].[Housing]

SELECT OwnerAddress
FROM [dbo].[Housing]

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM [dbo].[Housing]

ALTER TABLE [dbo].[Housing]
Add OwnerSpiltAddress Nvarchar(255);

Update [dbo].[Housing]
SET  OwnerSpiltAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE [dbo].[Housing]
Add OwnerSpiltCity Nvarchar(255);

Update [dbo].[Housing]
SET  OwnerSpiltCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE [dbo].[Housing]
Add OwnerSpiltState Nvarchar(255);

Update [dbo].[Housing]
SET  OwnerSpiltState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

----------------------------------------------------------------------------------------------------------

--- Changing Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [dbo].[Housing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END
FROM [dbo].[Housing]

UPDATE [dbo].[Housing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END
FROM [dbo].[Housing]
----------------------------------------------------------------------------------------------------------

--- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM [dbo].[Housing]

--ORDER BY ParcelID
)
SELECT *
FROM ROWNumCTE
WHERE row_num > 1
----------------------------------------------------------------------------------------------------------

--- DELETE Unused Columns

SELECT *
FROM [dbo].[Housing]

ALTER TABLE [dbo].[Housing]
DROP COLUMN SaleDate