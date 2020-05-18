#!/bin/sh
git pull
~/.local/bin/mkdocs build
sudo cp -r site/* /srv/digital-design-docs/
