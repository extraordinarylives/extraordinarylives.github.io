$(function () {
  // Init Lightbox2
  lightbox.option({
    fadeDuration: 500,
    imageFadeDuration: 0,
    resizeDuration: 250,
    maxWidth: 1200
  });

  // Init Micromodal
  (function () {
    var trigger = $('[data-micromodal-trigger]');

    if (!trigger) return;

    MicroModal.init({
      onShow: modal => console.info(`${modal.id} is shown`), // [1]
      onClose: modal => console.info(`${modal.id} is hidden`), // [2]
      disableFocus: false, // [6]
      debugMode: true // [9]
    });

    // Micromodal triggers
    $('[data-micromodal-trigger]').click(function (e) {
      e.preventDefault();
    });

  })();


  $('.js-nav-trigger').on('click', function (e) {
    e && e.preventDefault()

    $('.js-nav-menu').toggleClass('is-active');
  });
});
