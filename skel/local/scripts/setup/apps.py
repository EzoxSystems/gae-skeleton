import os
import shutil


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

    copy_files(TEMPLATE_DIRECTORY, app_location)

    lib_location = os.path.join(app_location, 'lib')
    if not os.path.exists(lib_location):
        os.makedirs(lib_location)

    copy_files(
        os.path.join(BASE_LOCATION, 'skel'), lib_location, DIRECTORIES_TO_IGNORE)


def copy_files(root_src_dir, root_dst_dir, dirs_to_ignore=None,
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


#def update_app(app_name, path=''):
    #update_paths_to_ignore = ()
