import { Controller } from "@hotwired/stimulus"

// Brazilian document validation utilities
export default class extends Controller {
  static targets = ["cpfInput", "cnpjInput", "phoneInput", "cepInput"]
  
  connect() {
    console.log("Customer form controller connected")
    this.setupValidations()
  }
  
  setupValidations() {
    // Setup input masks and validations
    if (this.hasCpfInputTarget) {
      this.cpfInputTargets.forEach(input => {
        input.addEventListener('input', (e) => this.formatCPF(e))
        input.addEventListener('blur', (e) => this.validateCPF(e))
      })
    }
    
    if (this.hasCnpjInputTarget) {
      this.cnpjInputTargets.forEach(input => {
        input.addEventListener('input', (e) => this.formatCNPJ(e))
        input.addEventListener('blur', (e) => this.validateCNPJ(e))
      })
    }
    
    if (this.hasPhoneInputTarget) {
      this.phoneInputTargets.forEach(input => {
        input.addEventListener('input', (e) => this.formatPhone(e))
      })
    }
    
    if (this.hasCepInputTarget) {
      this.cepInputTargets.forEach(input => {
        input.addEventListener('blur', (e) => this.fetchAddressByCEP(e))
      })
    }
  }
  
  formatCPF(event) {
    let value = event.target.value.replace(/\D/g, '')
    if (value.length > 11) value = value.slice(0, 11)
    
    if (value.length > 9) {
      value = value.replace(/^(\d{3})(\d{3})(\d{3})(\d{1,2})/, '$1.$2.$3-$4')
    } else if (value.length > 6) {
      value = value.replace(/^(\d{3})(\d{3})(\d{1,3})/, '$1.$2.$3')
    } else if (value.length > 3) {
      value = value.replace(/^(\d{3})(\d{1,3})/, '$1.$2')
    }
    
    event.target.value = value
  }
  
  validateCPF(event) {
    const cpf = event.target.value.replace(/\D/g, '')
    
    if (cpf.length !== 11) {
      this.setFieldError(event.target, 'CPF deve ter 11 dígitos')
      return false
    }
    
    // Check for known invalid CPFs
    if (/^(\d)\1{10}$/.test(cpf)) {
      this.setFieldError(event.target, 'CPF inválido')
      return false
    }
    
    // Validate first digit
    let sum = 0
    for (let i = 0; i < 9; i++) {
      sum += parseInt(cpf.charAt(i)) * (10 - i)
    }
    let digit = 11 - (sum % 11)
    if (digit >= 10) digit = 0
    if (digit !== parseInt(cpf.charAt(9))) {
      this.setFieldError(event.target, 'CPF inválido')
      return false
    }
    
    // Validate second digit
    sum = 0
    for (let i = 0; i < 10; i++) {
      sum += parseInt(cpf.charAt(i)) * (11 - i)
    }
    digit = 11 - (sum % 11)
    if (digit >= 10) digit = 0
    if (digit !== parseInt(cpf.charAt(10))) {
      this.setFieldError(event.target, 'CPF inválido')
      return false
    }
    
    this.clearFieldError(event.target)
    return true
  }
  
  formatCNPJ(event) {
    let value = event.target.value.replace(/\D/g, '')
    if (value.length > 14) value = value.slice(0, 14)
    
    if (value.length > 12) {
      value = value.replace(/^(\d{2})(\d{3})(\d{3})(\d{4})(\d{1,2})/, '$1.$2.$3/$4-$5')
    } else if (value.length > 8) {
      value = value.replace(/^(\d{2})(\d{3})(\d{3})(\d{1,4})/, '$1.$2.$3/$4')
    } else if (value.length > 5) {
      value = value.replace(/^(\d{2})(\d{3})(\d{1,3})/, '$1.$2.$3')
    } else if (value.length > 2) {
      value = value.replace(/^(\d{2})(\d{1,3})/, '$1.$2')
    }
    
    event.target.value = value
  }
  
  validateCNPJ(event) {
    const cnpj = event.target.value.replace(/\D/g, '')
    
    if (cnpj.length !== 14) {
      this.setFieldError(event.target, 'CNPJ deve ter 14 dígitos')
      return false
    }
    
    // Check for known invalid CNPJs
    if (/^(\d)\1{13}$/.test(cnpj)) {
      this.setFieldError(event.target, 'CNPJ inválido')
      return false
    }
    
    // CNPJ validation algorithm
    const weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
    const weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
    
    let sum = 0
    for (let i = 0; i < 12; i++) {
      sum += parseInt(cnpj.charAt(i)) * weights1[i]
    }
    let digit = sum % 11 < 2 ? 0 : 11 - (sum % 11)
    if (digit !== parseInt(cnpj.charAt(12))) {
      this.setFieldError(event.target, 'CNPJ inválido')
      return false
    }
    
    sum = 0
    for (let i = 0; i < 13; i++) {
      sum += parseInt(cnpj.charAt(i)) * weights2[i]
    }
    digit = sum % 11 < 2 ? 0 : 11 - (sum % 11)
    if (digit !== parseInt(cnpj.charAt(13))) {
      this.setFieldError(event.target, 'CNPJ inválido')
      return false
    }
    
    this.clearFieldError(event.target)
    return true
  }
  
