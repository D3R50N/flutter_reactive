"use client"

import Link from "next/link"
import { ThemeToggle } from "@/components/theme-toggle"
import { Button } from "@/components/ui/button"
import { ExternalLink, Menu, X } from "lucide-react"
import { useState } from "react"
import { MobileNav } from "./mobile-nav"
import { DocSearch } from "./search-dialog"

export function Header() {
  const [mobileNavOpen, setMobileNavOpen] = useState(false)

  return (
    <>
      <header className="sticky top-0 z-40 border-b border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
        <div className="flex h-16 items-center justify-between px-4 lg:px-6">
          {/* Mobile menu button */}
          <button
            onClick={() => setMobileNavOpen(true)}
            className="lg:hidden p-2 -ml-2"
          >
            <Menu className="h-5 w-5" />
            <span className="sr-only">Open menu</span>
          </button>

          {/* Logo for mobile */}
          <Link href="/" className="flex items-center gap-2 lg:hidden">
            <img src="/logo.svg" alt="Flutter Reactive" className="h-7 w-7" />
            <span className="font-semibold text-sm">Flutter Reactive</span>
          </Link>

          {/* Spacer for desktop */}
          <div className="hidden lg:block" />

          {/* Right side */}
          <div className="flex items-center gap-2">
            <div className="sm:block">
              <DocSearch />
            </div>

            <Button
              variant="ghost"
              size="sm"
              asChild
              className="hidden sm:flex hover:bg-accent/50"
            >
              <a
                href="https://pub.dev/packages/flutter_reactive"
                target="_blank"
                rel="noopener noreferrer"
                className="gap-2"
              >
                pub.dev
                <ExternalLink className="h-3 w-3" />
              </a>
            </Button>
            <Button
              variant="ghost"
              size="sm"
              asChild
              className="hidden sm:flex  hover:bg-accent/50"
            >
              <a
                href="https://github.com/D3R50N/flutter_reactive"
                target="_blank"
                rel="noopener noreferrer"
                className="gap-2"
              >
                GitHub
                <ExternalLink className="h-3 w-3" />
              </a>
            </Button>
            <ThemeToggle />
          </div>
        </div>
      </header>

      {/* Mobile navigation */}
      <MobileNav open={mobileNavOpen} onClose={() => setMobileNavOpen(false)} />
    </>
  );
}
