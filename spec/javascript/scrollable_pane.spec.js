import 'jest-extended';
import * as scrollablePaneModule from '../../app/javascript/scrollable_pane';

describe('handleResizeOnScrollablePane', () => {
  let scrollablePane;

  beforeEach(() => {
    jest.useFakeTimers();
    document.body.innerHTML = '<div class="moj-scrollable-pane"></div>';
    scrollablePane = document.querySelector('.moj-scrollable-pane');
  });

  afterEach(() => {
    document.body.innerHTML = '';
    jest.clearAllTimers();
    jest.restoreAllMocks();
  });

  it('should add hide-horizontal-scroll class and adjust styles on large screens', () => {
    // Mock global window width to simulate large screens
    Object.defineProperty(window, 'innerWidth', { writable: true, configurable: true, value: 1024 });

    // Call handleResizeOnScrollablePane directly
    scrollablePaneModule.handleResizeOnScrollablePane(scrollablePane);

    // Verify that the hide-horizontal-scroll class was added
    expect(scrollablePane.classList.contains('hide-horizontal-scroll')).toBe(true);

    // Verify that styles were set to hidden, and then adjusted
    expect(scrollablePane.style.overflow).toBe('hidden');
    expect(scrollablePane.style.overflowY).toBe('hidden');

    jest.runAllTimers();  // Simulate any timeouts
    expect(scrollablePane.style.overflow).toBe('auto');
    expect(scrollablePane.style.overflowY).toBe('hidden');
  });

  it('should remove hide-horizontal-scroll class and adjust styles on small screens', () => {
    // Mock global window width to simulate small screens
    Object.defineProperty(window, 'innerWidth', { writable: true, configurable: true, value: 800 });

    // Call handleResizeOnScrollablePane directly
    scrollablePaneModule.handleResizeOnScrollablePane(scrollablePane);

    // Verify that the hide-horizontal-scroll class was removed
    expect(scrollablePane.classList.contains('hide-horizontal-scroll')).toBe(false);

    // Verify that styles were set to scroll for both axes
    expect(scrollablePane.style.overflow).toBe('scroll');
    expect(scrollablePane.style.overflowY).toBe('auto');
  });
});

describe('checkAndHandleResizeOnScrollablePane', () => {
  let scrollablePane;

  beforeEach(() => {
    jest.useFakeTimers();
    document.body.innerHTML = '<div class="moj-scrollable-pane"></div>';
  });

  afterEach(() => {
    document.body.innerHTML = '';
    jest.clearAllTimers();
    jest.restoreAllMocks();
  });

  it('should not call handleResizeOnScrollablePane if moj-scrollable-pane is not present', () => {
    // Mock the handleResizeOnScrollablePane function
    const handleResizeOnScrollablePaneMock = jest.spyOn(scrollablePaneModule, 'handleResizeOnScrollablePane');

    // Clear the DOM
    document.body.innerHTML = '';

    // Execute the check function which should not call the mocked handleResizeOnScrollablePane
    scrollablePaneModule.checkAndHandleResizeOnScrollablePane();

    // Verify that the mock was not called
    expect(handleResizeOnScrollablePaneMock).not.toHaveBeenCalled();
  });
});
