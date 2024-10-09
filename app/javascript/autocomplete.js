import { distance } from "fastest-levenshtein";
import accessibleAutocomplete from "accessible-autocomplete";

// Convert select fields to use accessible-autocomplete instead.
//
// Also includes functions to support requirements to make the autocompletion more fuzzy
const stopWords = ["a", "the", "of", "in", "and", "at", "&"];

const removePunctuation = (str) => str.replace(/[^\w\s]/g, "");

const sanitizeInput = (str) =>
  removePunctuation(str)
    .trim()
    .toLowerCase()
    .split(/\s+/)
    .filter((token) => !stopWords.includes(token));

const fuzzyMatch = (option, query) =>
  query.some((word) => option.some((w) => w.includes(word)));

export function convertSelectToAutocomplete() {
  [
    ...document.querySelectorAll(
      '[data-module="accessible-autocomplete"]:not([data-converted="true"])',
    ),
  ].forEach((element) => {
    const name = element.dataset.name;
    const values = element.dataset.values;

    let counts = null;
    if (values) {
      try {
        counts = JSON.parse(values);
      } catch {}
    }

    accessibleAutocomplete.enhanceSelectElement({
      selectElement: element,
      defaultValue: "",
      showNoOptionsFound: name === null,
      name: name,
      autoselect: element.dataset.autoselect === "true",
      source: (query, populateResults) => {
        const trimmed = sanitizeInput(query);
        const filtered = [...element.options].filter((opt) =>
          fuzzyMatch(sanitizeInput(opt.text), trimmed),
        );

        const sorted = filtered.sort((a, b) => {
          if (counts) {
            const countA = counts[a.text] || 0;
            const countB = counts[b.text] || 0;

            if (countA !== countB) {
              return countB - countA;
            }
          }
          const distA = distance(query.toLowerCase(), a.text.toLowerCase());
          const distB = distance(query.toLowerCase(), b.text.toLowerCase());

          return distA - distB;
        });

        populateResults(sorted.map((opt) => opt.text));
      },
    });
    element.dataset.converted = true;
  });
}
