#!/usr/bin/env python
#
# Copyright 2012 Ezox Systems LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

"""Defines how the assets are combined, compiled, and moved into the static
directory structures.

You currently must add you coffeescripts to the list in _bundle_app_coffee.
This is to ensure files are included in the correct order in the compiled
javascript.

Some common things to do here:
    Compile coffeescript, uglify the resultant js into demo.js.
    Compile your JST templates into template.js.
    Compile and minify your less into demo.css.
    Combine third party js into one libs.js package.
"""

import logging

from os import path

from webassets import Bundle
from webassets import Environment
from webassets.script import CommandLineEnvironment

from . import BASE_LOCATION
from . import INPUT_FILES
from . import _bundle_images


def _bundle_app_coffee(app, env, debug=False):
    """Compile the apps coffeescript and bundle it into demo.js"""
    COFFEE_PATH = 'coffee'
    scripts = (
        path.join(COFFEE_PATH, 'app.coffee'),
        path.join(COFFEE_PATH, 'menu.coffee'),
        path.join(COFFEE_PATH, 'router.coffee'),
    )

    if not scripts:
        return

    all_js = Bundle(
        *scripts,
        filters='coffeescript',
        output=path.join('..', '..', app, 'static', 'script', '%s.js' % (app,))
    )
    env.add(all_js)

    if not debug:
        all_js.filters = 'closure_js'


def _bundle_app_jsts(app, env, debug=False):
    """Compile and bundle JSTs into template.js"""
    all_js = Bundle(
        path.join('jst', '*.jst'),
        path.join('jst', '*', '*.jst'),
        filters='jst',
        output=path.join('..', '..', app, 'static', 'script', 'template.js')
    )
    env.add(all_js)

    if not debug:
        all_js.filters = 'closure_js'


def _bundle_3rd_party_js(app, env, debug=False):
    """Combine thrid party js libs into libs.js.

    For debug, they are left uncompressed.  For production the minified
    versions are used.  We suggest using hte vendor supplied minified version
    of each library.
    """
    JSPATH = path.join('js', 'lib')

    if debug:
        scripts = ()
        if not scripts:
            return

        all_js = Bundle(
            *scripts,
            output=path.join('..', '..', app, 'static', 'script', 'libs.js')
        )
    else:
        JSPATH = path.join(JSPATH, 'min')

        scripts = ()
        if not scripts:
            return

        all_js = Bundle(
            *scripts,
            output=path.join('..', '..', app, 'static', 'script', 'libs.js')
        )

    env.add(all_js)
    if debug:
        all_js.build()


def _bundle_3rd_party_css(app, env, debug=False):
    """Bundle any thrid party CSS files."""
    if debug:
        items = ()
        if not items:
            return

        bundle = Bundle(
                *items,
                output=path.join('..', '..', app, 'static', 'css', 'lib.css')
            )
    else:
        items = ()
        if not items:
            return

        bundle = Bundle(
                *items,
                output=path.join('..', '..', app, 'static', 'css', 'lib.css')
            )

    env.add(bundle)


def _bundle_app_less(app, env, debug):
    """Compile and minify demo's less files into demo.css."""
    bundle = Bundle(
        Bundle(path.join('less', '%s.less' % (app,)), filters='less'),
        output=path.join('..', '..', app, 'static', 'css', '%s.css' % (app,))
    )

    if not debug:
        bundle.filters = 'cssmin'

    env.add(bundle)


def _setup_env(app, debug=True, cache=True):
    """Setup the webassets environment."""
    env = Environment(INPUT_FILES, path.join(BASE_LOCATION, app))
    # We use underscore's templates by default.
    env.config['JST_COMPILER'] = '_.template'
    if debug:
        env.config['CLOSURE_COMPRESSOR_OPTIMIZATION'] = 'WHITESPACE_ONLY'
        env.manifest = False
    else:
        env.config['CLOSURE_COMPRESSOR_OPTIMIZATION'] = 'ADVANCED_OPTIMIZATIONS'

    env.debug = False
    env.cache = cache

    #javascript
    _bundle_app_jsts(app, env, debug)
    _bundle_app_coffee(app, env, debug)
    _bundle_3rd_party_js(app, env, debug)

    #css
    _bundle_app_less(app, env, debug)
    _bundle_3rd_party_css(app, env, debug)

    #images
    _bundle_images(app, env)

    return env


def _load_logger():
    # Setup a logger
     log = logging.getLogger('webassets')
     log.addHandler(logging.StreamHandler())
     log.setLevel(logging.DEBUG)
     return log


def build(app='', debug=True, cache=True):
    env = _setup_env(app, debug, cache)
    log = _load_logger()
    cmdenv = CommandLineEnvironment(env, log)

    cmdenv.rebuild()

def watch(app='', debug=False, cache=False):
    env = _setup_env(app, debug, cache)
    log = _load_logger()
    cmdenv = CommandLineEnvironment(env, log)

    cmdenv.watch()

