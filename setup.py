from setuptools import setup

setup(
    name='commands',
    version='0.1',
    py_modules=['commands'],
    install_requires=[
        'Click',
        'pyyaml',
        'voluptuous'
    ],
    entry_points='''
        [console_scripts]
        deploy=commands:deploy
        parse=commands:parse
        apply=commands:apply
        build=commands:build
        logs=commands:logs
        push=commands:push
    ''',
)
