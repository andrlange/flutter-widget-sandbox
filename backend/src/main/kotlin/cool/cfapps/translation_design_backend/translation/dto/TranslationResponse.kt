package cool.cfapps.translation_design_backend.translation.dto

// Response DTOs
data class TranslationResponse(
    val id: Long,
    val category: String,
    val locale: String,
    val key: String,
    val value: String,
    val initialValue: String,
    val maxLength: Int,
    val createdAt: String,
    val updatedAt: String,
    val isCustomizable: Boolean = true
)