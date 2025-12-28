(function () {
  const STORAGE_KEY = 'bp-theme';

  function getPreferredTheme() {
    const stored = window.localStorage.getItem(STORAGE_KEY);
    if (stored === 'light' || stored === 'dark') return stored;
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      return 'dark';
    }
    // Default to dark mode if no preference is stored
    return 'dark';
  }

  function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
  }

  const initial = getPreferredTheme();
  applyTheme(initial);

  const toggle = document.querySelector('.theme-toggle');
  if (!toggle) return;

  toggle.addEventListener('click', function () {
    const current = document.documentElement.getAttribute('data-theme') || 'dark';
    const next = current === 'light' ? 'dark' : 'light';
    applyTheme(next);
    window.localStorage.setItem(STORAGE_KEY, next);
  });
})();
