import { WebPlugin } from '@capacitor/core';

import type { SystemStatsPlugin } from './definitions';

export class SystemStatsWeb extends WebPlugin implements SystemStatsPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
