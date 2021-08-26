stickbot_desp = [
    dependency ('requests', method: 'dub'),
    dependency ('cachetools', method: 'dub'),
    dependency ('tg_d', method: 'dub', version: '>=0.0.4'),
    dependency ('di', method: 'dub'),
    libtms_dep
]

stickbot_source = [
    'app.d',
    'kimp/tms.d',
    'kimp/stickbot.d',
    'kimp/log.d',
    'kimp/exit.d',
    'kimp/storage.d'
]

stickbot = executable ('stickbot',
    stickbot_source,
    dependencies: stickbot_desp,
    install: true
)
