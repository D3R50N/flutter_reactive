"use client";

import { cn } from "@/lib/utils";
import {
  Code,
  Download,
  ExternalLink,
  FileQuestion,
  FileText,
  Home,
  Layers,
  Lightbulb,
  Link2,
  Package,
  ShieldCheck,
  ShoppingCart,
  X,
  Zap,
} from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect } from "react";

const navigation = [
  {
    title: "Getting Started",
    items: [
      { title: "Introduction", href: "/", icon: Home },
      { title: "Installation", href: "/installation", icon: Download },
    ],
  },
  {
    title: "Concepts",
    items: [
      { title: "Reactive & ReactiveN", href: "/concepts/reactive", icon: Zap },
      { title: "Binding & Widgets", href: "/concepts/binding", icon: Link2 },
      { title: "Validation", href: "/concepts/validation", icon: ShieldCheck },
      { title: "Derived State", href: "/concepts/derived", icon: Layers },
      { title: "Transactions", href: "/concepts/transactions", icon: Zap },
      { title: "Dependencies", href: "/concepts/dependencies", icon: Package },
    ],
  },
  {
    title: "Use Cases",
    items: [
      { title: "Practical Workflows", href: "/use-cases", icon: Lightbulb },
    ],
  },
  {
    title: "Examples",
    items: [
      { title: "Simple Counter", href: "/examples/counter", icon: Code },
      { title: "Form", href: "/examples/form", icon: FileText },
      { title: "Todo List", href: "/examples/todo", icon: Layers },
      { title: "Shopping Cart", href: "/examples/cart", icon: ShoppingCart },
    ],
  },
  {
    title: "Resources",
    items: [{ title: "FAQ", href: "/faq", icon: FileQuestion }],
  },
];

interface MobileNavProps {
  open: boolean;
  onClose: () => void;
}

export function MobileNav({ open, onClose }: MobileNavProps) {
  const pathname = usePathname();

  // Close on route change
  useEffect(() => {
    onClose();
  }, [pathname, onClose]);

  // Prevent body scroll when open
  useEffect(() => {
    if (open) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "";
    }
    return () => {
      document.body.style.overflow = "";
    };
  }, [open]);

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 lg:hidden">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-background/80 backdrop-blur-sm"
        onClick={onClose}
      />

      {/* Sidebar */}
      <div className="fixed left-0 top-0 h-full w-72 bg-sidebar text-sidebar-foreground shadow-lg">
        <div className="flex h-full flex-col">
          {/* Header */}
          <div className="flex h-16 items-center justify-between border-b border-sidebar-border px-4">
            <div className="flex items-center gap-3">
              <img src="/logo.svg" alt="Flutter Reactive" className="h-8 w-8" />
              <span className="font-semibold text-sm">Flutter Reactive</span>
            </div>
            <button onClick={onClose} className="p-2 -mr-2">
              <X className="h-5 w-5" />
              <span className="sr-only">Close menu</span>
            </button>
          </div>

          {/* Navigation */}
          <nav className="flex-1 overflow-y-auto px-3 py-4">
            {navigation.map((section) => (
              <div key={section.title} className="mb-4">
                <div className="px-3 py-2 text-xs font-medium uppercase tracking-wider text-sidebar-foreground/60">
                  {section.title}
                </div>
                <div className="mt-1 space-y-1">
                  {section.items.map((item) => {
                    const isActive = pathname === item.href;
                    return (
                      <Link
                        key={item.href}
                        href={item.href}
                        className={cn(
                          "flex items-center gap-3 rounded-md px-3 py-2 text-sm transition-colors",
                          isActive
                            ? "bg-sidebar-accent text-sidebar-primary"
                            : "text-sidebar-foreground/80 hover:bg-sidebar-accent hover:text-sidebar-foreground",
                        )}
                      >
                        {section.title != "Examples" && (
                          <item.icon className="h-4 w-4" />
                        )}
                        {item.title}
                      </Link>
                    );
                  })}
                </div>
              </div>
            ))}
          </nav>

          {/* Footer */}
          <div className="border-t border-sidebar-border p-4 space-y-2">
            <a
              href="https://pub.dev/packages/flutter_reactive"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-2 text-sm text-sidebar-foreground/80 hover:text-sidebar-foreground transition-colors"
            >
              <ExternalLink className="h-4 w-4" />
              pub.dev
            </a>
            <a
              href="https://github.com/D3R50N/flutter_reactive"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-2 text-sm text-sidebar-foreground/80 hover:text-sidebar-foreground transition-colors"
            >
              <ExternalLink className="h-4 w-4" />
              GitHub
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
