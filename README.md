# Trusted Research Environment Data Dictionary (TREDD) 💥📖💥

This package contains a collection of functions which enable users to generate one coherent, visually appealing (sort of 🤔) data dictionary. The main package function `generate_dd()` will return a formatted data dictionary excel workbook, where each sheet corresponds to a specific dataset. 

Once the dictionary is outputted, the user will need to complete a small number of clean-up steps in order to ensure the home tab drop down hyperlinks work as intended:

1. Check to see is a sheet reference named `select_sheet` was successfully created in the output file by  selecting `Formulas > Name Manager`.

2. Ensuring that your cursor is on the the drop-down list cell, insert a hyperlink by selecting `Insert > Link > This Document > Defined Names > 'select_sheet'`. Once set, test if this drop-down hyperlink points to an empty cell when clicked.

3. Select `Formulas > Name Manager > and "select_sheet"` and enter the following into the `'Refers To'` box:

        =INDIRECT(ADDRESS(3,1,,,INDIRECT("select_dataset")))



Save the defined name and test if the links work as intended. 

After adding the hyperlink, please reformat the hyperlink, drop down cell using the following properties, to ensure consistency will the rest of the file:

    `face = bold, size = 20, colour = black, family='Arial'`
