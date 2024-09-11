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

excels_to_unpack = {
        "unformatted_dd_file_name": "unformatted_data_dictionary.xlsx",
        "file_name": "dhsc_dd_2024_02_28.xlsx"
    }

# unpack the unformatted data dictionary
def unpack_unformatted_dd(unformatted_dd_file_name:str):
    """
    Unpacks the unformatted excel data dictionary into a json string, which
    can then be copied directly into DAE.
    """
    unpacked_dict = {}

    data_dictionary = pd.read_excel(f'.\excels_to_unpack\{unformatted_dd_file_name}', sheet_name=None) 
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

def unpack_table_mapping(data_dictionary_file_name: str, mapping_columns:list, sheet_name: str):
    """
    Function to unpack the table and display_name_label columns
    from a data dictionary excel, outputted as a json string that can
    be copied directly into DAE. 
    This is because the unformatted data dictionary does not specify 
    the tables a field belongs to.

    Applicable to msds-v2 and mhsds

    data_dictionary_file_name: name of dictionary file in excels_to_unpack folder.
        Needs .xlsx at end
    sheet_name: name of sheet in excel, representing data dictionary interested in

    unpacked_dict={"table":"display_name",
                   "table":"display_name"}
    """
    dictionary_df = pd.read_excel(f'.\excels_to_unpack\{data_dictionary_file_name}', sheet_name=sheet_name, header=2)

    # filter above to columns given (eg table, display_name / display_name_label)
    dictionary_df = dictionary_df[mapping_columns]
    # if table column, remove dars_nic number from table column
    if "table" in mapping_columns:
        dictionary_df["table"] = dictionary_df["table"].replace(to_replace='_dars_nic_[0-9]{6}_\w{5}', regex=True, value="_{dars_nic}")

    unpacked_dict = dictionary_df.to_dict(orient="records")

    with open(f"unpacked_{sheet_name}_mapping.json", "w+") as file:
        file.write(json.dumps(unpacked_dict, indent=4))
    return


unpack_table_mapping(data_dictionary_file_name="dhsc_dd_2024_02_28.xlsx", mapping_columns=["table", "display_name_label"], sheet_name="msds-v2")

unpack_table_mapping(data_dictionary_file_name="dhsc_dd_2024_02_28.xlsx", mapping_columns=["table", "display_name_label"], sheet_name="mhsds")