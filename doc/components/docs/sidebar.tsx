"use client";

import { cn } from "@/lib/utils";
import {
  ChevronDown,
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
  Zap,
} from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";

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

export function Sidebar() {
  const pathname = usePathname();
  const [openSections, setOpenSections] = useState<string[]>(
    navigation.map((n) => n.title),
  );

  const toggleSection = (title: string) => {
    setOpenSections((prev) =>
      prev.includes(title) ? prev.filter((t) => t !== title) : [...prev, title],
    );
  };

  return (
    <aside className="fixed left-0 top-0 z-30 h-screen w-64 border-r border-sidebar-border bg-sidebar text-sidebar-foreground hidden lg:block">
      <div className="flex h-full flex-col">
        {/* Logo */}
        <div className="flex h-16 items-center gap-3 border-b border-sidebar-border px-6">
          <img src="/logo.svg" alt="Flutter Reactive" className="h-8 w-8" />
          <span className="font-semibold text-sm">Flutter Reactive</span>
        </div>

        {/* Navigation */}
        <nav className="flex-1 overflow-y-auto sidebar-scroll px-3 py-4">
          {navigation.map((section) => (
            <div key={section.title} className="mb-4">
              <button
                onClick={() => toggleSection(section.title)}
                className="flex w-full items-center justify-between px-3 py-2 text-xs font-medium uppercase tracking-wider text-sidebar-foreground/60 hover:text-sidebar-foreground transition-colors"
              >
                {section.title}
                <ChevronDown
                  className={cn(
                    "h-3 w-3 transition-transform",
                    openSections.includes(section.title) && "rotate-180",
                  )}
                />
              </button>
              {openSections.includes(section.title) && (
                <div className="mt-1 ">
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
              )}
            </div>
          ))}
        </nav>

        {/* Footer */}
        <div className="border-t border-sidebar-border p-4">
          <a
            href="https://pub.dev/packages/flutter_reactive"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-2 text-xs text-sidebar-foreground/60 hover:text-sidebar-foreground transition-colors"
          >
            <ExternalLink className="h-3 w-3" />
            pub.dev
          </a>
        </div>
      </div>
    </aside>
  );
}
