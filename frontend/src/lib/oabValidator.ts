// Estados brasileiros válidos para OAB
const VALID_STATES = [
  'AC',
  'AL',
  'AP',
  'AM',
  'BA',
  'CE',
  'DF',
  'ES',
  'GO',
  'MA',
  'MT',
  'MS',
  'MG',
  'PA',
  'PB',
  'PR',
  'PE',
  'PI',
  'RJ',
  'RN',
  'RS',
  'RO',
  'RR',
  'SC',
  'SP',
  'SE',
  'TO'
];

interface OabValidationResult {
  isValid: boolean;
  normalizedOab?: string;
  error?: string;
}

/**
 * Valida e normaliza o número da OAB para o formato padrão UF_NUMERO
 *
 * Formatos aceitos:
 * - PR 54159, PR54159, PR_54159, PR/54159
 * - 54159/PR, 54159PR, 54159 PR
 * - Com zeros na frente: PR054159, PR_054159, etc.
 *
 * @param input - String com o número da OAB em qualquer formato aceito
 * @returns Objeto com resultado da validação e OAB normalizada
 */
export function validateAndNormalizeOab(input: string): OabValidationResult {
  if (!input || typeof input !== 'string') {
    return {
      isValid: false,
      error: 'OAB é obrigatória'
    };
  }

  // Remove espaços extras e converte para maiúsculo
  const cleanInput = input.trim().toUpperCase();

  // Regex para capturar diferentes formatos
  // Captura: UF (opcional) + separador (opcional) + número + separador (opcional) + UF (opcional)
  // eslint-disable-next-line no-useless-escape
  const oabRegex = /^(?:([A-Z]{2})[\s_\/]?)?(\d{4,6})(?:[\s_\/]?([A-Z]{2}))?$/;

  const match = cleanInput.match(oabRegex);

  if (!match) {
    return {
      isValid: false,
      error: 'Formato da OAB inválido. Use formatos como: PR_54159, PR 54159, 54159/PR, etc.'
    };
  }

  const [, prefixState, number, suffixState] = match;

  // Determina qual estado usar (prefixo ou sufixo)
  const state = prefixState || suffixState;

  if (!state) {
    return {
      isValid: false,
      error: 'Estado da OAB não informado. Exemplo: PR_54159'
    };
  }

  // Valida se o estado existe
  if (!VALID_STATES.includes(state)) {
    return {
      isValid: false,
      error: `Estado "${state}" não é válido. Estados aceitos: ${VALID_STATES.join(', ')}`
    };
  }

  // Valida o número (deve ter entre 1 e 6 dígitos)
  if (number.length < 1 || number.length > 6) {
    return {
      isValid: false,
      error: 'Número da OAB deve ter entre 1 e 6 dígitos'
    };
  }

  // Remove zeros à esquerda do número, mas mantém pelo menos 4 dígitos
  const normalizedNumber = number.replace(/^0+/, '') || '0';
  const paddedNumber = normalizedNumber.padStart(4, '0');

  // Retorna no formato padrão UF_NUMERO
  const normalizedOab = `${state}_${paddedNumber}`;

  return {
    isValid: true,
    normalizedOab
  };
}

/**
 * Função auxiliar que apenas valida se a OAB está no formato correto
 * @param oab - String com a OAB
 * @returns boolean indicando se é válida
 */
export function isValidOab(oab: string): boolean {
  return validateAndNormalizeOab(oab).isValid;
}

/**
 * Função auxiliar que retorna apenas a OAB normalizada ou null se inválida
 * @param oab - String com a OAB
 * @returns String normalizada ou null se inválida
 */
export function normalizeOab(oab: string): string | null {
  const result = validateAndNormalizeOab(oab);
  return result.isValid ? result.normalizedOab! : null;
}
