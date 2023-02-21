window.addEventListener("DOMContentLoaded", initNavigationTree);
window.addEventListener("DOMContentLoaded", initVersionMenu);
window.addEventListener("scroll", handlePageScroll);

function handlePageScroll(scrollEvent) {
  updateTableOfContents(scrollEvent);
  updateStickyHeader(scrollEvent);
}

function handleTreeMenuButtonClick(event) {
  const parentMenuItem = event.target;
  parentMenuItem.classList.toggle("is-active");
}

function handleVersionMenuChange(changeEvent) {
  const selectElement = changeEvent.target;
  const selectedVersion =
    selectElement.options[selectElement.selectedIndex].value;

  window.location.href = `/${selectedVersion}`;
}

function initNavigationTree() {
  document
    .querySelectorAll(".js-tree-menu-parent-item")
    .forEach((buttonElement) => {
      buttonElement.addEventListener("click", handleTreeMenuButtonClick);
    });
}

function initVersionMenu() {
  const selectElement = document.querySelector(".js-version-menu");

  selectElement.addEventListener("change", handleVersionMenuChange);
}

function updateStickyHeader(scrollEvent) {
  const siteHeaderElement = document.querySelector(".js-sticky-site-header");
  const distanceScrolled = scrollEvent.target.scrollingElement.scrollTop;

  siteHeaderElement.classList.toggle("is-stuck", distanceScrolled >= 50);
}

function updateTableOfContents() {
  const allHeadings = Array.from(
    document.querySelectorAll("h2[id], h3[id], h4[id], h5[id], h6[id]")
  );

  let lowestSectionAboveFold = null;

  // Using Array.prototype.every() because you can't break out of a forEach
  allHeadings.reverse().every((heading) => {
    const headingId = heading.id;
    const coords = heading.getBoundingClientRect();

    if (coords.top <= 100) {
      lowestSectionAboveFold = headingId;
      return false;
    }

    return true;
  });

  const allAnchors = Array.from(document.querySelectorAll(".js-toc-button"));

  allAnchors.forEach((anchor) => {
    anchor.classList.toggle(
      "is-active",
      anchor.href.endsWith(`#${lowestSectionAboveFold}`)
    );
  });
}
