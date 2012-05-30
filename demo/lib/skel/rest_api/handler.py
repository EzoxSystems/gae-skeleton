import json
import logging

import webapp2


class JsonHandler(webapp2.RequestHandler):

    def __init__(self, request=None, response=None):
        super(JsonHandler, self).__init__(request, response)

        self.json_response = {}

    def write_json_response(self, json_response):
        self.response.headers['Content-type'] = 'application/json'

        if json_response:
            if not self.json_response:
                self.json_response = json_response
            else:
                self.json_response.update(json_response)

        logging.info("$$$$$$$$$RESPONSE$$$$$$$$$$$")
        logging.info(self.json_response)
        self.response.write(json.dumps(self.json_response))


class RestApiHandler(JsonHandler):

    def __init__(self, entity, schema, request=None, response=None):
        super(RestApiHandler, self).__init__(request, response)

        self.entity = entity
        self.schema = schema

    def get(self, resource_id):
        from google.appengine.ext import ndb

        key = ndb.Key(urlsafe=resource_id)
        resource = key.get()

        if not resource:
            self.error(404)
            response = {}
        else:
            response = resource.to_dict()

        self.write_json_response(response)

    def delete(self, args):
        from google.appengine.ext import ndb

        urlsafe = self.request.path.rsplit('/', 1)[-1]
        if not urlsafe:
            return

        ndb.Key(urlsafe=urlsafe).delete()
        logging.info("Deleted %s with key: %s", self.entity, urlsafe)

    def post(self, args):
        self.process(args)

    def put(self, args):
        self.process(args)

    def process(self, args):
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


class RestApiListHandler(JsonHandler):

    def __init__(self, entity, schema, request=None, response=None):
        super(RestApiListHandler, self).__init__(request, response)

        self.entity = entity
        self.schema = schema

    def get(self, args):
        query = RestQuery()
        resources = query.fetch(self.entity, self.request.params)

        response = [entity.to_dict() for entity in resources]

        self.write_json_response(response)


class RestQuery(object):

    def fetch(self, entity, params):
        self.query_filters = RestQueryFilters()

        limit = int(params.get('limit', 100))

        query = entity.query()
        query = self._parse(entity, query, params)

        return query.fetch(limit)

    def _parse(self, entity, query, params):
        filters = ["f%s" % (f) for f in self.query_filters.filters.iterkeys()]

        logging.info("**********PARSING QUERY***********")
        logging.info(params)
        for prop, value in params.iteritems():
            logging.info(prop)
            psplit = prop.split('_')
            if len(psplit) < 2:
                continue

            f = psplit[0].lower()
            if f not in filters:
                continue

            prop = getattr(entity, '_'.join(psplit[1:]))

            logging.info("Adding query")
            query = self.query_filters.get(
                query, f, prop, value)

        return query


class RestQueryFilters(object):

    def __init__(self):
        self.filters = {
            'eq': self._add_equality_filter,
            'like': self._add_like_filter,
        }

    def get(self, query, query_filter, prop, val):
        logging.info("$$$$$$$$$$QUERY FILTER$$$$$$$$$$$$$")
        logging.info(query_filter)
        f = self.filters.get(query_filter[1:])
        if not f:
            return query

        return f(query, prop, val)

    def _add_equality_filter(self, query, filter_property, val):
        return query.filter(filter_property == val)

    def _add_like_filter(self, query, filter_property, val):
        query = query.filter(filter_property >= val)
        return query.filter(filter_property < val + u"\uFFFD")

