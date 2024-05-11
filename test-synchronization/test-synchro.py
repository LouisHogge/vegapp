import json
import datetime
from controllers.test_auth_controller import TestAuthController
from controllers.test_synchronization_controller import TestSynchronizationController
import urllib3
from urllib3.exceptions import InsecureRequestWarning


# Suppress only the single InsecureRequestWarning from urllib3
urllib3.disable_warnings(InsecureRequestWarning)
# Define the base URL of the API
base_url = "https://springboot-api.apps.speam.montefiore.uliege.be"

def load_test_config():
    with open('test_config.json', 'r') as file:
        return json.load(file)

def log_and_print(message,color_code=None):
    with open("logs/test_config.txt", "a") as log_file:
        if color_code:
            print(color_code + message + "\033[0m")
            log_file.write(message + "\n") # Log file doesn't need the color codes
        else:
            # print(message)
            log_file.write(message + "\n")
            
def main():
    # Load the tests configuration
    configs = load_test_config()
    
    # Run the tests regarding the authentication controller
    log_and_print(f"=== Starting Authentication Tests at {datetime.datetime.now()} ===", "\033[94m") # Blue color
    auth_tests = configs['tests_config_authentication_controller']
    tester = TestAuthController(base_url, auth_tests)
    results = tester.run_tests()
    for result in results:
        log_and_print(str(result))
    auth_token = tester.get_auth_token()
    log_and_print(f"=== Authentication Tests Completed === \n", "\033[94m") # Blue color
    
    # Run the tests regarding the synchronization controller
    log_and_print(f"=== Starting Synchronization Tests at {datetime.datetime.now()} ===", "\033[94m") # Blue color
    sync_tests = configs['tests_config_synchronization_controller']
    tester = TestSynchronizationController(base_url, auth_token, sync_tests)
    results = tester.run_tests()
    for result in results:
        log_and_print(str(result))
    log_and_print(f"=== Synchronization Tests Completed ===\n", "\033[94m") # Blue color

if __name__ == "__main__":
    main()