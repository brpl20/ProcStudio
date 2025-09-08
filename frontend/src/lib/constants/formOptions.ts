// Form Options Constants
export const SOCIETY_OPTIONS = [
  { value: 'individual', label: 'Individual' },
  { value: 'company', label: 'Sociedade' }
];

export const ACCOUNTING_OPTIONS = [
  { value: 'simple', label: 'Simples Nacional' },
  { value: 'real_profit', label: 'Lucro Real' },
  { value: 'presumed_profit', label: 'Lucro Presumido' }
];

export const PARTNERSHIP_TYPES = [
  { value: 'socio', label: 'Sócio' },
  { value: 'associado', label: 'Associado' },
  { value: 'socio_de_servico', label: 'Sócio de Serviço' }
];

// INSS Constants by year
export const INSS_CONSTANTS = {
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
