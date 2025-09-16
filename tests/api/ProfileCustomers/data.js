/**
 * Random Data Generators for Profile Customer Tests
 * Dynamically imports types and constants from frontend project
 */

const { faker, CPFGenerator } = require("./config");
const fs = require('fs');
const path = require('path');

// Dynamic importer for frontend constants and types
class FrontendImporter {
  constructor() {
    this.frontendPath = path.resolve(__dirname, '../../../frontend/src/lib');
    this.cache = new Map();
  }

  /**
   * Extract TypeScript enum values from source code
   */
  extractEnumValues(content, enumName) {
    const enumRegex = new RegExp(`export\\s+type\\s+${enumName}\\s*=\\s*([^;]+);`, 'i');
    const match = content.match(enumRegex);
    
    if (!match) return [];
    
    // Extract values from union type like 'value1' | 'value2' | 'value3'
    const unionType = match[1];
    const values = unionType.match(/'([^']+)'/g);
    
    return values ? values.map(v => v.replace(/'/g, '')) : [];
  }

  /**
   * Extract array constants from TypeScript files
   */
  extractArrayConstant(content, constantName) {
    const arrayRegex = new RegExp(`export\\s+const\\s+${constantName}[^=]*=\\s*\\[([\\s\\S]*?)\\];`, 'i');
    const match = content.match(arrayRegex);
    
    if (!match) return [];
    
    // Extract objects with value and label properties
    const objectMatches = match[1].match(/{\s*value:\s*'([^']+)'[^}]*}/g);
    
    return objectMatches ? objectMatches.map(obj => {
      const valueMatch = obj.match(/value:\s*'([^']+)'/);
      return valueMatch ? valueMatch[1] : null;
    }).filter(Boolean) : [];
  }

  /**
   * Get customer types from frontend
   */
  getCustomerTypes() {
    if (this.cache.has('customerTypes')) {
      return this.cache.get('customerTypes');
    }

    try {
      const customerTypesPath = path.join(this.frontendPath, 'api/types/customer.types.ts');
      const content = fs.readFileSync(customerTypesPath, 'utf8');
      const types = this.extractEnumValues(content, 'CustomerType');
      
      this.cache.set('customerTypes', types);
      return types;
    } catch (error) {
      console.warn('Could not load CustomerType from frontend, using fallback');
      return ['physical_person', 'legal_person', 'representative', 'counter'];
    }
  }

  /**
   * Get customer status from frontend
   */
  getCustomerStatus() {
    if (this.cache.has('customerStatus')) {
      return this.cache.get('customerStatus');
    }

    try {
      const customerTypesPath = path.join(this.frontendPath, 'api/types/customer.types.ts');
      const content = fs.readFileSync(customerTypesPath, 'utf8');
      const status = this.extractEnumValues(content, 'CustomerStatus');
      
      this.cache.set('customerStatus', status);
      return status;
    } catch (error) {
      console.warn('Could not load CustomerStatus from frontend, using fallback');
      return ['active', 'inactive', 'deceased'];
    }
  }

  /**
   * Get gender types from frontend
   */
  getGenderTypes() {
    if (this.cache.has('genderTypes')) {
      return this.cache.get('genderTypes');
    }

    try {
      const customerTypesPath = path.join(this.frontendPath, 'api/types/customer.types.ts');
      const content = fs.readFileSync(customerTypesPath, 'utf8');
      const genders = this.extractEnumValues(content, 'Gender');
      
      this.cache.set('genderTypes', genders);
      return genders;
    } catch (error) {
      console.warn('Could not load Gender from frontend, using fallback');
      return ['male', 'female', 'other'];
    }
  }

