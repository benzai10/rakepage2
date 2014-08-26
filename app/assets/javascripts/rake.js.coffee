jQuery ->
  $('#leaflet-type-id').parent().hide()
  leaflet_type = $('#leaflet-type-id').html()
  $('#myrake_id').change ->
    category = $('#myrake_id :selected').val()
    rakename = $('#myrake_id :selected').text()
    options = $(leaflet_type).filter("optgroup[label=#{category}]").html()
    $('.rake-name').val(rakename)
    if options
      $('#leaflet-type-id').html(options)
      $('#leaflet-type-id').parent().show()
    else
      $('#leaflet-type-id').empty()
      $('#leaflet-type-id').parent().hide()
