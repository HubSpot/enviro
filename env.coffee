if module? and not window?.module?
  # We're on the server

  defaultKey = 'NODE_ENV'
  envOverride = {}

  getEnv = (key) ->
    envOverride[key] ? process.env[key]

  getDefaultEnv = ->
    getEnv defaultKey

  setEnv = (key, env) ->
    envOverride[key] = env

else
  # We're on the client

  defaultKey = 'ENV'

  getEnv = (key) ->
    window[key] ? window.localStorage?[key]

  getDefaultEnv = ->
    if env = getEnv(defaultKey)
      env
    else
      'prod'

  setEnv = (key, env) ->
    window[key] = env

MAP =
  'prod': 'production'
  'qa': 'development'

normalize = (env) ->
  MAP[env?.toLowerCase?()] ? env?.toLowerCase?() ? env

denormalize = (env) ->
  env = env?.toLowerCase?()

  for ours, theirs of MAP
    if env is theirs
      return ours

  return env

# Get the environment the code is running in.
#
# It should be called with the name of the calling service,
# so we can override the env of specific services when
# necessary.
#
# The environment corresponds to what servers should be hit, so
# the env of local means that you want to hit a local instance of
# that server.  This is not a common occurance, so attempts are made
# to rewrite local into qa whereever it is not explicitly requested.
#
# Reads the NODE_ENV env var as the default, {SERVICE_NAME}_ENV
# for sepecific services on the server.  On the client, it looks
# to the ENV or {SERVICE_NAME}_ENV properties in localStorage.
#
# Paths can be dot deliminated to search in multiple locations, for
# example: 'api.gamera' would look for GAMERA_ENV, then API_ENV then
# just ENV (or NODE_ENV on the server), then default to 'qa'.
#
# STATIC and API are two services which you might want to
# override to control which static and APIs you
# are talking to.
#
# To maintain compatibility with other node libs, you should
# use 'production' rather than 'prod'.
get = (service, def) ->
  env = null

  if service
    for pathPart in service.split('.').reverse()
      service = "#{ pathPart.toUpperCase() }_ENV"

      break if env = getEnv(service)

  env ?= def ? getDefaultEnv() ? 'qa'

  normalize(env)

set = (key, env) ->
  if arguments.length is 1
    env = key
    key = defaultKey

  setEnv(key, env)

getInternal = (service, def) ->
  denormalize(get(service, def))

getShort = getInternal

deployed = (service, def) ->
  getEnv("#{ service.toUpperCase() }_DEPLOYED") ? getEnv('DEPLOYED')

debug = (service, def) ->
  getEnv("#{ service.toUpperCase() }_DEBUG") ? getEnv('DEBUG') ? false

exports = {normalize, denormalize, get, getInternal, getShort, deployed, debug, set}

if not module? or window?.module?
  window.Enviro = exports
else
  module.exports = exports
