package cool.cfapps.translation_design_backend.translation.model

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Index
import jakarta.persistence.Table
import java.time.LocalDateTime

@Entity
@Table(
    name = "translations",
    indexes = [
        Index(name = "idx_category", columnList = "category"),
        Index(name = "idx_locale", columnList = "locale"),
        Index(name = "idx_key", columnList = "key_name"),
        Index(name = "idx_category_locale_key", columnList = "category,locale,key_name", unique = true)
    ]
) class Translation(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(nullable = false, length = 100)
    val category: String,

    @Column(nullable = false, length = 10)
    val locale: String,

    @Column(nullable = false, name = "key_name", length = 200)
    val key: String,

    @Column(name="translation", columnDefinition = "TEXT")
    val value: String,

    @Column(name = "initial_translation", columnDefinition = "TEXT")
    val initialValue: String,

    @Column(name = "max_length", nullable = false)
    val maxLength: Int,

    @Column(name = "created_at", nullable = false)
    val createdAt: LocalDateTime = LocalDateTime.now(),

    @Column(name = "updated_at", nullable = false)
    val updatedAt: LocalDateTime = LocalDateTime.now()
) {
    // Für JPA wird ein no-arg constructor benötigt
    constructor() : this(
        id = 0,
        category = "",
        locale = "",
        key = "",
        value = "",
        initialValue = "",
        maxLength = 0,
        createdAt = LocalDateTime.now(),
        updatedAt = LocalDateTime.now()
    )

    fun copy(value: String, updatedAt: LocalDateTime) = Translation(
        id = id,
        category = category,
        locale = locale,
        key = key,
        value = value,
        initialValue = initialValue,
        maxLength = maxLength,
        createdAt = createdAt,
        updatedAt = updatedAt
    )
}