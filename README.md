MATE Média Archívum — quick deploy & test

This repository contains EPrints templates customized with a Bootstrap 5 based header and a green brand color for the Magyar Agrár- és Élettudományi Egyetem.

What I changed
- Added `html/static/css/mae_custom.css` for custom styles.
- Updated templates to include Bootstrap 5 CSS/JS and the custom stylesheet:
  - `templates/default_internal.xml`
  - `hu/templates/default_internal.xml`
  - `templates/default.xml`
  - `hu/templates/default.xml`
  - `cfg/templates/default.xml`

Quick test (on the running EPrints instance)
1. Deploy the updated files to your EPrints server (place files into the same paths under your EPrints `archives/<archive>/` folder or reload from your source tree).
2. Clear any cached templates (restart the webserver or EPrints services if needed).
3. Open the site in a browser and verify:
   - Header shows the green `#007548` bar with the provided logo.
   - The site title reads "Magyar Agrár- és Élettudományi Egyetem — Média Archívuma" in the header.
   - The `Browse` menu appears as a right-aligned dropdown on larger screens and inside the navbar toggler on small screens.
   - Search box is visible and functional.

Troubleshooting
- If styles don't appear, ensure `/static/css/mae_custom.css` is reachable by the webserver.
- If the navbar behaviors don't work, confirm the Bootstrap JS bundle is loaded (check browser devtools network/console).

Want more?
- I can: apply Bootstrap classes to more templates, refine spacing/colors, or create variants for print/low-contrast modes.
- The search results page has also been restyled via CSS to use Bootstrap cards and highlight titles; to check, perform a repository search and review the list of results (they should appear as spaced cards with green titles).

