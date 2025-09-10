# frozen_string_literal: true

namespace :cad do
  desc 'Criação de Tarefas'
  task jobs: :environment do
    jobs_data = [
      { description: 'New task test', deadline: '2023-07-04', status: 'pending', priority: 'alta',
        comment: 'Sem comentarios', created_at: '2023-07-04 20:08:11.417339000 -0300', updated_at: '2023-08-16 13:43:14.900091000 -0300', profile_admin_id: 1, work_id: nil, profile_customer_id: 24 },
      { description: 'Create new task', deadline: '2023-07-04', status: 'late', priority: 'normal', comment: '',
        created_at: '2023-07-04 20:22:07.800991000 -0300', updated_at: '2023-08-16 13:48:10.762643000 -0300', profile_admin_id: 1, work_id: nil, profile_customer_id: 1 },
      { description: 'Teste live', deadline: '2023-07-29', status: 'pending', priority: 'alta', comment: '',
        created_at: '2023-07-04 23:01:44.507215000 -0300', updated_at: '2023-08-16 13:48:10.768476000 -0300', profile_admin_id: 1, work_id: nil, profile_customer_id: 1 },
      { description: 'Teste live 2', deadline: '2023-08-18', status: 'late', priority: 'normal', comment: '',
        created_at: '2023-07-04 23:02:38.321419000 -0300', updated_at: '2023-08-16 13:48:10.774600000 -0300', profile_admin_id: 1, work_id: nil, profile_customer_id: 1 },
      { description: 'Nova Descrição', deadline: '2023-08-16', status: 'late', priority: 'alta', comment: '',
        created_at: '2023-07-04 23:06:04.888484000 -0300', updated_at: '2023-08-16 13:48:10.780663000 -0300', profile_admin_id: 1, work_id: nil, profile_customer_id: 1 },
      { description: 'This is a new Job #99', deadline: '1990-11-18', status: 'pending', priority: 'low',
        comment: 'Lorem ipsum dolor sit amet, consectetur adipiscing...', created_at: '2023-07-04 23:12:30.748052000 -0300', updated_at: '2023-08-16 13:48:10.787070000 -0300', profile_admin_id: 1, work_id: nil, profile_customer_id: 1 },
      { description: 'New task test', deadline: '2023-07-10', status: 'pending', priority: nil, comment: nil,
        created_at: '2023-07-10 19:07:35.927021000 -0300', updated_at: '2023-08-16 13:49:16.943464000 -0300', profile_admin_id: 1, work_id: 1, profile_customer_id: 1 },
      { description: 'Novo teste teste', deadline: '2023-10-16', status: 'finished', priority: 'alta',
        comment: 'Novo testes', created_at: '2023-07-10 19:08:40.661384000 -0300', updated_at: '2023-08-16 13:49:16.949403000 -0300', profile_admin_id: 1, work_id: 1, profile_customer_id: 1 },
      { description: 'This is a new Job #2', deadline: '1990-11-18', status: 'pending', priority: 'low',
        comment: 'Lorem ipsum dolor sit amet, consectetur adipiscing...', created_at: '2023-07-10 19:13:20.462523000 -0300', updated_at: '2023-08-16 13:49:16.954948000 -0300', profile_admin_id: 1, work_id: 1, profile_customer_id: 1 },
      { description: 'Testing create', deadline: '2023-08-15', status: 'finished', priority: 'normal',
        comment: 'Nada por enquanto', created_at: '2023-07-10 19:18:02.586027000 -0300', updated_at: '2023-08-16 13:49:16.961062000 -0300', profile_admin_id: 1, work_id: 1, profile_customer_id: 1 }
    ]

    jobs_data.each do |job_attributes|
      Job.find_or_create_by(job_attributes)
    end
  end
end
