# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  Dropzone.autoDiscover = false
  dz = new Dropzone("#new_msg", {
    maxFileSize: 100,
    uploadMultiple: false,
    dictDefaultMessage: '',
    dictResponseError: 'Error while uploading file!',
    addRemoveLinks: false
    # init: ->
    #   this.on "error", (file, response) ->
    #     alert(response)
    })
  dz.on "success", (file, response) -> 
    window.location = response.msgs_path
  dz.on "error", (file, response) ->
    $('.dz-progress').hide()
    $('.dz-error-mark').hide()
    $('.dz-error-message').hide()
    $('.dz-filename').hide()
    $('.dz-size').hide()
    $('#error-alert-text').html response.join('<br>')
    $('#error-alert').fadeIn(1000)
    console.log "error"
    console.log response

$(document).ready(ready)
#$(document).on('page:load', ready)


