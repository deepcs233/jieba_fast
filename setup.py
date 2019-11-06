# -*- coding: utf-8 -*-
from distutils.core import setup, Extension
import platform

LONGDOC = 'Use C and Swig to Speed up jieba<Chinese Words Segementation Utilities>'

jieba_fast_functions_py2 = Extension('_jieba_fast_functions_py2',
                         sources=['jieba_fast/source/jieba_fast_functions_wrap_py2_wrap.c'],
                           )

jieba_fast_functions_py3 = Extension('_jieba_fast_functions_py3',
                         sources=['jieba_fast/source/jieba_fast_functions_wrap_py3_wrap.c'],
                           )

if platform.python_version().startswith('2'):
    setup(name='jieba_fast',
          version='0.53',
          description='Use C and Swig to Speed up jieba<Chinese Words Segementation Utilities>',
          long_description=LONGDOC,
          author='Sun, Junyi, deepcs233',
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
            'Programming Language :: Python :: 3.4',
            'Programming Language :: Python :: 3.5',
            'Programming Language :: Python :: 3.7',
            'Topic :: Text Processing',
            'Topic :: Text Processing :: Indexing',
            'Topic :: Text Processing :: Linguistic',
        ],
        keywords='NLP,tokenizing,Chinese word segementation',
        packages=['jieba_fast'],
        package_dir={'jieba_fast':'jieba_fast'},
          package_data={'jieba_fast':['*.*','finalseg/*','analyse/*','posseg/*','source/*']},
        ext_modules = [jieba_fast_functions_py2],
    )


if platform.python_version().startswith('3'):
    setup(name='jieba_fast',
          version='0.52',
        description='Use C and Swig to Speed up jieba<Chinese Words Segementation Utilities>',
        long_description=LONGDOC,
        author='Sun, Junyi, deepcs233',
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
            'Programming Language :: Python :: 3.4',
            'Programming Language :: Python :: 3.5',
            'Programming Language :: Python :: 3.7',
            'Topic :: Text Processing',
            'Topic :: Text Processing :: Indexing',
            'Topic :: Text Processing :: Linguistic',
        ],
        keywords='NLP,tokenizing,Chinese word segementation',
        packages=['jieba_fast'],
        package_dir={'jieba_fast':'jieba_fast'},
          package_data={'jieba_fast':['*.*','finalseg/*','analyse/*','posseg/*','source/*']},
        ext_modules = [jieba_fast_functions_py3],
    )
