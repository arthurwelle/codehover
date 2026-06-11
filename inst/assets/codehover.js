// codehover v2 — vanilla JS, no jQuery.
// Event delegation: works for any number of codehover tables per page,
// including content injected after load (e.g. reveal.js slides).
(function () {
  "use strict";

  document.addEventListener("mouseover", function (e) {
    if (!e.target || !e.target.closest) return;
    var tr = e.target.closest(".codehover tr[data-link]");
    if (!tr) return;

    var container = tr.closest(".codehover");
    var img = container.querySelector(".codehover-img img");
    var link = tr.getAttribute("data-link");
    if (img && link) img.setAttribute("src", link);

    var incremental = container.classList.contains("codehover-incremental");
    var rows = container.querySelectorAll("tr[data-link]");
    var seen = false;
    for (var i = 0; i < rows.length; i++) {
      var isCurrent = rows[i] === tr;
      if (isCurrent) seen = true;
      var on = incremental ? !seen || isCurrent : isCurrent;
      rows[i].classList.toggle("hover", on);
    }
  });
})();
