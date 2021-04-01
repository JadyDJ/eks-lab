from setuptools import setup

try:
    unicode
    def u8(s):
        return s.decode('unicode-escape').encode('utf-8')
except NameError:
    def u8(s):
        return s.encode('utf-8')

setup(name='headers.dist',
      version='0.1',
      description=u8('A distribution with headers'),
      headers=['header.h']
      )
