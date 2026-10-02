#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
require_gum
"$ROOT/data/book_database.sh" init
exec "$ROOT/ui/main_menu.sh"
