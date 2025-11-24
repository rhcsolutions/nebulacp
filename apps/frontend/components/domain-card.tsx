import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Globe, Lock, AlertCircle } from 'lucide-react';

interface DomainCardProps {
  domain: string;
  ssl: boolean;
  status: 'active' | 'pending' | 'error';
}

export function DomainCard({ domain, ssl, status }: DomainCardProps) {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium">{domain}</CardTitle>
        <Globe className="h-4 w-4 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <div className="flex items-center space-x-2 text-xs">
          {ssl ? (
            <>
              <Lock className="h-3 w-3 text-green-500" />
              <span className="text-green-500">SSL Active</span>
            </>
          ) : (
            <>
              <AlertCircle className="h-3 w-3 text-orange-500" />
              <span className="text-orange-500">No SSL</span>
            </>
          )}
        </div>
        <div className="mt-2">
          <span className={`text-xs px-2 py-1 rounded-full ${
            status === 'active' ? 'bg-green-500/10 text-green-500' :
            status === 'pending' ? 'bg-orange-500/10 text-orange-500' :
            'bg-red-500/10 text-red-500'
          }`}>
            {status}
          </span>
        </div>
      </CardContent>
    </Card>
  );
}
