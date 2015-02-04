window.Store = do ->
  localStorageSupported = do ->
    try
      `(('localStorage' in window) && window['localStorage'] !== null)`
    catch e
      false

  if localStorageSupported
    # will displace data until it can successfully save
    safeSet = (key, value) ->
      try
        localStorage.setItem key, value
        value
      catch e
        for num in [0..5]
          localStorage.removeItem localStorage.key localStorage.length - 1
        safeSet key, value
    {
      set: safeSet

      get: (key) ->
        localStorage[key]

      expire: (key) ->
        value = localStorage[key]
        localStorage.removeItem(key)
        value
    }
  else
    createCookie = (name, value, days) ->
      if days
        date = new Date
        date.setTime(date.getTime() + (days*24*60*60*1000))
        expires = "; expires=" + date.toGMTString()
      else
        expires = ""

      document.cookie = name + "=" + value + expires + "; path=/"

      value

    getCookie = (key) ->
      key = key + "="
      for cookieFragment in document.cookie.split(';')
        return cookieFragment.replace(/^\s+/, '').substring(key.length + 1, cookieFragment.length) if cookieFragment.indexOf(key) == 0
      return null

    {
      set: (key, value) ->
        createCookie key, value, 1

      get: getCookie

      expire: (key) ->
        value = Store.get key
        createCookie key, "", -1
        value
    }
