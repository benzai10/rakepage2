$(function() {

    jQuery(function() {
      var tz = jstz.determine();
      $.cookie('timezone', tz.name(), { path: '/' });
    });

    $(".label-score-0").on('click', function() {
        var currentScore = $(".current-score").val();
        if (currentScore == "1") {
            $(".current-score").val(0);
            var newMotionCounter = parseInt($(".motion-counter").html()) - 1;
            $(".motion-counter").html(newMotionCounter.toString());
        } else if (currentScore == "2") {
            $(".current-score").val(0);
            var newActionCounter = parseInt($(".action-counter").html()) - 1;
            $(".action-counter").html(newActionCounter.toString());
        } else {
            $(".current-score").val(0);
        }
    });

    $(".label-score-1").on('click', function() {
        var currentScore = $(".current-score").val();
        if (currentScore == "2") {
            $(".current-score").val(1);
            var newActionCounter = parseInt($(".action-counter").html()) - 1;
            $(".action-counter").html(newActionCounter.toString());
            var newMotionCounter = parseInt($(".motion-counter").html()) + 1;
            $(".motion-counter").html(newMotionCounter.toString());
        } else if (currentScore != "1") {
            var newMotionCounter = parseInt($(".motion-counter").html()) + 1;
            $(".motion-counter").html(newMotionCounter.toString());
            $(".current-score").val(1);
        }
    });

    $(".label-score-2").on('click', function() {
        var currentScore = $(".current-score").val();
        if (currentScore == "1") {
            $(".current-score").val(2);
            var newMotionCounter = parseInt($(".motion-counter").html()) - 1;
            $(".motion-counter").html(newMotionCounter.toString());
            var newActionCounter = parseInt($(".action-counter").html()) + 1;
            $(".action-counter").html(newActionCounter.toString());
        } else if (currentScore != "2") {
            var newActionCounter = parseInt($(".action-counter").html()) + 1;
            $(".action-counter").html(newActionCounter.toString());
            $(".current-score").val(2);
        }
    });

    $("#setReminderModal").on('shown.bs.modal', function(){
        $('.history-chain').attr('checked', false);
        $('.task-comment').val('');
        $('.reminderat').val(1);
    });

    $("#newLeafletModal").on('shown.bs.modal', function(){
        $('.history-chain').attr('checked', false);
        $('.task-comment').val('');
        $('.reminderat').val(1);
    });

    $("#myModal").on('shown.bs.modal', function(){
        $('.history-chain').attr('checked', false);
        $('.task-comment').val('');
        $('.reminderat').val(1);
    });

    $("#editLeafletModal").on('shown.bs.modal', function(){
        $('.history-chain').attr('checked', false);
        $('.task-comment').val('');
        $('.reminderat').val(1);
        $('.current-score').val(0);
        $(".label-score-1").removeClass("active");
        $(".label-score-2").removeClass("active");
        $(".label-score-0").addClass("active");
    });

    $('.add-recommendation-form').hide();

    $('.add-recommendation').click(function(){
        $('.add-recommendation-form').show();
        ga('send', 'event', 'button', 'click', 'add-bookmark');
        return false;
    });

    $('.create-rake-info').hide();

    $('#create-rake-info').click(function(){
        if ($('#create-rake-toggle').html().indexOf("Create Rake") > 0) {
            $('.master-rake-content').hide();
            $('.create-rake-info').show();
            $('#create-rake-toggle').html('<i class="fa fa-long-arrow-right white"></i>' + 'Back');
        } else {
            $('.create-rake-info').hide();
            $('.master-rake-content').show();
            $('#create-rake-toggle').html('<i class="fa fa-plus white"></i>' + 'Create Rake');
        }
    });

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
            $('.navbar').fadeOut();
        } else {
            $('.scrolltop').fadeOut();
            $('.navbar').fadeIn();
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
    // $('.scrolllearn').click(function(){
    //     $("html, body").animate({ scrollTop: $(this).offset().top }, 700);
    //     return false;
    // });

    // scroll to tab pane
    function scrollToAnchor(aid){
        var aTag = $("a[name='"+ aid +"']");
        $('html,body').animate({scrollTop: aTag.offset().top},'slow');
    };

    $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
        var eth = e.target.href;
        var anchorname = eth.substring(eth.indexOf('#') + 1, eth.length);
        scrollToAnchor(anchorname);
        $('.add-recommendation-form').hide();
    });

    $(".leaflet-save").click(function() {
        var leafletid = $(this).data('id');
        var leaflettitle = $(this).data('title');
        var collapse = $(this).data('collapse');
        var heapid = $(this).data('heapid');
        var rakename = $(this).data('rakename');
        $(".leaflet-id").val(leafletid);
        $(".leaflet-custom-title").val(leaflettitle);
        $(".collapse-section").val(collapse);
        $(".heap-id").val(heapid);
        $(".rake-name").val(rakename);
        ga('send', 'event', 'button', 'click', 'leaflet-save');
    });

    $(".leaflet-edit").click(function() {
        var leafletid = $(this).data('id');
        var leaflettitle = $(this).data('title');
        var heapId = $(this).data('heapid');
        var leafletdescription = $(this).data('description');
        var leafleturl = $(this).data('url');
        var leafletgoal = $(this).data('goal');
        var leafletnote = $(this).data('note');
        var motioncount = $(this).data('motioncount');
        var actioncount = $(this).data('actioncount');
        var scheduledcount = $(this).data('scheduledcount');
        var collapse = $(this).data('collapse');
        var reminderat = $(this).data('reminder');
        var origin = $(this).data('origin');
        var rating = $(this).data('rating');
        var arrayRatingStars = $(".rating-input .fa");
        for (var i = 0; i < arrayRatingStars.length; i++) {
            if (i < parseInt(rating)) {
                arrayRatingStars[i].classList.remove('fa-star-o');
                arrayRatingStars[i].classList.add('fa-star');
            }
            else {
                arrayRatingStars[i].classList.remove('fa-star');
                arrayRatingStars[i].classList.add('fa-star-o');
            }
        }
        $(".leaflet-id").val(leafletid);
        $(".leaflet-custom-title").val(leaflettitle);
        $(".heap-id").val(heapId);
        $(".leaflet-description").val(leafletdescription)
        $(".leaflet-url").val(leafleturl);
        $(".leaflet-goal").val(leafletgoal);
        $(".leaflet-note").val(leafletnote);
        $(".collapse-section").val(collapse);
        $(".origin").val(origin);
        $(".rating").val(rating);
        $(".motion-counter").html(motioncount.toString());
        $(".action-counter").html(actioncount.toString());
        ga('send', 'event', 'button', 'click', 'leaflet-edit');
    });

    $(".leaflet-create").click(function() {
        var leafletTypeId = $(this).data('typeid');
        var heapId = $(this).data('heapid');
        var collapse = $(this).data('collapse');
        var elementId = "url-" + leafletTypeId;
        var url = document.getElementById("url-" + leafletTypeId).value;
        $(".leaflet-type-id").val(leafletTypeId);
        $(".leaflet-custom-title").val("");
        $(".heap-id").val(heapId);
        $(".collapse-section").val(collapse);
        $(".leaflet-url").val(url);
        $("#current-score").val(0);
        $("#label-score-0-new").addClass("active");
        $("#label-score-1-new").removeClass("active");
        $("#label-score-2-new").removeClass("active");
        var arrayRatingStars = $(".rating-input .fa");
        for (var i = 0; i < arrayRatingStars.length; i++) {
            arrayRatingStars[i].classList.remove('fa-star');
            arrayRatingStars[i].classList.add('fa-star-o');
        }
        ga('send', 'event', 'button', 'click', 'leaflet-create');
    });

    $(".leaflet-copy").click(function() {
        var leafletid = $(this).data('id');
        var heapId = $(this).data('heapid');
        $(".leaflet-id").val(leafletid);
        $(".heap-id").val(heapId);
        ga('send', 'event', 'button', 'click', 'leaflet-copy');
    });

    $(".leaflet-master-save").click(function() {
        var leafletid = $(this).data('id');
        $(".leaflet-id").val(leafletid);
    });

    $(".leaflet-master-edit").click(function() {
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
        ga('send', 'event', 'master-rakes-index', 'add-new-master-rake', 'new-master-rake');
    });

    $(".rake-create").click(function() {
        var categoryId = $(this).data('category');
        var userId = $(this).data('user');
        $(".category-id").val(categoryId);
        $(".created-by").val(userId);
        if (categoryId != "none") {
            $(".category-select").hide();
        }
        ga('send', 'event', 'button', 'click', 'rake-create');
    });

    $(".panel-top-rake").on("shown.bs.collapse", function () {
        var selected = $(this);
        var collapseh = $(".collapse .in").height();
        $("html, body").animate({ scrollTop: selected - collapseh }, 700);
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
        ga('send', 'event', 'link', 'click', 'external');

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
        ga('send', 'event', 'button', 'click', 'refresh');
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

    $('.sign-in-label').click(function() {
        ga('send', 'event', 'landing-page', 'sign-in-label', 'sign-in');
    });

    $('.sign-in-icon').click(function() {
        ga('send', 'event', 'landing-page', 'sign-in-icon', 'sign-in');
    });

    $('#sign-up').click(function() {
        ga('send', 'event', 'landing-page', 'sign-up-button', 'sign-up');
    });

    $('#take-a-look').click(function() {
        ga('send', 'event', 'landing-page', 'take-a-look-button', 'take-a-look');
    });

    $('#my-bookmarking-rakes').click(function() {
        ga('send', 'event', 'master-rakes-index', 'nav', 'my-bookmarking-rakes');
    });

    $('#master-rakes-sign-in').click(function() {
        ga('send', 'event', 'master-rakes-index', 'sign-in-link', 'sign-in');
    });

    $('#view-new-master-rakes').click(function() {
        ga('send', 'event', 'master-rakes-index', 'view', 'new-master-rakes');
    });

    $('#view-featured-master-rakes').click(function() {
        ga('send', 'event', 'master-rakes-index', 'view', 'featured-master-rakes');
    });

    $('#view-all-master-rakes').click(function() {
        ga('send', 'event', 'master-rakes-index', 'view', 'all-master-rakes');
    });

    $('#master-rake-sign-in').click(function() {
        ga('send', 'event', 'master-rake-show', 'sign-in-link', 'sign-in');
    });

    $('#ga-my-bookmarking-rakes').click(function() {
        ga('send', 'event', 'master-rake-show', 'nav', 'my-bookmarking-rakes');
    });

    $('#view-master-rakes-index').click(function() {
        ga('send', 'event', 'master-rake-show', 'nav', 'all-master-rakes');
    });

    $('#view-personal-rake').click(function() {
        ga('send', 'event', 'master-rake-show', 'nav', 'view-personal-rake');
    });

    $('#create-personal-rake').click(function() {
        ga('send', 'event', 'master-rake-show', 'nav', 'create-personal-rake');
    });

    $('#view-related-rakes').click(function() {
        ga('send', 'event', 'master-rake-show', 'view', 'view-related-rakes');
    });

    $('#view-news').click(function() {
        ga('send', 'event', 'master-rake-show', 'view', 'news');
    });

    $('#view-channels').click(function() {
        ga('send', 'event', 'master-rake-show', 'view', 'channels');
    });

    $('#ga-feed-refresh').click(function() {
        ga('send', 'event', 'master-rake-show', 'click', 'news-refresh');
    });

    $('#ga-feed-refresh-sign-in').click(function() {
        ga('send', 'event', 'master-rake-show', 'click', 'news-refresh-sign-in');
    });

    $('#ga-create-personal-rake-to-bookmark').click(function() {
        ga('send', 'event', 'button', 'click', 'ga-create-personal-rake-to-bookmark');
    });

    $('#ga-sign-in-to-bookmark').click(function() {
        ga('send', 'event', 'master-rake-show', 'sign-in-link', 'sign-in-to-bookmark');
    });

    $('#ga-all-bookmarking-rakes').click(function() {
        ga('send', 'event', 'my-rakes-index', 'nav', 'all-master-rakes');
    });

    $('#ga-view-myrakes').click(function() {
        ga('send', 'event', 'my-rakes-index', 'view', 'all-my-rakes');
    });

    $('#ga-view-reminders').click(function() {
        ga('send', 'event', 'my-rakes-index', 'view', 'reminders');
    });

    $('#ga-view-all-rakes').click(function() {
        ga('send', 'event', 'my-rakes-index', 'view', 'all-master-rakes');
    });

    $('#ga-my-bookmarking-rakes-index').click(function() {
        ga('send', 'event', 'my-rake-show', 'nav', 'my-bookmarking-rakes');
    });

    $('#ga-all-master-rakes').click(function() {
        ga('send', 'event', 'my-rake-show', 'nav', 'all-master-rakes');
    });

    $('#my-rakes-sign-in').click(function() {
        ga('send', 'event', 'my-rake-show', 'sign-in-link', 'sign-in');
    });

    $('#view-master-rake').click(function() {
        ga('send', 'event', 'my-rake-show', 'nav', 'view-master-rake');
    });

    $('#ga-related-rakes').click(function() {
        ga('send', 'event', 'my-rake-show', 'view', 'view-related-rakes');
    });

    $('#ga-feed').click(function() {
        ga('send', 'event', 'my-rake-show', 'view', 'news');
    });

    $('#ga-channels').click(function() {
        ga('send', 'event', 'my-rake-show', 'view', 'channels');
    });

    $('#ga-my-feed-refresh').click(function() {
        ga('send', 'event', 'my-rake-show', 'click', 'news-refresh');
    });

    $('#ga-my-feed-refresh-sign-in').click(function() {
        ga('send', 'event', 'my-rake-show', 'click', 'news-refresh-sign-in');
    });

    $('#ga-my-sign-in-to-bookmark').click(function() {
        ga('send', 'event', 'my-rake-show', 'sign-in-link', 'sign-in-to-bookmark');
    });


    $('.excerpt-more').hide();

});

