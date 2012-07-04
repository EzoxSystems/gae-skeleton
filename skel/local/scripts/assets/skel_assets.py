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


def _bundle_skel(app_path, env, debug=False):
    """Combine thrid party js libs into libs.js.

    For debug, they are left uncompressed.  For production the minified
    versions are used.  We suggest using the vendor supplied minified version
    of each library.
    """

    JS_LIB_PATH = path.join('js', 'lib')
    third_js = Bundle(
        path.join(JS_LIB_PATH, 'json2.js'),
        path.join(JS_LIB_PATH, 'jquery.js'),
        path.join(JS_LIB_PATH, 'underscore.js'),
        path.join(JS_LIB_PATH, 'backbone.js'),
        path.join(JS_LIB_PATH, 'backbone.paginator.js'),
        path.join(JS_LIB_PATH, 'bootstrap.js'),
        path.join(JS_LIB_PATH, 'bootstrap-typeahead-improved.js'),
        path.join(JS_LIB_PATH, 'date.js'),
    )

    #TOOD: add require so we can simplify this
    COFFEE_PATH = 'coffee'
    coffee_js = Bundle(
        path.join(COFFEE_PATH, 'nested.coffee'),
        path.join(COFFEE_PATH, 'app.coffee'),
        path.join(COFFEE_PATH, 'datagrid.coffee'),
        path.join(COFFEE_PATH, 'skel.coffee'),
        path.join(COFFEE_PATH, 'channel.coffee'),
        path.join(COFFEE_PATH, 'utils.coffee'),
        path.join(COFFEE_PATH, 'smartbox.coffee'),
        filters='coffeescript'
    )

    all_js = Bundle(
        third_js,
        Bundle(
            path.join('templates', '**', '*.jst'), filters='jst', debug=False),
        coffee_js,
        output=path.join(app_path, 'script', 'skel.js'))

    env.add(all_js)

    if not debug:
        all_js.filters = 'closure_js'


def _bundle_3rd_party_css(app_path, env, debug=False):
    """Bundle any thrid party CSS files."""
    if debug:
        bundle = Bundle(
                path.join('css', 'bootstrap.css'),
                output=path.join(app_path, 'css', 'lib.css')
            )
    else:
        bundle = Bundle(
                path.join('css', 'min', 'bootstrap.min.css'),
                output=path.join(app_path, 'css', 'lib.css')
            )

    env.add(bundle)


def _setup_env(app='', debug=True, cache=True):
    """Setup the webassets environment."""
    if app:
        app_path = path.join('..', '..', app, 'static')
        env = Environment(
            path.join(INPUT_FILES, '..', '..', 'skel', 'assets'),
            path.join(BASE_LOCATION, '..'))
    else:
        app_path = path.join('..', 'static')
        env = Environment(
            path.join(INPUT_FILES, '..', '..', 'skel', 'assets'),
            path.join(BASE_LOCATION))

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
    _bundle_skel(app_path, env, debug)

    #css
    _bundle_3rd_party_css(app_path, env, debug)

    #images
    _bundle_images(app, env, is_skel=True)

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

    cmdenv.build()

def watch(app='', debug=False, cache=False):
    env = _setup_env(app, debug, cache)
    log = _load_logger()
    cmdenv = CommandLineEnvironment(env, log)

    cmdenv.watch()
