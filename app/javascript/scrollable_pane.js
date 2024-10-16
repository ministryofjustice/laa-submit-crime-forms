export function handleResizeOnScrollablePane(scrollablePane) {
  const isLargeScreen = window.innerWidth >= 1024;

  if (isLargeScreen) {
    applyLargeScreenStyles(scrollablePane);
  } else {
    applySmallScreenStyles(scrollablePane);
  }
}

function applyLargeScreenStyles(element) {
  if (!element.classList.contains('hide-horizontal-scroll')) {
    element.classList.add('hide-horizontal-scroll');
  }

  // Force repaint on Safari by toggling overflow properties
  element.style.overflow = 'hidden';
  element.style.overflowY = 'hidden';

  requestAnimationFrame(() => {
    element.style.overflow = 'auto';
    element.style.overflowY = 'hidden';
  });
}

function applySmallScreenStyles(element) {
  if (element.classList.contains('hide-horizontal-scroll')) {
    element.classList.remove('hide-horizontal-scroll');
  }

  element.style.overflow = 'scroll';
  element.style.overflowY = 'auto';
}

export function checkAndHandleResizeOnScrollablePane() {
  const scrollablePane = document.querySelector('.moj-scrollable-pane');
  if (scrollablePane) {
    handleResizeOnScrollablePane(scrollablePane);
  }
}
