import "../css/app.scss";

// Add CSRF Token on all HTMX requests
document.body.addEventListener("htmx:configRequest", (event) => {
  event.detail.headers["x-csrf-token"] = document
    .querySelector("meta[name='csrf-token']")
    .getAttribute("content");
});
