--DATA EXPLORATION

--Univariate Analysis--------------------------------------------------------------------

--Looking at distribution of Age in workplace--------------------------------------------*

Select
	Max(Age),
	Min(Age)
From
	project_portfolio.dbo.hr_employee_role
Order by
	1

--Mock Histogram

Use project_portfolio
GO
With HfreqCTE As 
(
	Select
		Age,
		Education,
		COUNT(Age) AS HFreq,
		CAST(ROUND(COUNT(Age)/(Select COUNT(*)), 2) AS INT) AS AgePerc
	From project_portfolio.dbo.hr_employee_role
	Group By Age, Education
	)
Select
	Age,
	Education,
	HFreq,
	CAST(REPLICATE('*', AgePerc) AS varchar(100)) AS Histogram
From
	HfreqCTE

--Looking at distribution of Education in workplace------------------------------------------*

Select
	Education
From
	project_portfolio.dbo.hr_employee_role

--Mock Histogram

Use project_portfolio
GO
With HfreqCTE2 As 
(
	Select
		Education,
		COUNT(Education) AS HFreq2,
		CAST(ROUND(COUNT(Education)/(Select COUNT(*)), 2) AS INT) AS EduPerc
	From project_portfolio.dbo.hr_employee_role
	Group By Education
	)
Select
	Education,
	HFreq2,
	CAST(REPLICATE('*', EduPerc) AS varchar(100)) AS Histogram
From
	HfreqCTE2

--Looking at distribution of departments------------------------------------*
Select
	Department,
	COUNT(Department) AS DepartmentEmployees
From
	project_portfolio.dbo.hr_employee_role
Group By
	Department

--Mock Histogram

Use project_portfolio
GO
With HfreqCTE3 As 
(
	Select
		Gender,
		Department,
		COUNT(Department) AS HFreq3,
		ROUND(COUNT(Department)/(Select COUNT(*)), 2) AS DeptPerc
	From project_portfolio.dbo.hr_employee_role
	Group By Gender, Department
	)
Select
	Gender,
	Department,
	HFreq3,
	CAST(REPLICATE('*', DeptPerc) AS varchar(100)) AS Histogram
From
	HfreqCTE3

--Looking at Distance traveled to work from home------------------------------------*
Select
	Id,
	Age,
	Gender,
	(Select AVG(DistanceFromHome) From project_portfolio.dbo.hr_employee_role) AS AvgDistance
From
	project_portfolio.dbo.hr_employee_role

Select
	Id,
	Age,
	Gender,
	DistanceFromHome
From
	project_portfolio.dbo.hr_employee_role
Where
	Id IN (
	Select Id
	From project_portfolio.dbo.hr_employee_performance
	Where JobRole = 'Laboratory Technician')

--Mock Histogram

Use project_portfolio
GO
With HfreqCTE4 As 
(
	Select
		Age,
		Gender,
		DistanceFromHome,
		COUNT(DistanceFromHome) AS HFreq4,
		CAST(ROUND(COUNT(DistanceFromHome)/(Select COUNT(*)), 2) AS INT) AS DistancePerc
	From project_portfolio.dbo.hr_employee_role
	Group By Age, Gender, DistanceFromHome
	)
Select
	Age,
	Gender,
	DistanceFromHome,
	HFreq4,
	CAST(REPLICATE('*', DistancePerc) AS varchar(100)) AS Histogram
From
	HfreqCTE4


--Bivariate Analysis-------------------------------------------------------------------------------------------------------

--Looking at Attrition by Department------------------------------------------------------------------------------------*

Select
	role.Age, role.Gender, role.Education, role.EducationField, role.MaritalStatus,
	performance.YearsAtCompany, performance.YearsInCurrentRole, role.Attrition, role.Department,
	COUNT(YearsAtCompany) AS Freq8,
	CAST(ROUND(COUNT(YearsAtCompany)/(Select COUNT(*)), 2) AS INT) AS RoundPerc
From
	project_portfolio.dbo.hr_employee_performance AS performance
	Right JOIN project_portfolio.dbo.hr_employee_role AS role
	ON performance.Id = role.Id
