import requests
import pandas as pd
from dotenv import load_dotenv
import os
import urllib.parse
from main import *


load_dotenv()
API_TOKEN = os.getenv("API_Token")
USE_API_TOKEN = os.getenv("Use_API_Token") == "TRUE"
PRESENTER_MODE = os.getenv("Presenter_Mode") == "TRUE"
BASE_URL = os.getenv("Base_Url") if os.getenv("Base_Url") is not None else "https://ephtracking.cdc.gov/apigateway/api/v1"

def send_request(url, params, method='GET', body=None, API_TOKEN=None, USE_API_TOKEN=False, PRESENTER_MODE=False):
    present_url = url if not params else f"{url}?{'&'.join([f'{key}={params[key]}' for key in params.keys()])}"
    if USE_API_TOKEN:
        params['apiToken'] = API_TOKEN
    request_url = url if not params else f"{url}?{'&'.join([f'{key}={params[key]}' for key in params.keys()])}"
    if PRESENTER_MODE:
        print(f"Request sent to {present_url} {f'with body {body}' if body else ''}")
    else:
        print(f"Request sent to {request_url} {f'with body {body}' if body else ''}")

    try:

        if method == 'GET':
            response = requests.get(request_url)
        elif method == 'POST':
            response = requests.post(request_url, json=body)
        response.raise_for_status()
        response_data = response.json()
        if 'errorTypeId' in response_data:
            raise ValueError(f"Error: {response_data['message']}")
        return response_data
    except requests.exceptions.HTTPError as err:
        raise ValueError("Received bad status code from API") from err
    except requests.exceptions.RequestException as err:
        raise SystemExit("Failed to connect to API") from err


def handle_contentareas(API_TOKEN, USE_API_TOKEN, PRESENTER_MODE, core_holder):
    url = f"{BASE_URL}/contentareas/json"
    response = send_request(url, {}, API_TOKEN=API_TOKEN, USE_API_TOKEN=USE_API_TOKEN, PRESENTER_MODE=PRESENTER_MODE)
    transformed_data = [
        {
            'Id': int(item['id']),
            'Name': item['name']
        }
        for item in response
    ]
    response_data = pd.DataFrame(transformed_data)
    response_data.sort_values(by='Id', inplace=True)
    return response_data

def handle_indicators(API_TOKEN, USE_API_TOKEN, PRESENTER_MODE, core_holder):
    url = f"{BASE_URL}/indicators/{core_holder[CONTENT_AREA_ID]}"
    response = send_request(url, {}, API_TOKEN=API_TOKEN, USE_API_TOKEN=USE_API_TOKEN, PRESENTER_MODE=PRESENTER_MODE)
    transformed_data = [
        {
            'Id': int(item['id']),
            'Name': item['name']
        }
        for item in response
    ]
    response_data = pd.DataFrame(transformed_data)
    response_data.sort_values(by='Id', inplace=True)
    return response_data

def handle_measures(API_TOKEN, USE_API_TOKEN, PRESENTER_MODE, core_holder):
    url = f"{BASE_URL}/measures/{core_holder[INDICATOR_ID]}"
    response = send_request(url, {}, API_TOKEN=API_TOKEN, USE_API_TOKEN=USE_API_TOKEN, PRESENTER_MODE=PRESENTER_MODE)
    transformed_data = [
        {
            'Id': int(item['id']),
            'Name': item['name']
        }
        for item in response
    ]
    response_data = pd.DataFrame(transformed_data)
    response_data.sort_values(by='Id', inplace=True)
    return response_data

def handle_geographicType(API_TOKEN, USE_API_TOKEN, PRESENTER_MODE, core_holder):
    url = f"{BASE_URL}/geographicTypes/{core_holder[MEASURE_ID]}"
    response = send_request(url, {}, API_TOKEN=API_TOKEN, USE_API_TOKEN=USE_API_TOKEN, PRESENTER_MODE=PRESENTER_MODE)
    transformed_data = [
        {
            'Id': int(item['geographicTypeId']),
            'Name': item['geographicType']
        }
        for item in response
    ]
    response_data = pd.DataFrame(transformed_data)
    response_data.sort_values(by='Id', inplace=True)
    return response_data

def handle_geographicItems(API_TOKEN, USE_API_TOKEN, PRESENTER_MODE, core_holder):
    url = f"{BASE_URL}/geographicItems/{core_holder[MEASURE_ID]}/{core_holder[GEOGRAPHIC_TYPE_ID]}/0"
    response = send_request(url, {}, API_TOKEN=API_TOKEN, USE_API_TOKEN=USE_API_TOKEN, PRESENTER_MODE=PRESENTER_MODE)
    transformed_data = [
        {
            'Id': int(item['childGeographicId'] if item['childGeographicId'] is not None else item['parentGeographicId']),
            'Name': item['childName'] if item['childName'] is not None else item['parentName']
        }
        for item in response
    ]
    response_data = pd.DataFrame(transformed_data)
    response_data.sort_values(by='Id', inplace=True)
    return response_data

