import json
import logging

import webapp2

from skel.datastore import EntityBase
from .rules import RestQueryRule


class JsonHandler(webapp2.RequestHandler):

    def __init__(self, request=None, response=None):
        super(JsonHandler, self).__init__(request, response)

        self.json_response = {}

    def write_json_response(self, json_response):
        self.response.headers['Content-type'] = 'application/json'

        if not self.json_response:
            self.json_response = json_response
        else:
            self.json_response.update(json_response)

        self.response.write(json.dumps(self.json_response))


class RestApiSaveHandler(JsonHandler):

    def post(self, resource_id, *args, **kwargs):
        self.process(resource_id, *args, **kwargs)

    def put(self, resource_id, *args, **kwargs):
        self.process(resource_id, *args, **kwargs)

    def process(self, resource_id, *args, **kwargs):
        from voluptuous import Schema

        obj = json.loads(self.request.body)
        schema = Schema(self.schema, extra=True)

        try:
            obj = schema(obj)
        except:
            logging.exception('validation failed')
            logging.info(obj)

        entity = self.entity.from_dict(obj)
        entity.put()

        self.write_json_response(entity.to_dict())

    def delete(self, resource_id, *args, **kwargs):
        from google.appengine.ext import ndb

        if not resource_id:
            return

        key = ndb.Key(urlsafe=resource_id)
        if self.entity._get_kind() != key.kind():
            return

        key.delete()

        logging.info("Deleted %s with key: %s", self.entity, resource_id)


class RestApiHandler(RestApiSaveHandler):

    def __init__(self, entity, schema, request=None, response=None):
        super(RestApiHandler, self).__init__(request, response)

        self.entity = entity
        self.schema = schema

    def get(self, resource_id, *args, **kwargs):
        from google.appengine.ext import ndb

        key = ndb.Key(urlsafe=resource_id)
        resource = key.get()

        if not resource:
            self.error(404)
            response = {}
        else:
            response = resource.to_dict()

        self.write_json_response(response)


class RestApiListHandler(RestApiSaveHandler):

    def __init__(self, entity, schema, request=None, response=None,
                 default_filters=None, query_schema=None):
        super(RestApiListHandler, self).__init__(request, response)

        self.entity = entity
        self.schema = schema
        self.query_schema = query_schema
        self.query = RestQuery(default_filters=default_filters)

    def get(self, *args, **kwargs):
        resources = self.query.fetch(
            self.entity, self.request.params, self.query_schema)

        response = [entity.to_dict() for entity in resources]

        self.write_json_response(response)


class RestQuery(object):

    def __init__(self, default_filters=None, **kwargs):
        self.default_filters = default_filters if default_filters else []

    def fetch(self, entity, params, query_schema=None):
        if query_schema:
            from voluptuous import Schema
            #convert params for validation
            #TODO: need to handle complex values. this is a quick fix to get it in
            query_params = {}
            query_params.update(params)

            schema = Schema(query_schema, extra=True)
            params = schema(query_params)

        self.query_filters = RestQueryFilters()
        limit = int(params.get('limit', 100))

        query = entity.query()

        for default_filters in self.default_filters:
            query = query.filter(default_filters)

        query = self._parse(entity, query, params)

        return query.fetch(limit)

    def _parse(self, entity, query, params):
        filters = ["f%s" % (f) for f in self.query_filters.filters.iterkeys()]

        for prop, value in params.iteritems():

            psplit = prop.split('_')
            if len(psplit) < 2:
                continue

            f = psplit[0].lower()
            if f not in filters:
                continue

            prop_string = '_'.join(psplit[1:])

            if hasattr(entity, '_query_properties'):
                query_rule = entity.get_query_property(prop_string)

                if query_rule and isinstance(query_rule, RestQueryRule):
                    prop_string = query_rule.prop
                    if query_rule.empty_as_none and not value:
                        value = None

                    value = query_rule.parse_value(value)

            entity_prop = getattr(entity, prop_string)

            if isinstance(value, basestring):
                value = value.strip()

            query = self.query_filters.get(
                query, f, entity_prop, value)

        return query


class RestQueryFilters(object):

    def __init__(self):
        self.filters = {
            'eq': self._add_equality_filter,
            'neq': self._add_inequality_filter,
            'like': self._add_like_filter,
            'gt': self._add_greater_than_filter,
        }

    def get(self, query, query_filter, prop, val):
        f = self.filters.get(query_filter[1:])
        if not f:
            return query

        return f(query, prop, val)

    def _add_equality_filter(self, query, filter_property, val):
        return query.filter(filter_property == val)

    def _add_inequality_filter(self, query, filter_property, val):
        return query.filter(filter_property != val)

    def _add_like_filter(self, query, filter_property, val):
        query = query.filter(filter_property >= val)
        return query.filter(filter_property < val + u"\uFFFD")

    def _add_greater_than_filter(self, query, filter_property, val):
        return query.filter(filter_property >= val)
