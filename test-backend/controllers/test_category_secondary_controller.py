import requests
import json
from .test_controller import TestController

###########################################################
# Test the endpoints of the Category Secondary Controller #
###########################################################

### @PostMapping("/categorySecondary/{garden_name}")
### @PutMapping("/categorySecondary/{garden_name}/{category_name}")
### @DeleteMapping("/categorySecondary/{name}")

class TestCategorySecondaryController(TestController):
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
    
    # Implement specific category secondary tests
    
    # Test the POST request
    def test1(self):
        # A garden must be created
        result = self.create_garden()
        # Get the details of the garden
        garden = self.get_garden()
        garden_id = garden[0]
        garden_name = garden[1]
        
        # First Test : POST request
        print("Test with good category secondary")
        endpoint = f'/categorySecondary/{garden_name}'
        data = {"name":"test category", "color":'GREEN'}
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        response = requests.post(url, headers=headers, json=data, verify=False)
        if response.status_code != 200:
            result = self.delete_garden()
            result['Success'] = False
            return result
        print("Status Code : " + str(response.status_code))
        print("Response : " + response.text)
        print(f"\033[92mTest passed\033[0m")
        print()
        
        # Second Test : POST request
        print("Test with good category secondary but same name")
        endpoint = f'/categorySecondary/{garden_name}'
        data = {"name":"test category", "color":'GREEN'}
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        response = requests.post(url, headers=headers, json=data, verify=False)
        if response.status_code != 409:
            result = self.delete_garden()
            result['Success'] = False
            return result
        print("Status Code : " + str(response.status_code))
        print("Response : " + response.text)
        print(f"\033[92mTest passed\033[0m")
        print()
        
        # Third Test : POST request
        print("Test with good category secondary but incorrect color")
        endpoint = f'/categorySecondary/{garden_name}'
        data = {"name":"test category", "color":'DARK GREEN'}
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        response = requests.post(url, headers=headers, json=data, verify=False)
        if response.status_code != 403:
            result = self.delete_garden()
            result['Success'] = False
            return result
        print("Status Code : " + str(response.status_code))
        print(f"\033[92mTest passed\033[0m")
        print()       
         
        return self.delete_garden()
    
    # Test the PUT request
    def test2(self):
        # A garden must be created
        result = self.create_garden()
        # Get the details of the garden
        garden = self.get_garden()
        garden_id = garden[0]
        garden_name = garden[1]
        
        # First Test : POST request
        print("Test with good category secondary")
        endpoint = f'/categorySecondary/{garden_name}'
        data = {"name":"test category", "color":'GREEN'}
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        response = requests.post(url, headers=headers, json=data, verify=False)
        if response.status_code != 200:
            result = self.delete_garden()
            result['Success'] = False
            return result
        print("Status Code : " + str(response.status_code))
        print("Response : " + response.text)
        id = response.json()['id']
        print(f"\033[92mTest passed\033[0m")
        print()
        
        # Second Test : PUT request
        print("Test changes to category secondary")
        endpoint = f'/categorySecondary/{garden_name}/test category'
        data = {"name":"new test category", "color":'RED'}
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        response = requests.put(url, headers=headers, json=data, verify=False)
        if response.status_code != 200:
            result = self.delete_garden()
            result['Success'] = False
            return result
        print("Status Code : " + str(response.status_code))
        print("Response : " + response.text)
        print(f"\033[92mTest passed\033[0m")
        print()
        
        # Third Test : PUT request X2 -> Should be not found as name was changed
        print("Test changes to category secondary name not found")
        endpoint = f'/categorySecondary/{garden_name}/test category'
        data = {"name":"new test category", "color":'RED'}
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        response = requests.put(url, headers=headers, json=data, verify=False)
        print("Status Code : " + str(response.status_code))
        print("Response : " + response.text)
        if response.status_code != 404:
            result = self.delete_garden()
            result['Success'] = False
            return result
        print("Status Code : " + str(response.status_code))
        print("Response : " + response.text)
        print(f"\033[92mTest passed\033[0m")
        print()
        
        # Fourth Test : PUT request X2
        print("Test changes to category secondary again with same data")
        endpoint = f'/categorySecondary/{garden_name}/new test category'
        data = {"name":"new test category", "color":'RED'}
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        response = requests.put(url, headers=headers, json=data, verify=False)
        print("Status Code : " + str(response.status_code))
        print("Response : " + response.text)
        if response.status_code != 200:
            result = self.delete_garden()
            result['Success'] = False
            return result
        print("Status Code : " + str(response.status_code))
        print("Response : " + response.text)
        print(f"\033[92mTest passed\033[0m")
        print()
        
        return self.delete_garden()
    
    # Test the DELETE request
    def test3(self):
        # A garden must be created
        result = self.create_garden()
        # Get the details of the garden
        garden = self.get_garden()
        garden_id = garden[0]
        garden_name = garden[1]
        
        # First Test : POST request
        print("Test with good category secondary")
        endpoint = f'/categorySecondary/{garden_name}'
        data = {"name":"test category", "color":'GREEN'}
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        response = requests.post(url, headers=headers, json=data, verify=False)
        if response.status_code != 200:
            result = self.delete_garden()
            result['Success'] = False
            return result
        print("Status Code : " + str(response.status_code))
        print("Response : " + response.text)
        id = response.json()['id']
        print(f"\033[92mTest passed\033[0m")
        print()
        
        # Second Test : DELETE request
        print("Test delete category secondary")
        endpoint = f'/categorySecondary/test category/{garden_name}'
        data = {"name": "test category"}
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        response = requests.delete(url, headers=headers, json=data, verify=False)
        if response.status_code != 200:
            result = self.delete_garden()
            result['Success'] = False
            return result
        print("Status Code : " + str(response.status_code))
        print("Response : " + response.text)
        print(f"\033[92mTest passed\033[0m")
        print()
        
        return self.delete_garden()