  formatPhone(event) {
    let value = event.target.value.replace(/\D/g, '')
    if (value.length > 11) value = value.slice(0, 11)
    
    if (value.length > 6) {
      if (value.length === 11) {
        value = value.replace(/^(\d{2})(\d{5})(\d{4})/, '($1) $2-$3')
      } else if (value.length === 10) {
        value = value.replace(/^(\d{2})(\d{4})(\d{4})/, '($1) $2-$3')
      } else {
        value = value.replace(/^(\d{2})(\d{4,5})(\d{0,4})/, '($1) $2-$3')
      }
    } else if (value.length > 2) {
      value = value.replace(/^(\d{2})(\d{0,5})/, '($1) $2')
    } else if (value.length > 0) {
      value = value.replace(/^(\d{0,2})/, '($1')
    }
    
    event.target.value = value
  }
  
  async fetchAddressByCEP(event) {
    const cep = event.target.value.replace(/\D/g, '')
    
    if (cep.length !== 8) {
      return
    }
    
    try {
      const response = await fetch(`https://viacep.com.br/ws/${cep}/json/`)
      const data = await response.json()
      
      if (!data.erro) {
        // Find the parent address container
        const addressContainer = event.target.closest('.address-fields')
        if (addressContainer) {
          // Fill in the address fields
          const streetInput = addressContainer.querySelector('[name*="street"]')
          const neighborhoodInput = addressContainer.querySelector('[name*="neighborhood"]')
          const cityInput = addressContainer.querySelector('[name*="city"]')
          const stateSelect = addressContainer.querySelector('[name*="state"]')
          
          if (streetInput) streetInput.value = data.logradouro
          if (neighborhoodInput) neighborhoodInput.value = data.bairro
          if (cityInput) cityInput.value = data.localidade
          if (stateSelect) stateSelect.value = data.uf
        }
      } else {
        this.setFieldError(event.target, 'CEP não encontrado')
      }
    } catch (error) {
      console.error('Error fetching address:', error)
      this.setFieldError(event.target, 'Erro ao buscar CEP')
    }
  }
  
  setFieldError(field, message) {
    field.classList.add('input-error')
    
    // Find or create error message element
    let errorElement = field.parentElement.querySelector('.label-text-alt.text-error')
    if (!errorElement) {
      const label = document.createElement('label')
      label.className = 'label'
      const span = document.createElement('span')
      span.className = 'label-text-alt text-error'
      label.appendChild(span)
      field.parentElement.appendChild(label)
      errorElement = span
    }
    
    errorElement.textContent = message
  }
  
  clearFieldError(field) {
    field.classList.remove('input-error')
    
    const errorElement = field.parentElement.querySelector('.label-text-alt.text-error')
    if (errorElement) {
      errorElement.parentElement.remove()
    }
  }
  
  // Dynamic field management
  addField(event) {
    const button = event.currentTarget
    const container = button.closest('.dynamic-fields-container')
    const template = container.querySelector('.field-template')
    const newField = template.cloneNode(true)
    
    // Update field indices
    const currentIndex = container.querySelectorAll('.dynamic-field').length
    newField.innerHTML = newField.innerHTML.replace(/\[0\]/g, `[${currentIndex}]`)
    newField.classList.remove('field-template')
    newField.classList.add('dynamic-field')
    
    container.insertBefore(newField, button.parentElement)
    this.setupValidations()
  }
  
  removeField(event) {
    const field = event.currentTarget.closest('.dynamic-field')
    
    // If it has an ID, mark it for destruction
    const idInput = field.querySelector('[name*="[id]"]')
    if (idInput && idInput.value) {
      const destroyInput = document.createElement('input')
      destroyInput.type = 'hidden'
      destroyInput.name = idInput.name.replace('[id]', '[_destroy]')
      destroyInput.value = '1'
      field.appendChild(destroyInput)
      field.style.display = 'none'
    } else {
      field.remove()
    }
  }
  
  // Password generation
  generatePassword(event) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*'
    let password = ''
    
    for (let i = 0; i < 12; i++) {
      password += chars.charAt(Math.floor(Math.random() * chars.length))
    }
    
    const form = event.currentTarget.closest('form')
    const passwordField = form.querySelector('[name*="password"]')
    const confirmationField = form.querySelector('[name*="password_confirmation"]')
    
    if (passwordField) passwordField.value = password
    if (confirmationField) confirmationField.value = password
    
    // Show password temporarily
    passwordField.type = 'text'
    if (confirmationField) confirmationField.type = 'text'
    
    setTimeout(() => {
      passwordField.type = 'password'
      if (confirmationField) confirmationField.type = 'password'
    }, 5000)
  }
  
  // Form submission with validation
  async submitForm(event) {
    event.preventDefault()
    
    const form = event.target
    const submitButton = form.querySelector('[type="submit"]')
    
    // Basic client-side validation
    if (!form.checkValidity()) {
      form.reportValidity()
      return
    }
    
    // Disable submit button and show loading
    submitButton.disabled = true
    const originalText = submitButton.textContent
    submitButton.innerHTML = '<span class="loading loading-spinner"></span> Processando...'
    
    try {
      // Let Turbo handle the form submission
      form.requestSubmit()
    } catch (error) {
      console.error('Form submission error:', error)
      submitButton.disabled = false
      submitButton.textContent = originalText
    }
  }
};
