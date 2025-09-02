import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';
import { svelte } from '@sveltejs/vite-plugin-svelte';
import * as fs from 'fs';
import * as path from 'path';
import { Plugin } from 'vite';

function rewriteAssetPathsPlugin(): Plugin {
    const manifestPath = path.resolve('public/vite/manifest.json');
    let manifest: Record<string, { file: string }> | null = null;

    // Load client-side manifest if it exists (production)
    if (fs.existsSync(manifestPath)) {
        manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf-8'));
    }

    return {
        name: 'rewrite-asset-paths',
        enforce: 'pre',
        transform(code, id) {
            if (id.endsWith('.svelte')) {
                if (manifest) {
                    // Production: Rewrite asset paths using client-side manifest
                    let transformedCode = code;
                    for (const [assetKey, assetData] of Object.entries(manifest)) {
                        // Match assets like /assets/image.jpg, /assets/script.js, /assets/style.css
                        const assetRegex = new RegExp(`/assets/${assetKey.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}`, 'g');
                        transformedCode = transformedCode.replace(assetRegex, `/vite/${assetData.file}`);
                    }
                    return transformedCode;
                } else {
                    // Development: Fallback to /vite-dev/assets/ for all assets
                    return code.replace(/\/assets\//g, '/vite-dev/assets/');
                }
            }
            return null;
        },
    };
}

// Function to recursively find all .svelte files
function findSvelteFiles(dir: string, baseDir: string = dir): Record<string, string> {
    const entries: Record<string, string> = {};
    const files = fs.readdirSync(dir, { withFileTypes: true });

    for (const file of files) {
        const fullPath = path.join(dir, file.name);
        if (file.isDirectory()) {
            // Recurse into subdirectories
            Object.assign(entries, findSvelteFiles(fullPath, baseDir));
        } else if (file.isFile() && file.name.endsWith('.svelte')) {
            // Create entry for .svelte file
            const relativePath = path.relative(baseDir, fullPath);
            const name = relativePath.replace('.svelte', '').replace(/\//g, '-'); // e.g., components-MyComponent
            entries[`svelte-${name}`] = fullPath;
        }
    }
    return entries;
}

// Collect all .svelte files in app/frontend
const svelteComponents = findSvelteFiles(path.resolve('app/frontend'));

export default defineConfig(({ mode }) => {

    const isProduction = (process.env.RAILS_ENV === 'development' || process.env.RAILS_ENV === 'test' ? false : true);

    return {
        base: isProduction ? '/vite/' : '/vite-dev/',
        plugins: [
            rewriteAssetPathsPlugin(),
            {
                ...RubyPlugin(),
                apply(config, { command }) {
                    if (command === 'build') {
                        if (config.plugins) { // Add this check
                            config.plugins = config.plugins.filter((plugin) => {
                                return !!(plugin && typeof plugin === 'object' && 'name' in plugin && plugin.name !== 'vite-plugin-ruby:assets-manifest');
                            });
                        }
                    }
                    return true;
                },
            },
            svelte({
                include: ['app/frontend/**/*.svelte'],
                compilerOptions: {
                    // hydratable: false,
                },
            }),
            {
                name: 'force-manifest',
                configResolved(config) {
                    console.log('Resolved build.manifest:', config.build.manifest);
                    if (!config.build.manifest) {
                        config.build.manifest = 'manifest-ssr.json';
                        console.log('Forced build.manifest to manifest-ssr.json');
                    }
                },
            },
        ],
        build: {
            ssr: true,
            outDir: 'public/vite-ssr',
            manifest: 'manifest.json',
            rollupOptions: {
                input: {
                    ...svelteComponents,
                    ssr: 'app/frontend/ssr/ssr.js',
                },
                output: {
                    format: 'es',
                    entryFileNames: 'assets/[name]-[hash].js',
                    chunkFileNames: 'assets/[name]-[hash].js',
                    assetFileNames: 'assets/[name]-[hash][extname]',
                    manualChunks(id) {
                        if (id.indexOf('.svelte') !== -1) {
                            const lastSegment = id.split('/').pop();
                            if (lastSegment) {
                                const componentName = lastSegment.replace('.svelte', '');
                                return `svelte-${componentName}`;
                            }
                        }
                    }
                },
            },
        },
        optimizeDeps: {
            include: ['svelte'],
        },
        logLevel: 'info',
    };
});