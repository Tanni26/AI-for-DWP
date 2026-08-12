# Ticket: Copilot Gives Vague Answers on Contract Templates — Contract Specialist

**Raised by:** Contract Specialist  
**Date:** 2026-08-12  
**Severity:** Medium — user productivity impact, no data or access issue  
**Status:** Open

---

## User Report

> "Copilot gives vague, generic answers when I ask about clauses in our contract templates library, doesn't seem to actually read the documents."

---

## Triage Analysis

**Root cause (candidates — ranked by likelihood):**

1. **SharePoint library not indexed, or indexing incomplete** — Copilot relies on the Microsoft Search index to retrieve SharePoint content. If the contract templates library was recently created, recently had a large number of files uploaded, or has never been fully crawled, Copilot will not have access to the actual document content and will fall back on general knowledge — producing generic, non-specific answers.
2. **Library permissions preventing Copilot from reading files** — Even with Search indexing, if the library has unusual permission settings (e.g., permissions applied at file level with no top-level access), Copilot may be unable to retrieve specific content.
3. **Prompting approach** — Copilot responds to what it is asked. If prompts are broad (e.g., "What does our contract say about termination?") without referencing a specific document or folder, Copilot may answer from general legal knowledge rather than grounding in the specific files. This is a known behaviour, not a fault.
4. **File format issues** — If templates are stored as older formats (.doc rather than .docx), password-protected, or scanned PDFs (image-based), Copilot cannot read their text content.

---

## Investigation Steps

1. Ask the user to share a specific example: what prompt did she use, and what did the response say? This will confirm whether Copilot is responding generically or returning an error.
2. Check the SharePoint library in the Search Admin Centre — confirm whether the library and its files are indexed.
3. Ask the user to try referencing the file explicitly in her prompt: *"Summarise the termination clause in the standard services agreement stored in [library name]."*
4. Open one of the template files directly and confirm it is a readable Word document (not a scanned image or password-protected file).
5. Confirm she has read access to the library and its files.

---

## Resolution Path

- **Indexing lag:** If the library is not yet indexed, raise a Search indexing request or wait up to 72 hours for full crawl. No content changes should be made to the library during this period.
- **Prompting approach:** Advise the user to be more specific in her prompts — reference the document name or folder directly. See the Copilot Prompting Starter Guide for examples.
- **File format:** If files are not in a readable format, advise the document owner to save templates as standard .docx files and re-upload. Password protection must be removed for Copilot to read content.
- **Permissions:** If confirmed as a permissions issue, resolve as per standard SharePoint access process.

---

## Notes

This is a common early-adoption issue. Users expect Copilot to behave like a human who has read every document in a folder. The reality is that Copilot needs the content to be indexed and needs specific prompts to ground its response in a particular document. A short prompt-coaching session with the Contract Specialist is likely to resolve most of her frustration even before any technical fix is applied.
