require("./BHClient")

c = BHClient:new("http://127.0.0.1:1337")
c:initialize()

while true do
    c:useControls()
    c:advanceFrame()

    if c:timeToUpdate() then
        c:saveScreenshot()
        local statements = {
            c:setStatement("x", 512, "INT"),
            c:getStatement("x"),
            c:updateStatement(),
            c:setControlsStatement(),
            c:checkRestartStatement(),
            c:checkExitStatement()
        }

        local x_response, controls_response, restart_response, exit_response = c:sendList(statements)
        local xType, x = c:get(x_response)
        c:setControls(controls_response)
        c:checkRestart(restart_response)

        if c:checkExit(exit_response) then break end
    end
end
