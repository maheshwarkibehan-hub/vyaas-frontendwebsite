'use client';

import React from 'react';
import { motion } from 'framer-motion';
import { LucideIcon } from 'lucide-react';

interface TokenBalanceProps {
    count: number;
    icon: LucideIcon;
    label: string;
    color: 'blue' | 'green' | 'purple';
}

export function TokenBalance({ count, icon: Icon, label, color }: TokenBalanceProps) {
    const colorStyles = {
        blue: 'from-blue-500/20 to-cyan-500/20 border-blue-500/30 text-blue-400 hover:bg-blue-500/30',
        green: 'from-green-500/20 to-emerald-500/20 border-green-500/30 text-green-400 hover:bg-green-500/30',
        purple: 'from-purple-500/20 to-pink-500/20 border-purple-500/30 text-purple-400 hover:bg-purple-500/30',
    };

    return (
        <motion.div
            whileHover={{ scale: 1.05 }}
            className={`flex items-center gap-2 px-3 py-1.5 bg-gradient-to-r ${colorStyles[color]} border rounded-full transition-colors cursor-default`}
            title={label}
        >
            <Icon size={14} />
            <span className="font-bold text-sm">{count}</span>
        </motion.div>
    );
}
