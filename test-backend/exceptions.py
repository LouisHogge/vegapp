class TestFailureException(Exception):
    """Exception raised for errors in the test results."""
    def __init__(self, url, status_code, message, response):
        self.url = url
        self.status_code = status_code
        self.message = message
        self.response = response
        super().__init__(self.message)

    def __str__(self):
        return f"{self.message} -- Status Code: {self.status_code} at URL: {self.url} with Server's Response : {self.response}"