Group By
	role.Age,
	role.Gender,
	role.Education,
	role.EducationField,
	role.MaritalStatus,
	performance.YearsAtCompany,
	performance.YearsInCurrentRole,
	role.Attrition,
	role.Department

--Looking at years spent at a company to Attrition*-------------------------------------------------------------------------

Select
	YearsAtCompany
From
	project_portfolio.dbo.hr_employee_performance

Select
	role.Age, role.Gender, role.Education, role.EducationField, role.MaritalStatus,
	performance.YearsAtCompany, performance.YearsInCurrentRole, role.Attrition, role.Department,
	COUNT(YearsAtCompany) AS Freq8,
	CAST(ROUND(COUNT(YearsAtCompany)/(Select COUNT(*)), 2) AS INT) AS RoundPerc,
	CASE
		WHEN YearsAtCompany = 0 THEN 0
		WHEN YearsInCurrentRole = 0 THEN 0
		ELSE ((YearsInCurrentRole/YearsAtCompany)*100)
		END AS YearPerc
From project_portfolio.dbo.hr_employee_performance AS performance
	Right JOIN project_portfolio.dbo.hr_employee_role AS role
	ON performance.Id = role.Id
Group By
	role.Age,
	role.Gender,
	role.Education,
	role.EducationField,
	role.MaritalStatus,
	performance.YearsAtCompany,
	performance.YearsInCurrentRole,
	role.Attrition,
	role.Department

--Looking at the measure of involvment in the job to Attrition*-------------------------------------------------------------------------

Create Procedure Temp_Job_Comparison
As 
Select
	role.Education, performance.JobInvolvement, performance.StockOptionLevel,
	role.DistanceFromHome, role.Attrition,
	COUNT(JobInvolvement) AS JIFreq, COUNT(StockOptionLevel) AS SOFreq, COUNT(DistanceFromHome) AS DFHFreq,
	CAST(ROUND(COUNT(JobInvolvement)/(Select COUNT(*)), 2) AS INT) AS JobInvolvePerc
From project_portfolio.dbo.hr_employee_performance AS performance
	Right JOIN project_portfolio.dbo.hr_employee_role AS role
	ON performance.Id = role.Id
Group By
	Education,
	JobInvolvement,
	StockOptionLevel,
	DistanceFromHome,
	Attrition

EXEC Temp_Job_Comparison @Education = 3

--Looking at the measure of satisfaction with the job to Attrition*-------------------------------------------------------------------------

Select
	role.Age, role.Gender, role.Education, performance.JobSatisfaction,
	performance.TrainingTimesLastYear, role.Attrition,
	COUNT(role.Age) AS AFreq, COUNT(JobSatisfaction) AS JSFreq, COUNT(TrainingTimesLastYear) AS TTFreq,
	CAST(ROUND(COUNT(JobSatisfaction)/(Select COUNT(*)), 2) AS INT) AS JobSatPerc
From project_portfolio.dbo.hr_employee_performance AS performance
	Right JOIN project_portfolio.dbo.hr_employee_role AS role
	ON performance.Id = role.Id
Group By
	role.Age,
	role.Gender,
	Education,
	JobSatisfaction,
	TrainingTimesLastYear,
	Attrition
---------------------------------------------------------------------------------------------------------------

---Cleaning Data

--Looking for missing values
Select
	*
From
	project_portfolio.dbo.hr_employee_role
Where
	Id IS NULL

Select
	*
From
	project_portfolio.dbo.hr_employee_performance
Where
	Id IS NULL

--Looking for duplicates to remove

Select
	*,
	ROW_NUMBER() OVER (
		Partition By Age, Gender, JobInvolvement, JobLevel, JobRole, JobSatisfaction,
		NumCompaniesWorked, Over18, OverTime, PercentSalaryHike
		Order By Id
		) As row_num
From
	project_portfolio.dbo.hr_employee_performance
Order By
	Id



---Other queries-----------------------------------------------------------------------------------------------

---Work environment satisfaction rating------------------------------------------------------------------------

