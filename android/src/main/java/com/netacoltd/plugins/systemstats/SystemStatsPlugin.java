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

@CapacitorPlugin(name = "SystemStats")
public class SystemStatsPlugin extends Plugin {

    private final CpuMonitor cpuMonitor = new CpuMonitor();

    @PluginMethod
    public void getSystemStats(PluginCall call) {
        JSObject ret = new JSObject();
        Context context = getContext();

        ret.put("cpuUsage", cpuMonitor.getAppCpuUsage());

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
