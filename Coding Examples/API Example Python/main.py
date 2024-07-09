import traceback

import numpy as np
import pandas as pd
import api_requests
from dotenv import load_dotenv
import os
import re
from api_requests import *

# Keys
CONTENT_AREA_ID = "content_area_id"
INDICATOR_ID = "indicator_id"
MEASURE_ID = "measure_id"
MEASURE_NAME = "measure_name"
GEOGRAPHIC_TYPE_ID = "geographic_type_filter_id"
GEOGRAPHIC_ITEM_IDS = "geographic_item_filter_ids"
TEMPORAL_TYPE_ID = "temporal_type_filter_id"
TEMPORAL_ITEM_IDS = "temporal_item_filter_ids"
STRATIFICATION_LEVEL_ID = "stratification_level_id"
STRATIFICATION_TYPE_IDS = "stratification_type_ids"
STRATIFICATION_TYPE_LOCAL_IDS = "stratification_type_ids"
API_TOKEN_PARAM = "apiToken"

# Load environment variables
load_dotenv()
API_TOKEN = os.getenv("API_Token")
USE_API_TOKEN = os.getenv("Use_API_Token") == "TRUE"
PRESENTER_MODE = os.getenv("Presenter_Mode") == "TRUE"
ROWS_PER_PAGE = 10

# Constants for user interaction
BACK = ['b', 'back']
RESET = ['r', 'reset']
NEW = ['n', 'new']
EXIT = ['x', 'exit']

# Global variables
user_selections = {

}

advanced_options = {}

current_options = []
current_page = 1

function_id = 0
user_input_status = 0
advanced_options_id = 0


# Function mapping
function_map = {
    0: {
        "function": lambda api_token, use_api_token, presenter_mode: handle_contentareas(api_token, use_api_token, presenter_mode, user_selections),
        "valid_actions": [4, 5, 6],
        "actions": [lambda user_input, options: set_user_selections(user_input, CONTENT_AREA_ID, options)],
        "Table Name": "Available Content Areas"
    },
    1: {
        "function": lambda api_token, use_api_token, presenter_mode: handle_indicators(api_token, use_api_token, presenter_mode, user_selections),
        "valid_actions": [1, 3, 4, 5, 6],
        "actions": [lambda user_input, options: set_user_selections(user_input, INDICATOR_ID, options)],
        "Table Name": "Available Indicators"
    },
    2: {
        "function": lambda api_token, use_api_token, presenter_mode: handle_measures(api_token, use_api_token, presenter_mode, user_selections),
        "valid_actions": [1, 3, 4, 5, 6],
        "actions": [lambda user_input, options: set_user_selections(user_input, MEASURE_ID, options)],
        "Table Name": "Available Measures"
    },
    3: {
        "function": lambda api_token, use_api_token, presenter_mode: handle_geographicType(api_token, use_api_token, presenter_mode, user_selections),
        "valid_actions": [1, 3, 4, 5, 6],
        "actions": [lambda user_input, options: set_user_selections(user_input, GEOGRAPHIC_TYPE_ID, options)],
        "Table Name": "Available Geographic Types"
    },
    4: {
        "function": lambda api_token, use_api_token, presenter_mode: handle_geographicItems(api_token, use_api_token, presenter_mode, user_selections),
        "valid_actions": [1, 3, 4, 5, 7],
        "actions": [lambda user_input, options: set_user_selections(user_input, GEOGRAPHIC_ITEM_IDS, options)],
        "Table Name": "Available Geographic Items"
    },
    6: {
        "function": lambda api_token, use_api_token, presenter_mode: handle_stratificationTypes(api_token, use_api_token, presenter_mode, user_selections),
        "valid_actions": [1, 3, 4, 5, 7],
        "actions": [lambda user_input, options: set_user_selections(user_input, STRATIFICATION_TYPE_IDS, options)],
        "Table Name": "Available Stratifications For "
    },
    5: {
        "function": lambda api_token, use_api_token, presenter_mode: handle_stratificationLevel(api_token, use_api_token, presenter_mode, user_selections),
        "valid_actions": [1, 3, 4, 5, 6],
        "actions": [lambda user_input, options: set_user_selections(user_input, STRATIFICATION_LEVEL_ID, options)],
        "Table Name": "Available Stratification Levels"
    },
    7: {
        "function": lambda api_token, use_api_token, presenter_mode: handle_temporalType(api_token, use_api_token, presenter_mode, user_selections),
        "valid_actions": [1, 3, 4, 5, 6],
        "actions": [lambda user_input, options: set_user_selections(user_input, TEMPORAL_TYPE_ID, options)],
        "Table Name": "Available Temporal Types"
    },
    8: {
        "function": lambda api_token, use_api_token, presenter_mode: handle_temporalItems(api_token, use_api_token, presenter_mode, user_selections),
        "valid_actions": [1, 3, 4, 5, 7],
        "actions": [lambda user_input, options: set_user_selections(user_input, TEMPORAL_ITEM_IDS, options)],
        "Table Name": "Available Temporal Items"
    },
    9: {
        "function": lambda api_token, use_api_token, presenter_mode: handle_getCoreHolder(api_token, use_api_token, presenter_mode, user_selections, advanced_options),
        "valid_actions": [2, 4, 5],
        "actions": [],
        "Table Name": ""
    }
}




