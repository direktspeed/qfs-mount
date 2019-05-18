#!/bin/bash

error=0
checkFileInTAR()
{
    local archive="$1"
    local fileInTar="$2"
    local correctChecksum="$3"

    local mountFolder="$( mktemp -d )"

    # try with index recreation
    python3 ratarmount.py -c "$archive" "$mountFolder" &>/dev/null
    checksum="$( md5sum "$mountFolder/$fileInTar" 2>/dev/null | sed 's| .*||' )"
    if test "$checksum" != "$correctChecksum"; then
        echo "File sum of '$fileInTar' in mounted TAR '$archive'"' does not match! It seems there was a mounting error!'
        return 1
    fi
    fusermount -u "$mountFolder" &>/dev/null

    # retry without forcing index recreation
    python3 ratarmount.py "$archive" "$mountFolder" &>/dev/null
    checksum="$( md5sum "$mountFolder/$fileInTar" 2>/dev/null | sed 's| .*||' )"
    if test "$checksum" != "$correctChecksum"; then
        echo "File sum of '$fileInTar' in mounted TAR '$archive'"' does not match! It seems there was a mounting error!'
        return 1
    fi
    fusermount -u "$mountFolder" &>/dev/null

    echo "Tested succesfully '$fileInTar' in '$archive' for checksum $correctChecksum"

    return 0
}

checkFileInTAR tests/single-file.tar bar d3b07384d113edec49eaa6238ad5ff00
checkFileInTAR tests/single-file-with-leading-dot-slash.tar bar d3b07384d113edec49eaa6238ad5ff00
checkFileInTAR tests/folder-with-leading-dot-slash.tar foo/bar 2b87e29fca6ee7f1df6c1a76cb58e101
checkFileInTAR tests/folder-with-leading-dot-slash.tar foo/fighter/ufo 2709a3348eb2c52302a7606ecf5860bc
checkFileInTAR tests/single-nested-file.tar foo/fighter/ufo 2709a3348eb2c52302a7606ecf5860bc

exit $error
