package com.agrovision.app.model

import com.google.gson.annotations.SerializedName

data class PredictResponse(
    @SerializedName("success") val success: Boolean? = null,
    @SerializedName("class") val rawClass: String? = null,
    @SerializedName("disease") val disease: String? = null,
    @SerializedName("prediction") val prediction: Any? = null, // Can be String or Nested object
    @SerializedName("confidence") val confidence: Float? = null,
    @SerializedName("confidence_score") val confidenceScore: Float? = null,
    @SerializedName("predicted_class") val predictedClass: String? = null,
    @SerializedName("probabilities") val probabilities: Map<String, Float>? = null,
    @SerializedName("message") val message: String? = null,
    @SerializedName("error") val error: String? = null,
    @SerializedName("detail") val detail: String? = null
) {
    fun getResolvedClass(): String {
        // Try to extract from nested prediction object if it exists
        if (prediction is Map<*, *>) {
            val className = prediction["class_name"] as? String
                ?: prediction["normalized_class_name"] as? String
            if (className != null) return className
        }

        return (prediction as? String)
            ?: rawClass
            ?: disease
            ?: predictedClass
            ?: probabilities?.maxByOrNull { it.value }?.key
            ?: "Unknown"
    }

    fun getResolvedConfidence(): Float {
        var score: Float? = confidence ?: confidenceScore

        if (score == null && prediction is Map<*, *>) {
            score = (prediction["confidence"] as? Number)?.toFloat()
                ?: (prediction["confidence_score"] as? Number)?.toFloat()
        }

        if (score == null) {
            score = probabilities?.maxByOrNull { it.value }?.value
        }

        val finalScore = score ?: 0.88f

        // Convert 0.0-1.0 to percentage if needed
        return if (finalScore <= 1.0f) finalScore * 100f else finalScore
    }
}

enum class AppLanguage {
    ENGLISH,
    MARATHI
}

data class DiseaseInfo(
    val key: String,
    val nameEn: String,
    val nameMr: String,
    val category: String,
    val chemicalRemedyEn: String,
    val chemicalRemedyMr: String,
    val organicRemedyEn: String,
    val organicRemedyMr: String,
    val preventionEn: String,
    val preventionMr: String
)
