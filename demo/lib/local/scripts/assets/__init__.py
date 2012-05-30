import os


BASE_LOCATION = os.getcwdu()
INPUT_FILES = os.path.join(BASE_LOCATION, 'assets')


def _bundle_images(app, env, is_skel=False):
    """Copy images into static."""
    #TODO: add png crush or something similar
    import shutil

    if is_skel:
        root_src_dir = os.path.join(
            BASE_LOCATION, '..', 'skel', 'assets', 'img')
        root_dst_dir = os.path.join(BASE_LOCATION, 'static', 'img')
    else:
        root_src_dir = os.path.join(BASE_LOCATION, 'assets', 'img')
        root_dst_dir = os.path.join(BASE_LOCATION, 'static', 'img')

    for src_dir, dirs, files in os.walk(root_src_dir):
        dst_dir = src_dir.replace(root_src_dir, root_dst_dir)
        if not os.path.exists(dst_dir):
            os.mkdir(dst_dir)
        for file_ in files:
            src_file = os.path.join(src_dir, file_)
            dst_file = os.path.join(dst_dir, file_)
            if os.path.exists(dst_file):
                os.remove(dst_file)
            shutil.copy(src_file, dst_dir)

