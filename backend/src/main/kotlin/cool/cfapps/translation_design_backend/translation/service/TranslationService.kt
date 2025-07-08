package cool.cfapps.translation_design_backend.translation.service

import cool.cfapps.translation_design_backend.translation.dto.CreateTranslationRequest
import cool.cfapps.translation_design_backend.translation.dto.TranslationListResponse
import cool.cfapps.translation_design_backend.translation.dto.TranslationResponse
import cool.cfapps.translation_design_backend.translation.dto.UpdateTranslationRequest
import cool.cfapps.translation_design_backend.translation.exception.TranslationAlreadyExistsException
import cool.cfapps.translation_design_backend.translation.exception.TranslationNotFoundException
import cool.cfapps.translation_design_backend.translation.model.Translation
import cool.cfapps.translation_design_backend.translation.repository.TranslationRepository
import jakarta.transaction.Transactional
import org.springframework.stereotype.Service
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

@Service
@Transactional
class TranslationService(
    private val translationRepository: TranslationRepository
) {

    fun createTranslation(request: CreateTranslationRequest): TranslationResponse {
        // Prüfe ob Translation bereits existiert

        println("createTranslation request: $request")
        if (translationRepository.existsByCategoryAndLocaleAndKey(
                request.category,
                request.locale,
                request.key
            )) {
            throw TranslationAlreadyExistsException(
                "Translation bereits vorhanden für category='${request.category}', locale='${request.locale}', key='${request.key}'"
            )
        }

        val now = LocalDateTime.now()
        val translation = Translation(
            category = request.category,
            locale = request.locale,
            key = request.key,
            value = request.value,
            initialValue = request.value, // value wird in initialValue übernommen
            maxLength = limitLength(request.maxLength),
            createdAt = now,
            updatedAt = now
        )

        val savedTranslation = translationRepository.save(translation)
        return mapToResponse(savedTranslation, useInitialValue = false)
    }

    fun updateTranslation(request: UpdateTranslationRequest): TranslationResponse {
        val existingTranslation = translationRepository.findByCategoryAndLocaleAndKey(
            request.category,
            request.locale,
            request.key
        ) ?: throw TranslationNotFoundException(
            "Translation nicht gefunden für category='${request.category}', locale='${request.locale}', key='${request.key}'"
        )

        val updatedTranslation = existingTranslation.copy(
            value = request.value,
            updatedAt = LocalDateTime.now(),
        )

        val savedTranslation = translationRepository.save(updatedTranslation)
        return mapToResponse(savedTranslation, useInitialValue = false)
    }

    fun deleteTranslation(category: String, locale: String, key: String) {
        val translation = translationRepository.findByCategoryAndLocaleAndKey(category, locale, key)
            ?: throw TranslationNotFoundException(
                "Translation nicht gefunden für category='$category', locale='$locale', key='$key'"
            )

        translationRepository.delete(translation)
    }

    fun findTranslation(
        category: String,
        locale: String,
        key: String,
        useInitialValue: Boolean = false
    ): TranslationResponse {
        val translation = translationRepository.findByCategoryAndLocaleAndKey(category, locale, key)
            ?: throw TranslationNotFoundException(
                "Translation nicht gefunden für category='$category', locale='$locale', key='$key'"
            )

        return mapToResponse(translation, useInitialValue)
    }

    fun findAllByCategoryAndLocale(
        category: String,
        locale: String,
        useInitialValue: Boolean = false
    ): TranslationListResponse {
        val translations = translationRepository.findByCategoryAndLocale(category, locale)
        val responses = translations.map { mapToResponse(it, useInitialValue) }

        return TranslationListResponse(
            translations = responses,
            count = responses.size
        )
    }

    fun findAllByLocale(locale: String, useInitialValue: Boolean = false): TranslationListResponse {
        val allTranslations = translationRepository.findAll()
        val filteredTranslations = allTranslations.filter { it.locale == locale }
        val responses = filteredTranslations.map { mapToResponse(it, useInitialValue) }

        return TranslationListResponse(
            translations = responses,
            count = responses.size
        )
    }

    private fun mapToResponse(translation: Translation, useInitialValue: Boolean): TranslationResponse {
        val formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME

        return TranslationResponse(
            id = translation.id,
            category = translation.category,
            locale = translation.locale,
            key = translation.key,
            value = if (useInitialValue) translation.initialValue else translation.value,
            initialValue = translation.initialValue,
            maxLength = translation.maxLength,
            createdAt = translation.createdAt.format(formatter),
            updatedAt = translation.updatedAt.format(formatter)
        )
    }

    private fun limitLength(value: Int): Int {
        return if (value <= 0 || value >= 1024) 1024 else value
    }
}