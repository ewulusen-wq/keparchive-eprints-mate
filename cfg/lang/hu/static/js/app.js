console.log("üdvözlett app.jsből")
document.addEventListener("DOMContentLoaded", function () {

    console.log("=== EPRINTS LIGHTBOX START ===");

    const docLinks = document.querySelectorAll(".ep_document_link");
    console.log("Talált document linkek:", docLinks.length);

    if (docLinks.length === 0) {
        console.log("Nincs kép az oldalon");
        return;
    }

    const images = [];

    docLinks.forEach((link, index) => {

        console.log("----");
        console.log("Link index:", index);

        const img = link.querySelector("img");

        if (!img) {
            console.log("Nincs kép a linkben");
            return;
        }

        console.log("Kép src:", img.src);

        if (img.src.includes("fileicons")) {
            console.log("Fileicon kihagyva");
            return;
        }

        images.push(img.src);
        console.log("Kép hozzáadva a galériához");

        link.addEventListener("click", function (e) {
            e.preventDefault();
            openLightbox(images.indexOf(img.src));
        });

    });

    console.log("Galéria képek:", images.length);

    let currentIndex = 0;

    function openLightbox(index) {

        console.log("Lightbox megnyitása:", index);

        currentIndex = index;

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

        console.log("Lightbox bezárva");

        const overlay = document.getElementById("ep_lightbox_overlay");
        if (overlay) overlay.remove();

        document.removeEventListener("keydown", keyControl);
    }

    function nextImage() {

        currentIndex++;

        if (currentIndex >= images.length) currentIndex = 0;

        console.log("Következő kép:", currentIndex);

        document.getElementById("ep_lightbox_img").src = images[currentIndex];
    }

    function prevImage() {

        currentIndex--;

        if (currentIndex < 0) currentIndex = images.length - 1;

        console.log("Előző kép:", currentIndex);

        document.getElementById("ep_lightbox_img").src = images[currentIndex];
    }

    function keyControl(e) {

        if (e.key === "Escape") closeLightbox();
        if (e.key === "ArrowRight") nextImage();
        if (e.key === "ArrowLeft") prevImage();
    }

    console.log("=== EPRINTS LIGHTBOX READY ===");

});