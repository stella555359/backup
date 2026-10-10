import os
from openpyxl import load_workbook
import pandas as pd
import json
from datetime import datetime
import re
import glob
from openpyxl import load_workbook
from openpyxl.styles import Alignment, PatternFill, Font
from openpyxl.utils import get_column_letter
from openpyxl.formatting.rule import CellIsRule

# Global dictionary for KPI ID to Name mapping
KPI_ID_NAME_MAPPING = {
    "00007": "KPI#2b - Inter-release SW activation downtime with firmware update",
    "00060": "KPI#2k - Inter-release SW activation",
    "00061": "KPI#4a - Complete BTS SW upgrade",
    "00062": "KPI#4b - Complete BTS SW upgrade",
    "02001": "Software Download Duration",
    "02002": "Software Provision Duration",
    "00015": "KPI#5 - Manual capacity module reset downtime",
    "00008": "KPI#2c - Intra-release SW activation downtime without firmware update",
    "00001": "KPI#1a - Manual site reset downtime",
    "00002": "KPI#1b - Manual site reset downtime",
    "00003": "KPI#1c - Manual site reset downtime"
}

# Function to create a directory path if it doesn't exist
def create_directory(path):
    if not os.path.exists(path):
        os.makedirs(path)

# Function to process debug logs and save filtered data to an Excel file
def get_oam_kpi_from_debug_log(debug_log_path, kpi_id_list, kpi_restore_path):
    # Ensure the output path exists
    create_directory(kpi_restore_path)

    # Regular expression to match the desired log lines
    log_pattern = re.compile(
        r"Reported KPI results: ID=(?P<ID>\d+), VALUE=(?P<VALUE>[\d.]+)(?:, SOURCE=(?P<SOURCE>\w+))?(?:, VARIANT=(?P<VARIANT>\{.*?\}))?(?:, ENTITY_ID=(?P<ENTITY_ID>\S+))?"
    )

    # Initialize a list to store extracted data
    extracted_data = []

    # Read the log file and extract matching lines
    with open(debug_log_path, "r", encoding="utf-8", errors="ignore") as log_file:
        for line in log_file:
            match = log_pattern.search(line)
            if match:
                data = match.groupdict()
                if data["ID"] in kpi_id_list:
                    # Handle VARIANT field
                    if data["ID"] == "00015":
                        variant = json.loads(data["VARIANT"])
                        data["VARIANT"] = variant.get("serial_number")
                    elif data["VARIANT"]:
                        variant = json.loads(data["VARIANT"])
                        data["VARIANT"] = variant.get("rat", "NO VARIANT")
                    else:
                        data["VARIANT"] = "NO VARIANT"
                    extracted_data.append(data)

    # Print the extracted data
    print("Extracted Data:", extracted_data)
    output_file =None
    # Convert the extracted data to a DataFrame
    if extracted_data:
        df = pd.DataFrame(extracted_data)
        # Save the DataFrame to an Excel file
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        output_file = os.path.join(kpi_restore_path, f"oam_kpi_{timestamp}.xlsx")
        with pd.ExcelWriter(output_file, engine="openpyxl") as writer:
            df.to_excel(writer, sheet_name="original_data", index=False)
    # Print the output file path
    print(f"Output File Path: {output_file}")
    # Load the Excel file and ensure ID column retains its original formatting
    if output_file:
        output_file_parsing(output_file)
    else:
        print("oam kpi report generation failed")
        # assert output_file, f"oam kpi report generation failed"
    # Return the path to the output file
    return output_file

def output_file_parsing(output_file):    # Load the Excel file and ensure ID column retains its original formatting
    df = pd.read_excel(output_file, sheet_name="original_data", dtype={"ID": str})

    # Group by ID, VARIANT, and ENTITY_ID, calculate the mean VALUE
    grouped_df = df.groupby(["ID", "VARIANT", "ENTITY_ID"], as_index=False).agg({
        "VALUE": "mean"
    })

    print("original data", df)
    print("base data:", grouped_df)
    # Save the result to a new sheet named 'base'
    with pd.ExcelWriter(output_file, engine="openpyxl", mode="a") as writer:
        grouped_df.to_excel(writer, sheet_name="base", index=False)

