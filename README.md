# Plot & Possibility

A personal terminal book manager for stories to escape into and ideas to grow with.

## Run

Requires Bash 3.2+, Python 3, and [Gum](https://github.com/charmbracelet/gum). On macOS:

```bash
brew install gum
cd book-manager
./app.sh
```

Python 3 is used only inside the data layer for correct CSV handling. If `python3 --version` fails, install Python 3 first. Use the arrow keys and Enter to select menu items; Esc goes back. Start with **Add Book** and try `The Hunger Games`, `1984`, or `Part of Your World`. Books outside the catalog can be entered manually. The repository includes my saved library; saving a book does not imply I have read it.

## Features

- **Add books:** look up a full title in the offline catalog to fill in its author, genre, year, and link, or enter details manually for another book.
- **Browse and search:** view saved books and their details, or search your library by part of a title, author, genre, or reading status.
- **Track reading:** mark books as owned, want-to-read, reading, or finished. Give them a rating from 1 to 5, or leave them unrated. Status and rating can be updated later.
- **Keep your library:** books are saved in `books.csv` between sessions, and duplicate title-and-author entries are rejected.
- **View your reading profile:** see your favorite genres and learning goals in the My Reading Profile screen. These preferences can be customized in the two files under `book-manager/config/`.
- **Save recommendations:** choose a suggestion and add it directly to your want-to-read list. It will be excluded the next time recommendations are generated.

## Recommendations

Three independent programs generate candidates concurrently:

| Strategy | How it chooses books |
| --- | --- |
| History | Matches genres from saved books, giving extra weight to finished and highly rated books and ignoring books rated 1 or 2. |
| Interests | Matches favorite genres in the reading profile, with earlier preferences receiving higher priority. |
| Discovery | Explores learning goals such as finance and startups, giving priority to genres not yet represented in the library. |

The app displays running/done messages, waits for all three programs, and pipes their combined candidates into refinement. The refiner ranks candidates, removes duplicates and books already saved, and selects up to two books per strategy with one per genre within each strategy. Each suggestion includes a reason. As more catalog books are saved, the available shortlist may become shorter.

The saved library grows through the app's Add Book and Save Recommendation actions. The offline catalog supplies metadata and recommendation candidates and can be expanded by adding entries to `book-manager/catalog/books.tsv`.

## Architecture

`app.sh` starts the UI. The UI gathers choices and calls workflows; workflows coordinate the book and recommendation components; `data/book_database.sh` is the only application component that opens `books.csv`. Each component has a separate file. The three recommendation programs run in Bash background processes (`&`), their process IDs are captured with `$!`, and the workflow synchronizes them with `wait`. Each writes to its own temporary file. The workflow combines those files and pipes them into `refine_recommendations.sh`, which reads stdin and writes a shortlist to stdout. Progress messages use stderr so they do not corrupt the data stream.

## Personalization

The reading profile focuses on dystopian fiction, rom-coms, period fiction, and history, with an offline catalog including Suzanne Collins, George Orwell, and Abby Jimenez. Discovery recommendations introduce practical personal finance, startup building, and habits or focus. The history strategy uses saved genres and gives extra weight to finished or highly rated books, while ignoring books rated 1 or 2. The interests strategy follows `config/interests.txt`; discovery follows `config/discovery.txt` and prefers genres not yet in the library. The refiner removes saved books and duplicates and keeps up to two recommendations per strategy, with one per genre within each strategy. This balances familiar reading with learning something new.

## Demo video

**[Download and watch the narrated demo (MP4, 3:27, about 3 MB)](https://github.com/yara-alsinan/plot-and-possibility/raw/refs/heads/main/book-manager/demo/plot-and-possibility-demo.mp4)**

The demo shows adding a book, searching the saved library, and generating and saving recommendations. The recording is compressed using the instructor's 720p AV1 settings with mono AAC audio.

## Understand and test it

- [Plain-English walkthrough](book-manager/WALKTHROUGH.md)
- [Commands, data formats, and project layout](book-manager/README.md)

```bash
./book-manager/tests/smoke.sh
```

Tests use a temporary library. They do not change your saved books.

## Scope

This is an intentionally small, offline application. Metadata and suggestions come from 24 curated catalog entries, not live AI or an online book API. The recommendation “agents” are independent rule-based Bash programs. Metadata lookup matches a title exactly, ignoring case; unknown titles use manual entry. Recommendation scoring is a heuristic, not a prediction of book quality. The catalog groups classic period fiction with historical fiction for browsing. Run one app instance at a time. No paid services, accounts, or API keys are required to use it.

Book descriptions are short original notes. Background references include [Part of Your World](https://www.hachettebookgroup.com/titles/abby-jimenez/part-of-your-world/9781538704370/?lens=forever), [The Lean Startup](https://www.penguinrandomhouse.com/books/210088/the-lean-startup-by-eric-ries/), and [Atomic Habits](https://global.penguinrandomhouse.com/announcements/avery-celebrates-5-years-of-atomic-habits-an-astounding-260-weeks-on-the-nyt-bestseller-list/). Catalog links lead to Open Library searches.
