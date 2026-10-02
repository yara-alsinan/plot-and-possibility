# Understand your book manager

Start by running the app. Add a real book, choose its actual status, search for it, and request recommendations. Then read this guide alongside the files. You do not need to memorize the code; you need to know what each piece receives, does, and returns.

## The five layers

Think of ordering food: the menu helps you choose, a coordinator routes your request, specialists do individual jobs, and a storage service keeps records. In this app:

```text
You → UI → Workflow → Book/recommendation components → Data layer → CSV
```

Not every action visits every box. Browsing just needs UI → workflow → data layer. Adding uses metadata plus the data layer.

## Trace “Add Book”

1. `app.sh` checks for Gum, initializes storage if needed, and launches the main menu.
2. `ui/main_menu.sh` sees your Add Book choice and opens `ui/library_screen.sh`.
3. The library screen asks for a title and asks `workflows/manage_library.sh` for metadata.
4. The workflow calls `books/fetch_book_metadata.sh`, which looks up the title in the offline catalog and returns tab-separated fields. If it is unknown, the UI asks for manual details.
5. The UI asks for status and rating, then sends seven fields to the workflow's `add` command.
6. The workflow fills missing metadata and calls `data/book_database.sh add`.
7. The data layer validates the fields, checks for duplicates, and saves a new CSV version. The UI displays confirmation.

The catalog is a list of possible books. The library is the collection you have actually saved. These are different files with different purposes.

## Trace “Get Recommendations”

1. The recommendation screen calls `workflows/get_recommendations.sh`.
2. It starts three independent scripts with `&`. History uses your saved books, interests uses your favorite shelves, and discovery explores your learning goals.
3. Immediately after each launch, `$!` gives the process ID. The workflow saves that number.
4. `wait` uses those IDs to wait for completion and check for failure. All scripts have already been launched before waiting begins, so they can run concurrently.
5. Each script writes its candidates to its own temporary file. They cannot overwrite one another's results.
6. `cat` combines the files. `|` sends the combined text directly into `refine_recommendations.sh` as standard input.
7. The refiner sorts by score, removes books already saved and duplicate candidates, and limits the shortlist for variety.
8. The UI shows the shortlist and reasons. If you save a recommendation, it goes through the same library workflow and data layer.

## Shell concepts in plain English

| Symbol or tool | Meaning here |
| --- | --- |
| `"$1"`, `"$2"` | The first and second arguments supplied to a script |
| `$(...)` | Run a command and capture its output |
| `source` | Load shared definitions into this Bash process |
| `exec` | Replace the current process with another command |
| `&` | Start a command in the background |
| `$!` | The most recently launched background process ID |
| `wait` | Wait for a background process and receive its exit status |
| `>` | Write standard output to a file |
| `>&2` | Send a message to standard error |
| `\|` | Connect one program's output to the next program's input |
| `awk` | Process text as records and fields |
| `trap` | Arrange cleanup when the script exits or is interrupted |

**Standard output (stdout)** carries the actual book records. **Standard error (stderr)** carries progress and errors. Separating them lets us capture recommendations without accidentally capturing a “running” message as a book.

The application uses ordinary Bash plus small `awk` commands. The database script embeds Python only to parse/write CSV correctly, including book titles with commas or quotation marks. Its `save` function writes a temporary file and replaces the old one, rather than leaving a half-written library if interrupted.

## One sentence per file

| File | Job |
| --- | --- |
| `app.sh` | Start the app |
| `common.sh` | Define shared paths and shell settings |
| `ui/main_menu.sh` | Let the user choose an operation |
| `ui/library_screen.sh` | Ask for book details and show saved books |
| `ui/recommendations_screen.sh` | Show suggestions and offer to save one |
| `ui/helpers.sh` | Share small menu/display functions |
| `workflows/manage_library.sh` | Route library operations to components |
| `workflows/get_recommendations.sh` | Coordinate concurrent agents and the refinement pipe |
| `books/fetch_book_metadata.sh` | Look up known book details |
| `books/search_books.sh` | Accept a query and ask the database to search |
| `recommendations/recommend_from_history.sh` | Match genres from saved/high-rated books |
| `recommendations/recommend_from_interests.sh` | Match favorite genres from the profile |
| `recommendations/recommend_for_discovery.sh` | Suggest learning topics, favoring unfamiliar genres |
| `recommendations/refine_recommendations.sh` | Turn candidates into a short, deduplicated list |
| `data/book_database.sh` | Validate, retrieve, and persist library records |
| `data/books.csv` | Store saved books between runs |
| `catalog/books.tsv` | Provide the small offline pool of known books |
| `config/interests.txt` | List favorite reading genres in priority order |
| `config/discovery.txt` | List learning goals in priority order |
| `tests/smoke.sh` | Check complete workflows using a temporary library |

## Practice explaining these

- Why should the UI never open `books.csv` directly?
- What would change if storage moved to SQLite? (The data layer; its command/output interface could stay the same.)
- Where is the meaningful pipe, and what exactly passes through it?
- Why launch all three agents before the first `wait`?
- Why are there three temporary files rather than one shared output file?
- What happens with an empty library? (History has no candidates, but interests and discovery still work.)
- Are these AI agents? (No. They are independent rule-based recommendation programs.)
- What is personalized? (Genres, learning goals, catalog selection, recommendation rules, and the interface theme.)
- What are the limitations? (Small offline catalog, exact title lookup, simple rules, single app instance.)
