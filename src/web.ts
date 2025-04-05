import { WebPlugin } from '@capacitor/core';

import type { SystemStatsPlugin } from './definitions';

export class SystemStatsWeb extends WebPlugin implements SystemStatsPlugin {
  getSystemStats(): Promise<{ cpuUsage: number; totalRAM: number; availableRAM: number; totalStorage: number; availableStorage: number; }> {
    return Promise.resolve({
      availableRAM: 0,
      availableStorage: 0,
      cpuUsage: 0,
      totalRAM: 0,
      totalStorage: 0
    });
  }  
}
