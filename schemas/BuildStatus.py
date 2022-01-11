import re

STATUS = [
    'SUCCESS',
    'FAILURE',
    'SKIPPED'
]
STATUS_PATTERN = rf'^({"|".join(STATUS)})$'


class BuildStatus(str):

    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v):
        if not isinstance(v, str):
            raise TypeError('string required')

        pattern = re.compile(STATUS_PATTERN)
        m = pattern.fullmatch(v.upper())
        if not m:
            raise ValueError('invalid status')

        return cls(f'{m.group(0)}')
