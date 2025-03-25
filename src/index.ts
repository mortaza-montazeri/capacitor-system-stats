import { registerPlugin } from '@capacitor/core';

import type { SystemStatsPlugin } from './definitions';

const SystemStats = registerPlugin<SystemStatsPlugin>('SystemStats', {
  web: () => import('./web').then((m) => new m.SystemStatsWeb()),
});

export * from './definitions';
export { SystemStats };