def handle_stratificationLevel(API_TOKEN, USE_API_TOKEN, PRESENTER_MODE, core_holder):
    url = f"{BASE_URL}/stratificationlevel/{core_holder[MEASURE_ID]}/{core_holder[GEOGRAPHIC_TYPE_ID]}/0"
    response = send_request(url, {}, API_TOKEN=API_TOKEN, USE_API_TOKEN=USE_API_TOKEN, PRESENTER_MODE=PRESENTER_MODE)
    transformed_data = [
        {
            'Id': int(item['id']),
            'Name': item['name'],
            'StratificationTypes': [st['id'] for st in item['stratificationType']]
        }
        for item in response
    ]
    response_data = pd.DataFrame(transformed_data)
    response_data.sort_values(by='Id', inplace=True)
    print(response_data.head())
    return response_data

def handle_stratificationTypes(API_TOKEN, USE_API_TOKEN, PRESENTER_MODE, core_holder):
    url = f"{BASE_URL}/stratificationTypes/{core_holder[MEASURE_ID]}/{core_holder[GEOGRAPHIC_TYPE_ID]}/0"
    response = send_request(url, {}, API_TOKEN=API_TOKEN, USE_API_TOKEN=USE_API_TOKEN, PRESENTER_MODE=PRESENTER_MODE)
    response_data = pd.DataFrame([])
    if len(response) > 0:
        transformed_data = [
            {
                'Id': int(strat_item['localId']),
                'Name': strat_item['name'],
                'ColumnName': item['columnName'],
                'DisplayName': item['displayName'],
                'StratificationTypeId': item['stratificationTypeId']
            }
            for item in response for strat_item in item['stratificationItem']
        ]
        response_data = pd.DataFrame(transformed_data)
        response_data.sort_values(by='Id', inplace=True)
    return response_data

def handle_temporalType(API_TOKEN, USE_API_TOKEN, PRESENTER_MODE, core_holder):
    url = f"{BASE_URL}/temporalType/{core_holder[MEASURE_ID]}"
    response = send_request(url, {}, API_TOKEN=API_TOKEN, USE_API_TOKEN=USE_API_TOKEN, PRESENTER_MODE=PRESENTER_MODE)
    transformed_data = [
        {
            'Id': int(item['temporalTypeId']),
            'Name': item['name']
        }
        for item in response
    ]
    response_data = pd.DataFrame(transformed_data)
    response_data.sort_values(by='Id', inplace=True)
    return response_data

def handle_temporalItems(API_TOKEN, USE_API_TOKEN, PRESENTER_MODE, core_holder):
    url = f"{BASE_URL}/temporalItems/{core_holder[MEASURE_ID]}/{core_holder[GEOGRAPHIC_TYPE_ID]}/{core_holder[GEOGRAPHIC_TYPE_ID]}/{core_holder[GEOGRAPHIC_ITEM_IDS]}?AgeBandId=1,2,3,4,5&GenderId=1,2"
    response = send_request(url, {}, API_TOKEN=API_TOKEN, USE_API_TOKEN=USE_API_TOKEN, PRESENTER_MODE=PRESENTER_MODE)
    transformed_data = [
        {
            'Id': int(item['temporal']),
            'Name': item['temporal']
        }
        for item in response
    ]
    response_data = pd.DataFrame(transformed_data)
    response_data.sort_values(by='Id', inplace=True)
    return response_data


def handle_getCoreHolder(API_TOKEN, USE_API_TOKEN, PRESENTER_MODE, core_holder, advanced_options):
    url_get = (f"{BASE_URL}/getCoreHolder/{core_holder[MEASURE_ID]}/{core_holder[STRATIFICATION_LEVEL_ID]}/"
               f"{core_holder[GEOGRAPHIC_TYPE_ID]}/{core_holder[GEOGRAPHIC_ITEM_IDS]}/{core_holder[TEMPORAL_TYPE_ID]}/{core_holder[TEMPORAL_ITEM_IDS]}/0/0")
    response = send_request(url_get, advanced_options, method='GET', API_TOKEN=API_TOKEN, USE_API_TOKEN=USE_API_TOKEN, PRESENTER_MODE=PRESENTER_MODE)
    resultType = response['tableReturnType']
    data = response[resultType]
    groups = response['lookupList']
    core_holder_result = []

    for item in data:
        group_id = item['groupById']
        if group_id in groups:
            stratification = ' BY '.join([f"{strat_item['name']}: {strat_item['itemName']}" for strat_item in groups[group_id]])
            core_holder_result.append({
                'Data': item['secondaryValueDisplay'] if item['secondaryValue'] else item['displayValue'],
                'Units': item['secondaryValueName'] if item['secondaryValueName'] else item['calculationType'],
                'Location': item['geo'] if item['parentGeo'] is None else f"{item['geo']}, {item['parentGeo']}",
                'Time': format_temporal(item['temporal']),
                'Stratification': stratification
            })

    response_data = pd.DataFrame(core_holder_result)
    response_data.sort_values(by=['Time', 'Location'], inplace=True)
    return response_data


def format_temporal(temporal):
    if len(temporal) == 4:
        return temporal
    if len(temporal) == 6:
        return f"{temporal[4:]}/{temporal[:4]}"
    if len(temporal) == 8:
        return f"{temporal[4:6]}/{temporal[6:]}/{temporal[:4]}"
