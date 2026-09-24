(function () {
  var btn = document.getElementById('themetoggle');
  if (!btn) return;
  var root = document.documentElement;

  function current() {
    var set = root.getAttribute('data-theme');
    if (set) return set;
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }

  btn.addEventListener('click', function () {
    var next = current() === 'dark' ? 'light' : 'dark';
    root.setAttribute('data-theme', next);
    try { localStorage.setItem('rb-theme', next); } catch (e) {}
    if (document.querySelector('.mermaid')) location.reload();
  });
})();
