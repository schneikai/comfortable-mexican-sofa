window.CMS ?= {}

window.CMS.files = ->
  window.CMS.filesLibrary = new window.CMS.FilesLibrary

  # Open the files library.
  $(document).on 'click', '.cms-files-open', (e) ->
    window.CMS.filesLibrary.open($(this).data(), e)
    e.preventDefault()

  # When clicking a file path in the file list select it to make it easy to copy&paste.
  $(document).on 'click', '.cms-uploader-filelist input[type=text]', ->
    $(this).select()

  # Remove a page file.
  $(document).on 'click', '.cms-page-file-delete', (e) ->
    if confirm $(this).data('ask')
      $("input[name='" + $(this).data('fieldName') + "']").removeAttr('value')

      fileList = $(this).closest('.page-files')

      $(this).closest('.page-file').fadeOut 'slow', ->
        $(this).remove()

        if fileList.find('.page-file').length < 2
          fileList.find('> .cms-files-open').show()
        else
          fileList.find('> .cms-files-open').hide()

    e.preventDefault()


# This method is called when the files library is in select mode and a file was selected.
# file: fileId, fileLabel, fileUrl, file_thumbnail, fileIsImage
# elm: jQuery object of the element that was clicked to open the files library (aka browse button)
window.selectCMSPageFile = (file, elm) ->
  $("input[name='" + elm.data('fieldName') + "']").val(file.fileId)

  fileList = elm.closest('.page-files')

  entry = fileList.find('.page-file').first().clone()
  entry.attr('id', entry.attr('id') + file.fileId)
  entry.find('.thumbnail').attr('href', file.fileUrl)
  entry.find('.thumbnail img').attr('src', file.fileThumbnail) if file.fileIsImage
  entry.find('.file-label').text(file.fileLabel)
  entry.find('.cms-files-open').data(elm.data())
  entry.find('.cms-page-file-delete').data('fieldName', elm.data('fieldName'))

  # The browse button is either a "replace the current file" or a "add a new file" button...
  if elm.parent().hasClass('page-file')
    elm.parent().replaceWith entry.show()
  else
    fileList.append entry.fadeIn('slow')

  fileList.find('> .cms-files-open').hide()


# When the files library is opened in a modal window we need to remove the
# left and right columns. Triggering this early to prevent flicker.
$('body').ready ->
  in_iframe = ->
    try
      return window.self != window.top
    catch e
      return true

  if in_iframe() && $('body.c-comfy-admin-cms-files').length > 0
    $('body').addClass('in-iframe')
