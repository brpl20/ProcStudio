const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    './app/frontend/**/*.{js,svelte}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        // Neutral Palette
        'snow': '#FEFEFA',
        'alabaster': '#F0F4F3',
        'crimson': '#B5192B',
        'salmon': '#FD7964',
        'gray-medium': '#999999',
        'charcoal': '#373F45',
        
        // Blue Palette
        'azure': '#0277EE',
        'sky-light': '#CBEEFE',
        'sky': '#98D9FD',
        'cobalt': '#0057B0',
        'navy': '#002272',
        
        // Yellow Palette
        'cream': '#FDF4DD',
        'gold': '#A4872F',
        
        // Red Palette
        'coral': '#FC3C32',
        'silver': '#B0B0B0',
        'pearl': '#EDEDED',
        
        // Green Palette
        'forest': '#0B5F1F',
        'mint': '#E7FCD8',
      },
    },
  },
  plugins: [
    require('daisyui'),
    // require('@tailwindcss/forms'),
    // require('@tailwindcss/typography'),
    // require('@tailwindcss/container-queries'),
  ],
  daisyui: {
    themes: [
      {
        procstudio: {
          "primary": "#0277EE",           // azure
          "primary-focus": "#0057B0",     // cobalt
          "primary-content": "#FEFEFA",   // snow
          
          "secondary": "#B5192B",          // crimson
          "secondary-focus": "#8B1421",   // darker crimson
          "secondary-content": "#FEFEFA", // snow
          
          "accent": "#FD7964",             // salmon
          "accent-focus": "#FC5C44",       // darker salmon
          "accent-content": "#002272",     // navy
          
          "neutral": "#373F45",            // charcoal
          "neutral-focus": "#2A3035",      // darker charcoal
          "neutral-content": "#F0F4F3",    // alabaster
          
          "base-100": "#FEFEFA",           // snow (main background)
          "base-200": "#F0F4F3",           // alabaster (secondary background)
          "base-300": "#EDEDED",           // pearl (tertiary background)
          "base-content": "#373F45",       // charcoal (main text)
          
          "info": "#98D9FD",                // sky
          "info-content": "#002272",        // navy
          
          "success": "#0B5F1F",             // forest
          "success-content": "#E7FCD8",     // mint
          
          "warning": "#A4872F",             // gold
          "warning-content": "#FDF4DD",      // cream
          
          "error": "#FC3C32",               // coral
          "error-content": "#FEFEFA",       // snow
          
          "--rounded-box": "0.5rem",
          "--rounded-btn": "0.375rem",
          "--rounded-badge": "1.9rem",
          "--animation-btn": "0.25s",
          "--animation-input": "0.2s",
          "--btn-text-case": "none",
          "--btn-focus-scale": "0.95",
          "--border-btn": "1px",
          "--tab-border": "1px",
          "--tab-radius": "0.5rem",
        },
      },
      "light",
      "dark",
    ],
    darkTheme: "dark",
    base: true,
    styled: true,
    utils: true,
    prefix: "",
    logs: true,
  }
}