// codehover — vanilla JS, no jQuery.
// Event delegation: works for any number of codehover tables per page,
// including content injected after load (e.g. reveal.js slides).
// Rows react to hover (mouse), tap (touch) and focus/arrow keys (keyboard).
(function () {
  "use strict";

  function rowFromEvent(e) {
    if (!e.target || !e.target.closest) return null;
    return e.target.closest(".codehover tr[data-link]");
  }

  function activate(tr) {
    var container = tr.closest(".codehover");
    if (!container) return;

    var img = container.querySelector(".codehover-img img");
    var link = tr.getAttribute("data-link");
    if (img && link) {
      var alt = tr.getAttribute("data-alt");
      img.setAttribute("src", link);
      if (alt !== null) img.setAttribute("alt", alt);
    }

    var incremental = container.classList.contains("codehover-incremental");
    var rows = container.querySelectorAll("tr[data-link]");
    var seen = false;
    for (var i = 0; i < rows.length; i++) {
      var isCurrent = rows[i] === tr;
      if (isCurrent) seen = true;
      var on = incremental ? !seen || isCurrent : isCurrent;
      rows[i].classList.toggle("hover", on);
    }
  }

  function onPoint(e) {
    var tr = rowFromEvent(e);
    if (tr) activate(tr);
  }

  document.addEventListener("mouseover", onPoint);
  // Tap on touch devices, and click for mouse users who prefer clicking.
  document.addEventListener("click", onPoint);
  // Keyboard: rows are focusable (tabindex="0" set by ch_row()).
  document.addEventListener("focusin", onPoint);

  document.addEventListener("keydown", function (e) {
    if (e.key !== "ArrowDown" && e.key !== "ArrowUp" &&
        e.key !== "Enter" && e.key !== " ") return;

    var tr = rowFromEvent(e);
    if (!tr) return;

    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      activate(tr);
      return;
    }

    var container = tr.closest(".codehover");
    if (!container) return;
    var rows = container.querySelectorAll("tr[data-link]");
    var idx = Array.prototype.indexOf.call(rows, tr);
    var next = rows[idx + (e.key === "ArrowDown" ? 1 : -1)];
    if (!next) return;
    e.preventDefault();
    next.focus();          // focusin then activates it
  });
})();
