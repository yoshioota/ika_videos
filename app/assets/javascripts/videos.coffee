$(document).on 'ajax:success', '.videos__index a[data-remote]', (e)->
  toastr.info('削除しました')
  $.get('videos/search.js')
