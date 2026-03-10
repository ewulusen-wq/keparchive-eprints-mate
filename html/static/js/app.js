document.addEventListener("DOMContentLoaded", function() {

    console.log("🎬 Fancybox lightbox script elindult");

    // 1. Keresd meg az összes dokumentum linket
    const docLinks = document.querySelectorAll('.ep_document_link');
    console.log("📸 Találtam dokumentum linkeket:", docLinks.length);

    if(docLinks.length === 0) {
        console.log("❌ Nincs dokumentum link, kilépek");
        return;
    }

    // 2. Hozz létre egy konténert a lightbox thumb-eknek
    const container = document.createElement('div');
    container.className = 'ep_lightbox_container';
    document.body.prepend(container); // a body elejére
    console.log("📦 Konténer létrehozva és hozzáadva a body-hoz");

    // 3. Minden linkből csak a képet szedjük ki
    const images = [];
    docLinks.forEach((link, index) => {
        const img = link.querySelector('img');
        if(img) {
            console.log(`🖼️ Kép ${index + 1}: ${img.src}`);
            images.push({
                src: img.src.replace('.hassmallThumbnailVersion',''), // nagyobb kép, ha van
                caption: img.alt || `Document ${index+1}`
            });

            // thumbnail a konténerbe
            const thumb = document.createElement('img');
            thumb.src = img.src;
            thumb.className = 'ep_lightbox_thumb';
            thumb.alt = img.alt || `Document ${index+1}`;

            // kattintás indul a lightbox
            thumb.addEventListener('click', function(e) {
                e.preventDefault(); // ne nyíljon meg az eredeti link
                console.log("🖱️ Kattintás a thumb-on, Fancybox megnyitása...");
                Fancybox.show(
                    images.map(imgObj => ({
                        src: imgObj.src,
                        type: 'image',
                        caption: imgObj.caption
                    })),
                    {
                        infinite: true,
                        Carousel: {
                            friction: 0.95,
                            preload: 1
                        }
                    }
                );
            });

            container.appendChild(thumb);
        }
    });

    console.log("✅ Script befejezve. Összesen " + images.length + " kép feldolgozva.");

});
