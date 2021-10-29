--Cleaning Data in SQL


Select 
	*
From
	project_portfolio.dbo.nashville_housing

--------------------------------------------------------------------------------

--Date Format Standardization

Select 
	ConvertedSaleDate,
	cast(SaleDate as DATE) AS TrimmedSaleDate
From
	project_portfolio.dbo.nashville_housing


ALTER TABLE nashville_housing
Add ConvertedSaleDate DATE;

Update nashville_housing
Set ConvertedSaleDate = convert(DATE,SaleDate)
---------------------------------------------------------------------------------

--Fix Property Address

Select 
	*
From
	project_portfolio.dbo.nashville_housing
Where
	PropertyAddress IS NULL
Order By
	ParcelID

--Since the PropertyAddress has NULLS and the ParcelID can identify the address, if the ParcelID is present in the record, 
--the NULLs can be filled in with the PropertyAddress of table 2. A self-join will be used here

Select 
	nh1.ParcelID, nh1.PropertyAddress, nh2.ParcelID, nh2.PropertyAddress,
	ISNULL(nh1.PropertyAddress, nh2.PropertyAddress)
--ISNULL was added to replace the NULLs in nh1 PropertyAddress with nh2.PropertyAddress
--since the PropertyAddresses were matched on ParcelID and not UniqueID, ensuring these rows are not joined on the same record
From
	project_portfolio.dbo.nashville_housing AS nh1
	JOIN project_portfolio.dbo.nashville_housing AS nh2
	ON nh1.ParcelID = nh2.ParcelID
	AND nh1.[UniqueID ] <> nh2.[UniqueID ]
Where
	nh1.PropertyAddress IS NULL

Update nh1
SET PropertyAddress = ISNULL(nh1.PropertyAddress, nh2.PropertyAddress)
From
	project_portfolio.dbo.nashville_housing AS nh1
	JOIN project_portfolio.dbo.nashville_housing AS nh2
	ON nh1.ParcelID = nh2.ParcelID
	AND nh1.[UniqueID ] <> nh2.[UniqueID ]
Where
	nh1.PropertyAddress IS NULL
---------------------------------------------------------------------------------

--Split Address into separate columns

--PropertyAddress

Select 
	PropertyAddress
From
	project_portfolio.dbo.nashville_housing
--Where
--	PropertyAddress IS NULL
--Order By
--	ParcelID

Select 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address1,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address2
From
	project_portfolio.dbo.nashville_housing


ALTER TABLE nashville_housing
Add SplitPropertyAddress NVARCHAR(255);

Update nashville_housing
Set SplitPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE nashville_housing
Add SplitPropertyCity NVARCHAR(255);

Update nashville_housing
Set SplitPropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select
	*
From
	project_portfolio.dbo.nashville_housing


--OwnerAddress

Select
	PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
	PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
	PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From
	project_portfolio.dbo.nashville_housing


ALTER TABLE nashville_housing
Add SplitOwnerAddress NVARCHAR(255);

Update nashville_housing
Set SplitOwnerAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

ALTER TABLE nashville_housing
Add SplitOwnerCity NVARCHAR(255);

Update nashville_housing
Set SplitOwnerCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE nashville_housing
Add SplitOwnerState NVARCHAR(255);

Update nashville_housing
Set SplitOwnerState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


Select
	*
From
	project_portfolio.dbo.nashville_housing
----------------------------------------------------------------------------------

--Change Y to Yes and N to No in Sold As Vacant column

Select
	Distinct(SoldAsVacant),
	Count(SoldAsVacant)
From
	project_portfolio.dbo.nashville_housing
Group By
	SoldAsVacant
Order By
	2

Select
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
From
	project_portfolio.dbo.nashville_housing

Update nashville_housing
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

-------------------------------------------------------------

--Remove dupicate data

With NumRowCTE AS(
Select
	*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order BY
					uniqueID
				 ) AS row_num
From
	project_portfolio.dbo.nashville_housing
--Order BY
--	ParcelID
)

Select -- use DELETE here to remove isolated duplicates
	*
From
	NumRowCTE
Where
	row_num > 1
Order By
	PropertyAddress

-----------------------------------------------------------------------------

--Delete Unused Columns

Select
	*
From
	project_portfolio.dbo.nashville_housing

Alter Table project_portfolio.dbo.nashville_housing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate
