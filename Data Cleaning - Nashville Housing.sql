-- Data cleaning on Nashville Housing Dataset

-- Link to the dataset: https://www.kaggle.com/datasets/tmthyjames/nashville-housing-data

-- Checking what does our Dataset contains
select * from Nashville

-- Selecting the unique rows from LandUse column
select distinct LandUse from Nashville
order by 1 

-- Deleting unwanted columns
alter table Nashville
drop column Acreage, TaxDistrict, LandValue, BuildingValue, TotalValue, OwnerAddress, OwnerName

-- Display the duplicate rows
select n1.ParcelID, n1.LandUse, n1.PropertyAddress, n1.LegalReference
from Nashville n1
join Nashville n2 
	on n1.ParcelID = n2.ParcelID
	and n1.[UniqueID ] <> n2.[UniqueID ]

-- Checking the Row count before deleting the duplicates (result = 56477)
select count(UniqueID) as TotalCount from Nashville

-- Finding & Deleting the duplicate rows
with RowNumCte as(
select *, ROW_NUMBER() over ( partition by ParcelID, PropertyAddress, SalePrice,
LegalReference, DateSold order by UniqueID) Row_Num
from Nashville
)
select * from RowNumCte
where Row_Num > 1
order by PropertyAddress

with RowNumCte as(
select *, ROW_NUMBER() over ( partition by ParcelID, PropertyAddress, SalePrice,
LegalReference, DateSold order by UniqueID) Row_Num
from Nashville
)
delete from RowNumCte
where Row_Num > 1

-- Checking the Row count after deleting the duplicates (result = 56374)
select count(UniqueID) as TotalCount from Nashville


-- Renaming rows with wrong names
select distinct LandUse from Nashville order by 1

update Nashville set LandUse ='VACANT RESIDENTIAL LAND' where LandUse = 'VACANT RES LAND'
update Nashville set LandUse ='VACANT RESIDENTIAL LAND' where LandUse = 'VACANT RESIENTIAL LAND'

select PropertyAddress from Nashville where LandUse = 'VACANT RESIDENTIAL LAND'

-- Updating PropertyAddress
update Nashville 
set PropertyAddress = REPLACE(PropertyAddress,'NASHVILLE','')
where PropertyAddress like '%NASHVILLE'

update Nashville 
set PropertyAddress = REPLACE(PropertyAddress,',','')
where PropertyAddress like '%, '


-- Convert the data type of SaleDate
alter table nashville
add DateSold date

update Nashville set DateSold = CONVERT(date, SaleDate)

select DateSold from Nashville

alter table nashville drop column SaleDate


-- Replacing Y with Yes and N with No in SoldAsVacant column
select distinct SoldAsVacant, COUNT(SoldAsVacant) as Total
from Nashville
group by SoldAsVacant


update Nashville
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from Nashville

-- Finding & Populating Property Address where it's Null
select n1.ParcelID, n1.PropertyAddress, n2.ParcelID, n2.PropertyAddress, 
ISNULL(n1.PropertyAddress, n2.PropertyAddress)
from Nashville n1
join Nashville n2
	on n1.ParcelID = n2.ParcelID
	and n1.[UniqueID ] <> n2.[UniqueID ]
where n1.PropertyAddress is null

update n1
set PropertyAddress = ISNULL(n1.PropertyAddress , n2.PropertyAddress)
from Nashville n1
join Nashville n2
	on n1.ParcelID = n2.ParcelID
	and n1.[UniqueID ] <> n2.[UniqueID ]
where n1.PropertyAddress is null


-- Breaking PropertyAddress into sub parts
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as City
from Nashville

alter table Nashville
add Address nvarchar(255),
City nvarchar(255)

