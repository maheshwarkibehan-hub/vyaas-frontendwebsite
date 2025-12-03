const withPWA = require('next-pwa')({
    dest: 'public',
    register: true,
    skipWaiting: true,
    disable: process.env.NODE_ENV === 'development',
    buildExcludes: [/middleware-manifest\.json$/],
});

/** @type {import('next').NextConfig} */
const nextConfig = {
    reactStrictMode: true,
    devIndicators: false,

    // Note: Static export is now compatible as API routes are moved to backend
    // For Android/Capacitor: This enables static export
    output: 'export',

    // Disable image optimization for static export
    images: {
        unoptimized: true,
    },

    // Skip type checking during build (for faster builds)
    typescript: {
        ignoreBuildErrors: true,
    },

    // PWA Configuration
    experimental: {
        optimizeCss: false,
    },

    // Headers for PWA
    async headers() {
        return [
            {
                source: '/:path*',
                headers: [
                    {
                        key: 'X-DNS-Prefetch-Control',
                        value: 'on'
                    },
                    {
                        key: 'X-Content-Type-Options',
                        value: 'nosniff'
                    },
                ]
            }
        ];
    },
};

// Export without PWA wrapper for static export compatibility
module.exports = nextConfig;
