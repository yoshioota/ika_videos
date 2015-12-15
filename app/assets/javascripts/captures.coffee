worker = ->
  return unless $('.captures')[0]
  $.ajax('/captures/captures.js', dataType: 'script')
  .done (data) =>
    setTimeout(worker, 10000)

ready = ->
  worker()

$(document).on('ready page:load', ready)

# TODO: formの下のdata-remoteを拾ってしまっている。。
$(document).on 'ajax:success', '.captures__index form#capture-form', (e)->
  return false if $(e.target).prop('tagName') != 'FORM' # FIXME: これはちょっといけてない。。
  toastr.info('削除しました')
  $.ajax('/captures/captures.js', dataType: 'script')
