# frozen_string_literal: true

module DocxServices
  module FormatterConstants
    DOCUMENT_PREFIXES = {
      cpf: {
        male: 'inscrito no CPF sob o nº',
        female: 'inscrita no CPF sob o nº'
      },
      cnpj: {
        company: 'inscrita no CNPJ sob o nº'
      },
      rg: {
        male: 'portador da cédula de identidade RG nº',
        female: 'portadora da cédula de identidade RG nº'
      },
      oab: {
        male: 'inscrito na OAB sob o nº',
        female: 'inscrita na OAB sob o nº'
      },
      nb: {
        default: 'número do benefício'
      },
      nit: {
        default: 'número de inscrição do trabalhador'
      },
      email: {
        default: 'com endereço eletrônico:'
      },
      phone: {
        default: 'com telefone:'
      }
    }.freeze

    ADDRESS_PREFIXES = {
      person: {
        male: 'residente e domiciliado',
        female: 'residente e domiciliada'
      },
      company: {
        default: 'com sede à'
      }
    }.freeze
  end
end