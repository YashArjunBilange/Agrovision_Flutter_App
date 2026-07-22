package com.agrovision.app.network

import com.agrovision.app.model.PredictResponse
import okhttp3.MultipartBody
import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.Multipart
import retrofit2.http.POST
import retrofit2.http.Part

interface AgroVisionApiService {

    @Multipart
    @POST("predict")
    suspend fun predictDisease(
        @Part file: MultipartBody.Part
    ): Response<PredictResponse>

    @GET("health")
    suspend fun checkHealth(): Response<Map<String, Any>>

    @GET("model-info")
    suspend fun getModelInfo(): Response<Map<String, Any>>
}