  /**
   * Get nationality types from frontend
   */
  getNationalityTypes() {
    if (this.cache.has('nationalityTypes')) {
      return this.cache.get('nationalityTypes');
    }

    try {
      const customerTypesPath = path.join(this.frontendPath, 'api/types/customer.types.ts');
      const content = fs.readFileSync(customerTypesPath, 'utf8');
      const nationalities = this.extractEnumValues(content, 'Nationality');
      
      this.cache.set('nationalityTypes', nationalities);
      return nationalities;
    } catch (error) {
      console.warn('Could not load Nationality from frontend, using fallback');
      return ['brazilian', 'foreigner'];
    }
  }

  /**
   * Get civil status types from frontend
   */
  getCivilStatusTypes() {
    if (this.cache.has('civilStatusTypes')) {
      return this.cache.get('civilStatusTypes');
    }

    try {
      const customerTypesPath = path.join(this.frontendPath, 'api/types/customer.types.ts');
      const content = fs.readFileSync(customerTypesPath, 'utf8');
      const statuses = this.extractEnumValues(content, 'CivilStatus');
      
      this.cache.set('civilStatusTypes', statuses);
      return statuses;
    } catch (error) {
      console.warn('Could not load CivilStatus from frontend, using fallback');
      return ['single', 'married', 'divorced', 'widower', 'union'];
    }
  }

  /**
   * Get capacity types from frontend
   */
  getCapacityTypes() {
    if (this.cache.has('capacityTypes')) {
      return this.cache.get('capacityTypes');
    }

    try {
      const customerTypesPath = path.join(this.frontendPath, 'api/types/customer.types.ts');
      const content = fs.readFileSync(customerTypesPath, 'utf8');
      const capacities = this.extractEnumValues(content, 'Capacity');
      
      this.cache.set('capacityTypes', capacities);
      return capacities;
    } catch (error) {
      console.warn('Could not load Capacity from frontend, using fallback');
      return ['able', 'relatively', 'unable'];
    }
  }

  /**
   * Get Brazilian states from frontend constants
   */
  getBrazilianStates() {
    if (this.cache.has('brazilianStates')) {
      return this.cache.get('brazilianStates');
    }

    try {
      const statesPath = path.join(this.frontendPath, 'constants/brazilian-states.ts');
      const content = fs.readFileSync(statesPath, 'utf8');
      const states = this.extractArrayConstant(content, 'BRAZILIAN_STATES');
      
      this.cache.set('brazilianStates', states);
      return states;
    } catch (error) {
      console.warn('Could not load Brazilian states from frontend, using fallback');
      return ['SP', 'RJ', 'MG', 'RS', 'PR', 'SC', 'BA', 'GO', 'PE', 'CE'];
    }
  }

  /**
   * Get Brazilian banks from frontend constants
   */
  getBrazilianBanks() {
    if (this.cache.has('brazilianBanks')) {
      return this.cache.get('brazilianBanks');
    }

    try {
      const banksPath = path.join(this.frontendPath, 'constants/brazilian-banks.ts');
      const content = fs.readFileSync(banksPath, 'utf8');
      
      // Extract bank names from label properties
      const bankMatches = content.match(/label:\s*'([^']+)'/g);
      const banks = bankMatches ? bankMatches.map(match => {
        return match.match(/label:\s*'([^']+)'/)[1];
      }) : []; // Include all banks from frontend
      
      this.cache.set('brazilianBanks', banks);
      return banks;
    } catch (error) {
      console.warn('Could not load Brazilian banks from frontend, using fallback');
      return [
        'Banco do Brasil S.A.',
        'Caixa Econômica Federal',
        'Banco Bradesco S.A.',
        'Itaú Unibanco S.A.',
        'BANCO SANTANDER (BRASIL) S.A.'
      ];
    }
  }

  /**
   * Get bank account types from frontend constants
   */
  getBankAccountTypes() {
    if (this.cache.has('bankAccountTypes')) {
      return this.cache.get('bankAccountTypes');
    }

    try {
      const accountTypesPath = path.join(this.frontendPath, 'constants/bank-account-types.ts');
      const content = fs.readFileSync(accountTypesPath, 'utf8');
      const types = this.extractArrayConstant(content, 'BANK_ACCOUNT_TYPES');
      
      // Filter to get only Portuguese values
      const portugueseTypes = types.filter(type => ['Corrente', 'Poupança'].includes(type));
      
      this.cache.set('bankAccountTypes', portugueseTypes);
      return portugueseTypes;
    } catch (error) {
      console.warn('Could not load Bank Account Types from frontend, using fallback');
      return ['Corrente', 'Poupança'];
    }
  }
}

