import tailwindcss from '@tailwindcss/vite';
import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';
import path from 'path';

// Small helper to pretty-print possibly JSON payloads
function formatMaybeJSON(input) {
  try {
    const obj = typeof input === 'string' ? JSON.parse(input) : JSON.parse(input.toString('utf8'));
    return JSON.stringify(obj, null, 2);
  } catch (_e) {
    const text = Buffer.isBuffer(input) ? input.toString('utf8') : String(input ?? '');
    return text;
  }
}

// Dev-only middleware to capture raw request bodies under /api
function proxyDebugPlugin() {
  const METHODS_WITH_BODY = new Set(['POST', 'PUT', 'PATCH', 'DELETE']);
  const MAX_LOG_BYTES = 1024 * 128; // 128KB guard to avoid flooding the console
  return {
    name: 'proxy-debug-middleware',
    configureServer(server) {
      server.middlewares.use('/api', (req, _res, next) => {
        if (!METHODS_WITH_BODY.has((req.method || '').toUpperCase())) {
          return next();
        }
        let total = 0;
        const chunks = [];
        req.on('data', (chunk) => {
          total += chunk.length;
          // Keep all data for forwarding, but clamp what we log later
          chunks.push(chunk);
        });
        req.on('end', () => {
          const bodyBuffer = Buffer.concat(chunks);
          // Stash the raw body for logging and for forwarding in proxyReq

          req.__rawBody = bodyBuffer;
          // Also keep a clamped copy for log readability

          req.__rawBodyPreview = bodyBuffer.slice(0, MAX_LOG_BYTES);
          next();
        });
        req.on('error', () => next());
      });
    }
  };
}

export default defineConfig({
  plugins: [tailwindcss(), svelte(), proxyDebugPlugin()],
  resolve: {
    alias: {
      $lib: path.resolve('./src/lib')
    }
  },
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true,
        secure: false,
        selfHandleResponse: true, // let us read and log responses before sending
        configure: (proxy, _options) => {
          proxy.on('error', (err, _req, _res) => {
            console.log('proxy error', err);
          });
          proxy.on('proxyReq', (proxyReq, req, _res) => {
            const method = req.method;
            const url = req.url;
            const contentType = req.headers['content-type'];

            // Never send body for GET requests
            if (method === 'GET' || method === 'HEAD') {
              proxyReq.removeHeader('content-type');
              proxyReq.removeHeader('content-length');
              // Don't write any body for GET requests
            } else {
              // Prefer raw body captured by our middleware

              const raw = req.__rawBody;

              // Write captured body into the outgoing proxy request when present
              if (raw && raw.length > 0) {
                if (contentType) {
                  proxyReq.setHeader('content-type', contentType);
                }
                proxyReq.setHeader('content-length', Buffer.byteLength(raw));
                try {
                  proxyReq.write(raw);
                } catch (_e) {
                  // ignore write errors here; will be surfaced as proxy error
                }
              }
            }

            const preview =
              req.__rawBodyPreview && req.__rawBodyPreview.length > 0
                ? `\n📦 Body (${contentType || 'unknown'}):\n${formatMaybeJSON(req.__rawBodyPreview)}`
                : '';
            console.log(`📤 Sending Request to Target: ${method} ${url}${preview}`);
          });

          proxy.on('proxyRes', (proxyRes, req, res) => {
            const { statusCode = 0 } = proxyRes;

            const chunks = [];
            proxyRes.on('data', (chunk) => chunks.push(chunk));
            proxyRes.on('end', () => {
              const bodyBuffer = Buffer.concat(chunks);
              const contentType = proxyRes.headers['content-type'] || '';
              const isJSON =
                typeof contentType === 'string' && contentType.includes('application/json');

              // Format the response body
              let bodyPreview = '';
              if (bodyBuffer.length > 0) {
                bodyPreview = isJSON ? formatMaybeJSON(bodyBuffer) : bodyBuffer.toString('utf8');
              } else {
                bodyPreview = '(empty response body)';
              }

              // Log headers for debugging
              const importantHeaders = {
                'content-type': proxyRes.headers['content-type'],
                'content-length': proxyRes.headers['content-length'],
                'cache-control': proxyRes.headers['cache-control'],
                'etag': proxyRes.headers['etag'],
                'last-modified': proxyRes.headers['last-modified'],
                'x-cache': proxyRes.headers['x-cache']
              };

              const headersInfo = Object.entries(importantHeaders)
                .filter(([_, value]) => value !== undefined)
                .map(([key, value]) => `  ${key}: ${value}`)
                .join('\n');

              console.log(`📥 Received Response from Target: ${statusCode} ${req.url}`);
              if (headersInfo) {
                console.log(`📋 Response Headers:\n${headersInfo}`);
              }
              console.log(`📦 Response Body (${bodyBuffer.length} bytes):\n${bodyPreview}`);

              // For 304 responses, add extra debugging info
              if (statusCode === 304) {
                console.log('🔄 304 Not Modified Details:');
                console.log('   - This means the resource hasn\'t changed since last request');
                console.log('   - Client should use cached version');
                console.log('   - Response body is typically empty for 304');
              }

              // Forward response to the browser
              try {
                Object.entries(proxyRes.headers).forEach(([key, value]) => {
                  if (value !== undefined) {
                    res.setHeader(key, value);
                  }
                });
                res.statusCode = statusCode;
                res.end(bodyBuffer);
              } catch (err) {
                console.log('proxy response forwarding error', err);
                res.statusCode = 500;
                res.end('Proxy response error');
              }
            });
          });
        }
      }
    }
  }
});
