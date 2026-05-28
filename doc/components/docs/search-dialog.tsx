"use client";

import { Button } from "@/components/ui/button";
import {
  CommandDialog,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
  CommandSeparator,
} from "@/components/ui/command";
import { docPages } from "@/lib/docs-pages";
import { Search } from "lucide-react";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useState } from "react";

export function DocSearch() {
  const router = useRouter();
  const [open, setOpen] = useState(false);

  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent) => {
      if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k") {
        event.preventDefault();
        setOpen(true);
      }
    };

    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, []);

  const groupedPages = useMemo(() => {
    const groups = new Map<string, typeof docPages>();
    for (const page of docPages) {
      const pages = groups.get(page.category) ?? [];
      pages.push(page);
      groups.set(page.category, pages);
    }

    return Array.from(groups.entries());
  }, []);

  const openPage = (href: string) => {
    setOpen(false);
    router.push(href);
  };

  return (
    <>
      <Button
        variant="outline"
        size="sm"
        onClick={() => setOpen(true)}
        className="gap-2 justify-between w-full sm:w-auto  hover:bg-accent/50"
      >
        <span className="flex items-center gap-2">
          <Search className="h-4 w-4" />
          <span className="hidden sm:inline">Search docs</span>
          <span className="sm:hidden">Search</span>
        </span>
        <span className="hidden sm:inline-flex text-xs text-muted-foreground border border-border rounded px-1.5 py-0.5">
          ⌘K
        </span>
      </Button>

      <CommandDialog
        open={open}
        onOpenChange={setOpen}
        title="Search documentation"
        description="Search the documentation pages and jump straight to a section."
        className="sm:max-w-[640px]"
      >
        <CommandInput placeholder="Search pages, concepts, examples..." />
        <CommandList>
          <CommandEmpty>No matching page found.</CommandEmpty>
          {groupedPages.map(([category, pages], groupIndex) => (
            <div key={category}>
              <CommandGroup heading={category}>
                {pages.map((page) => (
                  <CommandItem
                    key={page.href}
                    value={`${page.keywords.join(" ")} ${page.title}`}
                    onSelect={() => openPage(page.href)}
                    className="data-[selected=true]:bg-accent/10 "
                  >
                    <div className="flex flex-col items-start gap-0.5">
                      <span>{page.title}</span>
                      <span className="text-xs text-muted-foreground">
                        {page.description}
                      </span>
                    </div>
                  </CommandItem>
                ))}
              </CommandGroup>
              {groupIndex < groupedPages.length - 1 && <CommandSeparator />}
            </div>
          ))}
        </CommandList>
      </CommandDialog>
    </>
  );
}
