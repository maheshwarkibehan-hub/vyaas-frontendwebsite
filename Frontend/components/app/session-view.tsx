'use client';

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X } from 'lucide-react';
import type { AppConfig } from '@/app-config';
import { ChatTranscript } from '@/components/app/chat-transcript';
import { PreConnectMessage } from '@/components/app/preconnect-message';
import { TileLayout } from '@/components/app/tile-layout';
import {
  AgentControlBar,
  type ControlBarControls,
} from '@/components/livekit/agent-control-bar/agent-control-bar';
import { useChatMessages } from '@/hooks/useChatMessages';
import { useConnectionTimeout } from '@/hooks/useConnectionTimout';
import { useDebugMode } from '@/hooks/useDebug';
import { cn } from '@/lib/utils';
import { useResponsive } from '@/lib/responsive-utils';
import { ScrollArea } from '../livekit/scroll-area/scroll-area';
import { auth } from '@/lib/firebase';
import { saveChatHistory, updateUserLogin } from '@/lib/supabase';
import { getUserSubscription, deductCredits, COSTS, type PlanType } from '@/lib/subscription';
import { PricingModal } from '@/components/app/pricing-modal';
import { CreditBalance } from '@/components/app/credit-balance';
import { toast } from 'sonner';
import { useRoomContext } from '@livekit/components-react';
import { ImageGenModal } from '@/components/app/image-gen-modal';
import { CodeModeModal } from '@/components/app/code-mode-modal';

const MotionBottom = motion.create('div');

const IN_DEVELOPMENT = process.env.NODE_ENV !== 'production';

interface FadeProps {
  top?: boolean;
  bottom?: boolean;
  className?: string;
}

export function Fade({ top = false, bottom = false, className }: FadeProps) {
  return (
    <div
      className={cn(
        'from-background pointer-events-none h-4 bg-linear-to-b to-transparent',
        top && 'bg-linear-to-b',
        bottom && 'bg-linear-to-t',
        className
      )}
    />
  );
}
interface SessionViewProps {
  appConfig: AppConfig;
}

