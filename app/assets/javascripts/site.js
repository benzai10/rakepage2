$(function() {

    $(".leaflet-save").click(function() {
        var leafletid = $(this).data('id');
        var leaflettitle = $(this).data('title');
        $(".leaflet-id").val(leafletid);
        $(".leaflet-custom-title").val(leaflettitle);
    });

    $(".leaflet-create").click(function() {
        var leafletTypeId = $(this).data('typeid');
        // var heapId = $(this).data('heap_id');
        $(".leaflet-type-id").val(leafletTypeId);
        // $(".heap-id").val(heapId);
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

    //When link on mood
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

    $('#refresh-link').click(function() {
        $('#refresh-link').html("<i class='fa fa-spinner fa-spin'></i>");
    });
    
    $('#saved-refresh-link').click(function() {
        $('#saved-refresh-link').html("<i class='fa fa-spinner fa-spin'></i>");
    });

    $('.rake_title').click(function() {
        $('.leaflet-list').html("<i class='fa fa-spinner fa-spin'></i>");
    });


});
