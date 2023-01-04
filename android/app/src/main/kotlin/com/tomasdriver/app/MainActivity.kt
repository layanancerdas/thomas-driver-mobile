package com.tomasdriver.app

import android.Manifest
import android.annotation.TargetApi
import android.app.AlertDialog
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.tomasdriver.app/location"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "locationRequest"){
                if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.R){
                    this.checkLocationPermissionAPI30(30)
//                    this.checkBackgroundLocationPermissionAPI30(31)
                }
                result.success("Hello Kotlin")
            }
        }
    }

    private fun Context.checkSinglePermission(permission: String) : Boolean {
        return ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
    }
    @TargetApi(30)
    private fun Context.checkLocationPermissionAPI30(locationRequestCode : Int) {
        if (checkSinglePermission(Manifest.permission.ACCESS_FINE_LOCATION) &&
            checkSinglePermission(Manifest.permission.ACCESS_COARSE_LOCATION)) return
        val permList = arrayOf(Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION)
        requestPermissions(permList, locationRequestCode)
    }

    @TargetApi(30)
    private fun Context.checkBackgroundLocationPermissionAPI30(backgroundLocationRequestCode: Int) {
        if (checkSinglePermission(Manifest.permission.ACCESS_BACKGROUND_LOCATION)) return
        AlertDialog.Builder(this, android.R.style.Theme_Material_Dialog)
            .setTitle("Background location permission")
            .setMessage("We need background location access to enable direction and live tracking features even when the app is closed or not in use. Please allow from application settings")
            .setPositiveButton("Yes") { _, _ ->
                // this request will take user to Application's Setting page
                requestPermissions(
                    arrayOf(Manifest.permission.ACCESS_BACKGROUND_LOCATION),
                    backgroundLocationRequestCode
                )
            }
            .setNegativeButton("No") { dialog, _ ->
                dialog.dismiss()
            }
            .create()
            .show()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String?>,
        grantResults: IntArray
    ) {
        when (requestCode) {
            30 -> {
                if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                        requestPermissions(
                            arrayOf(Manifest.permission.ACCESS_BACKGROUND_LOCATION),
                            31
                        )
                    }
                } else {
                }
            }
        }
    }
}
