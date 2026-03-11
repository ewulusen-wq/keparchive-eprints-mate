console.log("üdvözlett app.jsből - EPrints Lightbox");

// Várjuk, hogy az oldal betöltődjön
document.addEventListener("DOMContentLoaded", function () {

    console.log("=== EPRINTS LIGHTBOX START ===");

    // minden dokumentum link a találati oldalon
    const docLinks = document.querySelectorAll(".ep_document_link");
    console.log("Talált document linkek:", docLinks.length);

    if (docLinks.length === 0) return;

    const images = [];

    docLinks.forEach(link => {
        // nagy előnézeti kép
        const previewDiv = link.nextElementSibling; // ep_preview div
        if (!previewDiv) return;

        const img = previewDiv.querySelector("img.ep_preview_image");
        if (!img) return;

        images.push(img.src);

        // kattintáskor lightbox nyitás
        link.addEventListener("click", function (e) {
            e.preventDefault();
            openLightbox(images.indexOf(img.src));
        });
    });

    let currentIndex = 0;

    function openLightbox(index) {
        currentIndex = index;

        // overlay létrehozása
        const overlay = document.createElement("div");
        overlay.id = "ep_lightbox_overlay";
        overlay.innerHTML = `
            <span id="ep_lightbox_close">✕</span>
            <span id="ep_lightbox_prev">❮</span>
            <img id="ep_lightbox_img">
            <span id="ep_lightbox_next">❯</span>
        `;
        document.body.appendChild(overlay);

        const img = document.getElementById("ep_lightbox_img");
        img.src = images[currentIndex];

        document.getElementById("ep_lightbox_close").onclick = closeLightbox;
        document.getElementById("ep_lightbox_prev").onclick = prevImage;
        document.getElementById("ep_lightbox_next").onclick = nextImage;

        document.addEventListener("keydown", keyControl);
    }

    function closeLightbox() {
        const overlay = document.getElementById("ep_lightbox_overlay");
        if (overlay) overlay.remove();
        document.removeEventListener("keydown", keyControl);
    }

    function nextImage() {
        currentIndex = (currentIndex + 1) % images.length;
        document.getElementById("ep_lightbox_img").src = images[currentIndex];
    }

    function prevImage() {
        currentIndex = (currentIndex - 1 + images.length) % images.length;
        document.getElementById("ep_lightbox_img").src = images[currentIndex];
    }

    function keyControl(e) {
        if (e.key === "Escape") closeLightbox();
        if (e.key === "ArrowRight") nextImage();
        if (e.key === "ArrowLeft") prevImage();
    }

    console.log("=== EPRINTS LIGHTBOX READY ===");
});