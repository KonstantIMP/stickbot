libtms_version = '0.1.0'

libtms_deps = [
    dependency('Magick++')
]

libtms_source = [
    'tms.cpp',
    'split.cpp'
]

libtms_headers = [
    'tms.hpp',
    'split.hpp'
]

libtms_lib = shared_library ('libtms-' + libtms_version,
    libtms_source,
    dependencies: libtms_deps,
    install: true
)

install_headers(libtms_headers, subdir: 'tms')

pkg = import('pkgconfig')

pkg.generate(
  description: 'A shared library for sticker creating',
    libraries: libtms_lib,
         name: 'libtms',
     filebase: 'libtms-' + libtms_version,
      version: libtms_version,
      subdirs: 'libtms',
     requires: 'Magick++',
  install_dir: join_paths(get_option('libdir'), 'pkgconfig')
)

libtms_dep = declare_dependency(
  link_with: libtms_lib,
  include_directories: './',
  dependencies: libtms_deps,
  sources: libtms_source
)

