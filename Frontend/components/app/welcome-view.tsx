import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { auth } from '@/lib/firebase';
import { onAuthStateChanged, signOut } from 'firebase/auth';
import { useAuthUI } from '@/components/app/auth-ui-provider';
import { PricingModal } from '@/components/app/pricing-modal';
import { getUserSubscription, type PlanType } from '@/lib/subscription';
import { isUserBlocked, checkSessionStatus, clearForceLogout } from '@/lib/supabase';
import { SuspendedModal } from '@/components/app/suspended-modal';
import { DailyRewardsModal } from '@/components/app/daily-rewards-modal';
import { Crown, Zap, Sparkles, Code, Image, MessageSquare, Shield, Clock, Users, Mic, Brain, Rocket, Gift } from 'lucide-react';
import { toast } from 'sonner';

const FeatureCard = ({ icon: Icon, title, desc, delay }: { icon: any, title: string, desc: string, delay: number }) => (
  <motion.div
    initial={{ opacity: 0, y: 30 }}
    whileInView={{ opacity: 1, y: 0 }}
    viewport={{ once: true }}
    transition={{ duration: 0.6, delay }}
    whileHover={{ scale: 1.05, y: -5 }}
    className="p-6 rounded-2xl bg-gradient-to-br from-white/5 to-white/10 border border-white/10 backdrop-blur-md hover:border-purple-500/50 transition-all group"
  >
    <div className="w-14 h-14 rounded-xl bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
      <Icon size={28} className="text-white" />
    </div>
    <h3 className="text-xl font-bold text-white mb-2">{title}</h3>
    <p className="text-white/60 leading-relaxed">{desc}</p>
  </motion.div>
);

const PlanCard = ({ name, price, features, popular, delay }: { name: string, price: string, features: string[], popular?: boolean, delay: number }) => (
  <motion.div
    initial={{ opacity: 0, scale: 0.9 }}
    whileInView={{ opacity: 1, scale: 1 }}
    viewport={{ once: true }}
    transition={{ duration: 0.5, delay }}
    whileHover={{ scale: 1.05 }}
    className={`relative p-8 rounded-3xl backdrop-blur-md transition-all ${popular
      ? 'bg-gradient-to-br from-purple-500/20 to-pink-500/20 border-2 border-purple-500'
      : 'bg-white/5 border border-white/10 hover:border-white/30'
      }`}
  >
    {popular && (
      <div className="absolute -top-4 left-1/2 -translate-x-1/2 bg-gradient-to-r from-purple-500 to-pink-500 text-white px-4 py-1 rounded-full text-sm font-bold flex items-center gap-1">
        <Sparkles size={14} /> POPULAR
      </div>
    )}
    <h3 className="text-2xl font-bold text-white mb-2">{name}</h3>
    <div className="flex items-baseline gap-2 mb-6">
      <span className="text-4xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-purple-400 to-pink-400">₹{price}</span>
      <span className="text-white/40">/month</span>
    </div>
    <ul className="space-y-3 mb-6">
      {features.map((feature, idx) => (
        <li key={idx} className="flex items-start gap-2 text-white/80">
          <Zap size={16} className="text-yellow-400 mt-1 flex-shrink-0" fill="currentColor" />
          <span>{feature}</span>
        </li>
      ))}
    </ul>
  </motion.div>
);

interface WelcomeViewProps {
  startButtonText: string;
  onStartCall: () => void;
}

