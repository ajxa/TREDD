# unpack.py function from NICOR DQ project

import json
import pandas as pd

"""
This is a python file used to unpack the DARS specifications for data sets, currently stored in excel files.
This file can be used to unpack any DARS spec.

dars_specs : update this list of dictionaries with the following:
    file_name: The name of the DARS spec excel file. 
               Ensure these are saved in the "dars_spec_excels" folder
               Include the .xlsx as well
    dae_table_name: The name of the table in DAE. Make sure it matches!

spark_types_to_replace : a dictionary of data types in the DARS specs, and the spark data types to replace them
    Note - some DARS spec data types don't match the data types in DAE
    We have examples of "decimal" fields in the specs which are "string" and "float" fields in DAE

dars_spec.json : the outputted json dictionary of the form    
    { "dae_table_name_A" : {
        "field_name_A1" : {
            "data_type" : data_type,
            "derived" : TRUE,
            },
        "field_name_A2" : ...
        },
     "dae_table_name_B" : {
        "field_name_B1" : {
            "data_type" : data_type,
            "derived" : TRUE,
            },
        "field_name_B2" : ...
        },    
    }
    ...
    }
    Can be copied and pasted directly into the DAE params notebook
"""

dars_specs = [
    {
        "file_name": "NICOR MINAP Full_DARS_Product_Specification.xlsx",
        "dae_table_name": "minap_enhanced",
    },
    {
        "file_name": "NICOR Adult Cardiac Surgery Product Specification 1.0.xlsx",
        "dae_table_name": "acs_combined_enhanced",
    },
    {
        "file_name": "APPROVED -NICOR-CRM-Devices product-spec V1.1.1.xlsx",
        "dae_table_name": "crm_pmicd_enhanced",
    },
    {
        "file_name": "APPROVED - NICOR-CRM-EPS product-spec v1.0.xlsx",
        "dae_table_name": "crm_eps_enhanced",
    },
    {
        "file_name": "NICOR Congenital Heart Disease Audit Full_DARS_Product_Specification.xlsx",
        "dae_table_name": "congenital_enhanced",
    },
    {
        "file_name": "APPROVED - NICOR Heart Failure v5 product-spec.xlsx",
        "dae_table_name": "hf_v5_enhanced",
    },
    {
        "file_name": "NICOR PCI Full_DARS_Product_Specification.xlsx",
        "dae_table_name": "pci_enhanced",
    },
    {
        "file_name": "DARS Product Spec for TAVI Full Product.xlsx",
        "dae_table_name": "tavi_enhanced",
    },
]

field_specs = {}
spark_types_to_replace = {
    "int": "integer",
    "numeric": "float",
    "numeric (int)": "integer",
    "numeric (decimal)": "integer",
    "datetime": "timestamp"
}


#{"table_name" : {
#  "field_name" : {
#    "data_type" : data_type,
#    "derived" : TRUE/FALSE,
#  }
#}}

for spec in dars_specs:
    field_specs_df = pd.read_excel(f'.\dars_spec_excels\{spec["file_name"]}', sheet_name="Fields", skiprows=1)  
    field_specs_df = (field_specs_df[["Database Field Name", "Field Type", "Field Group", "Included in the current DARS product?"]]
                      .rename(columns={"Database Field Name": "field_name", "Field Type": "data_type", "Field Group": "field_group"})
                      .dropna())
    field_specs_df = field_specs_df[field_specs_df["Included in the current DARS product?"] == "Yes"]
    field_specs_df = field_specs_df.drop(["Included in the current DARS product?"], axis=1)

    field_specs_df["field_group"].replace(regex=r'^Derived$', value="True", inplace=True)
    field_specs_df["field_group"].replace(regex=r'.*\b(?!True\b).+', value="False", inplace=True)

    field_specs_df["data_type"] = field_specs_df["data_type"].str.lower()
    field_specs_df["data_type"].replace(spark_types_to_replace, inplace=True)
    field_data_type_dictionary = {field_specs_df.at[x,"field_name"]: {"data_type": field_specs_df.at[x,"data_type"], "derived": field_specs_df.at[x,"field_group"]} for x in field_specs_df.index}

    print(spec["dae_table_name"])
    field_specs[spec["dae_table_name"]] = field_data_type_dictionary

with open("dars_spec.json", "w+") as file:
    file.write(json.dumps(field_specs, indent=4))