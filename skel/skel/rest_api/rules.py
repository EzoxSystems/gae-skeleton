

class RestQueryRule(object):

    def __init__(self, prop, func=None, empty_as_none=True):
        self.prop = prop
        self.empty_as_none = empty_as_none
        self.func = func

    def parse_value(self, value):
        if not self.func:
            return value

        return self.func(value)