action_map = {
    1: {
        "conditions": lambda user_input: user_input.lower() in BACK,
        "action": lambda user_input, options: decrement_function_id(),
        "prompt": "Enter 'B' to go back."
    },
    2: {
        "conditions": lambda user_input: user_input.lower() in NEW,
        "action": lambda user_input, options: reset_function_id(),
        "prompt": "Press 'N' to start a new selection."
    },
    3: {
        "conditions": lambda user_input: user_input.lower() in RESET,
        "action": lambda user_input, options: reset_function_id(),
        "prompt": "Press 'R' to reset all selections."
    },
    4: {
        "conditions": lambda user_input: True if re.match(r'^[p|P]\d+', user_input) else False,
        "action": lambda user_input, options: handle_page_change(user_input),
        "prompt": "Enter 'P<number>' to jump to a valid page number."
    },
    5: {
        "conditions": lambda user_input: user_input.lower() in EXIT,
        "action": lambda user_input, options: exit_program(),
        "prompt": "Press 'X' to exit the program."
    },
    6: {
        "conditions": lambda user_input: user_input.strip().isdigit(),
        "action": lambda user_input, options: [action(user_input.replace(" ", ""), options) for action in function_map[function_id]["actions"]],
        "prompt": "OR\n\tEnter an id from the list of options"
    },
    7: {
        "conditions": lambda user_input: all(i.strip().isdigit() for i in user_input.split(',')),
        "action": lambda user_input, options: [action(user_input.replace(" ", ""), options) for action in function_map[function_id]["actions"]],
        "prompt": "OR\n\tEnter a list of id's separated by commas"
    }
}


def get_max_lengths(data_dict):
    max_lengths = {}
    for key in data_dict.keys():
        max_value_length = max(len(str(data_dict[key])), len(key))
        max_lengths[key] = max_value_length
    return max_lengths


def print_options(options, page_number, items_per_page):
    """ Print a formatted table of options and selections """
    def print_section(title, dict):
        if len(dict) > 0:
            max_lengths = get_max_lengths(dict)
            total_length = sum(max_lengths.values()) + (3 * len(max_lengths))  # 3 spaces per key-value pair
            print("-" * total_length)
            print(title)
            for key in dict.keys():
                length = max_lengths[key]
                print(f"\t{key}: {str(dict[key]):<{length}}")
            print("-" * total_length)

    print_section("Current User Selections:", user_selections)
    print_section("Current Advanced Options:", advanced_options)

    total_pages = (len(options) + items_per_page - 1) // items_per_page
    table_name = function_map[function_id]['Table Name']
    start_index = (page_number - 1) * items_per_page
    end_index = start_index + items_per_page
    page_data = options.iloc[start_index:end_index]

    if function_id == 9:
        headers = ['Data', 'Units', 'Location', 'Time', 'Stratification']
        max_lengths = {header: max(len(header), page_data[header].astype(str).str.len().max()) for header in headers}
        total_length = sum(max_lengths.values()) + (3 * len(headers))
        print("-" * total_length)
        print(f"{user_selections[MEASURE_NAME]} (page {page_number} of {total_pages})")
        header_line = ''.join(f"{header:<{max_lengths[header]}}  " for header in headers)
        print(header_line)
        print("-" * total_length)
        for index, row in page_data.iterrows():
            row_line = ''.join(f"{str(row[header]):<{max_lengths[header]}}  " for header in headers)
            print(row_line)
        print("-" * total_length)

    else:
        if function_id == 6:
            table_name = f"{table_name} {options.iloc[0]['DisplayName']}"
        headers = ['Id', 'Name']
        max_lengths = {header: max(len(header), page_data[header].astype(str).str.len().max()) for header in headers}
        total_length = sum(max_lengths.values()) + (3 * len(headers))
        print("-" * total_length)
        print(f"{table_name} (page {page_number} of {total_pages})")
        header_line = ''.join(f"{header:<{max_lengths[header]}}  " for header in headers)
        print(header_line)
        print("-" * total_length)
        for index, row in page_data.iterrows():
            row_line = ''.join(f"{str(row[header]):<{max_lengths[header]}}  " for header in headers)
            print(row_line)
        print("-" * total_length)


