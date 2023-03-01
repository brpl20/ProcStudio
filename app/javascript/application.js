import '@hotwired/turbo-rails'
import 'controllers'
import './jquery'
import './jquery_ujs'
import './dataTables/jquery.dataTables'
import './cocoon'
import 'plugin/steps'



$(document).ready(function(){
  $(".dataTables_filter label input[type='search']").addClass('form-control')
  $('#example_length label select').addClass('form-control')

  $('#example-basic').steps({
    headerTag: 'h3',
    bodyTag: 'section',
    transitionEffect: 'slideLeft',
    autoFocus: true,
    showFinishButtonAlways: false,
    labels: {
      cancel: 'Cancelar',
      current: 'Etapa corrente:',
      finish: 'Finalizar',
      next: 'Próximo',
      previous: 'Anterior',
      loading: 'Carregando ...' 
    },
    onFinished: function (event, currentIndex) { 
     $('#form').submit();
    }
  });  
});
