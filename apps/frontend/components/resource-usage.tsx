'use client';

import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { LineChart, Line, XAxis, YAxis, ResponsiveContainer, Tooltip } from 'recharts';

export function ResourceUsage() {
  const [data, setData] = useState<any[]>([
    { time: '0s', cpu: 20, ram: 35 },
    { time: '10s', cpu: 25, ram: 38 },
    { time: '20s', cpu: 22, ram: 36 },
    { time: '30s', cpu: 28, ram: 40 },
    { time: '40s', cpu: 24, ram: 37 },
    { time: '50s', cpu: 26, ram: 39 },
  ]);

  useEffect(() => {
    // TODO: Connect to WebSocket for real-time updates
    const interval = setInterval(() => {
      setData((prev) => [
        ...prev.slice(1),
        {
          time: `${prev.length * 10}s`,
          cpu: Math.random() * 30 + 15,
          ram: Math.random() * 15 + 30,
        },
      ]);
    }, 10000);

    return () => clearInterval(interval);
  }, []);

  return (
    <Card>
      <CardHeader>
        <CardTitle>System Resources</CardTitle>
      </CardHeader>
      <CardContent>
        <ResponsiveContainer width="100%" height={200}>
          <LineChart data={data}>
            <XAxis dataKey="time" />
            <YAxis />
            <Tooltip />
            <Line type="monotone" dataKey="cpu" stroke="#6366f1" name="CPU %" />
            <Line type="monotone" dataKey="ram" stroke="#8b5cf6" name="RAM %" />
          </LineChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
}
