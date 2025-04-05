export interface SystemStatsPlugin {
  getSystemStats(): Promise<{
    cpuUsage: number;      // CPU usage in %
    totalRAM: number;      // Total RAM in bytes
    availableRAM: number;  // Available RAM in bytes
    totalStorage: number;  // Total disk space in bytes
    availableStorage: number; // Available disk space in bytes
  }>;
}
