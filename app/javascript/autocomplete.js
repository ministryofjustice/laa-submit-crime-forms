import { distance } from "fastest-levenshtein";
import accessibleAutocomplete from "accessible-autocomplete";

// Convert select fields to use accessible-autocomplete instead.
//
// Also includes functions to support requirements to make the autocompletion more fuzzy
const stopWords = ["a", "the", "of", "in", "and", "at", "&"];

// Maximum amount of partial matches that should count as found
const MAX_MATCHES = 1;

const matchCompose =
  (...matchers) =>
  (option, queryWords) => {
    return matchers.some((matcher) => matcher(option, queryWords));
  };

const removePunctuation = (str) => str.replace(/[^\w\s]/g, "");

const sanitizeInput = (str) =>
  removePunctuation(str)
    .trim()
    .toLowerCase()
    .split(/\s+/)
    .filter((token) => !stopWords.includes(token));

const exactMatch = (option, query) =>
  query.every((word) => option.some((w) => w.includes(word)));

const partialMatch = (option, query) =>
  query.filter((word) => option.some((w) => w.includes(word))) >= MAX_MATCHES;

const matcher = matchCompose(exactMatch, partialMatch);

export function convertSelectToAutocomplete() {
  const $acElements = document.querySelectorAll(
    '[data-module="accessible-autocomplete"]:not([data-converted="true"])',
  );
  if ($acElements) {
    for (let i = 0; i < $acElements.length; i++) {
      const element = $acElements[i];
      const name = element.getAttribute("data-name");
      accessibleAutocomplete.enhanceSelectElement({
        selectElement: element,
        defaultValue: "",
        showNoOptionsFound: name === null,
        name: name,
        source: (query, populateResults) => {
          const trimmed = sanitizeInput(query);
          const filtered = [...element.options].filter((opt) =>
            matcher(sanitizeInput(opt.text), trimmed),
          );

          const sorted = filtered.sort((a, b) => {
            const distA = distance(query.toLowerCase(), a.text.toLowerCase());
            const distB = distance(query.toLowerCase(), b.text.toLowerCase());

            return distA - distB;
          });

          populateResults(sorted.map((opt) => opt.text));
        },
        autoselect: $acElements[i].getAttribute("data-autoselect") === "true",
      });
      $acElements[i].setAttribute("data-converted", true);
    }
  }
}
