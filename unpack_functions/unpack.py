# unpack.py function from NICOR DQ project

import json
import pandas as pd
import numpy as np

"""
This is a python file used to unpack an excel file with multiple sheets into dataframes,
before saving them as a json file.
The contents of this json file can then be copied directly into DAE.

unpacked.json : the outputted json dictionary. For each row of each dataset dictionary (excel sheet), it follows
the form below. "row_index" is 0, 1, 2 etc (the row in the original excel sheet).
    "deaths": {
            "row_index": {
                "path": NaN,
                "table": deaths,
                "display_name": "FIELD_NAME",
                "display_name_label": "Field Name",
                "field_description": "Blah blah blah.",
                "variable_type": "Categorical",
                "data_type": "String",
                "units": NaN,
                "values": NaN,
                "notes": "Notes notes notes.",
                "links": "link here"
            } ... 

To convert dictionary representation back to dataframe (in DAE): 
    unpacked_dict["deaths"] is dictionary representation of deaths dataset
    deaths_df = pd.DataFrame.from_dict(unpacked_dict["deaths"], orient="index")
"""

excels_to_unpack = [
    {
        "file_name": "unformatted_data_dictionary.xlsx"
    }
]

unpacked_dict = {}

for excel in excels_to_unpack:
    data_dictionary = pd.read_excel(f'.\excels_to_unpack\{excel["file_name"]}', sheet_name=None) 
    # data_dictionary is a dictionary containing each sheet in the excel (now dataframes)
    sheets_to_delete = ["Home", "Refinements", "Dictonary_Priorities"]
    for sheet in sheets_to_delete:
        del data_dictionary[sheet]

    for dataset in data_dictionary.keys():
        data_dictionary_df = data_dictionary[dataset]

        for column in data_dictionary_df.columns:
            data_dictionary_df[column].replace(to_replace=np.nan, value="None", inplace=True)

        unpacked_dict[dataset] = data_dictionary[dataset].to_dict("index")
  
with open("unpacked.json", "w+") as file:
    file.write(json.dumps(unpacked_dict, indent=4))

#for dataset in unpacked_dict:
#    with open(f"unpacked_{dataset}.json", "w+") as file:
#        file.write(json.dumps(unpacked_dict[dataset], indent=4))

# problem: too many rows when copying into DAE. Cutting off half way. Need to split unpacked.json into sections.
# Group datasets together? Or just group every 4? Lots of copying across...
"""
for excel in excels_to_unpack:
    data_dictionary = pd.read_excel(f'.\excels_to_unpack\{excel["file_name"]}', sheet_name=None) 
    # data_dictionary is a dictionary containing each sheet in the excel (now dataframes)

    for dataset in data_dictionary.keys():
        data_dictionary_df = data_dictionary[dataset]
        for column in data_dictionary_df.columns:
            # replacing the "\n" in the strings as gives EOL error later
            data_dictionary_df[column].replace(regex=r'\n',value="", inplace=True)

        unpacked_dict[dataset] = data_dictionary[dataset].to_dict("index")
  
with open("unpacked.json", "w+") as file:
    file.write(json.dumps(unpacked_dict, indent=4))
"""