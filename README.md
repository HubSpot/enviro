env
===

Env is a Node and client-side ~60 LOC library to manage what environment your code is running in, and let you
override the environment for parts of the system.

### Usage

#### On Node
```coffeescript
Env = require('enviro')

Env.get('api') # Will return local, development, or production
Env.getInternal('api') # Will return local, qa, or prod

# Gets it's env from env vars, first would look to API_ENV, then NODE_ENV
```
#### On The Frontend
```coffeescript
hubspot.require ['enviro'], (Env) ->

  Env.get('usage_tracking')
  
  # Set with window.USAGE_TRACKING_ENV or localStorage.USAGE_TRACKING_ENV
  # If neither is defined, it will use hubspot.server.env
```

#### Functions

`get(serviceName, [default])` - returns 'development' or 'production' to let you know which servers serviceName should
be talking to

`getShort(serviceName, [default])` - returns 'local', 'qa' or 'prod', otherwise the same as `get`

`deployed(serviceName)` - Returns boolean based on whether serviceName should be considered actually deployed

#### Deployed

By convention, the environments defined by specific names refer to which server you should be communicating with,
not which environment this process is actually in.  The special `deployed` env can be used to get the actual
environment the process is running in.

Enviro also provides the `deployed` function which will return true if the service is deployed.

#### Manipulating Things

You can override what apis your software talks to, and whether it thinks it's deployed.

- The env var / localstorage key `API_ENV` will, for example, change what is returned by `Env.get('api')`
- The env var / localstorage key `GAMERA_DEPLOYED` will, for example, change what is returned by `Env.deployed('gamera')`
- A request for `Env.get('api.gamera')` will first look to `GAMERA_ENV`, then `API_ENV`
