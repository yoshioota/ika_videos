$(document).on 'ajax:success', '.playlists__show .destroy-btn a[data-remote]', (e)->
  toastr.info('削除しました')
  $('.playlist-form').submit()
