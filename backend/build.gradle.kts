plugins {
    kotlin("jvm") version "2.1.21"
    kotlin("plugin.spring") version "2.1.21"
    id("org.springframework.boot") version "3.5.3"
    id("io.spring.dependency-management") version "1.1.7"
    kotlin("plugin.jpa") version "2.1.21"
}

group = "cool.cfapps"
version = "0.0.1-SNAPSHOT"

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-security")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    implementation("org.jetbrains.kotlin:kotlin-reflect")
    implementation("org.springframework.boot:spring-boot-starter-validation")
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:2.8.9")
    runtimeOnly("org.postgresql:postgresql")
    // Test Dependencies
    testImplementation("org.springframework.boot:spring-boot-starter-test") {
        exclude(group = "org.junit.vintage", module = "junit-vintage-engine")
    }
    testImplementation("org.springframework.boot:spring-boot-testcontainers")
    testImplementation("org.testcontainers:junit-jupiter")
    testImplementation("org.testcontainers:postgresql")
    testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")

    // H2 für In-Memory Tests (Alternative zu Testcontainers)
    testRuntimeOnly("com.h2database:h2")

    // MockK für Kotlin-spezifische Mocks (optional)
    testImplementation("io.mockk:mockk:1.14.4")
    testImplementation("com.ninja-squad:springmockk:4.0.2")

    // AssertJ für bessere Assertions (optional)
    testImplementation("org.assertj:assertj-core")

}

kotlin {
    compilerOptions {
        freeCompilerArgs.addAll("-Xjsr305=strict")
    }
}

allOpen {
    annotation("jakarta.persistence.Entity")
    annotation("jakarta.persistence.MappedSuperclass")
    annotation("jakarta.persistence.Embeddable")
}


// Test Configuration
tasks.withType<Test> {
    useJUnitPlatform()

    doFirst {
        val mockitoJar = configurations.testRuntimeClasspath.get()
            .find { it.name.contains("mockito-core") }

        if (mockitoJar != null) {
            jvmArgs = listOf(
                "-javaagent:${mockitoJar.absolutePath}",
                "-Xshare:off"
            )
        } else {
            logger.warn("Mockito core jar not found in testRuntimeClasspath!")
        }
    }

    // Explizit H2 für Tests verwenden
    systemProperties["spring.profiles.active"] = "test"
    systemProperties["spring.datasource.driver-class-name"] = "org.h2.Driver"

    testLogging {
        events("passed", "skipped", "failed")
        showStandardStreams = false
    }

}


