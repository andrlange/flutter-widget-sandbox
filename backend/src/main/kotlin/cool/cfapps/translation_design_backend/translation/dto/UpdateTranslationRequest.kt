package cool.cfapps.translation_design_backend.translation.dto

import jakarta.validation.constraints.NotBlank

data class UpdateTranslationRequest(
    @field:NotBlank(message = "Category ist erforderlich")
    val category: String,

    @field:NotBlank(message = "Locale ist erforderlich")
    val locale: String,

    @field:NotBlank(message = "Key ist erforderlich")
    val key: String,

    @field:NotBlank(message = "Value ist erforderlich")
    val value: String
)