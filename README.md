# Trusted Research Environment (TRE) Service for England Data Dictionary code

This package contains all the functions to format an excel workbook comprising numerous data dictionary table sheets into one coherent, visually appealing (sort of) data dictionary.


The main function 'generate_dd' will return a formatted data dictionary excel workbook, where each sheet corresponds to a specific dataset. There are a number of steps which need to be completed before this workbook can be shared:


## Adding a dropdown list to the Home tab sheet

In the tab named "Home" there is a merged cell (F3:I3) which needs to be populated with a list of sheet names. This can be achieved by create a dropdown list using the range in the hidden "table_list" lookup table (Data > data validation > Allow = list) and pasting the following into the source:

	=table_list!$A$2:$A$1000

## Creating linkable drop-downs in the Home tab sheet

After creating a drop-down list of sheet names we can makes these linkable by:

1. Clicking on an empty cell (other than the drop-down itself) in the Home sheet and creating a defined name function called "select_sheet" (Formulas > Define Name).

2. Clicking on the dropdown list generated above and inserting a link (Insert > Link > This Document > Defined Names > "select_sheet").

3. Testing if the dropdown links point to the empty cell selected in step 1.

4. Going to Formulas > Name Manager > and "select_sheet". Then enter the following into the "Refers To" box:	

	=INDIRECT(ADDRESS(3,1,,,INDIRECT("select_dataset")))

5. Saving the defined name and testing if the links work as intended. Once done the newly created hyperlink text should be formatted as: (face = bold, size = 16, colour = black)

  