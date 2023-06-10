# Trusted Research Environment (TRE) Service for England Data Dictionary code 💥📖💥

This package contains all the functions to format an excel workbook comprising numerous data dictionary table sheets into one coherent, visually appealing (sort of 🤔) data dictionary.

The main function `generate_dd()` will return a formatted data dictionary excel workbook, where each sheet corresponds to a specific dataset. There are a number of steps which need to be completed in order to enable the hyperlinks in the drop-down list on the home tab:

1. A sheet reference named "select_sheet" will have already been created in the outputted file - please confirm this is the case by going on `Formulas > Name Manager`.

2. Next, ensuring that your cursor is highlight the drop-down list cell, insert a hyperlink by going on `Insert > Link > This Document > Defined Names > 'select_sheet'`.

3. Test if this hyperlink points to an empty cell when selected.

4. Then go to `Formulas > Name Manager > and "select_sheet"`. Then enter the following into the `'Refers To'` box:

        =INDIRECT(ADDRESS(3,1,,,INDIRECT("select_dataset")))

5.  Save the defined name and test if the links work as intended. Once done the newly created hyperlink text should be re-formatted as:

    `face = bold, size = 20, colour = black, family='Arial'`
