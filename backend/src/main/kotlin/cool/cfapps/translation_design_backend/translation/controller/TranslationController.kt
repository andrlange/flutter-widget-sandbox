package cool.cfapps.translation_design_backend.translation.controller

import cool.cfapps.translation_design_backend.translation.dto.CreateTranslationRequest
import cool.cfapps.translation_design_backend.translation.dto.ErrorResponse
import cool.cfapps.translation_design_backend.translation.dto.TranslationListResponse
import cool.cfapps.translation_design_backend.translation.dto.TranslationResponse
import cool.cfapps.translation_design_backend.translation.dto.UpdateTranslationRequest
import cool.cfapps.translation_design_backend.translation.exception.TranslationAlreadyExistsException
import cool.cfapps.translation_design_backend.translation.exception.TranslationNotFoundException
import cool.cfapps.translation_design_backend.translation.service.TranslationService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/translations")
@CrossOrigin(origins = ["*"]) // Für Flutter Development
class TranslationController(
    private val translationService: TranslationService
) {

    @PostMapping
    fun createTranslation(
        @RequestBody @Valid request: CreateTranslationRequest
    ): ResponseEntity<TranslationResponse> {
        println("createTranslation request: $request")
        val response = translationService.createTranslation(request)
        return ResponseEntity.status(HttpStatus.CREATED).body(response)
    }

    @PutMapping
    fun updateTranslation(
        @RequestBody @Valid request: UpdateTranslationRequest
    ): ResponseEntity<TranslationResponse> {
        val response = translationService.updateTranslation(request)
        return ResponseEntity.ok(response)
    }

    @DeleteMapping
    fun deleteTranslation(
        @RequestParam category: String,
        @RequestParam locale: String,
        @RequestParam key: String
    ): ResponseEntity<Void> {
        translationService.deleteTranslation(category, locale, key)
        return ResponseEntity.noContent().build()
    }

    @GetMapping("/single")
    fun getTranslation(
        @RequestParam category: String,
        @RequestParam locale: String,
        @RequestParam key: String,
        @RequestParam(defaultValue = "false") initialValue: Boolean
    ): ResponseEntity<TranslationResponse> {
        val response = translationService.findTranslation(category, locale, key, initialValue)
        return ResponseEntity.ok(response)
    }

    @GetMapping("/category")
    fun getTranslationsByCategoryAndLocale(
        @RequestParam category: String,
        @RequestParam locale: String,
        @RequestParam(defaultValue = "false") initialValue: Boolean
    ): ResponseEntity<TranslationListResponse> {
        val response = translationService.findAllByCategoryAndLocale(category, locale, initialValue)
        return ResponseEntity.ok(response)
    }

    @GetMapping("/locale")
    fun getTranslationsByLocale(
        @RequestParam locale: String,
        @RequestParam(defaultValue = "false") initialValue: Boolean
    ): ResponseEntity<TranslationListResponse> {
        val response = translationService.findAllByLocale(locale, initialValue)
        return ResponseEntity.ok(response)
    }
}

@RestControllerAdvice
class TranslationExceptionHandler {

    @ExceptionHandler(TranslationAlreadyExistsException::class)
    fun handleTranslationAlreadyExists(ex: TranslationAlreadyExistsException): ResponseEntity<ErrorResponse> {
        return ResponseEntity.status(HttpStatus.CONFLICT)
            .body(ErrorResponse(
                status = HttpStatus.CONFLICT.value(),
                error = "Translation Already Exists",
                message = ex.message ?: "Translation bereits vorhanden"
            ))
    }

    @ExceptionHandler(TranslationNotFoundException::class)
    fun handleTranslationNotFound(ex: TranslationNotFoundException): ResponseEntity<ErrorResponse> {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(ErrorResponse(
                status = HttpStatus.NOT_FOUND.value(),
                error = "Translation Not Found",
                message = ex.message ?: "Translation nicht gefunden"
            ))
    }

    @ExceptionHandler(Exception::class)
    fun handleGenericException(ex: Exception): ResponseEntity<ErrorResponse> {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(ErrorResponse(
                status = HttpStatus.INTERNAL_SERVER_ERROR.value(),
                error = "Internal Server Error",
                message = "Ein unerwarteter Fehler ist aufgetreten"
            ))
    }
}