export const SessionView = ({
  appConfig,
  ...props
}: React.ComponentProps<'section'> & SessionViewProps) => {
  useConnectionTimeout(200_000);
  useDebugMode({ enabled: IN_DEVELOPMENT });

  const messages = useChatMessages();
  const [chatOpen, setChatOpen] = useState(true);
  const { isMobile, isTablet, isLandscape, isLargeTablet } = useResponsive();

  // Subscription State
  const [credits, setCredits] = useState(0);
  const [planType, setPlanType] = useState<PlanType>('free');
  const [imageTokens, setImageTokens] = useState(0);
  const [codeTokens, setCodeTokens] = useState(0);
  const [showPricing, setShowPricing] = useState(false);
  const [timeLeft, setTimeLeft] = useState<number | null>(null);

  // Modal States
  const [showImageGen, setShowImageGen] = useState(false);
  const [showCodeMode, setShowCodeMode] = useState(false);

  const room = useRoomContext();

  // Fetch Subscription
  const fetchSub = async () => {
    if (auth.currentUser) {
      const sub = await getUserSubscription(auth.currentUser.uid);
      if (sub) {
        setCredits(sub.credits);
        setPlanType(sub.plan_type);
        setImageTokens(sub.image_tokens || 0);
        setCodeTokens(sub.code_tokens || 0);

        // Set Timer for Free Plan
        if (sub.plan_type === 'free') {
          setTimeLeft(5 * 60); // 5 minutes
        } else if (sub.plan_type === 'pro') {
          setTimeLeft(10 * 60 * 60); // 10 hours
        } else {
          setTimeLeft(null); // Unlimited
        }
      }
    }
  };

  useEffect(() => {
    fetchSub();
    const trackLogin = async () => {
      if (auth.currentUser) {
        await updateUserLogin(auth.currentUser.uid, auth.currentUser.email || '');
      }
    };
    trackLogin();
  }, []);

  // Timer Logic
  useEffect(() => {
    if (timeLeft === null || timeLeft <= 0) return;

    const timer = setInterval(() => {
      setTimeLeft((prev) => {
        if (prev !== null && prev <= 1) {
          clearInterval(timer);
          room.disconnect();
          toast.error("Session time limit reached! Please upgrade.");
          setShowPricing(true);
          return 0;
        }
        return prev !== null ? prev - 1 : null;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [timeLeft, room]);


  // Auto-open chat when messages arrive and keep it open
  useEffect(() => {
    if (messages.length > 0) {
      setChatOpen(true);
    }
  }, [messages.length]); // Only depend on message count, not chatOpen state

  // Action Handlers
  const handleAction = async (cost: number, action: () => void, reason: string, type?: 'image' | 'code') => {
    if (!auth.currentUser) return;

    // Optimistic check
    let canProceed = false;
    if (type === 'image' && imageTokens > 0) canProceed = true;
    else if (type === 'code' && codeTokens > 0) canProceed = true;
    else if (credits >= cost) canProceed = true;

    if (!canProceed) {
      toast.error(`Not enough credits or tokens! Need ${cost} credits.`);
      setShowPricing(true);
      return;
    }

    const success = await deductCredits(auth.currentUser.uid, cost, reason, type);
    if (success) {
      if (type === 'image' && imageTokens > 0) setImageTokens(prev => prev - 1);
      else if (type === 'code' && codeTokens > 0) setCodeTokens(prev => prev - 1);
      else setCredits(prev => prev - cost);

      action();
    } else {
      toast.error("Transaction failed. Please try again.");
      setShowPricing(true);
    }
  };

  const controls: ControlBarControls = {
    leave: true,
    microphone: true,
    chat: appConfig.supportsChatInput,
    camera: appConfig.supportsVideoInput,
    screenShare: appConfig.supportsVideoInput,
  };

  return (
    <section className="relative z-10 h-full w-full overflow-hidden flex" {...props}>
      {/* Main Session Area */}
      <div className="h-full w-full flex flex-col">

        {/* Top Bar with Credits */}
        <div className="absolute top-4 right-4 z-50 flex items-center gap-4">
          {timeLeft !== null && (
            <div className={cn(
              "px-3 py-1 rounded-full text-xs font-mono font-bold border",
              timeLeft < 60 ? "bg-red-500/20 border-red-500 text-red-400 animate-pulse" : "bg-black/40 border-white/10 text-white/60"
            )}>
              {Math.floor(timeLeft / 60)}:{(timeLeft % 60).toString().padStart(2, '0')}
            </div>
          )}
        </div>

        {/* Main Chat Area */}
        <div className="flex-1 flex flex-col">
          <div className="flex-1 overflow-hidden">
            <div
              className={cn(
                'h-full grid grid-cols-1 grid-rows-1',
                !chatOpen && 'pointer-events-none'
              )}
            >
              <ScrollArea className={cn(
                "pt-16",
                isMobile ? "px-3 pb-[180px]" : isLargeTablet ? "px-10 pb-[280px]" : isTablet ? "px-5 pb-[220px]" : "px-6 pb-[250px]"
              )}>
                <ChatTranscript
                  hidden={false}
                  messages={messages}
                  className={cn(
                    "mx-auto space-y-3",
                    isMobile ? "max-w-full" : isLargeTablet ? "max-w-6xl" : isTablet ? "max-w-3xl" : "max-w-4xl",
                    !chatOpen && "pointer-events-none"
                  )}
                />
              </ScrollArea>
            </div>
          </div>

          {/* Control Bar */}
          <div className={cn(
            "fixed bottom-0 left-0 right-0 z-50 border-t border-white/10 bg-black/10 backdrop-blur-md safe-bottom",
            isMobile ? "p-2" : isLargeTablet ? "p-6" : "p-4"
          )}>
            {appConfig.isPreConnectBufferEnabled && (
              <PreConnectMessage messages={messages} className="pb-4" />
            )}
            <div className={cn(
              "mx-auto",
              isMobile ? "max-w-full" : isLargeTablet ? "max-w-6xl" : isTablet ? "max-w-3xl" : "max-w-4xl"
            )}>
              <Fade bottom className="absolute inset-x-0 top-0 h-4 -translate-y-full" />
              <AgentControlBar
                controls={controls}
                onChatOpenChange={(open) => {
                  if (open) {
                    handleAction(COSTS.CHAT_MESSAGE, () => setChatOpen(true), 'Chat Message');
                  } else {
                    // Don't allow closing chat if there are messages - keep them visible
                    if (messages.length === 0) {
                      setChatOpen(false);
                    } else {
                      // Chat stays open when messages exist
                      console.log('[SessionView] Cannot close chat - messages exist');
                    }
                  }
                }}
                onWebsiteClick={() => handleAction(COSTS.IMAGE_GEN, () => setShowImageGen(true), 'Image Generation', 'image')}
                onCodeClick={() => handleAction(COSTS.CODE_MODE, () => setShowCodeMode(true), 'Code Mode', 'code')}
                onDisconnect={() => {
                  if (auth.currentUser && messages.length > 0) {
                    const formattedMessages = messages.map(msg => ({
                      role: msg.from?.isLocal ? 'user' : 'assistant',
                      content: msg.message
                    }));
                    saveChatHistory(auth.currentUser.uid, formattedMessages);
                  }
                }}
              />
            </div>
          </div>
        </div>
      </div>

      <TileLayout chatOpen={chatOpen} />

      <PricingModal
        isOpen={showPricing}
        onClose={() => setShowPricing(false)}
        currentPlan={planType}
        onSuccess={fetchSub}
      />

      <ImageGenModal
        isOpen={showImageGen}
        onClose={() => setShowImageGen(false)}
      />

      <CodeModeModal
        isOpen={showCodeMode}
        onClose={() => setShowCodeMode(false)}
      />
    </section>
  );
};
