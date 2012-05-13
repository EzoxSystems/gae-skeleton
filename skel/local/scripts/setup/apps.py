import os
import shutil
import subprocess


BASE_LOCATION = os.getcwdu()

DIRECTORIES_TO_IGNORE = (
    os.path.join(BASE_LOCATION, 'skel', 'assets'),
    os.path.join(BASE_LOCATION, 'skel', 'template'),
    os.path.join(BASE_LOCATION, 'skel', 'tests'))

TEMPLATE_DIRECTORY = os.path.join(BASE_LOCATION, 'skel', 'template')


def create_app(app_name, path=''):
    if path:
        app_location = os.path.join(BASE_LOCATION, app_name)
    else:
        app_location = os.path.join(BASE_LOCATION, app_name)

    if not os.path.exists(app_location):
        os.makedirs(app_location)

    copy_files(app_name, TEMPLATE_DIRECTORY, app_location)

    lib_location = os.path.join(app_location, 'lib')
    if not os.path.exists(lib_location):
        os.makedirs(lib_location)

    copy_files(
        app_name, os.path.join(
            BASE_LOCATION, 'skel'), lib_location, DIRECTORIES_TO_IGNORE)

    rename(app_name, app_location)


def copy_files(app_name, root_src_dir, root_dst_dir, dirs_to_ignore=None,
               files_to_ignore=None):

    if not dirs_to_ignore:
        dirs_to_ignore = []

    if not files_to_ignore:
        files_to_ignore = []

    def in_directory(src_dir):
        for d in dirs_to_ignore:
            if d in src_dir:
                return True

        return False

    for src_dir, dirs, files in os.walk(root_src_dir):

        if src_dir in dirs_to_ignore or in_directory(src_dir):
            continue

        dst_dir = src_dir.replace(root_src_dir, root_dst_dir)

        if not os.path.exists(dst_dir):
            os.mkdir(dst_dir)

        for file_ in files:
            if file_ in files_to_ignore:
                continue

            src_file = os.path.join(src_dir, file_)
            dst_file = os.path.join(dst_dir, file_)

            if os.path.exists(dst_file):
                os.remove(dst_file)

            shutil.copy2(src_file, dst_dir)

            out_file = open(os.path.join(dst_dir, '.rename.tmp'), "w")
            subprocess.call(
                ['sed', '-e', 's/Appname/%s/g' % (app_name,), '-e',
                 's/appname/%s/g' % (app_name.lower(),), dst_file],
                stdout=out_file)
            subprocess.call(
                ['mv', os.path.join(dst_dir, '.rename.tmp'), dst_file])


def rename(app_name, destination_directory):
    def _rename(item, name):
        os.rename(
            os.path.join(destination_directory, item),
            os.path.join(destination_directory, name))

    def _run(items):
        for item in items:
            if 'appname' in item:
                _rename(item, app_name.lower())
            if 'Appname' in item:
                _rename(item, app_name)

    for _, dirs, files in os.walk(destination_directory):
        _run(dirs)
        _run(files)

#def update_app(app_name, path=''):
    #update_paths_to_ignore = ()
