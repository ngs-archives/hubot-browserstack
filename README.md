hubot-browserstack
==================

A [Hubot] script to take screenshots with [BrowserStack].

```
me > hubot screenshot me http://www.google.com/
hubot > Started generating screenshots in http://www.browserstack.com/screenshots/d804f186e460dc4f2a30849a9686c3a8c4276c21
```

Installation
------------

1. Add `hubot-browserstack` to dependencies.

  ```bash
  npm install --save hubot-browserstack
  ```

2. Update `external-scripts.json`

  ```json
  ["hubot-browserstack"]
  ```

Setup
-----

Grab your BrowserStack _Username_ and _Access Key_ from _Your Account_ > _[Automate]_.

```bash
HUBOT_BROWSER_STACK_USERNAME=$(Your BrowserStack Username)
HUBOT_BROWSER_STACK_ACCESS_KEY=$(Your BrowserStack Access Key)
```

Default browsers are listed in [browsers.json] of this module.

If you prefer other browsers, you can specify JSON path with `HUBOT_BROWSER_STACK_DEFAULT_BROWSERS`.

```bash
HUBOT_BROWSER_STACK_DEFAULT_BROWSERS=$HOME/data/mybrowers.json
```

Make sure relative path will be resolved from process's working directory.


Author
------

[Atsushi Nagase]

License
-------

[MIT License]

[Automate]: https://www.browserstack.com/accounts/automate
[Hubot]: https://hubot.github.com/
[BrowserStack]: https://www.browserstack.com/
[browsers.json]: src/data/browsers.json
[Atsushi Nagase]: http://ngs.io/
[MIT License]: LICENSE
