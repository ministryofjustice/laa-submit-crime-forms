export function handleResizeOnScrollablePane() {
  const scrollablePane = document.querySelector('.moj-scrollable-pane');

  if (window.innerWidth >= 1024) {
      scrollablePane.classList.add('hide-horizontal-scroll');
      // Force repaint on Safari by changing overflow values slightly
      scrollablePane.style.overflow = 'hidden';
      scrollablePane.style.overflowY = 'hidden'; // Hide vertical scroll space
      setTimeout(() => {
          scrollablePane.style.overflow = 'auto';
          scrollablePane.style.overflowY = 'hidden'; // Ensure no vertical scrollbar space
      }, 0);
  } else {
      scrollablePane.classList.remove('hide-horizontal-scroll');
      scrollablePane.style.overflow = 'scroll';
      scrollablePane.style.overflowY = 'auto'; // Restore normal behavior on smaller screens
  }
}