def handle_user_input(options):
    """ Handle user interaction with the input dynamically """
    global function_id, user_input_status
    user_input_status = 1
    current_function = function_map[function_id]

    # List all prompts for the current function
    print('\nOptions:')
    for action_id in current_function["valid_actions"]:
        if action_id in action_map:
            print(f"\t{action_map[action_id]['prompt']}")

    user_input = input("Submit an input: ")

    # Process the user input
    for action_id in current_function["valid_actions"]:
        if action_id in action_map.keys() and action_map[action_id]["conditions"](user_input):
            action_map[action_id]["action"](user_input, options)
            return

    input("Invalid Submission (Press Enter To Continue)")


def set_user_selections(user_input, selector, options):
    global user_input_status, user_selections, advanced_options_id
    try:
        # Split the user input on commas and convert to integers
        selected_ids = [int(id.strip()) for id in user_input.split(',')]

        # Check if all selected IDs exist in the options DataFrame's 'id' column
        if all(selected_id in options['Id'].values for selected_id in selected_ids):
            user_input_status = 0
            if selector == CONTENT_AREA_ID:
                user_selections[CONTENT_AREA_ID] = f"{selected_ids[0]}"
            elif selector == INDICATOR_ID:
                user_selections[INDICATOR_ID] = f"{selected_ids[0]}"
            elif selector == MEASURE_ID:
                user_selections[MEASURE_ID] = f"{selected_ids[0]}"
                user_selections[MEASURE_NAME] = f"{options.loc[options['Id'] == selected_ids[0], 'Name'].item()}"
            elif selector == GEOGRAPHIC_TYPE_ID:
                user_selections[GEOGRAPHIC_TYPE_ID] = f"{selected_ids[0]}"
            elif selector == GEOGRAPHIC_ITEM_IDS:
                user_selections[GEOGRAPHIC_ITEM_IDS] = ','.join([f"{selected_id}" for selected_id in selected_ids])
            elif selector == STRATIFICATION_LEVEL_ID:
                user_selections[STRATIFICATION_LEVEL_ID] = f"{selected_ids[0]}"
                user_selections[STRATIFICATION_TYPE_IDS] = options.loc[options['Id'] == selected_ids[0], 'StratificationTypes'].item()
            elif selector == STRATIFICATION_TYPE_IDS and len(user_selections[STRATIFICATION_TYPE_IDS]) > 0:
                advanced_options[options.iloc[0]['ColumnName']] = ','.join([f"{selected_id}" for selected_id in selected_ids])
                advanced_options_id = len(advanced_options.keys())
                if advanced_options_id < len(user_selections[STRATIFICATION_TYPE_IDS]):
                    user_input_status = 1
            elif selector == TEMPORAL_TYPE_ID:
                user_selections[TEMPORAL_TYPE_ID] = f"{selected_ids[0]}"
            elif selector == TEMPORAL_ITEM_IDS:
                user_selections[TEMPORAL_ITEM_IDS] = ','.join([f"{selected_id}" for selected_id in selected_ids])
            else:
                print("Selector not recognized.")
                user_input_status = 1
        else:
            print("One or more IDs are not valid. Please check and try again.")
    except ValueError:
        print("Invalid input. Please enter only comma-separated numbers.")
    except Exception as e:
        print(f"An error occurred: {e}")




def decrement_function_id():
    global function_id, user_input_status
    if function_id > 0:
        function_id -= 2
    user_input_status = 0


def reset_function_id():
    global function_id, user_input_status, user_selections, advanced_options
    function_id = -1
    user_selections = {}
    advanced_options = {}
    user_input_status = 0

def handle_page_change(input):
    global current_page, current_options
    page_number = int(input[1:])
    total_pages = (len(current_options) + ROWS_PER_PAGE - 1) // ROWS_PER_PAGE
    if page_number > total_pages or page_number < 1:
        raise ValueError(f"Page number must be between 1 and {total_pages}")
    current_page = page_number

def exit_program():
    global user_input_status
    user_input_status = -1

def main():
    global user_input_status, function_id, current_options, current_page, advanced_options_id, user_selections
    print("Welcome to Trackings Interactive Text Based API Tutorial")
    while True:
        try:
            # Main interactive loop
            user_input_status = 1
            current_function = function_map[function_id]["function"]
            current_options = current_function(API_TOKEN, USE_API_TOKEN, PRESENTER_MODE)
            while user_input_status == 1:
                if function_id == 6:
                    if len(current_options) == 0:
                        break  # Skip stratification types if there are non=
                    filtered_options = current_options[current_options['StratificationTypeId'] == user_selections[STRATIFICATION_TYPE_IDS][advanced_options_id]].copy()
                    print_options(filtered_options, current_page, ROWS_PER_PAGE)
                    handle_user_input(filtered_options)
                else:
                    print_options(current_options, current_page, ROWS_PER_PAGE)
                    handle_user_input(current_options)
            if user_input_status == -1: break;
            function_id += 1
            advanced_options_id = 0
            current_page = 1


        except Exception as e:
            print(f"An error occurred: {e}")
            traceback.print_exc()
            input(f"Press <Enter> to Continue")


if __name__ == "__main__":
    main()
