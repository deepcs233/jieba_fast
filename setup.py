# -*- coding: utf-8 -*-
from distutils.core import setup,Extension

jieba_fast_functions = Extension('_jieba_fast_functions',
                         sources=['jieba_fast_functions_wrap.c'],
                           )
setup(name='jieba_fast',
      version='0.39',
      description='Use C and Swig to Speed up jieba<Chinese Words Segementation Utilities>',
      long_description=LONGDOC,
      author='Sun, Junyi, deepcs',
      author_email='shaohao97@gmail.com',
      url='https://github.com/deepcs233/jieba_fast',
      license="MIT",
      classifiers=[
        'Intended Audience :: Developers',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
        'Natural Language :: Chinese (Simplified)',
        'Natural Language :: Chinese (Traditional)',
        'Programming Language :: Python',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.6',
        'Programming Language :: Python :: 2.7',
        'Topic :: Text Processing',
        'Topic :: Text Processing :: Indexing',
        'Topic :: Text Processing :: Linguistic',
      ],
      keywords='NLP,tokenizing,Chinese word segementation',
      packages=['jieba_fast'],
      package_dir={'jieba_fast':'jieba_fast'},
      package_data={'jieba_fast':['*.*','finalseg/*','analyse/*','posseg/*']},
      ext_modules = [jieba_fast_functions],
)
