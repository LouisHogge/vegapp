import requests
import json
from .test_controller import TestController

###############################################
# Test the endpoints of the Garden Controller #
###############################################

### 1. Get /garden : get all gardens from DB
### 2. Get /garden/{name} : get a specific garden from DB
### 3. Post /garden : create a garden
### 4. Delete /garden/{id} : delete a garden
### 5. PUT /garden : update a garden

class TestGardenController(TestController):
    def __init__(self, base_url, auth_token, tests):
        self.base_url = base_url
        self.auth_token = auth_token
        self.tests = tests

    # Implement specific garden tests
    # Should be True : Verify getting all gardens from DB works
    def test1(self):
        return self.call_endpoint1('get', '/garden', None, 200)
    
    # Is status code is 200 even though the garden name is wrong, it shouldn't be accepted
    # So it passes the test if the status code is not 200
    # Wrong specific garden name from DB
    def test2(self):
        return self.call_endpoint2('get', '/garden/Garden of simon123', 'Garden of simon123', 200)
    
    # 201 is the code that should be sent
    # Create a garden   
    def test3(self):
        return self.call_endpoint1('post', '/garden', {"name":"test garden"}, 200)
    
    # Good specific garden name from DB
    def test4(self):
        return self.call_endpoint1('get', '/garden/test garden', 'test garden', 200)
    
    # 201 is the code that should be sent 
    # This test will be available soon
    # It tests that two garden cannot have the same name
    # server's response is not yet implemented
    def test5(self):
        return self.call_endpoint2('post', '/garden', {"name":"test garden"}, 200)
    
    # Delete a garden
    def test6(self):
        endpoint = '/garden/test garden'
        data = 'test garden'
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        response = requests.get(url, headers=headers, json=data, verify=False)
        
        try:
            response_bis = response.json() # Attempt to parse JSON
        except json.decoder.JSONDecodeError:
            response_bis = response.text
        id = response_bis['id']
        return self.call_endpoint1('delete', f'/garden/{id}', f'{id}', 200)
    
    # Test the PUT method for the garden
    def test7(self):
        # Create the garden first
        result = self.call_endpoint1('post', '/garden', {"name":"test garden"}, 200)
        
        # Get the id of the garden
        endpoint = '/garden/test garden'
        data = 'test garden'
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        response = requests.get(url, headers=headers, json=data, verify=False)
        try:
            response_bis = response.json() # Attempt to parse JSON
        except json.decoder.JSONDecodeError:
            response_bis = response.text
        id = response_bis['id']

        # For the garden with this id using the auth token to have the user, change the name of the garden
        data = {'id': id, 'name': 'new test garden'}
        endpoint = '/garden'
        url = f"{self.base_url}{endpoint}"
        response = requests.put(url, headers=headers, json=data, verify=False)
        
        # First Put should be successful and return 200
        try:
            response_bis = response.json() # Attempt to parse JSON
        except json.decoder.JSONDecodeError:
            response_bis = response.text
        if response.status_code != 200:
            result = self.call_endpoint1('delete', f'/garden/{id}', f'{id}', 200)
            result['Success'] = False
            return result
        
        # Second PUT should return 200
        response = requests.put(url, headers=headers, json=data, verify=False)
        try:
            response_bis = response.json() # Attempt to parse JSON
        except json.decoder.JSONDecodeError:
            response_bis = response.text
        if response.status_code != 200:
            result = self.call_endpoint1('delete', f'/garden/{id}', f'{id}', 200)
            result['Success'] = False
            return result
        
        # Third PUT should return 403 NOT FOUND as it isn't found
        response = requests.put(url, headers=headers, json={'id': 'hello, i am', 'name': 'new test garden'}, verify=False)
        try:
            response_bis = response.json() # Attempt to parse JSON
        except json.decoder.JSONDecodeError:
            response_bis = response.text
        if response.status_code != 403:
            result = self.call_endpoint1('delete', f'/garden/{id}', f'{id}', 200)
            result['Success'] = False
            return result
        
        # Ensure that the garden was updated
        # Get the id of the garden
        endpoint = '/garden/new test garden'
        data = 'new test garden'
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        response = requests.get(url, headers=headers, json=data, verify=False)
        try:
            response_bis = response.json() # Attempt to parse JSON
        except json.decoder.JSONDecodeError:
            response_bis = response.text
        new_name = response_bis['name']
        if (new_name == 'new test garden'):
            return self.call_endpoint1('delete', f'/garden/{id}', f'{id}', 200)
        
        else:
            # Delete the garden used for testing
            result = self.call_endpoint1('delete', f'/garden/{id}', f'{id}', 200)
            result['Success'] = False
            return result