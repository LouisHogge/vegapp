import requests
import sys
import json
from exceptions import TestFailureException
import urllib3
from urllib3.exceptions import InsecureRequestWarning


# Suppress only the single InsecureRequestWarning from urllib3
urllib3.disable_warnings(InsecureRequestWarning)

######################################################
# Test the endpoints of Controllers Using Inheritance#
######################################################

class TestController:        
    def check_test(self, url, status_code, test_result, function, description, response):
        # print(f'Response of the server : {response_server}')
        if test_result == True:
            print(f"Test : {description}")
            print(f"\033[92mTest passed\033[0m")
        else:
            print(f"Test : {description}")
            raise TestFailureException(url, status_code, f"\033[91mTest failed\033[0m in {function}", response)
        
    def run_tests(self):
        results = []
        for test in self.tests:
            try:
                method = getattr(self, test['function'])
                result = method()
                results.append(result)
                self.check_test(result['Url'], result['Status Code'], result['Success'], test['function'], test['description'], result['Response of Server'])
            except TestFailureException as e:
                print(e)
                # Optionally, stop further tests or handle errors differently
                sys.exit(1)  # Stop testing after the first failure -> exits with a non-zero status code to indicate failure
        return results

    # Test passes if result is the same as the expected status code
    def call_endpoint1(self, method, endpoint, data, expected_status_code):
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        if method.lower() == 'get':
            response = requests.get(url, headers=headers, json=data, verify=False)
        elif method.lower() == 'post':
            response = requests.post(url, headers=headers, json=data, verify=False)
        elif method.lower() == 'delete':
            response = requests.delete(url, headers=headers, json=data, verify=False)
        elif method.lower() == 'put':
            response = requests.put(url, headers=headers, json=data, verify=False)
        else:
            return None
        
        try:
            response_bis = response.json() # Attempt to parse JSON
        except json.decoder.JSONDecodeError:
            response_bis = response.text
        if response.status_code == expected_status_code:
            return {'Url': url, 'Status Code': response.status_code, 'Success': True, 'Response of Server': response_bis}
        else:
            return {'Url': url, 'Status Code': response.status_code, 'Success': False, 'Response of Server': response_bis}

    # Test passes if result is different from the expected status code
    def call_endpoint2(self, method, endpoint, data, expected_status_code):
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        if method.lower() == 'get':
            response = requests.get(url, headers=headers, json=data, verify=False)
        elif method.lower() == 'post':
            response = requests.post(url, headers=headers, json=data, verify=False)
        elif method.lower() == 'delete':
            response = requests.delete(url, headers=headers, json=data, verify=False)
        else:
            return None
        
        try:
            response_bis = response.json() # Attempt to parse JSON
        except json.decoder.JSONDecodeError:
            response_bis = response.text
        if response.status_code == expected_status_code:
            return {'Url': url, 'Status Code': response.status_code, 'Success': False, 'Response of Server': response_bis}
        else:
            return {'Url': url, 'Status Code': response.status_code, 'Success': True, 'Response of Server': response_bis}