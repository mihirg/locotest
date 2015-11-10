//= require is
//= require test

$('.dropdown-toggle').dropdown();
$(".level-nav-wrap ul li a").click(function(e) {
    e.preventDefault();
    $(".level-nav-wrap ul li a").addClass("selected").not(this).removeClass("selected");
});
$(".level-nav-wrap ul li").mouseenter ( function () {
    $(this).children(".level-dropdown").show().removeClass("hide").find(".slide").slideDown(200).removeClass("hide");
});
$(".level-nav-wrap ul li").mouseleave ( function () {
    $(this).children(".level-dropdown").find(".slide").slideUp(200).addClass("hide");
    $(this).children(".level-dropdown").delay(100).slideUp(100);
});
$("[rel=tooltip]").live('mouseenter', function(e){
    $(this).tooltip('show');
});
$("[rel=tooltip]").live('mouseleave', function(e){
    $(".tooltip").fadeOut();
});
$("[rel=tooltip]").live('click', function(e){
    $(".tooltip").hide();
});
$(".collapse").collapse({
    toggle: true
});
$(".toggle-plus").click (function() {
    $(this).toggleClass("active");
});
$(".expand .expand-init").click ( function (e) {
    e.preventDefault();
    $(this).parent(".expand").find(".expand-wrap").slideDown(200).addClass("block").css("height: auto");
});

$(function(){
    $("#selected-language").live('click', function(e) {
        e.preventDefault();
    });
});

$(function(){
    setWrapperHeight = function(){
        $("#wrapper").css("min-height", $("body").height() - $("footer").height() - 64);
    };
    setWrapperHeight();
    $(window).resize(setWrapperHeight);
});

// Open alien domains in a different page always.
$('a').live('click', function(e){
    source = $(e.srcElement)
    if (source.is('a') && e.srcElement.hostname
        && e.srcElement.hostname != window.location.hostname){
        source.attr('target', '_blank');
    }
});

$(function(){
    window.loadDiagramClientLibrary = function(callback) {
        if(!window.mxClient) {
            $.ajax({
                type: 'GET',
                url: window.mxClientLibraryPath,
                dataType: 'script',
                cache: true,
                success: function() {
                    callback();
                }
            });
        } else {
            callback();
        }
    };
});
