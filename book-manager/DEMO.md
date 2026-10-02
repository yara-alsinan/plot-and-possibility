# Demo and submission

Suggested length: about 2–3 minutes. The assignment asks for a short narrated video, not a specific duration. Record your own voice and use words you understand. This is an outline, not a claim that the demo is finished.

## Before recording

- Run `./book-manager/tests/smoke.sh` from the repository root.
- Open a terminal, make the text large enough to read, and run `./book-manager/app.sh`.
- Practice adding a book and finding recommendations once.
- Choose real reading statuses and ratings; you do not need to claim you finished a book to demonstrate the app.

## Three operations to show

1. **Add a book.** Try The Hunger Games or an Abby Jimenez title. Show the metadata match and choose a status/rating. Explain that the UI passes your choices to the workflow and the database layer saves them.
2. **Browse or search, then update.** Search for the saved book, open it, and update its status or rating. Explain that the records persist between app runs.
3. **Get recommendations.** Point out the running/done messages, the three strategies, and the reasons. Save one suggestion. Explain that the background programs run concurrently, `wait` synchronizes them, and a pipe sends combined candidates to refinement.

If useful, briefly show `workflows/get_recommendations.sh` to point out `&`, `$!`, `wait`, and `|`. Do not spend the whole video reading code.

## Before submitting

- [ ] Read the walkthrough and explain each required file in your own words.
- [ ] Create a repository in your own GitHub account and push this complete project.
- [ ] Record the narrated terminal demo.
- [ ] Add the video or a visible video link to the repository's root README.
- [ ] Check that the video is viewable by the instructor.
- [ ] Open the GitHub repository and confirm the README and `book-manager/` folder are visible.
- [ ] Enter the repository URL under **Assignment No 2** in the class sign-up sheet linked in the assignment PDF.

The local project alone is not the final submission: GitHub, the narrated video, and the sign-up-sheet URL are still required.
