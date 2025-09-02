# Color and Styling

## Color Base
Neutral colors:
#FEFEFA
#FOF4F3
#B5192B
#FD7964
#999999
#373F45

Blue:
#0277EE
#CBEEFE
#98D9FD
#0057B0
#002272

Yellow:
#FDF4DD
#A4872F

Red:
#FC3C32
#BOBOBO
#EDEDED

Green:
#0B5F1F
#E7FCD8

## Tailwind Configuration (config/tailwind.config.js)

- Added all brand colors with friendly names (snow, alabaster, crimson, azure, forest, etc.)
- Created a custom DaisyUI theme called "procstudio" with semantic color mappings
- Configured primary, secondary, accent, success, warning, and error states

## CSS Custom Properties (app/assets/stylesheets/colors.css)

- Global CSS variables for all colors (e.g., --color-azure, --color-crimson)
- Semantic aliases for common use cases
- Dark mode support structure
- Utility classes for direct usage

 ## Application Styles (app/assets/stylesheets/application.tailwind.css)

- Custom utility classes (.text-brand-primary, .gradient-primary)
- Branded component variants (.btn-brand-primary, .card-brand)
- Global theme application

## Usage Examples:

Tailwind Classes:
```
  <div class="bg-azure text-snow">
  <button class="btn btn-primary">Primary Button</button>
  <div class="bg-gradient-to-r from-crimson to-salmon">
```

CSS Variables:
```
color: var(--color-azure);
  background: var(--color-forest);
```

DaisyUI Theme:
```
<div data-theme="procstudio">
    <!-- Your content with brand colors -->
  </div>
```
