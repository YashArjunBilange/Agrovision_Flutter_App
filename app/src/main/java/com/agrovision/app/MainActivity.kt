package com.agrovision.app

import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.net.Uri
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import com.agrovision.app.model.AppLanguage
import com.agrovision.app.model.DiseaseInfo
import com.agrovision.app.network.NetworkClient
import com.agrovision.app.repository.RemediesRepository
import com.agrovision.app.ui.components.ImagePickerSection
import com.agrovision.app.ui.components.RemediesCard
import com.agrovision.app.ui.components.ResultCard
import com.agrovision.app.ui.components.TopBar
import com.agrovision.app.ui.theme.AgroVisionTheme
import com.agrovision.app.util.TextToSpeechHelper
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream

class MainActivity : ComponentActivity() {

    private lateinit var ttsHelper: TextToSpeechHelper

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ttsHelper = TextToSpeechHelper(this)

        setContent {
            AgroVisionTheme {
                MainScreen(ttsHelper)
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        ttsHelper.shutdown()
    }
}

@Composable
fun MainScreen(ttsHelper: TextToSpeechHelper) {
    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()

    var selectedImageUri by remember { mutableStateOf<Uri?>(null) }
    var currentLanguage by remember { mutableStateOf(AppLanguage.ENGLISH) }
    var isBackendOnline by remember { mutableStateOf(true) }
    var isLoading by remember { mutableStateOf(false) }

    var predictedInfo by remember { mutableStateOf<DiseaseInfo?>(null) }
    var confidenceScore by remember { mutableStateOf(0f) }

    // Check backend health on start
    LaunchedEffect(Unit) {
        withContext(Dispatchers.IO) {
            try {
                val healthResponse = NetworkClient.apiService.checkHealth()
                isBackendOnline = healthResponse.isSuccessful
            } catch (e: Exception) {
                isBackendOnline = false
            }
        }
    }

    // Gallery File Picker Contract (Supports JPG, JPEG, PNG, WEBP, etc.)
    val galleryLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        if (uri != null) {
            selectedImageUri = uri
            predictedInfo = null
        }
    }

    // Camera Capture Contract
    val cameraLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.TakePicturePreview()
    ) { bitmap: Bitmap? ->
        if (bitmap != null) {
            val uri = saveBitmapToCache(context, bitmap)
            selectedImageUri = uri
            predictedInfo = null
        }
    }

    // Permission Launcher
    val permissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        if (isGranted) {
            cameraLauncher.launch(null)
        } else {
            Toast.makeText(context, "Camera permission is required", Toast.LENGTH_SHORT).show()
        }
    }

    fun runDiseaseDetection() {
        val uri = selectedImageUri ?: return
        isLoading = true

        coroutineScope.launch(Dispatchers.IO) {
            try {
                val inputStream = context.contentResolver.openInputStream(uri)
                val bytes = inputStream?.readBytes() ?: ByteArray(0)
                inputStream?.close()

                val requestFile = bytes.toRequestBody("image/jpeg".toMediaTypeOrNull())
                val multipartBody = MultipartBody.Part.createFormData("file", "leaf_scan.jpg", requestFile)

                val response = NetworkClient.apiService.predictDisease(multipartBody)

                withContext(Dispatchers.Main) {
                    isLoading = false
                    if (response.isSuccessful && response.body() != null) {
                        val body = response.body()!!
                        val rawClass = body.getResolvedClass()
                        val confidence = body.getResolvedConfidence()

                        confidenceScore = confidence
                        predictedInfo = RemediesRepository.getDiseaseInfo(rawClass)

                        Toast.makeText(
                            context,
                            if (currentLanguage == AppLanguage.ENGLISH) "Diagnosis Complete!" else "निदान पूर्ण झाले!",
                            Toast.LENGTH_SHORT
                        ).show()
                    } else {
                        Toast.makeText(
                            context,
                            "API Error: ${response.code()} ${response.message()}",
                            Toast.LENGTH_LONG
                        ).show()
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    isLoading = false
                    Toast.makeText(
                        context,
                        "Network Error: ${e.localizedMessage}",
                        Toast.LENGTH_LONG
                    ).show()
                }
            }
        }
    }

    Scaffold(
        topBar = {
            TopBar(
                currentLanguage = currentLanguage,
                onLanguageToggle = {
                    currentLanguage = if (currentLanguage == AppLanguage.ENGLISH) AppLanguage.MARATHI else AppLanguage.ENGLISH
                },
                isBackendOnline = isBackendOnline
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
        ) {
            ImagePickerSection(
                selectedImageUri = selectedImageUri,
                language = currentLanguage,
                onUploadClick = { galleryLauncher.launch("image/*") },
                onTakePhotoClick = {
                    val permissionCheckResult = ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA)
                    if (permissionCheckResult == PackageManager.PERMISSION_GRANTED) {
                        cameraLauncher.launch(null)
                    } else {
                        permissionLauncher.launch(Manifest.permission.CAMERA)
                    }
                },
                onDetectClick = { runDiseaseDetection() },
                isLoading = isLoading
            )

            predictedInfo?.let { info ->
                ResultCard(
                    diseaseInfo = info,
                    confidenceScore = confidenceScore,
                    language = currentLanguage
                )

                RemediesCard(
                    diseaseInfo = info,
                    language = currentLanguage,
                    onSpeakClick = { textToSpeak ->
                        ttsHelper.speak(textToSpeak, currentLanguage)
                    }
                )

                Spacer(modifier = Modifier.height(24.dp))
            }
        }
    }
}

private fun saveBitmapToCache(context: android.content.Context, bitmap: Bitmap): Uri {
    val file = File(context.cacheBufferDir(), "camera_photo_${System.currentTimeMillis()}.jpg")
    val outputStream = FileOutputStream(file)
    bitmap.compress(Bitmap.CompressFormat.JPEG, 90, outputStream)
    outputStream.flush()
    outputStream.close()
    return Uri.fromFile(file)
}

private fun android.content.Context.cacheBufferDir(): File {
    val dir = File(cacheDir, "photos")
    if (!dir.exists()) dir.mkdirs()
    return dir
}
