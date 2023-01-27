window.addEventListener('DOMContentLoaded', initSiteSearch);

function handleFirstInputFocus(focusEvent) {
  const { inputElement } = window.appState.refs;

  inputElement.addEventListener('keyup', (keyUpEvent) => {
    clearTimeout(window.appState.refs.timer);

    window.appState.refs.timer = setTimeout(() => {
      handleKeyUp(keyUpEvent);
    }, 300);
  });

  inputElement.removeEventListener('focus', handleFirstInputFocus);

  inputElement.addEventListener('focus', handleInputFocus);

  handleInputFocus(focusEvent);

  loadSearchData();
}

function handleInputFocus(focusEvent) {}

function handleKeyUp(keyUpEvent) {
  render();
}

function highlightSubString(string, substring) {
  return string.replace(
    new RegExp(substring, 'ig'),
    (match) => `<span class="text--highlight">${match}</span>`
  );
}

function initSiteSearch() {
  window.appState = {
    refs: {
      inputElement: document.querySelector('.js-search-input'),
      searchResultsModal: document.querySelector('.js-search-results'),
      timer: null,
    },
    pages: [],
    results: [],
  };

  window.appState.refs.inputElement.addEventListener(
    'focus',
    handleFirstInputFocus
  );
}

function loadSearchData() {
  fetch('/assets/js/search.data.json')
    .then((response) => response.json())
    .then((pages) => {
      window.appState.pages = pages.map(sanitizeSearchData);
    });
}

function render() {
  const { inputElement, searchResultsModal } = window.appState.refs;

  const keywords = inputElement.value.toLowerCase().split(' ');

  searchResultsModal.innerHTML = ``;

  if (!keywords.length) {
    return;
  }

  const versionMenuElement = document.querySelector('.js-version-menu');

  const currentVersion =
    versionMenuElement.options[versionMenuElement.selectedIndex].value;

  const matchingPages = [];

  const pagesForCurrentVersion = window.appState.pages.filter(
    (page) => page.version === currentVersion
  );

  pagesForCurrentVersion.forEach((page) => {
    const lowerCaseTitle = page.title.toLowerCase();

    const augmentedPage = {
      ...page,
      matchScore: 0,
      numMatchesInContent: 0,
      snippet: null,
    };

    keywords.forEach((keyword) => {
      if (lowerCaseTitle.includes(keyword)) {
        augmentedPage.matchScore += 10;

        augmentedPage.title = highlightSubString(page.title, keyword);
      }

      const matchesInPageContent = Array.from(
        page.content.matchAll(new RegExp(keyword, 'ig'))
      );

      if (matchesInPageContent.length) {
        augmentedPage.matchScore += matchesInPageContent.length;
        augmentedPage.numMatchesInContent = matchesInPageContent.length;

        if (!augmentedPage.snippet) {
          const match = matchesInPageContent[0];

          const snippet = page.content.slice(
            Math.max(0, match.index - 25),
            match.index + keyword.length + 25
          );

          augmentedPage.snippet = `...${highlightSubString(
            snippet,
            keyword
          )}...`;
        }
      }
    });

    if (augmentedPage.matchScore > 0) {
      matchingPages.push(augmentedPage);
    }
  });

  matchingPages.sort((a, b) => a.matchScore - b.matchScore).reverse();

  const renderedResults = matchingPages
    .map((result) => {
      const { numMatchesInContent, snippet, title, url } = result;

      const suffix =
        numMatchesInContent >= 2
          ? `<span class="text--link">+ ${numMatchesInContent - 1} ${
              numMatchesInContent - 1 > 1 ? `matches` : `match`
            }</span>`
          : ``;

      return `
        <li class="SiteSearch-result js-search-result">
          <a class="SiteSearch-resultButton" href="${url}">
            <span class="SiteSearch-resultTitle">${title}</span>
            <span class="SiteSearch-resultURL">${url}</span>
            ${
              snippet
                ? `
                  <span class="SiteSearch-resultSnippet">
                    ${snippet}
                    ${suffix}
                  </span>
                `
                : 'No matches in page content'
            }
          </a>
        </li>
      `;
    })
    .join('');

  searchResultsModal.innerHTML = matchingPages.length
    ? `
      <li class="SiteSearch-resultTally">
        ${matchingPages.length} ${
        matchingPages.length === 1 ? `Page` : `Pages`
      } Matched
      </li>
      ${renderedResults}
    `
    : `
      <li class="SiteSearch-result--empty">
        No Results
      </li>
    `;
}

function sanitizeSearchData(page) {
  return {
    ...page,
    title: decodeURIComponent(page.title).replace(/\+/g, ' '),
    content: decodeURIComponent(page.content).replace(/\+/g, ' '),
  };
}
