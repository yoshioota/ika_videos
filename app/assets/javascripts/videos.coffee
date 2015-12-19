$(document).on 'ajax:success', '.videos__index .destroy-btn a[data-remote]', (e)->
  toastr.info('削除しました')
  $.get('videos/search.js?capture_id=' + URI.parseQuery(URI(location.href).query())['capture_id'])

$(document).on 'click', '.date_on-today-btn', (e)->
  date = new Date()
  $('#date_year').val(date.getFullYear())
  $('#date_month').val(date.getMonth() + 1)
  $('#date_day').val(date.getDate())
  $('#date_day').change()

$(document).on 'click', '.date_on-yesterday-btn', (e)->
  date = new Date()
  date.setDate(new Date().getDate() - 1)
  $('#date_year').val(date.getFullYear())
  $('#date_month').val(date.getMonth() + 1)
  $('#date_day').val(date.getDate())
  $('#date_day').change()

$(document).on 'click', '.date_on-clear-btn', (e)->
  date = new Date()
  $('#date_year, #date_month, #date_day').val('')
  $('#date_day').change()
