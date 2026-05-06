# WineBro Brand & Investor Deck

Two formats, same content. Pick the one that matches the use case.

| File | Size | When to use |
|---|---|---|
| `winebro-deck.html` | ~26 KB | Open in any browser → present full-screen → arrow keys to navigate. **Print to PDF** via the PDF button (or Ctrl/Cmd-P). Best for in-person pitches, screenshare demos, founder Keynote-style talks. |
| `winebro-deck.pptx` | ~50 KB | Open in PowerPoint, Keynote, or Google Slides. Edit text and slide layout natively. Best for **emailing to a brand BD contact** who expects an attachment, or for editing slide-by-slide. |

## Editing

**HTML:** Edit `winebro-deck.html` directly. Each `<section class="slide">` is a slide. Brand colours are defined as CSS variables at the top of the file (`--paprika`, `--thunder`, `--gold`, etc.) — change once, propagate everywhere.

**PPTX:** Edit `generate_pptx.py` and regenerate:

```bash
python docs/deck/generate_pptx.py
```

The script writes back to `winebro-deck.pptx`. **Don't edit the .pptx directly** unless it's a one-off — the next regeneration will overwrite your changes.

## Deck contents (12 slides, 16:9)

1. **Title** — "Your Bro for every bottle." Tagline + 3 stats pill row
2. **The problem** — Western wine apps don't know our food
3. **The market** — ₹14k Cr by 2030, 7% CAGR, 0 apps for India
4. **The product** — Scan / Pair / Journal / Bro Circle (4-card grid)
5. **Coverage** — 12 Indian brand tags in real brand colours
6. **Cultural moat** — Aam, Jamun, Imli, Tandoor (gold treatment)
7. **Defensibility** — D1–D10 data assets table with Year-1 targets
8. **Built right** — production stack, 36 PRs, 99/99 tests
9. **Monetisation** — 3 horizons: affiliate / premium / B2B
10. **Two asks** — split slide: brand BD ask + investor ask (₹50L)
11. **Why now** — Cream slide with pull-quote
12. **Closing** — same as title + contact block

## Things to do before sending externally

1. Replace `[your email]` and `[your number]` on slide 12
2. Confirm the investor ask amount (₹50L on slide 10) matches your real ask
3. (Optional) Swap the title-slide tagline if you choose a different one (deck-source default: "Your Bro for every bottle.")
4. (Optional) Replace contact placeholders with actual social handles / website

## Source of truth

Both files are generated from the same content as `docs/MARKETING-DECK.md`. If the strategic narrative changes, update the Markdown first, then sync the HTML and the Python script.
