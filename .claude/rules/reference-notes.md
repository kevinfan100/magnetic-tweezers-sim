---
globs: ["references/**/*.md"]
---

# Reference Notes Rules

## Notes-First Principle
- Structured notes in `references/notes/` are the **primary information source**
- ALWAYS check notes before reading the original PDF
- If notes are insufficient, use the "Page Ranges for Claude" section to find the right PDF pages, then **update the notes** after reading

## First-Time Paper Intake
- Read the table of contents first (usually pp. 1-10)
- Create a skeleton note from `_TEMPLATE.md`
- Deep-read 3-5 sections most relevant to the current task
- Fill in notes incrementally — no need to read the entire paper at once

## Note File Conventions
- Filename format: `[first-author-lastname]-[year]-[short-topic].md`
- Write note content in English (technical documentation)
- When extracting parameters or equations, always record the exact page number
- Never delete existing notes; mark outdated info with `[OUTDATED: reason]`
- Update `references/README.md` paper index when creating a new note

## Reading Papers
- PDFs have been converted to text files in `references/texts/` using `pdftotext -layout`
- Each text file has a corresponding `_page_index.txt` mapping PDF page numbers to line numbers
- To read a specific page range: check the page index, then use `Read` with `offset` and `limit`
- Text files are gitignored (regenerable); notes in `references/notes/` are the persistent record
- After reading text content, update the corresponding note file with new information
- For figures/diagrams that need visual inspection, use the PDF directly with `Read` tool's `pages` parameter (requires pdftoppm in PATH — restart Claude Code after Poppler install if needed)
