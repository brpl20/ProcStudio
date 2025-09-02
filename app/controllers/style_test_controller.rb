# frozen_string_literal: true

class StyleTestController < ApplicationController
  # No authentication required - this is a public test page
  # Following the pattern from HelloController which is also public

  def index
    @test_data = {
      colors: [
        { name: 'Snow', value: '#FEFEFA', class: 'bg-snow' },
        { name: 'Alabaster', value: '#F0F4F3', class: 'bg-alabaster' },
        { name: 'Crimson', value: '#B5192B', class: 'bg-crimson' },
        { name: 'Salmon', value: '#FD7964', class: 'bg-salmon' },
        { name: 'Charcoal', value: '#373F45', class: 'bg-charcoal' },
        { name: 'Azure', value: '#0277EE', class: 'bg-azure' },
        { name: 'Sky', value: '#98D9FD', class: 'bg-sky' },
        { name: 'Cobalt', value: '#0057B0', class: 'bg-cobalt' },
        { name: 'Navy', value: '#002272', class: 'bg-navy' },
        { name: 'Cream', value: '#FDF4DD', class: 'bg-cream' },
        { name: 'Gold', value: '#A4872F', class: 'bg-gold' },
        { name: 'Coral', value: '#FC3C32', class: 'bg-coral' },
        { name: 'Forest', value: '#0B5F1F', class: 'bg-forest' },
        { name: 'Mint', value: '#E7FCD8', class: 'bg-mint' }
      ]
    }
  end

  def form_test
    flash[:notice] = 'Form submitted successfully!' if params[:submit_action] == 'submit'
    flash[:error] = 'Error occurred!' if params[:submit_action] == 'error'
    flash[:warning] = 'Warning message!' if params[:submit_action] == 'warning'
    flash[:info] = 'Info message!' if params[:submit_action] == 'info'
    redirect_to style_test_path
  end
end