# Function to find the latest folder with a specific prefix
def compared_oam_kpi(oam_kpi_path, diff_threshold=10):
    # Extract kpi_restore_path from the oam_kpi_path
    kpi_restore_path = os.path.dirname(oam_kpi_path)

    # Extract the prefix (e.g., SBTS00) from the kpi_restore_path
    folder_name = os.path.basename(kpi_restore_path)
    prefix = folder_name.split("_")[0]

    # Extract the base directory from kpi_restore_path
    base_dir = os.path.dirname(kpi_restore_path)

    # Print the extracted prefix and base directory
    print(f"Prefix: {prefix}")
    print(f"Base Directory: {base_dir}")

    # Print the extracted kpi_restore_path
    print(f"KPI Restore Path: {kpi_restore_path}")

    # Find all folders under base_dir with the same prefix as kpi_restore_path, excluding kpi_restore_path itself

    # Standardize paths
    base_dir = os.path.normpath(base_dir)
    kpi_restore_path = os.path.normpath(kpi_restore_path)

    # Debugging information
    print(f"Base Directory: {base_dir}")
    print(f"KPI Restore Path: {kpi_restore_path}")
    print(f"Prefix: {prefix}")
    print(f"Glob Pattern: {os.path.join(base_dir, f'{prefix}*')}")

    # Debugging: List all folders in base_dir
    if os.path.exists(base_dir):
        all_dirs = [f for f in os.listdir(base_dir) if os.path.isdir(os.path.join(base_dir, f))]
        print(f"All Directories in Base Directory: {all_dirs}")
    else:
        print(f"Base Directory does not exist: {base_dir}")

    # Debugging: Check if KPI Restore Path exists
    if not os.path.exists(kpi_restore_path):
        print(f"KPI Restore Path does not exist: {kpi_restore_path}")

    # Escape special characters in prefix
    safe_prefix = re.escape(prefix)
    glob_pattern = os.path.join(base_dir, f"{safe_prefix}*")
    glob_pattern = glob_pattern.replace("\\", "/")  # Normalize to forward slashes
    print(f"Escaped and Normalized Glob Pattern: {glob_pattern}")

    # Attempt to find folders using glob
    all_folders = glob.glob(glob_pattern)
    print(f"All Folders Matching Prefix (Glob): {all_folders}")

    # Manual matching as a fallback
    if not all_folders:
        all_folders = [
            os.path.join(base_dir, folder)
            for folder in os.listdir(base_dir)
            if folder.startswith(prefix) and os.path.isdir(os.path.join(base_dir, folder))
        ]
        print(f"All Folders Matching Prefix (Manual): {all_folders}")

    matching_folders = [
        folder
        for folder in all_folders
        if os.path.isdir(folder) and os.path.abspath(folder) != os.path.abspath(kpi_restore_path)
    ]
    print(f"Matching Folders: {matching_folders}")
    # Sort folders by modification time to find the latest one
    if matching_folders:
        latest_folder = max(matching_folders, key=os.path.getmtime)
    else:
        latest_folder = None
    # Print the latest folder for debugging
    print(f"Latest Folder: {latest_folder}")
    # Check if latest_folder exists
    if not latest_folder:
        print(f"WARN: No Base Dir Found For Release: {prefix}")
        return None


    # Find the latest xlsx file in the latest_folder
    xlsx_files = [
        os.path.join(latest_folder, file) for file in os.listdir(latest_folder)
        if file.lower().endswith((".xlsx", ".xls"))
    ]
    print(f"Excel Files in Latest Folder: {xlsx_files}")

    # Check if any Excel files were found
    if not xlsx_files:
        print(f"WARN: No Base File Found For Release: {prefix}")
        excel_file_path = None
    else:
        # Select the most recently modified Excel file
        excel_file_path = max(xlsx_files, key=os.path.getmtime)
        print(f"Selected Excel File Path: {excel_file_path}")

    # If excel_file_path exists, merge the 'base' sheets and calculate the difference
    if excel_file_path:
        # Load the 'base' sheets from both files
        output_base_df = pd.read_excel(oam_kpi_path, sheet_name="base", dtype={"ID": str, "VARIANT": str, "ENTITY_ID": str})
        excel_base_df = pd.read_excel(excel_file_path, sheet_name="base", dtype={"ID": str, "VARIANT": str, "ENTITY_ID": str})
        print("Output Base DataFrame:", output_base_df)
        print("Excel Base DataFrame:", excel_base_df)

        # Clean and normalize ID and VARIANT columns
        output_base_df["ID"] = output_base_df["ID"].str.strip()
        excel_base_df["ID"] = excel_base_df["ID"].str.strip()
        output_base_df["VARIANT"] = output_base_df["VARIANT"].str.strip()
        excel_base_df["VARIANT"] = excel_base_df["VARIANT"].str.strip()
        output_base_df["ENTITY_ID"] = output_base_df["ENTITY_ID"].str.strip()
        excel_base_df["ENTITY_ID"] = excel_base_df["ENTITY_ID"].str.strip()

        # Ensure ID, VARIANT, and ENTITY_ID columns have consistent data types
        output_base_df = output_base_df.astype({"ID": str, "VARIANT": str, "ENTITY_ID": str})
        excel_base_df = excel_base_df.astype({"ID": str, "VARIANT": str, "ENTITY_ID": str})

        # Debugging: Print unique values in ID and VARIANT columns
        print("Output Base ID Column:", output_base_df["ID"].unique())
        print("Excel Base ID Column:", excel_base_df["ID"].unique())

        print("Output Base VARIANT Column:", output_base_df["VARIANT"].unique())
        print("Excel Base VARIANT Column:", excel_base_df["VARIANT"].unique())

        print("Output Base ENTITY_ID Column:", output_base_df["ENTITY_ID"].unique())
        print("Excel Base ENTITY_ID Column:", excel_base_df["ENTITY_ID"].unique())       

        # Extract suffixes from KPI Restore Path and Latest Folder
        suffix_output = f"_{os.path.basename(kpi_restore_path)}"
        suffix_excel = f"_{os.path.basename(latest_folder)}"

        # Merge the DataFrames on ID, VARIANT, and ENTITY_ID
        merged_df = pd.merge(output_base_df, excel_base_df, on=["ID", "VARIANT", "ENTITY_ID"], suffixes=(suffix_output, suffix_excel))
        print("Merged DataFrame:", merged_df)

        # Calculate the percentage difference in VALUE columns using dynamic suffixes
        merged_df["DIFF"] = ((merged_df[f"VALUE{suffix_output}"] - merged_df[f"VALUE{suffix_excel}"]) / merged_df[f"VALUE{suffix_excel}"] * 100).round(1)

        # Format the DIFF column to display percentage values with a '%' symbol
        merged_df["DIFF"] = merged_df["DIFF"].apply(lambda x: f"{x}%")

        # Update the 'diff' sheet to replace ID values with their corresponding names
        merged_df["ID"] = (
            merged_df["ID"].map(KPI_ID_NAME_MAPPING).fillna(merged_df["ID"])
        )

        # Save the merged DataFrame to a new sheet named 'diff'
        with pd.ExcelWriter(oam_kpi_path, engine="openpyxl", mode="a") as writer:
            merged_df.to_excel(writer, sheet_name="diff", index=False)

        print(f"Merged and calculated differences saved to 'diff' sheet in {oam_kpi_path}")
            # Load the workbook and access the 'diff' sheet
        workbook = load_workbook(oam_kpi_path)
        if "diff" in workbook.sheetnames:
            diff_sheet = workbook["diff"]

            # Set the first row to light blue fill
            header_fill = PatternFill(start_color="ADD8E6", end_color="ADD8E6", fill_type="solid")
            for cell in diff_sheet[1]:
                cell.fill = header_fill

            # Align all cell contents to the left
            for row in diff_sheet.iter_rows():
                for cell in row:
                    cell.alignment = Alignment(horizontal="left")

            # Set column widths
            column_widths = {"A": 53, "B": 15, "C": 12, "D": 36, "E": 36, "F": 12}
            for col_letter, width in column_widths.items():
                diff_sheet.column_dimensions[col_letter].width = width

            # Set all row heights to 30
            for row in diff_sheet.iter_rows():
                diff_sheet.row_dimensions[row[0].row].height = 18

            # Set the font for all cells to Calibri, size 10
            calibri_font = Font(name="Calibri", size=10)
            for row in diff_sheet.iter_rows():
                for cell in row:
                    cell.font = calibri_font
        workbook.save(oam_kpi_path)
        # Save the workbook
        workbook = load_workbook(oam_kpi_path)
        if "diff" in workbook.sheetnames:
            workbook.active = workbook.sheetnames.index("diff")
        workbook.save(oam_kpi_path)
        # Assert all rows with DIFF > diff_threshold and include all columns from the 'diff' sheet
        high_diff = merged_df[merged_df["DIFF"].str.rstrip('%').astype(float) > diff_threshold]
        assert high_diff.empty, f"following KPIs exceed {diff_threshold}%:\n{high_diff.to_string(index=False)}"




