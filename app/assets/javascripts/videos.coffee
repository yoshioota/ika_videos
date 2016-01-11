$(document).on 'ajax:success', '.videos__index .destroy-btn a[data-remote]', (e)->
  toastr.info('削除しました')
  $.get('videos/search.js?capture_id=' + URI.parseQuery(URI(location.href).query())['capture_id'])

$(document).on 'click', '.date_on-today-btn', (e)->
  date = new Date()
  $('#date_on_year').val(date.getFullYear())
  $('#date_on_month').val(date.getMonth() + 1)
  $('#date_on_day').val(date.getDate())
  $('#date_on_day').change()

$(document).on 'click', '.date_on-yesterday-btn', (e)->
  date = new Date()
  date.setDate(new Date().getDate() - 1)
  $('#date_on_year').val(date.getFullYear())
  $('#date_on_month').val(date.getMonth() + 1)
  $('#date_on_day').val(date.getDate())
  $('#date_on_day').change()

$(document).on 'click', '.date_on-clear-btn', (e)->
  date = new Date()
  $('#date_on_year, #date_on_month, #date_on_day').val('')
  $('#date_on_day').change()

$(document).on 'ready page:load', (e) ->
  return unless $('.videos__index')[0]
  $.get('/videos.js')
