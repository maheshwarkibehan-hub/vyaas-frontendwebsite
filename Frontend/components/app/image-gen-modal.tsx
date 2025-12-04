'use client';

import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, ExternalLink } from 'lucide-react';

interface ImageGenModalProps {
    isOpen: boolean;
    onClose: () => void;
}

export function ImageGenModal({ isOpen, onClose }: ImageGenModalProps) {
    return (
        <AnimatePresence>
            {isOpen && (
                <>
                    {/* Backdrop */}
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        onClick={onClose}
                        className="fixed inset-0 bg-black/95 backdrop-blur-sm z-[100]"
                    />

                    {/* Full Screen Modal */}
                    <motion.div
                        initial={{ opacity: 0, scale: 0.95 }}
                        animate={{ opacity: 1, scale: 1 }}
                        exit={{ opacity: 0, scale: 0.95 }}
                        className="fixed inset-0 md:inset-4 bg-black border-0 md:border md:border-white/20 md:rounded-2xl z-[101] overflow-hidden flex flex-col"
                    >
                        {/* Minimal Header */}
                        <div className="flex items-center justify-between px-4 py-3 bg-black/50 backdrop-blur-md border-b border-white/10">
                            <div className="flex items-center gap-2">
                                <div className="w-2 h-2 rounded-full bg-purple-500 animate-pulse" />
                                <span className="text-sm text-white/60 font-medium">AI Image Generator</span>
                            </div>
                            <button
                                onClick={onClose}
                                className="p-2 hover:bg-white/10 rounded-lg transition-colors"
                            >
                                <X size={20} className="text-white/80" />
                            </button>
                        </div>

                        {/* Full Screen iframe */}
                        <div className="flex-1 relative bg-black">
                            <iframe
                                src="https://vyaasai.lovable.app/"
                                className="absolute inset-0 w-full h-full border-0"
                                title="AI Image Generator"
                                allow="camera; microphone; clipboard-write"
                                sandbox="allow-same-origin allow-scripts allow-forms allow-popups allow-modals"
                            />
                        </div>
                    </motion.div>
                </>
            )}
        </AnimatePresence>
    );
}
