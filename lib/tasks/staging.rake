namespace :staging do

  desc 'Setup Development'
  task setup: :environment do

    p 'Executando o setup para desenvolvimento/staging...'

    p "APAGANDO BD... #{%x(rake db:drop)}"
    p "CRIANDO BD... #{%x(rake db:create)}"
    p "MIGRANDO TABELAS... #{%x(rake db:migrate)}"

    p 'Cadastrando office_type'
    p %x(rake cad:office_type)

    p 'Cadastrando office'
    p %x(rake cad:office)

    p 'Carregando seeds'
    p %x(rake db:seed)

    p 'Cadastrando customer'
    p %x(rake cad:customer)

    # p 'Cadastrando work'
    # p %x(rake cad:work)

    p 'Setup finalizado com sucesso!'
  end
end
