// Generated by CoffeeScript 1.3.3
(function() {

  $(document).ready(function() {
    return $('div').hide();
  });

  $(window).load(function() {
    var desc, logo, soon;
    logo = $('#logo');
    soon = $('#soon');
    desc = $('#desc');
    logo.fadeIn(1600);
    soon.fadeIn(1600);
    return desc.delay(100).fadeIn(800);
  });

}).call(this);