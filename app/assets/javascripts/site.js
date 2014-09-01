$(function() {

    $(window).scroll(function(){
        // add navbar opacity on scroll
        // if ($(this).scrollTop() > 100) {
        //     $(".navbar.navbar-fixed-top").addClass("scroll");
        // } else {
        //     $(".navbar.navbar-fixed-top").removeClass("scroll");
        // }

        // global scroll to top button
        if ($(this).scrollTop() > 300) {
            $('.scrolltop').fadeIn();
        } else {
            $('.scrolltop').fadeOut();
        }
    });

    // scroll navigation functionality
    $('.scrolltop').click(function(){
        var section = $($(this).data("section"));
        //(alert(section);
        //var top = section.offset().top;
        $("html, body").animate({ scrollTop: 0 }, 700);
        return false;
    });


   // scroll to learn more
    $('.scrolllearn').click(function(){
        $("html, body").animate({ scrollTop: $(this).offset().top }, 700);
        return false;
    });

    $(".leaflet-save").click(function() {
        var leafletid = $(this).data('id');
        var leaflettitle = $(this).data('title');
        var collapse = $(this).data('collapse');
        $(".leaflet-id").val(leafletid);
        $(".leaflet-custom-title").val(leaflettitle);
        $(".collapse-section").val(collapse);
    });

    $(".leaflet-edit").click(function() {
        var leafletid = $(this).data('id');
        var leaflettitle = $(this).data('title');
        var heapId = $(this).data('heapid');
        var leafletdescription = $(this).data('description');
        var leafleturl = $(this).data('url');
        var collapse = $(this).data('collapse');
        $(".leaflet-id").val(leafletid);
        $(".leaflet-custom-title").val(leaflettitle);
        $(".heap-id").val(heapId);
        $(".leaflet-description").val(leafletdescription)
        $(".leaflet-url").val(leafleturl);
        $(".collapse-section").val(collapse);
    });

    $(".leaflet-create").click(function() {
        var leafletTypeId = $(this).data('typeid');
        var heapId = $(this).data('heapid');
        var collapse = $(this).data('collapse');
        $(".leaflet-type-id").val(leafletTypeId);
        $(".heap-id").val(heapId);
        $(".collapse-section").val(collapse);
    });

    $(".leaflet-move").click(function() {
        var leafletid = $(this).data('id');
        var heapId = $(this).data('heapid');
        $(".leaflet-id").val(leafletid);
        $(".heap-id").val(heapId);
    });

    $(".leaflet-master-save").click(function() {
        var leafletid = $(this).data('id');
        $(".leaflet-id").val(leafletid);
    });


    $(".masterrake-create").click(function() {
        var categoryId = $(this).data('category');
        var userId = $(this).data('user');
        $(".category-id").val(categoryId);
        $(".created-by").val(userId);
        if (categoryId != "none") {
            $(".category-select").hide();
        }
    });

    $(".rake-create").click(function() {
        var categoryId = $(this).data('category');
        var userId = $(this).data('user');
        $(".category-id").val(categoryId);
        $(".created-by").val(userId);
        if (categoryId != "none") {
            $(".category-select").hide();
        }
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

        var id = $(this).attr("value")

        var element = $(".v_count_" + id);
        var sum = parseInt(element.text().slice(element.text().indexOf(":")+1,element.text().length).trim()) + 1;
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
        
        var id = $(this).attr("value")

        var element = $(".l_count_" + id);
        var sum = parseInt(element.text().slice(element.text().indexOf(":")+1,element.text().length).trim()) + 1;
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

    $('.load-rake').click(function() {
        var id = $(this).attr("value");
        $('#load-rake-' + id).html("<i class='fa fa-spinner fa-spin'></i>");
    });

    $('.add-subreddit-feed').click(function() {
        if (screen.width < 1024) {
          $('body').removeClass('nav-expanded');
        };
    });

    $('.add-rss-feed').click(function() {
        if (screen.width < 1024) {
          $('body').removeClass('nav-expanded');
        };
    });

    $('.excerpt-more').hide();

});

