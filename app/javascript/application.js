import '@hotwired/turbo-rails'
import 'controllers'
import './jquery'
import './jquery_ujs'
import './dataTables/jquery.dataTables'
import './cocoon'

$(document).ready(function(){
  $(".dataTables_filter label input[type='search']").addClass('form-control')
  $('#example_length label select').addClass('form-control')
});