// Initialize the frontend importer
const frontendImporter = new FrontendImporter();

// Dynamic enums loaded from frontend
const ENUMS = {
  get customerStatus() { return frontendImporter.getCustomerStatus(); },
  get customerType() { return frontendImporter.getCustomerTypes(); },
  get gender() { return frontendImporter.getGenderTypes(); },
  get nationality() { return frontendImporter.getNationalityTypes(); },
  get civilStatus() { return frontendImporter.getCivilStatusTypes(); },
  get capacity() { return frontendImporter.getCapacityTypes(); }
};

// Dynamic constants loaded from frontend
const BRAZILIAN_STATES = () => frontendImporter.getBrazilianStates();
const BRAZILIAN_BANKS = () => frontendImporter.getBrazilianBanks();
const ACCOUNT_TYPES = () => frontendImporter.getBankAccountTypes();

// Common professions in Brazil
const PROFESSIONS = [
  'Advogado', 'Médico', 'Engenheiro', 'Professor', 'Contador',
  'Arquiteto', 'Dentista', 'Enfermeiro', 'Psicólogo', 'Desenvolvedor',
  'Administrador', 'Jornalista', 'Designer', 'Comerciante', 'Empresário'
];

/**
 * Utility functions for random selection
 */
const randomUtils = {
  pickRandom: (array) => array[Math.floor(Math.random() * array.length)],
  
  randomInt: (min, max) => Math.floor(Math.random() * (max - min + 1)) + min,
  
  randomBool: () => Math.random() > 0.5,
  
  generateRG: () => {
    return `${Math.floor(Math.random() * 100000000).toString().padStart(9, "0")}`;
  },
  
  generatePhone: () => {
    const ddd = randomUtils.randomInt(11, 99);
    const number = randomUtils.randomInt(900000000, 999999999);
    return `+55 ${ddd} ${number}`;
  },
  
  generateCEP: () => {
    return `${randomUtils.randomInt(10000, 99999)}-${randomUtils.randomInt(100, 999)}`;
  },
  
  generateAccount: () => {
    return `${randomUtils.randomInt(10000, 99999)}-${randomUtils.randomInt(0, 9)}`;
  },
  
  generateAgency: () => {
    return `${randomUtils.randomInt(1000, 9999)}-${randomUtils.randomInt(0, 9)}`;
  }
};

/**
 * Data generators for different entity types
 */
