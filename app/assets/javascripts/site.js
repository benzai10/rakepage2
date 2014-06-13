$(function() {

   // scroll to learn more
    $('.scrolllearn').click(function(){
        $("html, body").animate({ scrollTop: $(this).offset().top }, 700);
        return false;
    });

    $(".leaflet-save").click(function() {
        var leafletid = $(this).data('id');
        var leaflettitle = $(this).data('title');
        $(".leaflet-id").val(leafletid);
        $(".leaflet-custom-title").val(leaflettitle);
    });

    $(".leaflet-create").click(function() {
        var leafletTypeId = $(this).data('typeid');
        var heapId = $(this).data('heapid');
        $(".leaflet-type-id").val(leafletTypeId);
        $(".heap-id").val(heapId);
    });

    $(".masterrake-create").click(function() {
        var categoryId = $(this).data('category');
        var userId = $(this).data('user');
        $(".category-id").val(categoryId);
        $(".created-by").val(userId);
    });

    $(".add-rss-feed").click(function() {
        var rakeId = $(this).data('rakeid');
        var channelType = $(this).data('channeltype');
        $(".rake-id-rss").val(rakeId);
        $(".channel-type-rss").val(channelType);
    });

    $(".add-subreddit-feed").click(function() {
        var rakeId = $(this).data('rakeid');
        var channelType = $(this).data('channeltype');
        $(".rake-id-subreddit").val(rakeId);
        $(".channel-type-subreddit").val(channelType);
    });

    $('input.tokenize').tokenfield();

   //Navigation Menu Slider
    $('#nav-expander').on('click',function(e){
      e.preventDefault();
      $('body').toggleClass('nav-expanded');
    });
    $('#nav-close').on('click',function(e){
      e.preventDefault();
      $('body').removeClass('nav-expanded');
    });

    // Initialize navgoco with default options
    // $(".main-menu").navgoco({
    //     caret: '<span class="caret"></span>',
    //     accordion: false,
    //     openClass: 'open',
    //     save: true,
    //     cookie: {
    //         name: 'navgoco',
    //         expires: false,
    //         path: '/'
    //     },
    //     slide: {
    //         duration: 300,
    //         easing: 'swing'
    //     }
    // });

    //When click on view
    $('.external').click(function() {

        id = $(this).attr("value")

        element = $(".v_count_" + id);
        sum = parseInt(element.text().slice(element.text().indexOf(":")+1,element.text().length).trim()) + 1;
        element.text(sum);

        $.ajax({
            url: "/leaflets/view_add",
            type: "POST",
            data: {leaflet: {
            id: $(this).attr("value") }},
        success: function(resp){ }
        });
    });

    //When click on heart
    $('.like').bind("click", function() {
        
        id = $(this).attr("value")

        element = $(".l_count_" + id);
        sum = parseInt(element.text().slice(element.text().indexOf(":")+1,element.text().length).trim()) + 1;
        element.text(sum);

        $('#feed-heart-icon-' + id).html("<i class='fa fa-heart'></i>");

        $.ajax({
            url: "/leaflets/like_add",
            type: "POST",
            data: {leaflet: {
            id: $(this).attr("value") }},
        success: function(resp){ }
        });
    });

    $('#refresh-link').click(function() {
        $('#refresh-link').html("<i class='fa fa-spinner fa-spin'></i>");
    });
    
    $('#saved-refresh-link').click(function() {
        $('#saved-refresh-link').html("<i class='fa fa-spinner fa-spin'></i>");
    });

    $('.rake_title').click(function() {
        $('.leaflet-list').html("<i class='fa fa-spinner fa-spin'></i>");
    });

    $('#refresh-icon').click(function() {
        $('#refresh-icon').html("<i class='fa fa-refresh fa-spin'></i>");
    });

    $('.refresh-button').click(function() {
        $('#refresh-icon').html("<i class='fa fa-refresh fa-spin'></i>");
    });


    $('.excerpt-more').hide();
});
