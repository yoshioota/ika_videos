$(document).on 'ajax:success', '.videos__index .destroy-btn a[data-remote]', (e)->
  toastr.info('削除しました')
  $.get('videos/search.js?capture_id=' + URI.parseQuery(URI(location.href).query())['capture_id'])
