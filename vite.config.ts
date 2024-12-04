import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    host: '0.0.0.0', // Allow external access
    strictPort: true,
    watch: {
      usePolling: true,
      interval: 100
    }
  },
  preview: {
    port: 3000,
    host: '0.0.0.0', // Allow external access for preview mode
    strictPort: true,
  },
  optimizeDeps: {
    exclude: ['lucide-react']
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom', 'react-router-dom'],
          'ui-vendor': ['@headlessui/react', '@tremor/react', 'lucide-react'],
          'editor-vendor': ['@tiptap/core', '@tiptap/react', '@tiptap/starter-kit']
        }
      }
    }
  }
});
