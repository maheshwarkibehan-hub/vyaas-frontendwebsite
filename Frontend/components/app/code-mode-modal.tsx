'use client';

import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Code2, Play, Copy, Check, Terminal, Loader2 } from 'lucide-react';
import { auth } from '@/lib/firebase';
import { getUserSubscription, deductCredits, COSTS } from '@/lib/subscription';
import { toast } from 'sonner';

interface CodeModeModalProps {
    isOpen: boolean;
    onClose: () => void;
}

export function CodeModeModal({ isOpen, onClose }: CodeModeModalProps) {
    const [prompt, setPrompt] = useState('');
    const [generatedCode, setGeneratedCode] = useState('');
    const [language, setLanguage] = useState('javascript');
    const [loading, setLoading] = useState(false);
    const [copied, setCopied] = useState(false);
    const [codeTokens, setCodeTokens] = useState(0);

    React.useEffect(() => {
        if (isOpen) {
            const fetchTokens = async () => {
                if (auth.currentUser) {
                    const sub = await getUserSubscription(auth.currentUser.uid);
                    if (sub) setCodeTokens(sub.code_tokens || 0);
                }
            };
            fetchTokens();
        }
    }, [isOpen]);

    const handleGenerate = async () => {
        if (!prompt.trim()) {
            toast.error('Please enter a prompt!');
            return;
        }

        setLoading(true);
        try {
            // Placeholder code generation
            const placeholderCode = `// ${prompt}\n\nfunction solution() {\n  // TODO: Implement logic\n  console.log("${prompt}");\n  return "Success!";\n}\n\nconst result = solution();\nconsole.log(result);`;

            setGeneratedCode(placeholderCode);
            setCodeTokens(prev => Math.max(0, prev - 1));
            toast.success('Code generated!');
        } catch (error) {
            toast.error('Failed to generate code');
        } finally {
            setLoading(false);
        }
    };

    const handleCopy = () => {
        navigator.clipboard.writeText(generatedCode);
        setCopied(true);
        toast.success('Copied!');
        setTimeout(() => setCopied(false), 2000);
    };

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
                        className="fixed inset-0 bg-black/80 backdrop-blur-sm z-[100]"
                    />

                    {/* Modal */}
                    <motion.div
                        initial={{ opacity: 0, scale: 0.9, y: 20 }}
                        animate={{ opacity: 1, scale: 1, y: 0 }}
                        exit={{ opacity: 0, scale: 0.9, y: 20 }}
                        className="fixed inset-4 md:inset-auto md:left-1/2 md:top-1/2 md:-translate-x-1/2 md:-translate-y-1/2 md:w-[700px] md:max-h-[80vh] bg-black border border-white/20 rounded-2xl z-[101] overflow-hidden flex flex-col"
                    >
                        {/* Header */}
                        <div className="flex items-center justify-between p-6 border-b border-white/10">
                            <div className="flex items-center gap-3">
                                <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-green-500 to-blue-500 flex items-center justify-center">
                                    <Terminal size={20} className="text-white" />
                                </div>
                                <div>
                                    <h2 className="text-xl font-bold text-white">AI Code Generator</h2>
                                    <p className="text-sm text-white/60">{codeTokens} tokens available</p>
                                </div>
                            </div>
                            <button onClick={onClose} className="p-2 hover:bg-white/10 rounded-lg transition-colors">
                                <X size={20} className="text-white/60" />
                            </button>
                        </div>

                        {/* Content */}
                        <div className="flex-1 overflow-y-auto p-6 space-y-6">
                            {/* Input */}
                            <div>
                                <label className="block text-sm font-medium text-white/80 mb-2">
                                    Language
                                </label>
                                <select
                                    value={language}
                                    onChange={(e) => setLanguage(e.target.value)}
                                    className="w-full mb-3 px-4 py-2 bg-white/5 border border-white/10 rounded-xl text-white focus:outline-none focus:border-green-500"
                                    disabled={loading}
                                >
                                    <option value="javascript">JavaScript</option>
                                    <option value="python">Python</option>
                                    <option value="typescript">TypeScript</option>
                                    <option value="java">Java</option>
                                </select>

                                <label className="block text-sm font-medium text-white/80 mb-2">
                                    What code do you need?
                                </label>
                                <textarea
                                    value={prompt}
                                    onChange={(e) => setPrompt(e.target.value)}
                                    placeholder="Create a function that sorts an array..."
                                    className="w-full h-24 px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-green-500 transition-all resize-none"
                                    disabled={loading}
                                />
                                <button
                                    onClick={handleGenerate}
                                    disabled={loading || !prompt.trim()}
                                    className="mt-3 w-full px-6 py-3 bg-gradient-to-r from-green-600 to-blue-600 hover:from-green-500 hover:to-blue-500 rounded-xl font-bold shadow-lg transition-all disabled:opacity-50 flex items-center justify-center gap-2"
                                >
                                    {loading ? (
                                        <>
                                            <Loader2 className="animate-spin" size={18} />
                                            Generating...
                                        </>
                                    ) : (
                                        <>
                                            <Play size={18} />
                                            Generate
                                        </>
                                    )}
                                </button>
                            </div>

                            {/* Generated Code */}
                            {generatedCode && (
                                <motion.div
                                    initial={{ opacity: 0 }}
                                    animate={{ opacity: 1 }}
                                    className="space-y-3"
                                >
                                    <div className="flex items-center justify-between">
                                        <span className="text-sm font-medium text-white/80">Generated Code</span>
                                        <button
                                            onClick={handleCopy}
                                            className="flex items-center gap-2 px-3 py-1.5 bg-white/10 hover:bg-white/20 rounded-lg transition-all text-sm"
                                        >
                                            {copied ? <Check size={14} className="text-green-400" /> : <Copy size={14} />}
                                            {copied ? 'Copied!' : 'Copy'}
                                        </button>
                                    </div>
                                    <div className="bg-black/80 border border-white/10 rounded-xl overflow-hidden">
                                        <div className="px-4 py-2 bg-white/5 border-b border-white/10 flex items-center gap-2">
                                            <div className="w-3 h-3 rounded-full bg-red-500" />
                                            <div className="w-3 h-3 rounded-full bg-yellow-500" />
                                            <div className="w-3 h-3 rounded-full bg-green-500" />
                                            <span className="ml-2 text-xs text-white/60">{language}</span>
                                        </div>
                                        <pre className="p-4 overflow-x-auto">
                                            <code className="text-sm text-green-400 font-mono">{generatedCode}</code>
                                        </pre>
                                    </div>
                                </motion.div>
                            )}
                        </div>
                    </motion.div>
                </>
            )}
        </AnimatePresence>
    );
}
