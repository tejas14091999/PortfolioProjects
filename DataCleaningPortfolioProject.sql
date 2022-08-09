/*

Cleaning Data in SQL Queries

*/

select *
from PortfolioProject2.NashvilleHousing


--------------------------------------------------------------------------------------
--Standardize the DATE format ()
alter table PortfolioProject2.NashvilleHousing
add SaleDateConverted date

Update PortfolioProject2.NashvilleHousing
set SaleDateConverted = Convert(Date, SaleDate)

select SaleDateConverted, SaleDate
from PortfolioProject2.NashvilleHousing

----------------------------------------------------------------------------------------

--Populate Property	Address Data
--Populate the PropertyAddress according to the ParcelID

--See if there are null entries in dataset, and try to figure a way to populate them
select *
from PortfolioProject2.NashvilleHousing
--where PropertyAddress  like 'NULL'
order by ParcelID

--SEE what should be populated in PropertyAddress for null values by joining with it self
select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress 
from PortfolioProject2.NashvilleHousing a
JOIN PortfolioProject2.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID --Join the tables such that the Parcel ID is same but the rows are different thus 
	--[cont.] to ensure that it is different entries
where a.PropertyAddress like 'NULL'

--Populating the PropertyAddress (if the value is null in a table, populated it with the value in the b table) as a separate column
--a)Works when PropertyAddress is autopopulated as NULL in SQL Server, and is not a hardcoded NULL in sheet
select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, nullif(a.PropertyAddress , b.PropertyAddress) 
from PortfolioProject2.NashvilleHousing a
JOIN PortfolioProject2.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID --Join the tables such that the Parcel ID is same but the rows are different thus 
	--[cont.] to ensure that it is different entries
where a.PropertyAddress like 'NULL'

--Hardcoded null as a string in PropertyAddress	
select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, 
CASE
	WHEN a.PropertyAddress like 'Null' THEN  b.PropertyAddress
END 
from PortfolioProject2.NashvilleHousing a
JOIN PortfolioProject2.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID --Join the tables such that the Parcel ID is same but the rows are different thus 
	--[cont.] to ensure that it is different entries
where a.PropertyAddress like 'NULL'

--Now update the null values in PropertyAddress column from the newly formed column with updated addresses
Update a
SET PropertyAddress = 
CASE
	WHEN a.PropertyAddress like 'Null' THEN  b.PropertyAddress
END 
from PortfolioProject2.NashvilleHousing a
JOIN PortfolioProject2.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID --Join the tables such that the Parcel ID is same but the rows are different thus 
	--[cont.] to ensure that it is different entries
where a.PropertyAddress like 'NULL'

---------------------------------------------------------------------------
--Breaking out address into individual columns

--See what we are dealing with, how the address looks like
select PropertyAddress
from PortfolioProject2.NashvilleHousing
--Delimiter as ',' in the address

--Separate the address over ','
select 
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as SplitAddress, --, ka left part is selected
substring(PropertyAddress, charindex(',', PropertyAddress)+1, LEN(PropertyAddress)) as SplitCity --, ka right part is selected
from PortfolioProject2.NashvilleHousing

--Add these newly formed Address to the table
alter table PortfolioProject2.NashvilleHousing
add PropertySplitAddress varchar(max)

Update PortfolioProject2.NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) 

alter table PortfolioProject2.NashvilleHousing
add PropertySplitCity varchar(max)

Update PortfolioProject2.NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress)+1, LEN(PropertyAddress))

select * 
from PortfolioProject2.NashvilleHousing --At the very last the 2 columns will appear, thus show the updated table


--DO the same for owner address, has 2 delimiter of ','
select OwnerAddress
from PortfolioProject2.NashvilleHousing

--We'll use parsename = super useful while dealing with delimiters
select --index is 3,2,1 for the Address
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1)
from PortfolioProject2.NashvilleHousing

alter table PortfolioProject2.NashvilleHousing
add OwnerSplitAddress varchar(max)

Update PortfolioProject2.NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3)

alter table PortfolioProject2.NashvilleHousing
add OwnerSplitCity varchar(max)

Update PortfolioProject2.NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2)

alter table PortfolioProject2.NashvilleHousing
add OwnerySplitState varchar(max)

Update PortfolioProject2.NashvilleHousing
set OwnerySplitState = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1)

select * 
from PortfolioProject2.NashvilleHousing --Show the updated table

--------------------------------------------------------------------------------------
--Change all Y and N to	Yes and No in "Sold as Vacant" field , ie keeping the entries coherant to Yes and No format only
select SoldAsVacant,
CASE
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END 
from PortfolioProject2.NashvilleHousing 

Update PortfolioProject2.NashvilleHousing  
SET SoldAsVacant = CASE
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

--Check if all Y and N have been converted
select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject2.NashvilleHousing 
group by SoldAsVacant
order by 2

-------------------------------------------------------------------------------------
--Remove Duplicates rows from the table(can also use rank, order rank, row number)
--Partition on basis of unique values of column

WITH RowNumCTE AS 
(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject2.NashvilleHousing 
)
select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress
--This gives and singles out all of the duplicates

--Now delete these duplicates
WITH RowNumCTE AS 
(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject2.NashvilleHousing 
)
DELETE 
from RowNumCTE
where row_num > 1
--order by PropertyAddress(Not works with delete)

--Now to check if you run the code which singles out the duplicates, the result will be blank


------------------------------------------------------------------------------------
--Delete unused columns	= helpful when unwanted views are created so can be removed, but usually, not good 
--[cont.] practise to remove from the main raw database 	
--here focused on the uncleaned source columns that we worked on till now, and some other not relevant columns

Alter Table PortfolioProject2.NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject2.NashvilleHousing 
DROP COLUMN SaleDate

select * 
from PortfolioProject2.NashvilleHousing 


