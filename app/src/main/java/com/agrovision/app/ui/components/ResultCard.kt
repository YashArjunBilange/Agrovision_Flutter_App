package com.agrovision.app.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.LocalOffer
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.agrovision.app.model.AppLanguage
import com.agrovision.app.model.DiseaseInfo
import com.agrovision.app.ui.theme.*

@Composable
fun ResultCard(
    diseaseInfo: DiseaseInfo,
    confidenceScore: Float,
    language: AppLanguage
) {
    val animatedProgress by animateFloatAsState(
        targetValue = (confidenceScore / 100f).coerceIn(0f, 1f),
        animationSpec = tween(durationMillis = 1000),
        label = "ConfidenceProgress"
    )

    val confidenceColor = when {
        confidenceScore >= 80f -> HighConfidenceGreen
        confidenceScore >= 50f -> MedConfidenceOrange
        else -> LowConfidenceRed
    }

    val confidenceText = when {
        confidenceScore >= 80f -> if (language == AppLanguage.ENGLISH) "High Accuracy" else "उच्च अचूकता"
        confidenceScore >= 50f -> if (language == AppLanguage.ENGLISH) "Moderate Accuracy" else "मध्यम अचूकता"
        else -> if (language == AppLanguage.ENGLISH) "Low Accuracy" else "कमी अचूकता"
    }

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            // Header Tag: Crop & Severity
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Surface(
                    color = PaleMint,
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Default.LocalOffer,
                            contentDescription = "Crop Category",
                            tint = ForestGreen,
                            modifier = Modifier.size(14.dp)
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = diseaseInfo.category,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            color = ForestGreen
                        )
                    }
                }

                Surface(
                    color = confidenceColor.copy(alpha = 0.15f),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Text(
                        text = confidenceText,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        color = confidenceColor,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Predicted Disease Name
            Text(
                text = if (language == AppLanguage.ENGLISH) "Predicted Disease / Condition:" else "निदान झालेला रोग / स्थिती:",
                fontSize = 12.sp,
                color = Color.Gray,
                fontWeight = FontWeight.Medium
            )

            Text(
                text = if (language == AppLanguage.ENGLISH) diseaseInfo.nameEn else diseaseInfo.nameMr,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = ForestGreen
            )

            Spacer(modifier = Modifier.height(14.dp))

            // Confidence Score Meter
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = if (language == AppLanguage.ENGLISH) "Model Confidence Score" else "मॉडेल विश्वासार्हता गुण",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = TextPrimary
                )
                Text(
                    text = String.format("%.1f%%", confidenceScore),
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = confidenceColor
                )
            }

            Spacer(modifier = Modifier.height(6.dp))

            // Progress bar
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(10.dp)
                    .clip(RoundedCornerShape(5.dp))
                    .background(Color.LightGray.copy(alpha = 0.4f))
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxHeight()
                        .fillMaxWidth(animatedProgress)
                        .clip(RoundedCornerShape(5.dp))
                        .background(confidenceColor)
                )
            }
        }
    }
}
