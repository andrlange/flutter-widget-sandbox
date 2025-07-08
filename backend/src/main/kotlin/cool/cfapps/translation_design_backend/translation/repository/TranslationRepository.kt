package cool.cfapps.translation_design_backend.translation.repository

import cool.cfapps.translation_design_backend.translation.model.Translation
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.CrudRepository
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository

@Repository
interface TranslationRepository : CrudRepository<Translation, Long> {

    // Finde Translation über unique constraint (category, locale, key)
    fun findByCategoryAndLocaleAndKey(
        category: String,
        locale: String,
        key: String
    ): Translation?

    // Alle Translations für eine bestimmte Kategorie und Locale
    fun findByCategoryAndLocale(category: String, locale: String): List<Translation>

    // Alle Translations für eine Kategorie
    fun findByCategory(category: String): List<Translation>

    // Alle verfügbaren Locales für eine Kategorie
    @Query("SELECT DISTINCT t.locale FROM Translation t WHERE t.category = :category")
    fun findDistinctLocalesByCategory(@Param("category") category: String): List<String>

    // Alle verfügbaren Kategorien
    @Query("SELECT DISTINCT t.category FROM Translation t")
    fun findDistinctCategories(): List<String>

    // Prüfe ob Translation existiert (nutzt den kombinatorischen Index)
    fun existsByCategoryAndLocaleAndKey(
        category: String,
        locale: String,
        key: String
    ): Boolean
}