import json
import datetime
import urllib3
from controllers.test_auth_controller import TestAuthController
from controllers.test_garden_controller import TestGardenController
from controllers.test_vegetable_controller import TestVegetableController
from controllers.test_category_secondary_controller import TestCategorySecondaryController
from controllers.test_plot_controller import TestPlotController
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
    
    # Run the tests regarding the garden controller
    log_and_print(f"=== Starting Garden Tests at {datetime.datetime.now()} ===", "\033[94m") # Blue color
    garden_tests = configs['tests_config_garden_controller']
    tester = TestGardenController(base_url, auth_token, garden_tests)
    # tester.run_tests()
    results = tester.run_tests()
    for result in results:
        log_and_print(str(result))
    log_and_print(f"=== Garden Tests Completed ===\n", "\033[94m") # Blue color

    # Run the tests regarding the vegetable controller
    log_and_print(f"=== Starting Vegetable Tests at {datetime.datetime.now()} ===", "\033[94m") # Blue color
    vegetable_tests = configs['tests_config_vegetable_controller']
    tester = TestVegetableController(base_url, auth_token, vegetable_tests)
    # tester.run_tests()
    results = tester.run_tests()
    for result in results:
        log_and_print(str(result))
    log_and_print(f"=== Vegetable Tests Completed ===\n", "\033[94m") # Blue color

    # Run and tests regarding the category secondary controller
    log_and_print(f"=== Starting Category Secondary Tests at {datetime.datetime.now()} ===", "\033[94m") # Blue color
    category_secondary_tests = configs['tests_config_category_secondary_controller']
    tester = TestCategorySecondaryController(base_url, auth_token, category_secondary_tests)
    # tester.run_tests()
    results = tester.run_tests()
    for result in results:
        log_and_print(str(result))
    log_and_print(f"=== Category Secondary Tests Completed ===\n", "\033[94m") # Blue color

    # Run the tests regarding the plot controller
    log_and_print(f"=== Starting Plot Tests at {datetime.datetime.now()} ===", "\033[94m") # Blue color
    plot_tests = configs['tests_config_plot_controller']
    tester = TestPlotController(base_url, auth_token, plot_tests)
    # tester.run_tests()
    results = tester.run_tests()
    for result in results:
        log_and_print(str(result))
    log_and_print(f"=== Plot Tests Completed ===\n", "\033[94m") # Blue color
    
if __name__ == "__main__":
    main()