--Nashville Housing Data Clean

SELECT * 
FROM nashvillehousing

--standardize date formatting

SELECT SaleDate,CONVERT(date,SaleDate)
FROM nashvillehousing

ALTER TABLE nashvillehousing
ADD SaleDateConverted date;

UPDATE nashvillehousing
SET saledateconverted = CONVERT(date,SaleDate)

SELECT SaleDateConverted,CONVERT(date,SaleDate)
FROM nashvillehousing

-- populate property address data

SELECT * 
FROM nashvillehousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID


SELECT nh1.ParcelID,nh1.PropertyAddress,nh2.ParcelID,nh2.PropertyAddress,ISNULL(nh1.PropertyAddress,nh2.PropertyAddress)
FROM nashvillehousing nh1
join nashvillehousing nh2 on nh1.ParcelID = nh2.ParcelID 
AND nh1.UniqueID <> nh2.UniqueID
WHERE nh1.PropertyAddress is null

UPDATE nh1
SET PropertyAddress = ISNULL(nh1.PropertyAddress,nh2.PropertyAddress)
FROM nashvillehousing nh1
join nashvillehousing nh2 on nh1.ParcelID = nh2.ParcelID 
AND nh1.UniqueID <> nh2.UniqueID
WHERE nh1.PropertyAddress is null

-- breaking out address into address,city,state

SELECT PropertyAddress
FROM nashvillehousing

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)[Address],
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))[City]
FROM nashvillehousing

ALTER TABLE nashvillehousing
Add PropertySplitAddress nvarchar(255);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE nashvillehousing
Add PropertySplitCity nvarchar(255);

UPDATE nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT PropertySplitAddress,PropertySplitCity
FROM nashvillehousing

SELECT owneraddress
FROM nashvillehousing

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM nashvillehousing

ALTER TABLE nashvillehousing
Add OwnerSplitAddress nvarchar(255);

UPDATE nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)
FROM nashvillehousing

ALTER TABLE nashvillehousing
Add OwnerSplitCity nvarchar(255);

UPDATE nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)
FROM nashvillehousing

ALTER TABLE nashvillehousing
Add OwnerSplitState nvarchar(255);

UPDATE nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM nashvillehousing

SELECT * 
FROM nashvillehousing

-- Clean up SoldasVacant field

SELECT DISTINCT(SoldasVacant),Count(SoldasVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldasVacant = 'Y' THEN 'YES'
WHEN SoldasVacant = 'N' THEN 'NO' 
ELSE SoldasVacant END AS SoldasVacant
FROM nashvillehousing

UPDATE nashvillehousing
SET SoldAsVacant = CASE WHEN SoldasVacant = 'Y' THEN 'YES'
WHEN SoldasVacant = 'N' THEN 'NO' 
ELSE SoldasVacant END

-- remove duplicates

WITH RowNumCTE AS (
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY UniqueID)
			row_num
FROM nashvillehousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


WITH RowNumCTE AS (
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY UniqueID)
			row_num
FROM nashvillehousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

-- delete unused columns

SELECT *
FROM nashvillehousing
order by UniqueID

ALTER TABLE nashvillehousing
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict,SaleDate

