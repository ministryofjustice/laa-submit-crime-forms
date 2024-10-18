export function handleResizeOnScrollablePane(scrollablePane) {
  if (!scrollablePane) return;
  const isLargeScreen = window.innerWidth >= 1024;

  isLargeScreen ?
    applyLargeScreenStyles(scrollablePane) :
    applySmallScreenStyles(scrollablePane);
}

function applyLargeScreenStyles(element) {
  element.classList.add('hide-horizontal-scroll');
  // Force repaint on Safari by toggling overflow properties
  element.style.overflow = 'hidden';
  element.style.overflowY = 'hidden';

    setTimeout(() => {
      element.style.overflow = 'auto';
      element.style.overflowY = 'hidden';
    }, 0);
}

function applySmallScreenStyles(element) {
  element.classList.remove('hide-horizontal-scroll');
  element.style.overflow = 'scroll';
  element.style.overflowY = 'auto';
}

export function checkAndHandleResizeOnScrollablePane() {
  const scrollablePanes = document.querySelectorAll('.moj-scrollable-pane');
    scrollablePanes.forEach((scrollablePane) => {
      handleResizeOnScrollablePane(scrollablePane);
    });
}
