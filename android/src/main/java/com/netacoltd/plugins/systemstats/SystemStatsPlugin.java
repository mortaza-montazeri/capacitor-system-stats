package com.netacoltd.plugins.systemstats;

import android.app.ActivityManager;
import android.content.Context;
import android.os.Environment;
import android.os.StatFs;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import java.io.RandomAccessFile;

@CapacitorPlugin(name = "SystemStats")
public class SystemStatsPlugin extends Plugin {

    @PluginMethod
    public void getSystemStats(PluginCall call) {
        JSObject ret = new JSObject();
        Context context = getContext();
        
        // CPU Usage (Approximation)
        try {
            RandomAccessFile reader = new RandomAccessFile("/proc/stat", "r");
            String load = reader.readLine();
            String[] toks = load.split(" +");

            long idle1 = Long.parseLong(toks[4]);
            long cpu1 = Long.parseLong(toks[1]) + Long.parseLong(toks[2]) + Long.parseLong(toks[3])
                        + Long.parseLong(toks[5]) + Long.parseLong(toks[6]) + Long.parseLong(toks[7]);
            Thread.sleep(360);
            reader.seek(0);
            load = reader.readLine();
            reader.close();

            toks = load.split(" +");
            long idle2 = Long.parseLong(toks[4]);
            long cpu2 = Long.parseLong(toks[1]) + Long.parseLong(toks[2]) + Long.parseLong(toks[3])
                        + Long.parseLong(toks[5]) + Long.parseLong(toks[6]) + Long.parseLong(toks[7]);

            float cpuUsage = (float) (cpu2 - cpu1) / ((cpu2 + idle2) - (cpu1 + idle1)) * 100;
            ret.put("cpuUsage", cpuUsage);
        } catch (Exception e) {
            ret.put("cpuUsage", -1);
        }

        // RAM Usage
        ActivityManager.MemoryInfo memoryInfo = new ActivityManager.MemoryInfo();
        ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        activityManager.getMemoryInfo(memoryInfo);
        ret.put("totalRAM", memoryInfo.totalMem);
        ret.put("availableRAM", memoryInfo.availMem);

        // Disk Usage
        StatFs statFs = new StatFs(Environment.getDataDirectory().getPath());
        long totalBytes = statFs.getTotalBytes();
        long freeBytes = statFs.getFreeBytes();
        ret.put("totalStorage", totalBytes);
        ret.put("availableStorage", freeBytes);

        call.resolve(ret);
    }
}
