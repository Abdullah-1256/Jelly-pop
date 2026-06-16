package com.example.candy_crush

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        configureAdaptiveRefreshRate()
    }

    private fun configureAdaptiveRefreshRate() {
        val attributes = window.attributes
        if (Build.VERSION.SDK_INT >= 31) {
            setFloatFieldIfAvailable(attributes, "preferredMinDisplayRefreshRate", 40f)
            setFloatFieldIfAvailable(attributes, "preferredMaxDisplayRefreshRate", 120f)
            window.attributes = attributes
            return
        }
        if (Build.VERSION.SDK_INT >= 21) {
            @Suppress("DEPRECATION")
            attributes.preferredRefreshRate = 120f
            window.attributes = attributes
        }
    }

    private fun setFloatFieldIfAvailable(
        attributes: WindowManager.LayoutParams,
        fieldName: String,
        value: Float,
    ) {
        runCatching {
            val field = attributes.javaClass.getField(fieldName)
            field.setFloat(attributes, value)
        }
    }
}
