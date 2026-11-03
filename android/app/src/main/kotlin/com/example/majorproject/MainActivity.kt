
package com.example.majorproject

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.bluetooth.le.BluetoothLeAdvertiser
import android.content.Context
import android.content.pm.PackageManager
import android.os.ParcelUuid
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

class MainActivity : FlutterActivity() {

    // ============================================================
    // SMS
    // ============================================================

    private val SMS_CHANNEL = "connectsafe/sms"
    private val SMS_PERMISSION_REQUEST = 1001

    // ============================================================
    // BLE
    // ============================================================

    private val BLE_CHANNEL = "connectsafe/ble"

    private val CONNECTSAFE_SERVICE_UUID =
        UUID.fromString(
            "0000feed-0000-1000-8000-00805f9b34fb"
        )

    private var bluetoothLeAdvertiser: BluetoothLeAdvertiser? = null

    private val advertiseCallback =
        object : AdvertiseCallback() {

            override fun onStartSuccess(
                settingsInEffect: AdvertiseSettings
            ) {
                super.onStartSuccess(settingsInEffect)
            }

            override fun onStartFailure(errorCode: Int) {
                super.onStartFailure(errorCode)
            }
        }

    // ============================================================
    // FLUTTER ENGINE
    // ============================================================

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        setupSmsChannel(flutterEngine)

        setupBleChannel(flutterEngine)
    }

    // ============================================================
    // SMS CHANNEL
    // ============================================================

    private fun setupSmsChannel(
        flutterEngine: FlutterEngine
    ) {

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SMS_CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "sendSMS") {

                val phone =
                    call.argument<String>("phone")

                val message =
                    call.argument<String>("message")

                if (phone == null || message == null) {

                    result.error(
                        "INVALID_ARGUMENT",
                        "Phone number or message is missing",
                        null
                    )

                    return@setMethodCallHandler
                }

                if (
                    ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.SEND_SMS
                    ) != PackageManager.PERMISSION_GRANTED
                ) {

                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(
                            Manifest.permission.SEND_SMS
                        ),
                        SMS_PERMISSION_REQUEST
                    )

                    result.error(
                        "PERMISSION_REQUIRED",
                        "SMS permission is required",
                        null
                    )

                    return@setMethodCallHandler
                }

                try {

                    val smsManager =
                        SmsManager.getDefault()

                    val parts =
                        smsManager.divideMessage(message)

                    if (parts.size > 1) {

                        smsManager.sendMultipartTextMessage(
                            phone,
                            null,
                            parts,
                            null,
                            null
                        )

                    } else {

                        smsManager.sendTextMessage(
                            phone,
                            null,
                            message,
                            null,
                            null
                        )
                    }

                    result.success(true)

                } catch (e: Exception) {

                    result.error(
                        "SMS_FAILED",
                        e.message,
                        null
                    )
                }

            } else {

                result.notImplemented()
            }
        }
    }

    // ============================================================
    // BLE CHANNEL
    // ============================================================

    private fun setupBleChannel(
        flutterEngine: FlutterEngine
    ) {

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            BLE_CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "startAdvertising" -> {

                    startBleAdvertising()

                    result.success(true)
                }

                "stopAdvertising" -> {

                    stopBleAdvertising()

                    result.success(true)
                }

                "isAdvertisingSupported" -> {

                    result.success(
                        isBleAdvertisingSupported()
                    )
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // ============================================================
    // CHECK BLE SUPPORT
    // ============================================================

    private fun isBleAdvertisingSupported(): Boolean {

        val bluetoothManager =
            getSystemService(
                Context.BLUETOOTH_SERVICE
            ) as BluetoothManager

        val adapter =
            bluetoothManager.adapter

        return adapter != null &&
                adapter.isEnabled &&
                adapter.isMultipleAdvertisementSupported
    }

    // ============================================================
    // START BLE ADVERTISING
    // ============================================================

    private fun startBleAdvertising() {

        if (
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.BLUETOOTH_ADVERTISE
            ) != PackageManager.PERMISSION_GRANTED
        ) {

            return
        }

        val bluetoothManager =
            getSystemService(
                Context.BLUETOOTH_SERVICE
            ) as BluetoothManager

        val bluetoothAdapter =
            bluetoothManager.adapter

        if (
            bluetoothAdapter == null ||
            !bluetoothAdapter.isEnabled
        ) {
            return
        }

        bluetoothLeAdvertiser =
            bluetoothAdapter.bluetoothLeAdvertiser

        if (bluetoothLeAdvertiser == null) {
            return
        }

        val settings =
            AdvertiseSettings.Builder()
                .setAdvertiseMode(
                    AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY
                )
                .setTxPowerLevel(
                    AdvertiseSettings.ADVERTISE_TX_POWER_HIGH
                )
                .setConnectable(true)
                .setTimeout(0)
                .build()

        val data =
            AdvertiseData.Builder()
                .setIncludeDeviceName(false)
                .addServiceUuid(
                    ParcelUuid(
                        CONNECTSAFE_SERVICE_UUID
                    )
                )
                .build()

        bluetoothLeAdvertiser?.startAdvertising(
            settings,
            data,
            advertiseCallback
        )
    }

    // ============================================================
    // STOP BLE ADVERTISING
    // ============================================================

    private fun stopBleAdvertising() {

        if (
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.BLUETOOTH_ADVERTISE
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        bluetoothLeAdvertiser?.stopAdvertising(
            advertiseCallback
        )

        bluetoothLeAdvertiser = null
    }

    // ============================================================
    // CLEANUP
    // ============================================================

    override fun onDestroy() {

        stopBleAdvertising()

        super.onDestroy()
    }
}

