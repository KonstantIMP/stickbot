stickbot_desp = [
    dependency ('requests', method: 'dub'),
    dependency ('cachetools', method: 'dub'),
    dependency ('tg_d', method: 'dub'),
    libtms_dep
]

stickbot_source = [
    'app.d'
]

stickbot = executable ('stickbot',
    stickbot_source,
    dependencies: stickbot_desp,
    install: true
)
