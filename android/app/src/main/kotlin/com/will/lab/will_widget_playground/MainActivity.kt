package com.will.lab.will_widget_playground

import android.app.ActivityManager
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.os.StatFs
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.FileReader

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.will/device"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getTotalStorage" -> {
                    val totalStorage = getTotalStorage()
                    result.success(totalStorage)
                }

                "getTotalStorage2" -> {
                    val totalStorage = getTotalMemory()
                    result.success(totalStorage)
                }

                "getFreeStorage" -> {
                    val freeStorage = getFreeStorage()
                    result.success(freeStorage)
                }

                "getRomInfo" -> {
                    val freeStorage = fetchRomInfo()
                    result.success(freeStorage)
                }

                "getRemUseInfo" -> {
                    val freeStorage = fetchRamUseInfo()
                    result.success(freeStorage)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getTotalStorage(): Long {
        val am: ActivityManager =
            getSystemService(ACTIVITY_SERVICE) as ActivityManager
        val memoryInfo: ActivityManager.MemoryInfo = ActivityManager.MemoryInfo()
        am.getMemoryInfo(memoryInfo)
        val totalMem = memoryInfo.totalMem / 1048576L
        println(memoryInfo.totalMem)
        return totalMem
    }

    private fun getFreeStorage(): Long {
        val am: ActivityManager =
            getSystemService(ACTIVITY_SERVICE) as ActivityManager
        val memoryInfo: ActivityManager.MemoryInfo = ActivityManager.MemoryInfo()
        am.getMemoryInfo(memoryInfo)
        val availMem = memoryInfo.availMem / 1048576L
        println(memoryInfo.availMem)
        println(memoryInfo.lowMemory)
        return availMem
    }

    private fun getTotalMemory(): Long {
        val str1 = "/proc/meminfo"
        val str2: String
        val arrayOfString: Array<String>
        var initialMemory: Long = 0
        try {
            val localFileReader = FileReader(str1)
            val localBufferedReader = BufferedReader(localFileReader, 8192)
            str2 = localBufferedReader.readLine()
            arrayOfString =
                str2.split("\\s+".toRegex()).dropLastWhile { it.isEmpty() }.toTypedArray()
            val i = arrayOfString[1].toInt()
            initialMemory = i.toLong() * 1024
            localBufferedReader.close()
        } catch (e: Exception) {
            println("getTotalMemory error: $e")
        }
        return initialMemory / 1048576L
    }

    private fun getFsTotalSize(anyPathInFs: String?): Long {
        if (TextUtils.isEmpty(anyPathInFs)) return 0
        val statFs = StatFs(anyPathInFs)
        val blockSize: Long = statFs.blockSizeLong
        val totalSize: Long = statFs.blockCountLong
        return blockSize * totalSize
    }

    fun fetchRomInfo(): Long {
        val romInfo: Long
        val totalMemory = try {
            getFsTotalSize(Environment.getExternalStorageDirectory().path)
        } catch (e: Exception) {
            0
        }
        romInfo = totalMemory / 1048576L
        return romInfo
    }

    fun fetchRamUseInfo(): Double {
        var ramUsage: Double = 0.0
        try {
            val availMemory = getAvailMemory()
            val totalMemory = getTotalMemory()
            ramUsage = (((totalMemory - availMemory).toDouble() / totalMemory.toDouble()) * 100)
            return ramUsage
        } catch (e: Exception) {
            return ramUsage
        }
    }

    private fun getAvailMemory(): Long {
        val am: ActivityManager =
            getSystemService(ACTIVITY_SERVICE) as ActivityManager
        val memoryInfo: ActivityManager.MemoryInfo = ActivityManager.MemoryInfo()
        am.getMemoryInfo(memoryInfo)
        return memoryInfo.availMem / 1048576L
    }





}