export const WelcomeView = ({
  startButtonText,
  onStartCall,
  ref,
}: React.ComponentProps<'div'> & WelcomeViewProps) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const { openAuthModal } = useAuthUI();
  const [showSuccessMessage, setShowSuccessMessage] = useState(false);
  const [isBlocked, setIsBlocked] = useState(false);
  const [checkingBlock, setCheckingBlock] = useState(false);
  const [showPricing, setShowPricing] = useState(false);
  const [currentPlan, setCurrentPlan] = useState<PlanType>('free');
  const [credits, setCredits] = useState(0);
  const [showDailyRewards, setShowDailyRewards] = useState(false);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        setIsAuthenticated(true);

        // Check if user is blocked
        const blocked = await isUserBlocked(user.uid);
        setIsBlocked(blocked);

        // Check if session is valid (Force Logout Check)
        const isSessionValid = await checkSessionStatus(user.uid, user.metadata.lastSignInTime);
        if (!isSessionValid) {
          // Clear force logout record so user can login again
          await clearForceLogout(user.uid);
          await signOut(auth);
          toast.error('Your session has been invalidated by an admin.');
          return;
        }

        const sub = await getUserSubscription(user.uid);
        if (sub) {
          setCurrentPlan(sub.plan_type as PlanType);
          setCredits(sub.credits);
        }
      } else {
        setIsAuthenticated(false);
        setIsBlocked(false);
      }
    });
    return () => unsubscribe();
  }, []);

  const handleGetStarted = async () => {
    if (!isAuthenticated) {
      openAuthModal();
      return;
    }

    // Check if user is blocked before starting session
    if (auth.currentUser) {
      setCheckingBlock(true);
      const blocked = await isUserBlocked(auth.currentUser.uid);
      setCheckingBlock(false);

      if (blocked) {
        setIsBlocked(true);
        return; // Don't logout, just show modal
      }
    }

    onStartCall();
  };

  const features = [
    { icon: Mic, title: "Voice AI Assistant", desc: "Natural voice conversations with advanced AI powered by Google Gemini" },
    { icon: Brain, title: "Smart Responses", desc: "Context-aware AI that understands and remembers your conversations" },
    { icon: Image, title: "Image Generation", desc: "Create stunning images from text descriptions using AI" },
    { icon: Code, title: "Code Assistance", desc: "Get help with coding, debugging, and technical questions" },
    { icon: MessageSquare, title: "Real-time Chat", desc: "Instant text-based conversations with AI assistant" },
    { icon: Shield, title: "Secure & Private", desc: "Your data is encrypted and protected with enterprise-grade security" },
  ];

  const plans = [
    { name: "Free", price: "0", features: ["100 Credits/month", "5 min sessions", "Basic AI chat", "5 Images", "Community support"] },
    { name: "Pro", price: "199", features: ["500 Credits/month", "10 hour sessions", "Advanced AI", "25 Images", "Priority support", "Code mode"], popular: true },
    { name: "Ultra", price: "499", features: ["2000 Credits/month", "Unlimited sessions", "Premium AI", "Unlimited images", "VIP support 24/7", "All features", "Early access"] },
  ];

  return (
    <div ref={ref} className="min-h-screen bg-black text-white overflow-hidden relative">
      {/* Background Effects */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-0 left-1/4 w-96 h-96 bg-purple-500/20 rounded-full blur-[120px] animate-pulse" />
        <div className="absolute bottom-0 right-1/4 w-96 h-96 bg-pink-500/20 rounded-full blur-[120px] animate-pulse" style={{ animationDelay: '1s' }} />
        <div className="absolute top-1/2 left-1/2 w-96 h-96 bg-blue-500/10 rounded-full blur-[120px] animate-pulse" style={{ animationDelay: '2s' }} />
      </div>

      {/* Hero Section */}
      <section className="relative min-h-screen flex items-center justify-center px-6 py-20">
        <div className="max-w-6xl mx-auto text-center">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            className="mb-8"
          >
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 backdrop-blur-md border border-white/20 mb-6">
              <Sparkles size={16} className="text-yellow-400" />
              <span className="text-sm font-medium">Powered by Google Gemini AI</span>
            </div>
            <h1 className="text-5xl sm:text-6xl md:text-8xl font-bold mb-6 bg-clip-text text-transparent bg-gradient-to-r from-purple-400 via-pink-400 to-blue-400 leading-tight px-4">
              VYAAS AI
            </h1>
            <p className="text-xl sm:text-2xl md:text-3xl text-white/80 mb-4 px-4">Your Intelligent AI Assistant</p>
            <p className="text-base sm:text-lg text-white/60 max-w-2xl mx-auto mb-12 px-6">
              Experience the future of AI interaction with voice, chat, and image generation - all in one powerful platform
            </p>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="flex flex-col sm:flex-row gap-3 md:gap-4 justify-center items-center mb-12 px-4"
          >
            <div className="flex flex-col sm:flex-row gap-3 md:gap-4 w-full sm:w-auto">
              <motion.button
                onClick={handleGetStarted}
                disabled={checkingBlock}
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className="px-6 py-3 md:px-8 md:py-4 bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-500 hover:to-pink-500 rounded-2xl text-white font-bold text-base md:text-lg shadow-2xl shadow-purple-500/50 transition-all disabled:opacity-50 disabled:cursor-not-allowed w-full sm:w-auto"
              >
                {checkingBlock ? (
                  <div className="flex items-center gap-2 justify-center">
                    <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                    Checking...
                  </div>
                ) : (
                  startButtonText
                )}
              </motion.button>
              {isAuthenticated && (
                <motion.button
                  onClick={() => setShowDailyRewards(true)}
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  className="px-6 py-3 md:px-8 md:py-4 bg-gradient-to-r from-yellow-600 to-orange-600 hover:from-yellow-500 hover:to-orange-500 rounded-2xl text-white font-bold text-base md:text-lg shadow-2xl shadow-yellow-500/50 transition-all flex items-center gap-2 justify-center w-full sm:w-auto"
                >
                  <Gift size={20} className="md:w-6 md:h-6" />
                  <span className="whitespace-nowrap">Daily Reward</span>
                </motion.button>
              )}
            </div>
            <button
              onClick={() => setShowPricing(true)}
              className="px-6 py-3 md:px-8 md:py-4 bg-white/10 hover:bg-white/20 backdrop-blur-md border border-white/20 rounded-xl font-bold text-base md:text-lg transition-all hover:scale-105 active:scale-95 flex items-center gap-2 justify-center w-full sm:w-auto"
            >
              <Crown size={18} className="md:w-5 md:h-5 text-yellow-400" />
              <span className="whitespace-nowrap">View Plans</span>
            </button>
          </motion.div>


        </div>
      </section>

      {/* Features Section */}
      <section className="relative py-20 px-6">
        <div className="max-w-7xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            className="text-center mb-16"
          >
            <h2 className="text-4xl md:text-5xl font-bold mb-4 bg-clip-text text-transparent bg-gradient-to-r from-purple-400 to-pink-400">
              Powerful Features
            </h2>
            <p className="text-xl text-white/60">Everything you need in one AI platform</p>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {features.map((feature, idx) => (
              <FeatureCard key={idx} {...feature} delay={idx * 0.1} />
            ))}
          </div>
        </div>
      </section>

      {/* Pricing Section */}
      <section className="relative py-20 px-6">
        <div className="max-w-7xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            className="text-center mb-16"
          >
            <h2 className="text-4xl md:text-5xl font-bold mb-4 bg-clip-text text-transparent bg-gradient-to-r from-purple-400 to-pink-400">
              Choose Your Plan
            </h2>
            <p className="text-xl text-white/60">Flexible pricing for everyone</p>
          </motion.div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-6xl mx-auto">
            {plans.map((plan, idx) => (
              <PlanCard key={idx} {...plan} delay={idx * 0.15} />
            ))}
          </div>

          <motion.div
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, delay: 0.5 }}
            className="text-center mt-12"
          >
            <button
              onClick={() => setShowPricing(true)}
              className="px-8 py-4 bg-gradient-to-r from-blue-600 to-cyan-600 hover:from-blue-500 hover:to-cyan-500 rounded-xl font-bold text-lg shadow-lg transition-all hover:scale-105"
            >
              Get Started Now
            </button>
          </motion.div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="relative py-20 px-6">
        <div className="max-w-6xl mx-auto">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            {[
              { icon: Users, value: "10K+", label: "Active Users" },
              { icon: MessageSquare, value: "1M+", label: "Conversations" },
              { icon: Image, value: "500K+", label: "Images Created" },
              { icon: Clock, value: "24/7", label: "Availability" },
            ].map((stat, idx) => (
              <motion.div
                key={idx}
                initial={{ opacity: 0, scale: 0.8 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: idx * 0.1 }}
                className="text-center"
              >
                <div className="w-16 h-16 mx-auto mb-4 rounded-2xl bg-gradient-to-br from-purple-500/20 to-pink-500/20 border border-white/10 flex items-center justify-center">
                  <stat.icon size={32} className="text-purple-400" />
                </div>
                <div className="text-3xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-purple-400 to-pink-400 mb-2">
                  {stat.value}
                </div>
                <div className="text-white/60">{stat.label}</div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="relative py-12 px-6 border-t border-white/10">
        <div className="max-w-7xl mx-auto">
          <div className="flex flex-col md:flex-row justify-between items-center gap-6">
            <div className="text-center md:text-left">
              <h3 className="text-2xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-purple-400 to-pink-400 mb-2">
                VYAAS AI
              </h3>
              <p className="text-white/60">Your Intelligent AI Assistant</p>
            </div>
            <div className="flex flex-col items-center md:items-end gap-2">
              <p className="text-white/60">© 2025 Maheshwar. All rights reserved.</p>
              <p className="text-white/40 text-sm">Powered by Google Gemini & LiveKit</p>
            </div>
          </div>
        </div>
      </footer>

      {/* Pricing Modal */}
      <PricingModal
        isOpen={showPricing}
        onClose={() => setShowPricing(false)}
        currentPlan={currentPlan}
        onSuccess={async () => {
          if (auth.currentUser) {
            const sub = await getUserSubscription(auth.currentUser.uid);
            if (sub) {
              setCurrentPlan(sub.plan_type as PlanType);
              setCredits(sub.credits);
            }
          }
        }}
      />

      {/* Suspended Modal */}
      <SuspendedModal isOpen={isBlocked} />

      {/* Daily Rewards Modal */}
      <DailyRewardsModal
        isOpen={showDailyRewards}
        onClose={() => setShowDailyRewards(false)}
      />
    </div>
  );
};