SELECT *
FROM NashvilleHousing

--Standardize Date Format

SELECT SaleDateConverted, convert(Date,SaleDate)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = convert(Date,SaleDate)

--Populate Property Address Data

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NashvilleHousing A
 JOIN NashvilleHousing B
  ON A.ParcelID=B.ParcelID
  AND A.[UniqueID ] <>  B.[UniqueID ]
  WHERE A.PropertyAddress IS NULL
  
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NashvilleHousing A
 JOIN NashvilleHousing B
  ON A.ParcelID=B.ParcelID
  AND A.[UniqueID ] <>  B.[UniqueID ]
  WHERE A.PropertyAddress IS NULL


--Breaking out Address into Individual Columns(Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address

FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


SELECT *
FROM NashvilleHousing

--Breaking out By OwnerAddress

SELECT OwnerAddress
FROM NashvilleHousing

SELECT PARSENAME (REPLACE(OwnerAddress,',' , '.'), 3)
,PARSENAME (REPLACE(OwnerAddress,',' , '.'), 2)
,PARSENAME (REPLACE(OwnerAddress,',' , '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnersplitAddress nchar(255);

UPDATE NashvilleHousing
SET OwnersplitAddress = PARSENAME (REPLACE(OwnerAddress,',' , '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnersplitCity nchar(255);

UPDATE NashvilleHousing
SET OwnersplitCity =PARSENAME (REPLACE(OwnerAddress,',' , '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnersplitState nchar(255);

UPDATE NashvilleHousing
SET OwnersplitState = PARSENAME (REPLACE(OwnerAddress,',' , '.'), 1)

SELECT *
FROM NashvilleHousing


--Change Y AND N to YES AND  NO FROM "SOLD AS VACANT" Field

SELECT DISTINCT(SoldAsVacant) , COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant 
ORDER BY 2

SELECT SoldAsVacant ,
CASE WHEN SoldAsVacant = 'Y'  THEN 'YES'
     WHEN SoldAsVacant = 'N'  THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y'  THEN 'YES'
     WHEN SoldAsVacant = 'N'  THEN 'NO'
	 ELSE SoldAsVacant
	 END

--Remove Duplicates

WITH ROWNUMCTE AS (
SELECT *,
Row_number () OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID
) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)


DELETE 
FROM ROWNUMCTE
WHERE ROW_NUM > 1
ORDER BY PropertyAddress

--To check whether duplicates are deleted
WITH ROWNUMCTE AS (
SELECT *,
Row_number () OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID
) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM ROWNUMCTE
WHERE ROW_NUM > 1


--Delete unused Columns

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN Landuse, TaxDistrict