# # # Example usage
# # debug_log_path = "debug_upgrade.log"
# kpi_id_list = ["00015"]
# # kpi_restore_path = "C:\\TA\\RobotDebug\\E2E_TL_Capacity\\SBTS00_ENB_9999_260312_000010"
# latest_log_path="C:\\TA\\RobotDebug\\[1]E2E_TL_Capacity_Module_Reset_with_OAM_KPI\\SBTS26R3_ENB_9999_260315_000003\\oam_kpi_20260316012850.xlsx"
# # Example usage of get_compared_kpi_log
# # result = get_compared_kpi_log(latest_log_path)
# # debug_log_path = "debug_3158.log"
# # kpi_id_list = ["00007", "00060","00060","00061","00062","02001","02002","00064","00063"]
# # kpi_restore_path = "C:\\TA\\RobotDebug\\E2E_TL_Upgrade\\SBTS26R2_ENB_9999_260313_000010"
# # latest_log_path=get_oam_kpi_from_debug_log(debug_log_path, kpi_id_list, kpi_restore_path)

# # Example usage of get_compared_kpi_log
# result = compared_oam_kpi(latest_log_path)
# # print("Compared KPI Log Path:", result)
output_file1="C:\\TA\\RobotDebug\\[1]E2E_TL_Capacity_Module_Reset_with_OAM_KPI\\SBTS26R3_ENB_9999_260315_000003\\oam_kpi_20260316012850.xlsx"
output_file2="C:\\TA\\RobotDebug\\[1]E2E_TL_Capacity_Module_Reset_with_OAM_KPI\\SBTS26R3_ENB_9999_260314_000008\\oam_kpi_20260315102448.xlsx"
output_file_parsing(output_file2)
output_file_parsing(output_file1)
result = compared_oam_kpi(output_file1)
print("Compared KPI Log Path:", result)