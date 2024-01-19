--Cleaning data in sql queries

SELECT *
FROM NashvilleHousing


--Standarize date format

SELECT SaleDate, CONVERT(DATE, SALEDATE)--We want to convert SaleDate to Date only
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE, SALEDATE)--It didn't work

ALTER TABLE NashvilleHousing--This way did work
ADD SALEDATECONVERTED DATE;

UPDATE NashvilleHousing
SET SALEDATECONVERTED = CONVERT(DATE, SALEDATE)




---Populate PropertyAddress data using a self-join

SELECT *
FROM NashvilleHousing
--where PropertyAddress is null
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(A.PROPERTYADDRESS, B.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PROPERTYADDRESS = ISNULL(A.PROPERTYADDRESS, B.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE A.PropertyAddress IS NULL





--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PROPERTYADDRESS, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PROPERTYADDRESS, CHARINDEX(',', PropertyAddress) +1, LEN(PROPERTYADDRESS)) as Address

FROM NashvilleHousing
--Adding columns
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PROPERTYADDRESS, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PROPERTYADDRESS, CHARINDEX(',', PropertyAddress) +1, LEN(PROPERTYADDRESS))





--Simpler way to do it using Parsename, we needed to replace the ','for '.' since it only works for .'s
SELECT OwnerAddress
FROM NashvilleHousing


SELECT OwnerAddress
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From NashvilleHousing





--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SOLDASVACANT), COUNT(SOLDASVACANT)
FROM NashvilleHousing
GROUP BY SOLDASVACANT
ORDER BY 2

SELECT SOLDASVACANT
, CASE WHEN SOLDASVACANT = 'Y' THEN  'Yes'
	WHEN SOLDASVACANT = 'N' THEN  'No'
	ELSE SOLDASVACANT
	END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SOLDASVACANT = CASE WHEN SOLDASVACANT = 'Y' THEN  'Yes'
	WHEN SOLDASVACANT = 'N' THEN  'No'
	ELSE SOLDASVACANT
	END





--Remove duplicates

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
				  ) row_num


FROM NashvilleHousing
)


--DELETE
--FROM RowNumCTE
--WHERE row_num > 1

SELECT *
FROM RowNumCTE
WHERE row_num > 1


--With this code we created a Row_Number first to be able to create an identifier for every row.
--Then we created a CTE to make this code WHERE row_num > 1 and filter out those duplicates.
--Later we created a DELETE query to eliminate all the duplicates and last we ran the CTE again to check if there were any left.







--Delete unused columns

SELECT*
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
