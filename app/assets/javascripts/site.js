$(function() {

    //When link on mood
    $('.external').click(function() {

        id = $(this).attr("value")

        element = $(".v_count_" + id);
        sum = parseInt(element.text().slice(element.text().indexOf(":")+1,element.text().length).trim()) + 1;
        element.text(" view count: " + sum);

        $.ajax({
            url: "/leaflets/view_add",
            type: "POST",
            data: {leaflet: {
            id: $(this).attr("value") }},
        success: function(resp){ }
        });
    });
});
