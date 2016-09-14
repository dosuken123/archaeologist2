# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# $(document).on('click', 'td[data-link]', (evt) -> 
    # window.location = this.dataset.link
# )

ready = ->
#	scrollToElement($('.history-group-<%= @group_histories.count-1 %>'));

# scrollToElement = (ele) ->
# 	$(window).scrollTop(ele.offset().top).scrollLeft(ele.offset().left)

# function scrollToElement(ele) {
#     $(window).scrollTop(ele.offset().top).scrollLeft(ele.offset().left);
# }

# Oct 29th for compatible against to dynamic DOM
# Aug 27th 2015 https://vitalets.github.io/x-editable/
# ready = ->
#   $('.editable').editable
#     mode: 'popup'


# Debug 
# paintIt = (element, backgroundColor, textColor) ->
#   element.style.backgroundColor = backgroundColor
#   if textColor?
#     element.style.color = textColor

# Debug 
# $ ->
#   $("a[data-background-color]").click ->
#     backgroundColor = $(this).data("background-color")
#     textColor = $(this).data("text-color")
#     paintIt(this, backgroundColor, textColor)

# $ ->
#  $("a[data-remote]").on "ajax:success", (e, data, status, xhr) ->
#    alert "The post was deleted."

# $("<%= escape_javascript(render @task) %>").appendTo("#tasks");

$(document).ready(ready)
$(document).on('page:load', ready)