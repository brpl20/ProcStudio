<script lang="ts">
  import { getCurrentInssConstants } from '../../constants/formOptions';

  const { minimumWage, inssCeiling } = getCurrentInssConstants();
</script>

<div class="alert alert-info mb-4">
  <svg
    xmlns="http://www.w3.org/2000/svg"
    class="stroke-current shrink-0 h-6 w-6"
    fill="none"
    viewBox="0 0 24 24"
  >
    <path
      stroke-linecap="round"
      stroke-linejoin="round"
      stroke-width="2"
      d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
    />
  </svg>
  <div>
    <div class="font-bold">Faixas de Valor:</div>
    <div class="text-sm mt-1">
      <div>
        • Salário Mínimo: R$ {minimumWage.toLocaleString('pt-BR', {
          minimumFractionDigits: 2
        })}
      </div>
      <div>
        • Teto INSS: R$ {inssCeiling.toLocaleString('pt-BR', {
          minimumFractionDigits: 2
        })}
      </div>
      <div class="mt-1">Valor R$ 0,00 = sócio não receberá pro-labore</div>
    </div>
  </div>
</div>