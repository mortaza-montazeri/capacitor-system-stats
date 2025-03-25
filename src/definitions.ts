export interface SystemStatsPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
