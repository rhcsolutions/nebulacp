import { ResourceUsage } from '@/components/resource-usage';
import { DomainCard } from '@/components/domain-card';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Plus, Server, Database, Mail, HardDrive } from 'lucide-react';

export default async function DashboardPage() {
  // TODO: Fetch real data from API
  const stats = {
    domains: 5,
    databases: 3,
    mailboxes: 12,
    storage: '45GB / 100GB',
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Dashboard</h1>
          <p className="text-muted-foreground">Welcome back to NebulaCP</p>
        </div>
        <Button>
          <Plus className="mr-2 h-4 w-4" />
          Add Domain
        </Button>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Domains</CardTitle>
            <Server className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.domains}</div>
            <p className="text-xs text-muted-foreground">Active websites</p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Databases</CardTitle>
            <Database className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.databases}</div>
            <p className="text-xs text-muted-foreground">PostgreSQL + MySQL</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Mail</CardTitle>
            <Mail className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.mailboxes}</div>
            <p className="text-xs text-muted-foreground">Email accounts</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Storage</CardTitle>
            <HardDrive className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.storage.split(' / ')[0]}</div>
            <p className="text-xs text-muted-foreground">of {stats.storage.split(' / ')[1]}</p>
          </CardContent>
        </Card>
      </div>

      <ResourceUsage />

      <div>
        <h2 className="text-2xl font-bold mb-4">Your Domains</h2>
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          <DomainCard 
            domain="example.com"
            ssl={true}
            status="active"
          />
          <DomainCard 
            domain="mysite.net"
            ssl={true}
            status="active"
          />
          <DomainCard 
            domain="demo.org"
            ssl={false}
            status="pending"
          />
        </div>
      </div>
    </div>
  );
}
