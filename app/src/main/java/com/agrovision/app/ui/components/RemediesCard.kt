package com.agrovision.app.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Healing
import androidx.compose.material.icons.filled.MedicalServices
import androidx.compose.material.icons.filled.Nature
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material.icons.filled.VolumeUp
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.agrovision.app.model.AppLanguage
import com.agrovision.app.model.DiseaseInfo
import com.agrovision.app.ui.theme.EmeraldGreen
import com.agrovision.app.ui.theme.ForestGreen
import com.agrovision.app.ui.theme.PaleMint
import com.agrovision.app.ui.theme.SunAmber

@Composable
fun RemediesCard(
    diseaseInfo: DiseaseInfo,
    language: AppLanguage,
    onSpeakClick: (String) -> Unit
) {
    var selectedTab by remember { mutableStateOf(0) }

    val chemicalText = if (language == AppLanguage.ENGLISH) diseaseInfo.chemicalRemedyEn else diseaseInfo.chemicalRemedyMr
    val organicText = if (language == AppLanguage.ENGLISH) diseaseInfo.organicRemedyEn else diseaseInfo.organicRemedyMr
    val preventionText = if (language == AppLanguage.ENGLISH) diseaseInfo.preventionEn else diseaseInfo.preventionMr

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
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Healing,
                        contentDescription = "Remedies Icon",
                        tint = ForestGreen,
                        modifier = Modifier.size(24.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = if (language == AppLanguage.ENGLISH) "Recommended Remedies" else "उपचारात्मक उपाय व सल्ला",
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = ForestGreen
                    )
                }

                // Audio Listen Button (TTS)
                IconButton(
                    onClick = {
                        val fullSpeechText = when (selectedTab) {
                            0 -> chemicalText
                            1 -> organicText
                            else -> preventionText
                        }
                        onSpeakClick(fullSpeechText)
                    },
                    modifier = Modifier
                        .size(38.dp)
                        .background(PaleMint, shape = RoundedCornerShape(10.dp))
                ) {
                    Icon(
                        imageVector = Icons.Default.VolumeUp,
                        contentDescription = "Read Aloud",
                        tint = ForestGreen,
                        modifier = Modifier.size(20.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Navigation Tabs (Chemical, Organic, Prevention)
            TabRow(
                selectedTabIndex = selectedTab,
                containerColor = PaleMint.copy(alpha = 0.5f),
                contentColor = ForestGreen,
                modifier = Modifier.height(42.dp)
            ) {
                Tab(
                    selected = selectedTab == 0,
                    onClick = { selectedTab = 0 }
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.Center,
                        modifier = Modifier.padding(horizontal = 4.dp)
                    ) {
                        Icon(Icons.Default.MedicalServices, contentDescription = null, modifier = Modifier.size(14.dp))
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = if (language == AppLanguage.ENGLISH) "Chemical" else "रासायनिक",
                            fontSize = 12.sp,
                            fontWeight = if (selectedTab == 0) FontWeight.Bold else FontWeight.Normal
                        )
                    }
                }

                Tab(
                    selected = selectedTab == 1,
                    onClick = { selectedTab = 1 }
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.Center,
                        modifier = Modifier.padding(horizontal = 4.dp)
                    ) {
                        Icon(Icons.Default.Nature, contentDescription = null, modifier = Modifier.size(14.dp))
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = if (language == AppLanguage.ENGLISH) "Organic" else "सेंद्रिय",
                            fontSize = 12.sp,
                            fontWeight = if (selectedTab == 1) FontWeight.Bold else FontWeight.Normal
                        )
                    }
                }

                Tab(
                    selected = selectedTab == 2,
                    onClick = { selectedTab = 2 }
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.Center,
                        modifier = Modifier.padding(horizontal = 4.dp)
                    ) {
                        Icon(Icons.Default.Shield, contentDescription = null, modifier = Modifier.size(14.dp))
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = if (language == AppLanguage.ENGLISH) "Prevention" else "प्रतिबंधात्मक",
                            fontSize = 12.sp,
                            fontWeight = if (selectedTab == 2) FontWeight.Bold else FontWeight.Normal
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(14.dp))

            // Remedy Content Box
            val displayText = when (selectedTab) {
                0 -> chemicalText
                1 -> organicText
                else -> preventionText
            }

            Surface(
                color = PaleMint.copy(alpha = 0.3f),
                shape = RoundedCornerShape(10.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(
                    text = displayText,
                    fontSize = 14.sp,
                    lineHeight = 22.sp,
                    color = ForestGreen,
                    fontWeight = FontWeight.Medium,
                    modifier = Modifier.padding(14.dp)
                )
            }
        }
    }
}
