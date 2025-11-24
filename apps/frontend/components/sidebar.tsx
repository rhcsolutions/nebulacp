'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import { 
  LayoutDashboard, 
  Globe, 
  Database, 
  Mail, 
  FileText, 
  HardDrive, 
  Sparkles, 
  Settings,
  Rocket 
} from 'lucide-react';

const navigation = [
  { name: 'Dashboard', href: '/', icon: LayoutDashboard },
  { name: 'Domains', href: '/domains', icon: Globe },
  { name: 'Databases', href: '/databases', icon: Database },
  { name: 'Mail', href: '/mail', icon: Mail },
  { name: 'Files', href: '/files', icon: FileText },
  { name: 'Backups', href: '/backups', icon: HardDrive },
  { name: 'AI Tools', href: '/ai/text', icon: Sparkles },
  { name: 'Settings', href: '/settings/profile', icon: Settings },
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <div className="w-64 bg-card border-r border-border flex flex-col">
      <div className="p-6 border-b border-border">
        <div className="flex items-center space-x-2">
          <Rocket className="h-8 w-8 text-primary" />
          <span className="text-xl font-bold">NebulaCP</span>
        </div>
      </div>
      <nav className="flex-1 p-4 space-y-1">
        {navigation.map((item) => {
          const isActive = pathname === item.href || pathname?.startsWith(item.href + '/');
          return (
            <Link
              key={item.name}
              href={item.href}
              className={cn(
                'flex items-center space-x-3 px-3 py-2 rounded-md text-sm font-medium transition-colors',
                isActive
                  ? 'bg-primary text-primary-foreground'
                  : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground'
              )}
            >
              <item.icon className="h-5 w-5" />
              <span>{item.name}</span>
            </Link>
          );
        })}
      </nav>
    </div>
  );
}
