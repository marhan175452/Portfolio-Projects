

// -- Standardize Date Format

SELECT SaleDate, CONVERT (Date, SaleDate)
From [Portfolio Project].[dbo].[Nashville ]

-- Populate Property Address Data

SELECT PropertyAddress
From [Portfolio Project].[dbo].[Nashville ]
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project].[dbo].[Nashville ] a 
JOIN [Portfolio Project].[dbo].[Nashville ] b
 on a.ParcelID = b.ParcelID
 AND a.[UniqueID] <> b.[UniqueID]
 WHERE a.PropertyAddress IS NULL

 UPDATE a
 SET PropertyAddress = ISNULL(a.PropertyAddress, 'No Address')
 FROM [Portfolio Project].[dbo].[Nashville ] a
 JOIN [Portfolio Project].[dbo].[Nashville ] b 
 on a.ParcelID = b.ParcelID
 AND a.[UniqueID] <> b.[UniqueID]
 WHERE a.PropertyAddress IS NULL

 -- Breaking out Address into Individual Columns (Address,CIty, State)

SELECT PropertyAddress
From [Portfolio Project].[dbo].[Nashville ]
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(' , ' , PropertyAddress) -1 ) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(' , ', PropertyAddress) +1 , LEN(PropertyAddress)) AS Address

From [Portfolio Project].[dbo].[Nashville ]

ALTER TABLE [Portfolio Project].[dbo].[Nashville ]
Add PropertySplitAddress Nvarchar(255);



UPDATE [Portfolio Project].[dbo].[Nashville]
SET PropertySplitAddress = CASE 
 WHEN CHARINDEX(',', PropertyAddress) > 0 
 THEN SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
 ELSE PropertyAddress 
 END
             
ALTER TABLE [Portfolio Project].[dbo].[Nashville ]
Add PropertySplitCity Nvarchar(255);

UPDATE [Portfolio Project].[dbo].[Nashville ]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN (PropertyAddress))


-- Change Y & N to Yes and No in 'Sold as vacant' field

SELECT Distinct(SoldAsVacant), COUNT (SoldAsVacant)
FROM [Portfolio Project].[dbo].[Nashville ]
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
       CASE WHEN SoldAsVacant = 1 THEN 'Yes'
            WHEN SoldAsVacant = 0 THEN 'No'
            ELSE 'Unknown' 
       END AS VacancyStatus
FROM [Portfolio Project].[dbo].[Nashville];

-- Remove Duplicates


WITH RowNumCTE AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
        ORDER BY UniqueID
    ) AS row_num
    FROM [Portfolio Project].[dbo].[Nashville]
)
SELECT *
FROM RowNumCTE
WHERE row_num = 1
ORDER BY PropertyAddress;

-- Delete Unused Column

ALTER TABLE [Portfolio Project].[dbo].[Nashville]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, BuildingValue

SELECT *
FROM [Portfolio Project].[dbo].[Nashville]