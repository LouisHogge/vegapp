import requests
import json
from .test_controller import TestController
from exceptions import TestFailureException

#######################################################
# Test the endpoints of the Authentication Controller #
#######################################################

### 1. Post /auth/register : Create a user
### 2. Post /auth/authenticate : Get token of user

class TestAuthController(TestController):
    
    def __init__(self, base_url, tests):
        self.base_url = base_url
        self.tests = tests
        
    # Implement specific authentication tests
    def get_auth_token(self):
        return self.auth_token
    
    def user_created_already(self):
        data = {"email" : "simon123@hotmail.com", "password" : "simsim123"}
        endpoint = "/auth/authenticate"
        url = self.base_url + endpoint
        response = requests.post(url, json=data, verify=False)
        try:
            self.auth_token = response.json()['token'] # Attempt to parse JSON
            self.response_bis = response.json()
        except json.decoder.JSONDecodeError:
            self.auth_token = response.text
            self.response_bis = response.text
        if response.status_code == 200:
            return (True, self.auth_token)
        else:
            return (False, None)
    
    def create_user(self):
        data = {"first_name" : "simon","last_name" : "loulou","email" : "simon123@hotmail.com","password" : "simsim123"}
        endpoint = "/auth/register"
        url = self.base_url + endpoint
        response = requests.post(url, json=data, verify=False)
        try:
            self.auth_token = response.json()['token'] # Attempt to parse JSON
            self.response_bis = response.json()
        except json.decoder.JSONDecodeError:
            self.auth_token = response.text
            self.response_bis = response.text
        if response.status_code == 200:
            return self.auth_token
        else:
            raise TestFailureException(url, response.status_code, "Test failed for creating the user", self.response_bis)

    # Should be True : Verify creating a user works and if it is already created if the server responds correctly
    def test1(self):
        user = self.user_created_already()
        if user[0]:
            # Response of the server is the token but don't want it to appear in the logs so change self.response_bis by a string
            return {'Url': self.base_url, 'Status Code': 200, 'Success': True, "Response of Server": "User already created"}
        else:
            self.create_user()
            return {'Url': self.base_url, 'Status Code': 200, 'Success': True, "Response of Server": "User created"}
        
    # tests if I cannot have the token withtout giving the password
    def test2(self):
        return self.call_endpoint2('post', '/auth/authenticate', {"email" : ""}, 200)