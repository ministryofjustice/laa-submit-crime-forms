# Javascript Testing

Using the Cuprite gem the following can help with running and debugging

## Running in browser instance

Run the tests with `HEADLESS=0` to have then open in the browser (versus running
in headless mode)

```
HEADLESS=0 rspec
```

When running in headless mode the following commands are avaliable in the test suite

### pause

This pauses the tests suite so you can view the state in the browser.

Continue by pressing `enter` in the (testing) terminal

### debug

This pauses the tests suite and opens the debug window in the browser so you can view the state.

Continue by pressing `enter` in the (testing) terminal

## Debugging

As with (all that I have used) browser based testing solution, they can crash and result
in the test suite refusing to initialise as instance of the server is left running.

To fix this look for running server instance using:

```
lsof -n -i :3023
```

and then kill them via their PID.