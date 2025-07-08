package cool.cfapps.translation_design_backend.translation.dto

import jakarta.validation.constraints.Max
import jakarta.validation.constraints.Min
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size

// Request DTOs
data class CreateTranslationRequest(
    @field:NotBlank(message = "Category ist erforderlich")
    @field:Size(max = 100, message = "Category darf maximal 100 Zeichen haben")
    val category: String,

    @field:NotBlank(message = "Locale ist erforderlich")
    @field:Size(max = 10, message = "Locale darf maximal 10 Zeichen haben")
    val locale: String,

    @field:NotBlank(message = "Key ist erforderlich")
    @field:Size(max = 200, message = "Key darf maximal 200 Zeichen haben")
    val key: String,

    @field:NotBlank(message = "Value ist erforderlich")
    val value: String,
    @field:Min(0, message = "MaxLength muss größer oder gleich 0 sein")
    @field:Max(1024, message = "MaxLength darf maximal 1024 sein")
    val maxLength: Int
)
