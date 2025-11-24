export interface User {
  id: string;
  email: string;
  username: string;
  role: 'ADMIN' | 'RESELLER' | 'USER';
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface Domain {
  id: string;
  domain: string;
  userId: string;
  type: 'WEB' | 'MAIL' | 'DNS' | 'PROXY';
  sslEnabled: boolean;
  sslExpires?: Date;
  path: string;
  phpVersion: string;
  createdAt: Date;
}

export interface Backup {
  id: string;
  userId: string;
  type: 'FULL' | 'INCREMENTAL';
  destination: string;
  schedule: string;
  lastRun?: Date;
  status: 'PENDING' | 'RUNNING' | 'SUCCESS' | 'FAILED';
  createdAt: Date;
}

export interface SystemStats {
  cpu: number;
  ram: number;
  disk: number;
  uptime: number;
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}
