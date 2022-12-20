SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--Standardise Date format

SELECT SaleDate,CONVERT(Date,SaleDate) as Date
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate=CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

SELECT SaleDateConverted
From PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDateConverted= CONVERT(Date,SaleDate)

--populate property address data

SELECT *
From PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID=b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID=b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

--breaking out address into individual columns

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as NewAddress
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousing

--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT (SoldAsVacant), COUNT (SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant=
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No'
ELSE SoldAsVacant
END

--Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
ORDER BY UniqueId)row_num
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num>1
ORDER BY PropertyAddress

DELETE
FROM RowNumCTE
WHERE row_num>1

--Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate