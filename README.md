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

## Architecture

`app.sh` starts the UI. The UI gathers choices and calls workflows; workflows coordinate the book and recommendation components; `data/book_database.sh` is the only application component that opens `books.csv`. Each component has a separate file. The three recommendation programs run in Bash background processes (`&`), their process IDs are captured with `$!`, and the workflow synchronizes them with `wait`. Each writes to its own temporary file. The workflow combines those files and pipes them into `refine_recommendations.sh`, which reads stdin and writes a shortlist to stdout. Progress messages use stderr so they do not corrupt the data stream.

## Personalization

The reading profile focuses on dystopian fiction, rom-coms, period fiction, and history, with an offline catalog including Suzanne Collins, George Orwell, and Abby Jimenez. Discovery recommendations introduce practical personal finance, startup building, and habits or focus. The history strategy uses saved genres and gives extra weight to finished or highly rated books, while ignoring books rated 1 or 2. The interests strategy follows `config/interests.txt`; discovery follows `config/discovery.txt` and prefers genres not yet in the library. The refiner removes saved books and duplicates and keeps up to two recommendations per strategy, with one per genre within each strategy. This balances familiar reading with learning something new.

## Demo video — still to be recorded

The required narrated demo has not been recorded yet. Before submitting, add the video to this repository or replace this paragraph with a clearly visible link. [Demo outline and submission checklist](book-manager/DEMO.md).

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
