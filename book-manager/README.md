# Project reference

See the [repository README](../README.md) for setup, architecture, personalization, and demo status.

## Files

```text
book-manager/
├── app.sh
├── common.sh
├── ui/
│   ├── main_menu.sh
│   ├── library_screen.sh
│   ├── recommendations_screen.sh
│   └── helpers.sh
├── workflows/
│   ├── manage_library.sh
│   └── get_recommendations.sh
├── books/
│   ├── fetch_book_metadata.sh
│   └── search_books.sh
├── recommendations/
│   ├── recommend_from_history.sh
│   ├── recommend_from_interests.sh
│   ├── recommend_for_discovery.sh
│   └── refine_recommendations.sh
├── data/
│   ├── book_database.sh
│   └── books.csv
├── catalog/books.tsv
├── config/
│   ├── interests.txt
│   └── discovery.txt
├── tests/smoke.sh
├── WALKTHROUGH.md
└── DEMO.md
```

The extra files have specific jobs: `common.sh` shares paths; `ui/helpers.sh` shares small display functions; `catalog/books.tsv` holds offline metadata; the two config files hold personal interests. Documentation and tests do not participate in normal application workflows.

## Component interfaces

Run these commands from `book-manager/`:

```bash
./workflows/manage_library.sh list
./workflows/manage_library.sh metadata 'The Hunger Games'
./workflows/manage_library.sh add 'The Hunger Games' 'Suzanne Collins' Unknown - want-to-read - -
./books/search_books.sh 'dystopian'
echo 'history' | ./books/search_books.sh
./workflows/manage_library.sh update-status 'The Hunger Games' 'Suzanne Collins' reading
./workflows/manage_library.sh update-rating 'The Hunger Games' 'Suzanne Collins' 5
./workflows/get_recommendations.sh
```

`add` takes seven positional arguments: title, author, genre, year, status, rating, link. It enriches `Unknown` genre or `-` year/link from the catalog before saving. Quote arguments that contain spaces. The metadata component optionally accepts an author as a second argument. Unknown metadata exits with status 2.

The database exposes `init`, `list`, `search TERM`, `exists TITLE AUTHOR`, `add` with the seven fields, `update-status TITLE AUTHOR STATUS`, and `update-rating TITLE AUTHOR RATING`. `exists` exits 0 for a match and 1 otherwise. Search matches a literal substring in title, author, genre, or status, ignoring case.

## Data formats

Persistent CSV header:

```text
title,author,genre,year,status,rating,link
```

CSV quoting is handled by Python's built-in `csv` module. The application rejects tabs, line breaks, and control characters in fields so that its tab-separated streams remain unambiguous. `-` means unknown or unrated. Status is `owned`, `want-to-read`, `reading`, or `finished`; rating is `-` or 1–5. Reading status is a single category, not a separate ownership flag.

Programs exchange headerless tab-separated rows:

| Output | Fields, in order |
| --- | --- |
| Database/search | title, author, genre, year, status, rating, link |
| Metadata | title, author, genre, year, link |
| Recommendations | title, author, genre, year, link, strategy, score, reason |

Use this to refine a saved candidate file:

```bash
cat candidates.tsv | ./recommendations/refine_recommendations.sh
```

No UI formatting is mixed into data output. Files ending in `.tsv` use actual tabs, not commas.

The catalog has a header and six fields: title, author, genre, year, link, note. You can add entries in the same format. Put one exact catalog genre per line in each profile file; earlier lines have higher priority. The history strategy needs saved books before it produces candidates. Exhausting the catalog can produce a shorter or empty shortlist.

For isolated experiments, set `BOOK_DB` to another CSV path. Tests also use `BOOK_CATALOG` and `BOOK_PROFILE` overrides. Writes replace the CSV atomically, but simultaneous writers are not supported.
