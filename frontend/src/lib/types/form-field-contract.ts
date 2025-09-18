/**
 * Form Field Interface Contract
 * Standardizes props across all form field components
 */

export interface FormFieldProps<T = string> {
  // Core props
  value: T;
  id?: string;
  name?: string;
  
  // Display props
  labelText?: string;
  placeholder?: string;
  hint?: string;
  
  // State props
  required?: boolean;
  disabled?: boolean;
  readonly?: boolean;
  
  // Validation props
  errors?: string | null;
  touched?: boolean;
  validate?: boolean;
  
  // Styling props
  wrapperClass?: string;
  inputClass?: string;
  labelClass?: string;
  
  // Testing props
  testId?: string;
  
  // Accessibility props
  ariaLabel?: string;
  ariaDescribedBy?: string;
}

export interface SelectFieldProps<T = string> extends FormFieldProps<T> {
  options: Array<{ value: T; label: string }>;
  emptyOptionLabel?: string;
}

export interface NumberFieldProps extends FormFieldProps<number> {
  min?: number;
  max?: number;
  step?: number;
}

export interface TextFieldProps extends FormFieldProps<string> {
  maxLength?: number;
  minLength?: number;
  pattern?: string;
  inputType?: 'text' | 'email' | 'tel' | 'url' | 'password';
}

export type FormFieldEventDetail<T = string> = {
  id: string;
  value: T;
  error?: string | null;
};

export type FormFieldEvents<T = string> = {
  input: FormFieldEventDetail<T>;
  blur: FormFieldEventDetail<T>;
  validate: FormFieldEventDetail<T>;
  change: FormFieldEventDetail<T>;
};