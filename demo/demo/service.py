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

"""Service endpoint mapping.

If this file gets large (say over 500 hundred lines), we suggest breaking
it up into a package.
"""
import logging

from skel.rest_api import handler as rest_handler


class PersonHandler(rest_handler.RestApiHandler):

    def __init__(self, request=None, response=None):
        from demo.person import Person
        from demo.person import person_schema

        super(PersonHandler, self).__init__(
            Person, person_schema, request, response)


class PersonListHandler(rest_handler.RestApiListHandler):

    def __init__(self, request=None, response=None):
        from demo.person import Person
        from demo.person import person_schema
        from demo.person import person_query_schema

        super(PersonListHandler, self).__init__(
            Person, person_schema, request, response,
            query_schema=person_query_schema)
