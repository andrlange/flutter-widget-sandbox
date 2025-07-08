package cool.cfapps.translation_design_backend.translation.dto

data class TranslationListResponse(
    val translations: List<TranslationResponse>,
    val count: Int
)