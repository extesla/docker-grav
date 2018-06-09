#!/bin/sh
# The MIT License (MIT)
#
# Copyright (c) 2018 Extesla, LLC.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
set -e

#: ==========================================================================
#: Global Variables
#: ==========================================================================

#: The directory that the shell script is located in.
SCRIPT_DIR="$(cd $(dirname $0) && pwd)"

#: The location of the docker file.
DOCKERFILE="$(dirname $SCRIPT_DIR/.)"

#: The fully qualified Docker image tag, e.g. extesla/alpine:latest
IMAGE_TAG=$(cat $SCRIPT_DIR/TAG)

#: ==========================================================================
#: Functions
#: ==========================================================================

print_status() {
    echo
    echo "## $1"
    echo
}

bail() {
    echo 'Error executing command, exiting'
    exit 1
}

exec_cmd_nobail() {
  user="$(id -un 2>/dev/null || true)"
  sh_c="sh -c"

  echo "+ $1"
  $sh_c "$1"
}

exec_cmd() {
    exec_cmd_nobail "$1" || bail
}

#: The command to be run, we define the command in a variable to easily
#: reference it (and it also allows us to make changes with as few code
#: modifications as possible!).
cmd="docker build --force-rm --tag='$IMAGE_TAG' $DOCKERFILE"
exec_cmd "$cmd"