const dataGenerators = {
  /**
   * Generate basic profile customer data
   */
  generateProfileCustomer: () => {
    const customerType = randomUtils.pickRandom(ENUMS.customerType);
    const gender = randomUtils.pickRandom(ENUMS.gender);
    const timestamp = Date.now();
    
    const baseData = {
      customer_type: customerType,
      name: faker.person.firstName(),
      last_name: faker.person.lastName(),
      status: randomUtils.pickRandom(ENUMS.customerStatus),
      cpf: CPFGenerator.generate(),
      rg: randomUtils.generateRG(),
      birth: faker.date.between({ from: '1950-01-01', to: '2005-12-31' }).toISOString().split('T')[0],
      gender: gender,
      civil_status: randomUtils.pickRandom(ENUMS.civilStatus),
      nationality: randomUtils.pickRandom(ENUMS.nationality),
      capacity: randomUtils.pickRandom(ENUMS.capacity),
      profession: randomUtils.pickRandom(PROFESSIONS),
      mother_name: `${faker.person.firstName()} ${faker.person.lastName()}`
    };

    // Adjust name based on gender for better realism
    if (gender === 'female') {
      baseData.name = faker.person.firstName('female');
    } else if (gender === 'male') {
      baseData.name = faker.person.firstName('male');
    }

    return baseData;
  },

  /**
   * Generate customer attributes (user data)
   */
  generateCustomerAttributes: () => {
    const timestamp = Date.now();
    return {
      email: `test_${timestamp}_${faker.internet.email()}`,
      password: "123456",
      password_confirmation: "123456"
    };
  },

  /**
   * Generate address data using frontend constants
   */
  generateAddress: () => ({
    zip_code: randomUtils.generateCEP(),
    street: faker.location.street(),
    number: randomUtils.randomInt(1, 9999),
    neighborhood: faker.location.city(),
    city: faker.location.city(),
    state: randomUtils.pickRandom(BRAZILIAN_STATES())
  }),

  /**
   * Generate phone data
   */
  generatePhone: () => ({
    phone_number: randomUtils.generatePhone()
  }),

  /**
   * Generate email data
   */
  generateEmail: () => {
    const timestamp = Date.now();
    return {
      email: `contact_${timestamp}_${faker.internet.email()}`
    };
  },

  /**
   * Generate bank account data using frontend constants
   */
  generateBankAccount: () => {
    const timestamp = Date.now();
    return {
      bank_name: randomUtils.pickRandom(BRAZILIAN_BANKS()),
      type_account: randomUtils.pickRandom(ACCOUNT_TYPES()),
      agency: randomUtils.generateAgency(),
      account: randomUtils.generateAccount(),
      operation: randomUtils.pickRandom(['001', '013', '023']),
      pix: randomUtils.randomBool() ? 
        `pix_${timestamp}@example.com` : 
        randomUtils.generatePhone().replace(/\s/g, '')
    };
  }
};

/**
 * Generate complete profile customer payload
 */
const generateCompleteProfileCustomer = () => {
  const timestamp = Date.now();
  
  return {
    profile_customer: {
      ...dataGenerators.generateProfileCustomer(),
      
      customer_attributes: dataGenerators.generateCustomerAttributes(),
      
      addresses_attributes: [
        dataGenerators.generateAddress()
      ],
      
      phones_attributes: [
        dataGenerators.generatePhone()
      ],
      
      emails_attributes: [
        dataGenerators.generateEmail()
      ],
      
      bank_accounts_attributes: [
        dataGenerators.generateBankAccount()
      ]
    }
  };
};

/**
 * Generate minimal profile customer for updates
 */
const generateMinimalProfileCustomer = () => {
  const timestamp = Date.now();
  
  return {
    profile_customer: {
      name: `Updated_${timestamp}_${faker.person.firstName()}`,
      last_name: `${faker.person.lastName()}`,
      status: randomUtils.pickRandom(ENUMS.customerStatus)
    }
  };
};

/**
 * Generate test data for specific scenarios
 */
const scenarioData = {
  physicalPerson: () => {
    const data = generateCompleteProfileCustomer();
    data.profile_customer.customer_type = 'physical_person';
    return data;
  },

  legalPerson: () => {
    const data = generateCompleteProfileCustomer();
    data.profile_customer.customer_type = 'legal_person';
    data.profile_customer.name = faker.company.name();
    data.profile_customer.last_name = 'LTDA';
    return data;
  },

  representative: () => {
    const data = generateCompleteProfileCustomer();
    data.profile_customer.customer_type = 'representative';
    return data;
  },

  inactiveCustomer: () => {
    const data = generateCompleteProfileCustomer();
    data.profile_customer.status = 'inactive';
    return data;
  }
};

module.exports = {
  ENUMS,
  BRAZILIAN_STATES,
  BRAZILIAN_BANKS,
  ACCOUNT_TYPES,
  PROFESSIONS,
  randomUtils,
  dataGenerators,
  generateCompleteProfileCustomer,
  generateMinimalProfileCustomer,
  scenarioData
};