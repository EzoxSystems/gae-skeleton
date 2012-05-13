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
    Compile coffeescript, uglify the resultant js into appname.js.
    Compile your JST templates into template.js.
    Compile and minify your less into appname.css.
    Combine third party js into one libs.js package.
"""

import logging

import os
from os import path

from webassets import Bundle
from webassets import Environment
from webassets.script import CommandLineEnvironment


BASE_LOCATION = os.getcwdu()
INPUT_FILES = path.join(BASE_LOCATION, 'assets')



def _bundle_images(app, env):
    """Push images into static."""
    #TODO: add png crush or something similar
    import shutil

    root_src_dir = path.join(INPUT_FILES, 'img')
    root_dst_dir = path.join(BASE_LOCATION, app, 'static', 'img')

    for src_dir, dirs, files in os.walk(root_src_dir):
        dst_dir = src_dir.replace(root_src_dir, root_dst_dir)
        if not os.path.exists(dst_dir):
            os.mkdir(dst_dir)
        for file_ in files:
            src_file = os.path.join(src_dir, file_)
            dst_file = os.path.join(dst_dir, file_)
            if os.path.exists(dst_file):
                os.remove(dst_file)
            shutil.move(src_file, dst_dir)


def _bundle_app_coffee(app, env, debug=False):
    """Compile the apps coffeescript and bundle it into appname.js"""
    COFFEE_PATH = 'coffee'
    APP_PATH = path.join(COFFEE_PATH, 'appname')
    scripts = (
        path.join(COFFEE_PATH, 'nested.coffee'),
        path.join(COFFEE_PATH, 'app.coffee'),
        path.join(APP_PATH, 'app.coffee'),
        path.join(APP_PATH, 'menu.coffee'),
        path.join(APP_PATH, 'contact.coffee'),
        path.join(APP_PATH, 'person.coffee'),
        path.join(APP_PATH, 'router.coffee'),
    )
    all_js = Bundle(
        *scripts,
        filters='coffeescript',
        output=path.join('..', '..', app, 'static', 'script', 'appname.js')
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
        all_js = Bundle(
            path.join(JSPATH, 'json2.js'),
            path.join(JSPATH, 'jquery.js'),
            path.join(JSPATH, 'underscore.js'),
            path.join(JSPATH, 'backbone.js'),
            path.join(JSPATH, 'bootstrap.js'),
            path.join(JSPATH, 'bootstrap-typeahead-improved.js'),
            output=path.join('..', '..', app, 'static', 'script', 'libs.js')
        )
    else:
        JSPATH = path.join(JSPATH, 'min')
        all_js = Bundle(
            path.join(JSPATH, 'json2.min.js'),
            path.join(JSPATH, 'jquery-min.js'),
            path.join(JSPATH, 'underscore-min.js'),
            path.join(JSPATH, 'backbone-min.js'),
            path.join(JSPATH, 'bootstrap-min.js'),
            path.join(JSPATH, 'bootstrap-typeahead-improved-min.js'),
            output=path.join('..', '..', app, 'static', 'script', 'libs.js')
        )

    env.add(all_js)
    if debug:
        all_js.build()


def _bundle_3rd_party_css(app, env, debug=False):
    """Bundle any thrid party CSS files."""
    if debug:
        bundle = Bundle(
                path.join('css', 'bootstrap.css'),
                output=path.join('..', '..', app, 'static', 'css', 'lib.css')
            )
    else:
        bundle = Bundle(
                path.join('css', 'min', 'bootstrap.min.css'),
                output=path.join('..', '..', app, 'static', 'css', 'lib.css')
            )

    env.add(bundle)


def _bundle_app_less(app, env, debug):
    """Compile and minify appname's less files into appname.css."""
    bundle = Bundle(
        Bundle(path.join('less', 'appname.less'), filters='less'),
        output=path.join('..', '..', app, 'static', 'css', 'appname.css')
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


def build(location, debug=True, cache=True):
    env = _setup_env(debug, cache)
    log = _load_logger()
    cmdenv = CommandLineEnvironment(env, log)

    cmdenv.rebuild()

def watch(location, debug=False, cache=False):
    env = _setup_env(location, debug, cache)
    log = _load_logger()
    cmdenv = CommandLineEnvironment(env, log)

    cmdenv.watch()

