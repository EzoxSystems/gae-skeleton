#!/usr/bin/env python

 #Copyright 2012 Ezox Systems LLC

# Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
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

from google.appengine.ext import ndb


class EntityBase(ndb.Model):

    _query_properties = {}

    # The entity's change revision counter.
    revision = ndb.IntegerProperty('r_', default=0)

    # Useful timestamps.
    added = ndb.DateTimeProperty('a_', auto_now_add=True)
    modified = ndb.DateTimeProperty('m_', auto_now=True)

    def _pre_put_hook(self):
        """Ran before the entity is written to the datastore.
        It is possible to "skip" revisions due to contention.
        """
        self.revision += 1

    def _default_dict(self):
        return {
            'key': self.key.urlsafe(),
            'revision': self.revision,
            'added': self.added.strftime('%Y-%m-%d %H:%M'), # TODO: Standardize
            'modified': self.modified.strftime('%Y-%m-%d %H:%M'), # TODO: Standardize
        }

    @classmethod
    def get_query_property(cls, prop):
        """Return the property to use in a query"""
        return cls._query_properties.get(prop)
