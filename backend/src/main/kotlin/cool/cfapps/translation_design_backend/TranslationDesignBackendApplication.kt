package cool.cfapps.translation_design_backend

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.ConfigurationPropertiesScan
import org.springframework.boot.runApplication

@SpringBootApplication
@ConfigurationPropertiesScan
class TranslationDesignBackendApplication

fun main(args: Array<String>) {
    runApplication<TranslationDesignBackendApplication>(*args)
}
