-- Simple test script for HTTP connection in BizHawk
local url = "http://127.0.0.1:8080"

-- Function to test HTTP connection
function test_http_connection()
    local response = comm.httpGet(url)
    if response then
        print("Connection successful!")
        print("Server response: " .. response)
    else
        print("Failed to connect")
    end
end

-- Call the function to test connection
test_http_connection()
