// scrollable_pane.test.js
import 'jest-extended'; // For additional matchers
import { handleResizeOnScrollablePane } from '../../app/javascript/scrollable_pane';

describe('handleResizeOnScrollablePane', () => {
  let scrollablePane;

  beforeEach(() => {
    jest.useFakeTimers(); // Use fake timers
    // Set up our document body
    document.body.innerHTML = '<div class="moj-scrollable-pane"></div>';
    scrollablePane = document.querySelector('.moj-scrollable-pane');
  });

  afterEach(() => {
    // Clean up the DOM
    document.body.innerHTML = '';
  });

  it('should add hide-horizontal-scroll class and adjust styles on large screens', () => {
    // Mock window.innerWidth
    global.innerWidth = 1024;

    // Call the function
    handleResizeOnScrollablePane();

    // Assertions
    expect(scrollablePane.classList.contains('hide-horizontal-scroll')).toBe(true);
    expect(scrollablePane.style.overflow).toBe('hidden');
    expect(scrollablePane.style.overflowY).toBe('hidden');

    // Simulate the setTimeout callback
    jest.runAllTimers();

    // Assertions after setTimeout
    expect(scrollablePane.style.overflow).toBe('auto');
    expect(scrollablePane.style.overflowY).toBe('hidden');
  });

  it('should remove hide-horizontal-scroll class and adjust styles on small screens', () => {
    // Mock window.innerWidth
    global.innerWidth = 800;

    // Call the function
    handleResizeOnScrollablePane();

    // Assertions
    expect(scrollablePane.classList.contains('hide-horizontal-scroll')).toBe(false);
    expect(scrollablePane.style.overflow).toBe('scroll');
    expect(scrollablePane.style.overflowY).toBe('auto');
  });
});
