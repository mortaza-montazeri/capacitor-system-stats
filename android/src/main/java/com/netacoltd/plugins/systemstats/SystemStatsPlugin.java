package com.netacoltd.plugins.systemstats;

import android.app.ActivityManager;
import android.content.Context;
import android.os.Environment;
import android.os.StatFs;
import android.util.Log;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.RandomAccessFile;

@CapacitorPlugin(name = "SystemStats")
public class SystemStatsPlugin extends Plugin {

    @PluginMethod
    public void getSystemStats(PluginCall call) {
        JSObject ret = new JSObject();
        Context context = getContext();
        
        // CPU Usage (Approximation)
        try {
            Process process = Runtime.getRuntime().exec("top -n 1");
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;
            String cpuUsage = null;
            while ((line = reader.readLine()) != null) {
                if (line.contains("CPU")) {
                    cpuUsage = line;
                    break;
                }
            }
            ret.put("cpuUsage", cpuUsage);
        } catch (Exception e) {
            Log.e("SystemStatsPlugin", "getSystemStats: ", e);
            ret.put("cpuUsage", null);
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
