worker = ->
  return unless $('.captures')[0]
  $.ajax('/captures/captures.js', dataType: 'script')
  .done (data) =>
    setTimeout(worker, 10000)

ready = ->
  worker()

$(document).on('ready page:load', ready)

$(document).on 'ajax:success', '.captures__index .capture-form', (e)->
  toastr.info('削除しました')
  $.ajax('/captures/captures.js', dataType: 'script')