--Select
--	EnvironmentSatisfaction
--From
--	project_portfolio.dbo.hr_employee_role

----Mock Histogram

--Use project_portfolio
--GO
--With freqCTE4 As 
--(
--	Select
--		EnvironmentSatisfaction,
--		COUNT(EnvironmentSatisfaction) AS Freq4,
--		CAST(ROUND(COUNT(EnvironmentSatisfaction)/(Select COUNT(*)), 2) AS INT) AS EnvPerc
--	From project_portfolio.dbo.hr_employee_role
--	Group By EnvironmentSatisfaction
--	)
--Select
--	EnvironmentSatisfaction,
--	Freq4,
--	CAST(REPLICATE('*', EnvPerc) AS varchar(100)) AS Histogram
--From
--	freqCTE4

----Income per month-------------------------------------------------------------------------

--Select
--	MAX(MonthlyIncome),
--	MIN(MonthlyIncome)
--From
--	project_portfolio.dbo.hr_employee_role

----Mock Histogram

--Use project_portfolio
--GO
--With freqCTE5 As 
--(
--	Select
--		MonthlyIncome,
--		COUNT(MonthlyIncome) AS Freq5,
--		CAST(ROUND(COUNT(MonthlyIncome)/(Select COUNT(*)), 2) AS INT) AS IncomePerc
--	From project_portfolio.dbo.hr_employee_role
--	Group By MonthlyIncome
--	)
--Select
--	MonthlyIncome,
--	Freq5,
--	CAST(REPLICATE('*', IncomePerc) AS varchar(100)) AS Histogram
--From
--	freqCTE5

----Education Field-------------------------------------------------------------------------

--Select
--	EducationField
--From
--	project_portfolio.dbo.hr_employee_role

----Mock Histogram

--Use project_portfolio
--GO
--With freqCTE6 As 
--(
--	Select
--		EducationField,
--		COUNT(EducationField) AS Freq6,
--		CAST(ROUND(COUNT(EducationField)/(Select COUNT(*)), 2) AS INT) AS EduFieldPerc
--	From project_portfolio.dbo.hr_employee_role
--	Group By EducationField
--	)
--Select
--	EducationField,
--	Freq6,
--	CAST(REPLICATE('*', EduFieldPerc) AS varchar(100)) AS Histogram
--From
--	freqCTE6

----Marital Status-------------------------------------------------------------------------

--Select
--	MaritalStatus
--From
--	project_portfolio.dbo.hr_employee_role

----Mock Histogram

--Use project_portfolio
--GO
--With freqCTE7 As 
--(
--	Select
--		MaritalStatus,
--		COUNT(MaritalStatus) AS Freq7,
--		CAST(ROUND(COUNT(MaritalStatus)/(Select COUNT(*)), 2) AS INT) AS MarPerc
--	From project_portfolio.dbo.hr_employee_role
--	Group By MaritalStatus
--	)
--Select
--	MaritalStatus,
--	Freq7,
--	CAST(REPLICATE('*', MarPerc) AS varchar(100)) AS Histogram
--From
--	freqCTE7

----Looking at Total of Attrition by Education

--Alter Table hr_employee_role
--ADD EduPerc FLOAT;

--Update hr_employee_role
--SET EduPerc = CASE
--		WHEN Attrition = 'No' THEN 1 
--		WHEN Attrition = 'Yes' THEN 2
--		ELSE Attrition
--		END

--Select
--	COUNT(EduPerc)
--From
--	project_portfolio.dbo.hr_employee_role
--Where
--	EduPerc = '1'

--Select
--	COUNT(EduPerc)
--From
--	project_portfolio.dbo.hr_employee_role
--Where
--	EduPerc = '2'

--Select
--	Id,
--	Age,
--	Education,
--	COUNT(EduPerc) OVER (
--		Partition By Education) AS AttritionCount
--From
--	project_portfolio.dbo.hr_employee_role
--Where
--	Attrition = 'Yes'
--Group By
--	Id,
--	Age,
--	Education,
--	EduPerc

------------------------------------------------------------------------------------

