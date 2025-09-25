// Form Options Constants

// Type definitions for options with badge styling
export interface FormOption {
  value: string;
  label: string;
}

export interface BadgeFormOption extends FormOption {
  badgeClass: string;
  dotClass?: string;
}


export const SOCIETY_OPTIONS: FormOption[] = [
  { value: 'individual', label: 'Individual' },
  { value: 'company', label: 'Sociedade' }
];

export const ACCOUNTING_OPTIONS: FormOption[] = [
  { value: 'simple', label: 'Simples Nacional' },
  { value: 'real_profit', label: 'Lucro Real' },
  { value: 'presumed_profit', label: 'Lucro Presumido' }
];

export const PARTNERSHIP_TYPES: FormOption[] = [
  { value: 'socio', label: 'Sócio' },
  { value: 'associado', label: 'Associado' },
  { value: 'socio_de_servico', label: 'Sócio de Serviço' }
];

export const JOBSTATUS: BadgeFormOption[] = [
  { value: 'pending', label: 'Pendente', badgeClass: 'badge badge-pending' },
  { value: 'in_progress', label: 'Em Progresso', badgeClass: 'badge badge-in_progress' },
  { value: 'completed', label: 'Concluído', badgeClass: 'badge badge-completed' },
  { value: 'cancelled', label: 'Cancelado', badgeClass: 'badge badge-cancelled' },
  { value: 'delayed', label: 'Atrasado', badgeClass: 'badge badge-delayed' }
];

export const JOBPRIORITY: BadgeFormOption[] = [
  { value: 'low', label: 'Baixa', dotClass: 'dot dot-low badge-low', badgeClass: 'badge badge-low' },
  { value: 'medium', label: 'Média', dotClass: 'dot dot-medium badge-medium', badgeClass: 'badge badge-medium' },
  { value: 'high', label: 'Alta', dotClass: 'dot dot-high badge-high', badgeClass: 'badge badge-high' },
  { value: 'urgent', label: 'Urgente', dotClass: 'dot dot-urgent badge-urgent', badgeClass: 'badge badge-urgent' }
];

// Helper functions that return both label and badge class
export const getJobStatusInfo = (value: string): { label: string; badgeClass: string } => {
  const status = JOBSTATUS.find((item) => item.value === value);
  return {
    label: status?.label || value,
    badgeClass: status?.badgeClass || 'badge'
  };
};

// Merged function that returns both label and badge class for priority
export const getJobPriorityInfo = (value: string): { label: string; badgeClass: string } => {
  const priority = JOBPRIORITY.find((item) => item.value === value);
  return {
    label: priority?.label || value,
    badgeClass: priority?.badgeClass || 'badge badge-outline'
  };
};

// INSS Constants by year
export const INSS_CONSTANTS: Record<number, { minimumWage: number; inssCeiling: number }> = {
  2025: {
    minimumWage: 1518.0,
    inssCeiling: 8157.41
  }
};

// Helper function to get current year INSS constants
export const getCurrentInssConstants = () => {
  const currentYear = new Date().getFullYear();
  return INSS_CONSTANTS[currentYear] || INSS_CONSTANTS[2025];
};
