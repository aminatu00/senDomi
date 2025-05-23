import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

// -- Configuration du buildscript pour les plugins comme google-services
// build.gradle.kts (project-level)

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // ✅ Plugin Google Services
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}


// -- Redéfinir le dossier de build global
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// -- Appliquer la nouvelle structure de build aux sous-projets
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// -- S'assurer que tous les sous-projets dépendent de :app (ordre d'évaluation)
subprojects {
    project.evaluationDependsOn(":app")
}

// -- Tâche "clean" corrigée (convertir Provider<Directory> en File)
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory.get().asFile)
}
