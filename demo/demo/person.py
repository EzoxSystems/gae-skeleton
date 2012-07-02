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

"""Person model definition and business logic."""

from google.appengine.ext import ndb

from skel.datastore import EntityBase
from skel.rest_api.rules import RestQueryRule

person_schema = {
    'key': basestring,
    'name': basestring,
    'notes': basestring,
    'contact_info': [{'type': basestring, 'value': basestring}],
}

person_query_schema = {
    'flike_name': basestring
}


class Person(EntityBase):
    """Represents a person."""

    _query_properties = {
        'name': RestQueryRule('name_', lambda x: x.lower(), False)
    }

    # Store the schema version, to aid in migrations.
    version_ = ndb.IntegerProperty('v_', default=1)

    # Person code, name, key
    name = ndb.StringProperty('n', indexed=False)
    name_ = ndb.ComputedProperty(lambda self: self.name.lower(), name='n_')

    # Phone / email / whatever.
    contact_info = ndb.JsonProperty('ci')

    # General remarks.
    notes = ndb.TextProperty('no')

    @classmethod
    def from_dict(cls, data):
        """Instantiate a Person entity from a dict of values."""
        key = data.get('key')
        person = None
        if key:
            key = ndb.Key(urlsafe=key)
            person = key.get()

        if not person:
            person = cls()

        person.name = data.get('name')
        person.contact_info = data.get('contact_info')
        person.notes = data.get('notes')

        return person

    def to_dict(self):
        """Return a Person entity represented as a dict of values
        suitable for rebuilding via Person.from_dict.
        """
        person = {
            'version': self.version_,
            # name
            'name': self.name,

            # Contact info
            'contact_info': self.contact_info,

            # Notes
            'notes': self.notes,
        }

        person.update(self._default_dict())
        return person
