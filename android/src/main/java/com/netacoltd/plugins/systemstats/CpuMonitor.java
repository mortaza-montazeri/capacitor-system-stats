package com.netacoltd.plugins.systemstats;

import android.os.Process;
import android.os.SystemClock;

public class CpuMonitor {
    private long lastAppCpuTime = Process.getElapsedCpuTime();
    private long lastWallTime = SystemClock.elapsedRealtime();

    public float getAppCpuUsage() {
        long appCpuTime = Process.getElapsedCpuTime(); // in ms
        long wallTime = SystemClock.elapsedRealtime(); // in ms

        if (lastWallTime == 0 || lastAppCpuTime == 0) {
            lastAppCpuTime = appCpuTime;
            lastWallTime = wallTime;
            return 0f; // Not enough data to calculate yet
        }

        long cpuDelta = appCpuTime - lastAppCpuTime;
        long wallDelta = wallTime - lastWallTime;

        lastAppCpuTime = appCpuTime;
        lastWallTime = wallTime;

        if (wallDelta == 0) return 0f;

        return ((float) cpuDelta / wallDelta) * 100f;
    }
}