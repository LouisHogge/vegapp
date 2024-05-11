import requests
import json
from .test_controller import TestController
from exceptions import TestFailureException

#######################################
# Test the Synchronization Controller #
#######################################

### 1. Post /synchronization : Synchronize the data of the user, creating an entry in the table associated with the user.

class TestSynchronizationController(TestController):
    
    def __init__(self, base_url, auth_token, tests):
        self.base_url = base_url
        self.auth_token = auth_token
        self.tests = tests
    
    # Create test garden
    def create_garden(self):
        return self.call_endpoint1('post', '/garden', {"name":"test garden"}, 200)

    # Get test garden name and id
    def get_garden(self):
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
        name = response_bis['name']
        return (id, name)
    
    # Delete test garden
    def delete_garden(self):
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
        
    # The expected https status code should be 201 but in our implementation, 200 is the one we chose.
    def test1(self):
        return self.call_endpoint1('post', '/sync', None, 200)
    
    # No data needed for the post as it is done with the auth token
    def test2(self):
        return self.call_endpoint1('post', '/sync', None, 409)
    
    # Delete should erase the entry in the sync table for the user with the corresponding token
    def test3(self):
        return self.call_endpoint1('delete', '/sync', None, 200)
    
    # Testing the first PUT request : should return 201 CREATED
    def test4(self):
        # A garden must be created
        result = self.create_garden()
        # Get the details of the garden
        garden = self.get_garden()
        garden_id = garden[0]
        garden_name = garden[1]
        # First activate the sync for the user
        result =  self.call_endpoint1('post', '/sync', None, 200)
        data = {"api_number":1,
                "url":f"https://springboot-api.apps.speam.montefiore.uliege.be/vegetable/Root/{garden_name}/null",
                "body":{ "name": "TESTOO", 
                         "seed_avaibility": 1,
                         "seed_expiration": 2026,
                         "harvest_start": 18,
                         "harvest_end": 22,
                         "plant_start": "March",
                         "plant_end": "November",
                         "note": "This is a note"
                        }, 
                "request_type":"post"}
        result = self.call_endpoint1('put', '/sync', data, 201)
        
        # Two PUT that are the same simulate a connection loss
        print("Test a simulation of a connection loss")
        result = self.call_endpoint1('put', '/sync', data, 200)
        print(f"\033[92mTest passed\033[0m")
        print()
        
        # Wrong api number
        print("Test a wrong api number")
        data = {"api_number":100,
                "url":f"https://springboot-api.apps.speam.montefiore.uliege.be/vegetable/Root/{garden_name}/null",
                "body":{ "name": "TESTOO", 
                         "seed_avaibility": 1,
                         "seed_expiration": 2026,
                         "harvest_start": 18,
                         "harvest_end": 22,
                         "plant_start": "March",
                         "plant_end": "November",
                         "note": "This is a note"
                        }, 
                "request_type":"post"}
        result = self.call_endpoint1('put', '/sync', data, 500)
        print(f"\033[92mTest passed\033[0m")
        print()
        
        return self.call_endpoint1('delete', '/sync', None, 200)
    
    # Testing the second PUT request : should return 200 OK