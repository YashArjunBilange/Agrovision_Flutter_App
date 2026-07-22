package com.agrovision.app.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val LightColorScheme = lightColorScheme(
    primary = ForestGreen,
    onPrimary = CardBackground,
    primaryContainer = PaleMint,
    onPrimaryContainer = ForestGreen,
    secondary = EmeraldGreen,
    onSecondary = CardBackground,
    background = WarmBackground,
    onBackground = TextPrimary,
    surface = CardBackground,
    onSurface = TextPrimary
)

@Composable
fun AgroVisionTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = LightColorScheme,
        typography = Typography,
        content = content
    )
}
