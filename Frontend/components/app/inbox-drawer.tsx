import React, { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Bell, Check, Trash2, MailOpen, Mail, RefreshCw } from 'lucide-react';
import { supabase } from '@/lib/supabase';
import { toast } from 'sonner';

interface InboxDrawerProps {
    isOpen: boolean;
    onClose: () => void;
    userId?: string;
    onNotificationChange?: () => void;
}

export interface Notification {
    id: string;
    title: string;
    message: string;
    type: string;
    is_read: boolean;
    created_at: string;
}

export const InboxDrawer = ({ isOpen, onClose, userId, onNotificationChange }: InboxDrawerProps) => {
    const [notifications, setNotifications] = useState<Notification[]>([]);
    const [loading, setLoading] = useState(false);
    const [selectedNotification, setSelectedNotification] = useState<Notification | null>(null);

    useEffect(() => {
        if (userId) {
            fetchNotifications();

            // Real-time subscription
            const channel = supabase
                .channel('public:user_notifications')
                .on('postgres_changes', {
                    event: '*',
                    schema: 'public',
                    table: 'user_notifications',
                    filter: `user_id=eq.${userId}`
                }, (payload) => {
                    console.log('Notification real-time event:', payload.eventType, payload);
                    if (payload.eventType === 'INSERT') {
                        setNotifications(prev => [payload.new as Notification, ...prev]);
                        toast.info('New message in Inbox!');
                        onNotificationChange?.(); // Update unread count
                    } else if (payload.eventType === 'UPDATE') {
                        setNotifications(prev => prev.map(n => n.id === payload.new.id ? payload.new as Notification : n));
                        onNotificationChange?.(); // Update unread count
                    } else if (payload.eventType === 'DELETE') {
                        setNotifications(prev => prev.filter(n => n.id !== payload.old.id));
                        onNotificationChange?.(); // Update unread count
                    }
                })
                .subscribe();

            return () => {
                supabase.removeChannel(channel);
            };
        }
    }, [userId]);

    // Refresh notifications when drawer opens
    useEffect(() => {
        if (isOpen && userId) {
            fetchNotifications();
        }
    }, [isOpen, userId]);

    const fetchNotifications = async () => {
        if (!userId) return;
        setLoading(true);
        const { data, error } = await supabase
            .from('user_notifications')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', { ascending: false });

        if (data) setNotifications(data);
        setLoading(false);
    };

    const markAsRead = async (id: string) => {
        // Optimistic update
        setNotifications(prev => prev.map(n => n.id === id ? { ...n, is_read: true } : n));
        await supabase.from('user_notifications').update({ is_read: true }).eq('id', id);
        onNotificationChange?.();
    };

    const markAllRead = async () => {
        // Optimistic update
        setNotifications(prev => prev.map(n => ({ ...n, is_read: true })));
        if (userId) {
            await supabase.from('user_notifications').update({ is_read: true }).eq('user_id', userId).eq('is_read', false);
            onNotificationChange?.();
        }
    };

    const deleteNotification = async (id: string) => {
        try {
            // Optimistic update
            setNotifications(prev => prev.filter(n => n.id !== id));

            const { error } = await supabase.from('user_notifications').delete().eq('id', id);

            if (error) {
                console.error('Error deleting notification:', error);
                // Revert optimistic update on error
                await fetchNotifications();
                toast.error('Failed to delete notification');
                return;
            }

            // Update unread count
            onNotificationChange?.();
            toast.success('Notification deleted');
        } catch (error) {
            console.error('Delete notification exception:', error);
            await fetchNotifications();
        }
    };

    const formatDate = (dateString: string) => {
        const date = new Date(dateString);
        return new Intl.DateTimeFormat('en-US', {
            month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit'
        }).format(date);
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
                        className="fixed inset-0 bg-black/60 backdrop-blur-sm z-[60]"
                    />

                    {/* Drawer */}
                    <motion.div
                        initial={{ x: '100%' }}
                        animate={{ x: 0 }}
                        exit={{ x: '100%' }}
                        transition={{ type: 'spring', damping: 25, stiffness: 200 }}
                        className="fixed right-0 top-0 h-full w-full max-w-md bg-[#0a0a0f] border-l border-white/10 shadow-2xl z-[70] flex flex-col"
                    >
                        {/* Header */}
                        <div className="p-6 border-b border-white/10 flex items-center justify-between bg-black/20">
                            <div className="flex items-center gap-3">
                                <div className="p-2 bg-purple-500/20 rounded-lg">
                                    <Bell className="text-purple-400" size={20} />
                                </div>
                                <div>
                                    <h2 className="text-xl font-bold text-white">Inbox</h2>
                                    <p className="text-sm text-white/40">Your notifications & updates</p>
                                </div>
                            </div>
                            <button
                                onClick={onClose}
                                className="p-2 hover:bg-white/10 rounded-full transition-colors text-white/60 hover:text-white"
                            >
                                <X size={20} />
                            </button>
                        </div>

                        {/* Actions */}
                        <div className="p-4 border-b border-white/10 flex justify-between items-center bg-white/5">
                            <span className="text-sm text-white/60">
                                {notifications.filter(n => !n.is_read).length} unread
                            </span>
                            <div className="flex gap-2">
                                <button
                                    onClick={fetchNotifications}
                                    className="p-2 hover:bg-white/10 rounded-lg text-white/60 hover:text-white transition-colors"
                                    title="Refresh"
                                >
                                    <RefreshCw size={16} className={loading ? 'animate-spin' : ''} />
                                </button>
                                <button
                                    onClick={markAllRead}
                                    className="flex items-center gap-2 px-3 py-1.5 text-xs font-medium bg-white/10 hover:bg-white/20 rounded-lg transition-colors text-white"
                                >
                                    <Check size={14} /> Mark all read
                                </button>
                            </div>
                        </div>

                        {/* List */}
                        <div className="flex-1 overflow-y-auto p-4 space-y-3">
                            {notifications.length === 0 ? (
                                <div className="flex flex-col items-center justify-center h-full text-white/40">
                                    <Bell size={48} className="mb-4 opacity-20" />
                                    <p>No notifications yet</p>
                                </div>
                            ) : (
                                notifications.map((notification) => (
                                    <motion.div
                                        key={notification.id}
                                        initial={{ opacity: 0, y: 10 }}
                                        animate={{ opacity: 1, y: 0 }}
                                        className={`relative p-4 rounded-xl border transition-all group ${notification.is_read
                                            ? 'bg-white/5 border-white/5 text-white/60'
                                            : 'bg-purple-500/10 border-purple-500/30 text-white'
                                            }`}
                                        onClick={() => {
                                            setSelectedNotification(notification);
                                            if (!notification.is_read) markAsRead(notification.id);
                                        }}
                                    >
                                        <div className="flex justify-between items-start mb-2">
                                            <h3 className={`font-semibold ${!notification.is_read ? 'text-purple-300' : ''}`}>
                                                {notification.title}
                                            </h3>
                                            <span className="text-xs text-white/40 whitespace-nowrap ml-2">
                                                {formatDate(notification.created_at)}
                                            </span>
                                        </div>

                                        <p className="text-sm leading-relaxed opacity-90 mb-3">
                                            {notification.message}
                                        </p>

                                        <div className="flex justify-between items-center mt-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                            <span className="text-xs px-2 py-1 rounded bg-white/10 uppercase tracking-wider">
                                                {notification.type}
                                            </span>
                                            <button
                                                onClick={(e) => {
                                                    e.stopPropagation();
                                                    deleteNotification(notification.id);
                                                }}
                                                className="p-1.5 hover:bg-red-500/20 text-white/40 hover:text-red-400 rounded transition-colors"
                                            >
                                                <Trash2 size={14} />
                                            </button>
                                        </div>

                                        {!notification.is_read && (
                                            <div className="absolute top-4 right-4 w-2 h-2 rounded-full bg-purple-500 shadow-[0_0_10px_rgba(168,85,247,0.5)]" />
                                        )}
                                    </motion.div>
                                ))
                            )}
                        </div>
                    </motion.div>

                    {/* Detailed Notification Modal */}
                    <AnimatePresence>
                        {selectedNotification && (
                            <>
                                <motion.div
                                    initial={{ opacity: 0 }}
                                    animate={{ opacity: 1 }}
                                    exit={{ opacity: 0 }}
                                    onClick={() => setSelectedNotification(null)}
                                    className="fixed inset-0 bg-black/80 backdrop-blur-sm z-[80]"
                                />
                                <motion.div
                                    initial={{ opacity: 0, scale: 0.9, y: 20 }}
                                    animate={{ opacity: 1, scale: 1, y: 0 }}
                                    exit={{ opacity: 0, scale: 0.9, y: 20 }}
                                    className="fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[calc(100%-2rem)] md:w-full max-w-2xl bg-[#0a0a0f] border border-white/20 rounded-2xl shadow-2xl z-[90] max-h-[80vh] overflow-hidden m-4"
                                >
                                    {/* Header */}
                                    <div className="p-6 border-b border-white/10 bg-gradient-to-r from-purple-500/10 to-pink-500/10">
                                        <div className="flex items-start justify-between mb-4">
                                            <div className="flex items-center gap-3">
                                                <div className="w-12 h-12 rounded-full bg-gradient-to-br from-purple-600 to-pink-600 flex items-center justify-center shadow-lg">
                                                    <span className="text-white font-bold text-lg">
                                                        {selectedNotification.type === 'success' ? '✅' :
                                                            selectedNotification.type === 'error' ? '❌' :
                                                                selectedNotification.type === 'info' ? '📢' : '📧'}
                                                    </span>
                                                </div>
                                                <div>
                                                    <h3 className="text-xl font-bold text-white">{selectedNotification.title}</h3>
                                                    <p className="text-sm text-white/60">From: VYAAS AI Admin</p>
                                                </div>
                                            </div>
                                            <button
                                                onClick={() => setSelectedNotification(null)}
                                                className="p-2 hover:bg-white/10 rounded-full transition-colors text-white/60 hover:text-white"
                                            >
                                                <X size={20} />
                                            </button>
                                        </div>
                                        <div className="flex items-center gap-4 text-sm text-white/60">
                                            <span>To: You</span>
                                            <span>•</span>
                                            <span>{new Date(selectedNotification.created_at).toLocaleString('en-US', {
                                                weekday: 'short',
                                                year: 'numeric',
                                                month: 'short',
                                                day: 'numeric',
                                                hour: '2-digit',
                                                minute: '2-digit'
                                            })}</span>
                                        </div>
                                    </div>

                                    {/* Body */}
                                    <div className="p-6 overflow-y-auto max-h-[50vh]">
                                        <div className="prose prose-invert max-w-none">
                                            <p className="text-white/90 leading-relaxed whitespace-pre-wrap">
                                                {selectedNotification.message}
                                            </p>
                                        </div>
                                    </div>

                                    {/* Footer */}
                                    <div className="p-4 border-t border-white/10 bg-white/5 flex justify-between items-center">
                                        <span className="text-xs px-3 py-1.5 rounded-full bg-white/10 uppercase tracking-wider text-white/60">
                                            {selectedNotification.type}
                                        </span>
                                        <button
                                            onClick={() => {
                                                deleteNotification(selectedNotification.id);
                                                setSelectedNotification(null);
                                            }}
                                            className="flex items-center gap-2 px-4 py-2 bg-red-500/20 hover:bg-red-500/30 text-red-400 rounded-lg transition-colors"
                                        >
                                            <Trash2 size={16} />
                                            Delete
                                        </button>
                                    </div>
                                </motion.div>
                            </>
                        )}
                    </AnimatePresence>
                </>
            )}
        </AnimatePresence>
    );
};
