# Environment and Public Health Tracking Network Interactive API Example

This project provides an interactive command-line interface to interact with the Public Health Tracking Network's API. It allows users to navigate through various data categories such as content areas, indicators, measures, and more, making selections and retrieving data based on those selections.

## Prerequisites

Before you begin, ensure you have met the following requirements:

* You have installed Python 3.9 or later. If not, you can download it from [here](https://www.python.org/downloads/). Follow the instructions on the website to install it.

* You have a command-line interface or terminal ready to use.

## Setting up the Project

1. Clone the project repository or download the source code.
2. Navigate to the project directory in your command line interface:
```
cd path/to/project-directory
```
3. Create a virtual environment:
```
python -m venv venv
```
4. Activate the virtual environment:
- On Windows:
  ```
  .\venv\Scripts\activate
  ```
5. Install the required Python packages:
```pip install -r requirements.txt```

## Setting up the Environment Variables

1. Rename the `.env-template` file to `.env`.
2. Open the `.env` file in a text editor.
3. Replace `<Set Your Token, request from tracking support desk: >` with your actual API token.

## Running the Project

To run the project, execute the following command in the virtual environment:
```
python main.py
```
To exit the project, submit 'x' or 'exit' at any time

## Deactivating the Virtual Environment

When you're done, you can deactivate the virtual environment by running:
```deactivate```

## Understanding the Script

### Overview

The script `main.py` orchestrates user interactions and API requests based on user input. 
It utilizes a series of functions mapped to specific data retrieval needs such as fetching content areas, indicators, and measures from the API.
The script `api_requests.py` script handles all interactions with the API, sending requests and processing responses.

### Functions

#### Defined in `main.py`
- **`main()`**: The entry point of the script, managing the high-level flow of user interactions and data fetching.
- **`handle_user_input(options)`**: Manages the user's input, checks conditions from `action_map`, and triggers corresponding actions.
- **`set_user_selections(user_input, selector, options)`**: Updates the `user_selections` dictionary based on user input and the current context.
- **`print_options(options, page_number, items_per_page)`**: Formats and prints the options available to the user based on the current page and selections.
- **`handle_page_change(input)`**: Changes the current page of displayed options based on user input.
- **`decrement_function_id()`**: Moves the function ID back, used to navigate to the previous step.
- **`reset_function_id()`**: Resets the function ID and clears selections, starting the process over.
- **`get_max_lengths(data_dict)`**: Calculates the maximum length of strings in each column for proper alignment during display.
- **`exit_program()`**: Sets a flag to terminate the main interaction loop, exiting the program.

#### Defined in `api_requests.py`
- **`send_request(url, params, method, body, API_TOKEN, USE_API_TOKEN, PRESENTER_MODE)`**: Handles sending HTTP requests to the API. It constructs the request based on the method, handles query parameters, and processes the response.
- **`handle_x` Func

### Main Objects

- **`user_selections`**: A dictionary storing the user's selections made during the session. It keeps track of choices across different categories such as content areas, indicators, and measures.
- **`advanced_options`**: A dictionary holding additional parameters that might be required for more complex queries or to refine the data retrieval based on user inputs.
- **`function_map`**: A dictionary mapping each step or stage in the user interaction to a specific function that should be executed. It includes metadata about valid actions at each stage and the corresponding table names for display.
- **`action_map`**: A dictionary managing the possible actions a user can take (like navigating back, resetting choices, or jumping to a page), the conditions of the input to take that action, and the functions that should be executed when those conditions are met.
tions**: These functions (`handle_contentareas`, `handle_indicators`, `handle_measures`, etc.) are responsible for fetching specific types of data from the API. They construct the appropriate URL, call `send_request` with the necessary parameters, and transform the API response into a structured format (typically a pandas DataFrame) that the rest of the application can use. Each function is tailored to handle the data structure of its respective API endpoint.