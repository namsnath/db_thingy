# db_thingy

An app to manage and work with SQLite databases.

## Important changes
### For `flutter_file_picker`
Changes made according to the [Android setup guide](https://github.com/miguelpruivo/flutter_file_picker/wiki/Setup#--android).
#### Gradle
Changes made due to build failing with `unexpected element <queries> found in <manifest>`.
Solution from [here](https://github.com/miguelpruivo/flutter_file_picker/wiki/Troubleshooting).
##### `android/build.gradle`
```
buildscript {
    dependencies {
        - classpath 'com.android.tools.build:gradle:3.5.0'
        + classpath 'com.android.tools.build:gradle:3.5.4'
    }
}
```
##### `android/gradle/wrapper/gradle-wrapper.properties`
```
- distributionUrl=https\://services.gradle.org/distributions/gradle-5.6.2-all.zip
+ distributionUrl=https\://services.gradle.org/distributions/gradle-6.1.1-all.zip
```

#### Proguard obfuscation
##### `android/app/proguard-rules.pro`
Create file with contents:
```
-keep class androidx.lifecycle.DefaultLifecycleObserver
```

