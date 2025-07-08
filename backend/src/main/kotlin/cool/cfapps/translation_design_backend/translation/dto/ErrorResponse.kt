package cool.cfapps.translation_design_backend.translation.dto


data class ErrorResponse(
    val status: Int,
    val error: String,
    val message: String
)