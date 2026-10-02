#!/usr/bin/env bash
# The only component that opens books.csv. Python's standard CSV parser handles
# titles containing commas and quotes; the rest of the application uses Bash.
source "$(dirname "$0")/../common.sh"
exec python3 - "$BOOK_DB" "$@" <<'PY'
import csv
import os
import sys
import tempfile

path, *args = sys.argv[1:]
fields = ['title', 'author', 'genre', 'year', 'status', 'rating', 'link']
statuses = {'owned', 'want-to-read', 'reading', 'finished'}

def fail(message):
    print(message, file=sys.stderr)
    sys.exit(1)

def key(title, author):
    return (' '.join(title.lower().split()), ' '.join(author.lower().split()))

def save(rows):
    # Replace the complete file atomically, so readers never see half a write.
    folder = os.path.dirname(os.path.abspath(path))
    os.makedirs(folder, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix='.books-', suffix='.tmp', dir=folder)
    try:
        with os.fdopen(fd, 'w', newline='', encoding='utf-8') as stream:
            writer = csv.DictWriter(stream, fieldnames=fields)
            writer.writeheader()
            writer.writerows(rows)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)

def emit(rows):
    for row in rows:
        print('\t'.join(row[field] for field in fields))

def validate(row):
    if not row['title'] or not row['author'] or not row['genre']:
        fail('Title, author, and genre are required.')
    if any(any(ord(c) < 32 or ord(c) == 127 for c in value) for value in row.values()):
        fail('Fields must be single lines without tabs or control characters.')
    if row['status'] not in statuses:
        fail('Status must be owned, want-to-read, reading, or finished.')
    if row['rating'] not in {'-', '1', '2', '3', '4', '5'}:
        fail('Rating must be 1 through 5, or - for unrated.')
    if row['year'] != '-' and not (len(row['year']) == 4 and row['year'].isascii() and row['year'].isdigit()):
        fail('Year must be four digits, or - for unknown.')
    if row['link'] != '-' and not row['link'].startswith(('https://', 'http://')):
        fail('Link must start with https:// or http://, or be - for unknown.')

try:
    if not args:
        fail('Usage: book_database.sh init|list|search|exists|add|update-status|update-rating ...')
    action, *values = args
    if os.path.exists(path):
        with open(path, newline='', encoding='utf-8') as stream:
            reader = csv.DictReader(stream)
            if reader.fieldnames != fields:
                fail('Unexpected library CSV header. See README.md for the schema.')
            rows = list(reader)
    else:
        rows = []
    if action == 'init' and not values:
        if not os.path.exists(path):
            save(rows)
    elif action == 'list' and not values:
        emit(rows)
    elif action == 'search' and len(values) == 1:
        term = values[0].lower().strip()
        emit([row for row in rows if any(term in row[f].lower() for f in ('title', 'author', 'genre', 'status'))])
    elif action == 'exists' and len(values) == 2:
        sys.exit(0 if any(key(r['title'], r['author']) == key(*values) for r in rows) else 1)
    elif action == 'add' and len(values) == 7:
        row = dict(zip(fields, (v.strip() for v in values)))
        validate(row)
        if any(key(r['title'], r['author']) == key(row['title'], row['author']) for r in rows):
            fail('That book is already in your library.')
        rows.append(row)
        save(rows)
    elif action in ('update-status', 'update-rating') and len(values) == 3:
        title, author, value = values
        match = next((r for r in rows if key(r['title'], r['author']) == key(title, author)), None)
        if match is None:
            fail('Book not found in your library.')
        match['status' if action == 'update-status' else 'rating'] = value
        validate(match)
        save(rows)
    else:
        fail('Unknown command or wrong number of arguments. See README.md.')
except (OSError, csv.Error, KeyError, TypeError) as error:
    fail('Library error: ' + str(error))
PY
