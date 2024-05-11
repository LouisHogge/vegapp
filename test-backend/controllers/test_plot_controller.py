import requests
import json
from .test_controller import TestController

#############################################
# Test the endpoints of the Plot Controller #
#############################################

### @GetMapping("/plot_years") : to get the plot years of a garden
### @GetMapping("/plot_names") : to get the plot names of a garden
### @GetMapping("/plot_versions") : to get the plot versions of a garden for a year and a plot
### @GetMapping("/plot/draw") : to get the information necessary to draw a specific plot
### @PostMapping("/plot/{garden_name}") : to create a plot for a garden
### @PutMapping("/plot/{garden_name}/{plot_name_old}") : to update a plot for a garden
### @DeleteMapping("/plot/{garden_name}/{plot_name}") : to delete a plot for a garden

class TestPlotController(TestController):
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
    
    # Implement specific plot tests
    
    # Test the GET request
    # Must be implemented
    def test1(self):
        # A garden must be created
        result = self.create_garden()
        # Get the details of the garden
        garden = self.get_garden()
        garden_id = garden[0]
        garden_name = garden[1]
        
        return self.delete_garden()