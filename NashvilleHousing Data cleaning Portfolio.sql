/*

Cleaning data in SQL queries

*/

SELECT *
FROM [Portfolio Project]..NashvilleHousing


--Standadize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate) AS NewDate
FROM [Portfolio Project]..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate) 

SELECT *
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Populate Property Address

SELECT *
FROM [Portfolio Project]..NashvilleHousing
--order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	ON a.parcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	ON a.parcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null



--Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM [Portfolio Project]..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
 FROM [Portfolio Project]..NashvilleHousing

 ALTER TABLE NashvilleHousing
 Add PrAddress Nvarchar(255);

 UPDATE NashvilleHousing
 SET PrAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

 ALTER TABLE NashvilleHousing
 Add PrCity Nvarchar(255);

 UPDATE NashvilleHousing
 SET PrCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

 SELECT *
FROM [Portfolio Project]..NashvilleHousing



SELECT OwnerAddress
FROM [Portfolio Project]..NashvilleHousing



SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
 Add OwAddress Nvarchar(255);

 UPDATE NashvilleHousing
 SET OwAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


 ALTER TABLE NashvilleHousing
 Add OwCity Nvarchar(255);

 UPDATE NashvilleHousing
 SET OwCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


 ALTER TABLE NashvilleHousing
 Add OwState Nvarchar(255);

 UPDATE NashvilleHousing
 SET OwState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)



 SELECT *
FROM [Portfolio Project]..NashvilleHousing


DELETE 
FROM
[Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN Address, City;

SELECT *
FROM [Portfolio Project]..NashvilleHousing




--Change Y and N to Yes and No in "Sold as Vacant" field


SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From [Portfolio Project]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
FROM [Portfolio Project]..NashvilleHousing


UPDATE  NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END




SELECT *
FROM [Portfolio Project]..NashvilleHousing


--Remove Duplicates


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

FROM [Portfolio Project]..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


--Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate