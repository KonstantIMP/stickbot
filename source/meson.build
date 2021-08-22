stickbot_desp = [
    dependency ('requests', method: 'dub'),
    dependency ('cachetools', method: 'dub'),
    dependency ('tg_d', method: 'dub'),
    dependency ('di', method: 'dub'),
    libtms_dep
]

stickbot_source = [
    'app.d',
    'kimp/tms.d',
    'kimp/loop.d',
    'kimp/answer.d',
    'kimp/storage.d'
]

stickbot = executable ('stickbot',
    stickbot_source,
    dependencies: stickbot_desp,
    install: true
)
