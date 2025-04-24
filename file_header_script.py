import os
import re
from typing import Final
from datetime import datetime


LICENSE_HEADER: Final[str] = f"""// SPDX-License-Identifier: Apache-2.0
// Copyright {datetime.now().year} BitCodersNN

"""
IGNORED_DIRECTORIES: Final[set[str]] = set()
IGNORED_FILES: Final[set[str]] = {'firebase_options.dart'}
DART_FILE_EXTENSION: Final[str] = '.dart'
DEFAULT_PROJECT_DIRECTORY: Final[str] = './lib'
ENCODING: Final[str] = 'utf-8'

LICENSE_PATTERN: Final[str] = (
    r'^// SPDX-License-Identifier:.*?\n'
    r'// Copyright \d{4} .*?\n\n'
)


def _has_license(content: str) -> bool:
    """Проверяет наличие лицензионного заголовка в содержимом файла."""
    return bool(re.search(LICENSE_PATTERN, content, re.MULTILINE))


def _add_license_to_file(file_path: str) -> None:
    """Добавляет лицензионный заголовок, если его нет в файле."""
    with open(file_path, 'r+', encoding=ENCODING) as file:
        content = file.read()

        if _has_license(content):
            print(f'Skipped (license exists): {file_path}')
            return

        if not content.startswith(LICENSE_HEADER):
            file.seek(0, 0)
            file.write(LICENSE_HEADER + content)
            print(f'Updated: {file_path}')
        else:
            print(f'Already up-to-date: {file_path}')


def _process_directory(directory: str) -> None:
    """Рекурсивно обрабатывает все .dart файлы в директории."""
    for root, dirs, files in os.walk(directory):
        dirs[:] = [d for d in dirs if d not in IGNORED_DIRECTORIES]

        for file in files:
            if file in IGNORED_FILES:
                continue
            if file.endswith(DART_FILE_EXTENSION):
                file_path = os.path.join(root, file)
                _add_license_to_file(file_path)


if __name__ == '__main__':
    print('Adding license headers to all {ext} files in: {dir}'.format(
        ext=DART_FILE_EXTENSION,
        dir=DEFAULT_PROJECT_DIRECTORY,
    ))
    _process_directory(DEFAULT_PROJECT_DIRECTORY)
    print('License headers added successfully.')
