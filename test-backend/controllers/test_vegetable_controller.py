import requests
import json
from .test_controller import TestController

###############################################
# Test the endpoints of the Veggie Controller #
###############################################

### @PostMapping("/vegetable/{category_primary_name}/{garden_name}/{category_secondary_name}")
### @PutMapping("/vegetable/{garden_name}/{category_primary_name_new}/{category_secondary_name_new}/{veggie_name}/{category_primary_name_old}/{category_secondary_name_old}")
class TestVegetableController(TestController):
    def __init__(self, base_url, auth_token, tests):
        self.base_url = base_url
        self.auth_token = auth_token
        self.tests = tests
        
    categories_primary = ['Bin', 'Root', 'Nightshade', 'Salad Green', 'Cruciferous', 'Alliums', 'Podded', 'Tubers', 'Stem', 'Leafy Green', 'Brassica', 'Solanaceous']
    fake_category = 'Apple'
    
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
    
    # Set data field for the requests
    def set_data(self, name, seed_avaibility, seed_expiration, harvest_start, harvest_end, plant_start, plant_end, note):
        return {"name": name, 
                "seed_availability": seed_avaibility,
                "seed_expiration": seed_expiration,
                "harvest_start": harvest_start,
                "harvest_end": harvest_end,
                "plant_start": plant_start,
                "plant_end": plant_end,
                "note": note}
    
    # Set data field for the requests
    def set_data_bis(self, name, seed_avaibility, seed_expiration, harvest_start, harvest_end, plant_start, plant_end, note, fake_data):
        return {"name": name, 
                "seed_availability": seed_avaibility,
                "seed_expiration": seed_expiration,
                "harvest_start": harvest_start,
                "harvest_end": harvest_end,
                "plant_start": plant_start,
                "plant_end": plant_end,
                "note": "<script>alert('XSS Demo');</script>",
                "fake": fake_data}
    
    # Implement specific vegetable tests
    
    # Test the POST request
    def test1(self):
        # A garden must be created
        result = self.create_garden()
        # Get the details of the garden
        garden = self.get_garden()
        garden_id = garden[0]
        garden_name = garden[1]
        
        # First Test, wrong URL
        endpoint = '/vegetable/Apple'
        data = self.set_data("TEST", 1, 2026, 18, 22, "March", "November", "This is a note")
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        response = requests.post(url, headers=headers, json=data, verify=False)
        if response.status_code == 200:
            result = self.delete_garden()
            result['Success'] = False
            return result
        
        # Second Test, wrong category
        print("Test with wrong category")
        endpoint = f'/vegetable/{self.fake_category}/{garden_name}/null'
        data = self.set_data("TEST", 1, 2026, 18, 22, "March", "November", "This is a note")
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        response = requests.post(url, headers=headers, json=data, verify=False)
        if response.status_code == 200:
            result = self.delete_garden()
            result['Success'] = False
            return result
        print("Status Code : " + str(response.status_code))
        print(f"\033[92mTest passed\033[0m")
        print()
        
        # Third Test, more data than needed
        print("Test with more data than needed")
        endpoint = f'/vegetable/Root/{garden_name}/null'
        data = self.set_data_bis("TEST", 1, 2026, 18, 22, "March", "Nov.", "This is a note", "Supplementary data")
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        response = requests.post(url, headers=headers, json=data, verify=False)
        if response.status_code == 200:
            result = self.delete_garden()
            result['Success'] = False
            return result
        print("Status Code : " + str(response.status_code))
        print("Response : " + response.text)
        print(f"\033[92mTest passed\033[0m")
        print()
        
        # Fourth Test, create vegetable with same name
        print("Test creating vegetable with same name")
        endpoint = f'/vegetable/Root/{garden_name}/null'
        data = self.set_data("TEST", 1, 2026, 18, 22, "March", "Nov.", "This is a note")
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        response = requests.post(url, headers=headers, json=data, verify=False)
        if response.status_code != 403:
            result = self.delete_garden()
            result['Success'] = False
            return result
        print("Status Code : " + str(response.status_code))
        print("Response : " + response.text)
        print(f"\033[92mTest passed\033[0m")
        print()
        
        # Fifth test, wrong data
        print("Test with wrong data")
        endpoint = f'/vegetable/Root/{garden_name}/null'
        data = self.set_data(1, 1, 2016, 11, 1, 1, 1, 1)
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        response = requests.post(url, headers=headers, json=data, verify=False)
        if response.status_code == 200:
            result = self.delete_garden()
            result['Success'] = False
            return result
        print("Status Code : " + str(response.status_code))
        print("Response : " + response.text)
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
        
        # First Test, create vegetable, modify it and see changes
        print("Test create vegetable, modify it and see changes")
        endpoint = f'/vegetable/Root/{garden_name}/null'
        data = self.set_data("TEST", 1, 2026, 18, 22, "March", "Nov.", "This is a note")
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        response = requests.post(url, headers=headers, json=data, verify=False)
        print("Status Code : " + str(response.status_code))
        print("Response : " + response.text)
        if response.status_code != 201:
            result = self.delete_garden()
            result['Success'] = False
            return result
        endpoint = f'/vegetable/{garden_name}/Root/null/TEST/Root/null'
        data = self.set_data("TEST", 1, 2023, 16, 19, "Jan.", "Nov.", "This is a note")
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        response = requests.put(url, headers=headers, json=data, verify=False)
        if response.status_code != 200:
            result = self.delete_garden()
            result['Success'] = False
            return result
        print("Updated vegetable")
        print("Status Code : " + str(response.status_code))
        print("Response : " + response.text)
        print(f"\033[92mTest passed\033[0m")
        print()
        
        print("Test wrong PUT request")
        endpoint = f'/vegetable/{garden_name}/Root/null/Hello/Root/null'
        data = self.set_data("TEST", 1, 2023, 16, 19, "Jan.", "Nov.", "This is a note")
        url = f"{self.base_url}{endpoint}"
        headers = {'Authorization': f'Bearer {self.auth_token}'}
        response = requests.put(url, headers=headers, json=data, verify=False)
        if response.status_code == 200:
            result = self.delete_garden()
            result['Success'] = False
            return result
        print("Updated vegetable")
        print("Status Code : " + str(response.status_code))
        print("Response : " + response.text)
        print(f"\033[92mTest passed\033[0m")
        print()
        
        return self.delete_garden()