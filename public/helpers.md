  3. Métodos Helper Úteis:
  job.assignees           # Todos os responsáveis principais
  job.supervisors         # Todos os supervisores
  job.primary_assignee    # Primeiro responsável
  job.all_members         # Todos os envolvidos
  job.add_assignee(user_profile, role: 'assignee')
  job.remove_assignee(user_profile)
