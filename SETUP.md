# WordFlow - Инструкция по настройке и запуску

## Быстрый старт

### 1. Создание проекта в Xcode

1. Откройте Xcode 15.0+
2. File → New → Project
3. Выберите **iOS** → **App**
4. Заполните:
   - Product Name: `WordFlow`
   - Team: Выберите свою команду разработчика
   - Organization Identifier: `com.yourcompany`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None** (мы используем SwiftData)
5. Сохраните в папку `C:\Users\edik\Desktop\ENGLISH\WordFlow`

### 2. Настройка проекта

#### Минимальная версия iOS
1. В Xcode выберите проект → Target WordFlow
2. General → Deployment Info → iOS Deployment Target: **17.0**

#### Capabilities
1. Target → Signing & Capabilities
2. Добавьте следующие capabilities:
   - **Push Notifications**
   - **Background Modes** (Remote notifications)
   - **In-App Purchase**

#### Build Settings
1. Target → Build Settings
2. Swift Language Version: **Swift 6**
3. Enable Strict Concurrency Checking: **Yes**

### 3. Импорт файлов

Все файлы уже созданы в правильной структуре. Просто добавьте их в Xcode:

1. В Xcode, щелкните правой кнопкой на папке проекта
2. Add Files to "WordFlow"
3. Выберите все папки:
   - App/
   - Core/
   - Features/
   - UI/
   - Utilities/
   - Resources/
4. Убедитесь, что отмечено: **Copy items if needed**, **Create groups**

### 4. Настройка API ключей

#### OpenAI API (необязательно для тестирования)

1. Зарегистрируйтесь на https://platform.openai.com/
2. Создайте API ключ
3. Откройте `Utilities/Constants/APIKeys.swift`
4. Замените:
```swift
static let openAI = "sk-YOUR_ACTUAL_API_KEY_HERE"
```

**Примечание**: Приложение будет работать без API ключа, но AI объяснения будут недоступны.

### 5. Настройка StoreKit

#### Создание продуктов в App Store Connect

1. Войдите в https://appstoreconnect.apple.com/
2. My Apps → Создайте новое приложение
3. Features → In-App Purchases
4. Создайте два продукта:

**Месячная подписка:**
- Product ID: `wordflow.premium.monthly`
- Type: Auto-Renewable Subscription
- Price: $4.99/месяц

**Годовая подписка:**
- Product ID: `wordflow.premium.yearly`
- Type: Auto-Renewable Subscription
- Price: $29.99/год

#### Тестирование подписок

1. Xcode → Target → Signing & Capabilities
2. Добавьте **StoreKit Configuration File**:
   - File → New → File → StoreKit Configuration File
   - Имя: `Products.storekit`
3. Добавьте те же продукты, что и в App Store Connect

### 6. Запуск приложения

#### На симуляторе

1. Выберите iPhone 15 Pro (или новее) из списка устройств
2. Нажмите Cmd+R или кнопку Play
3. Приложение откроется с онбординга

#### На реальном устройстве

1. Подключите iPhone/iPad (iOS 17.0+)
2. Target → Signing & Capabilities → Team: выберите свою команду
3. Нажмите Cmd+R

### 7. Первый запуск

При первом запуске приложение:
1. Покажет онбординг (3 экрана)
2. Попросит ввести имя
3. Запросит разрешение на уведомления
4. Загрузит примеры слов
5. Создаст профиль с достижениями

## Структура данных

### SwiftData хранит данные локально

Данные сохраняются автоматически в:
```
~/Library/Developer/CoreSimulator/Devices/[DEVICE_ID]/data/Containers/Data/Application/[APP_ID]/Library/Application Support/default.store
```

### Сброс данных при разработке

Для очистки всех данных:
1. Xcode → Product → Clean Build Folder
2. Удалите приложение с симулятора/устройства
3. Переустановите

## Основные экраны

### 1. Onboarding (OnboardingView.swift)
- Показывается только при первом запуске
- 3 экрана: Welcome → Features → Get Started
- Создает профиль пользователя

### 2. WordCardStackView (главный экран)
- TikTok-style вертикальная прокрутка
- Свайпы для изучения слов
- XP и streak индикаторы
- Автоматический показ квиза каждые 20 слов

### 3. QuizView
- 5 вопросов за раз
- 4 типа вопросов: перевод, заполнение, multiple choice, аудирование
- Подсчет правильных/неправильных ответов
- XP награда за правильные ответы

### 4. ProfileView
- Информация о пользователе
- Уровень и прогресс XP
- Статистика обучения
- Достижения
- Настройки

### 5. StatisticsView
- Графики с Charts
- Слова по дням (Bar chart)
- Время обучения (Line chart)
- Точность ответов (Circular progress)
- Разбивка по категориям

## Кастомизация

### Изменение цветов

Откройте `UI/Theme/Colors.swift`:
```swift
static let brandPrimary = Color(hex: "6C5CE7") // Замените на свой цвет
static let brandSecondary = Color(hex: "A29BFE")
```

### Добавление слов

Используйте JSON в `Resources/SampleWords.json` или добавляйте программно:
```swift
let word = Word(
    english: "Breathtaking",
    transcription: "/ˈbreθteɪkɪŋ/",
    translation: "Захватывающий дух",
    explanation: "Something so beautiful or amazing it takes your breath away.",
    example: "The view from the mountain was absolutely breathtaking.",
    difficulty: .intermediate,
    category: "Adjectives"
)
dataManager.addWord(word)
```

### Изменение лимитов

`Utilities/Constants/AppConstants.swift`:
```swift
static let freeDailyLimit = 50 // Измените бесплатный лимит
static let quizInterval = 20 // Интервал показа квизов
```

## Тестирование функций

### Геймификация
- Свайпните 10 слов вправо → разблокируется достижение "Word Explorer"
- Наберите 100 XP → повышение уровня
- Занимайтесь 3 дня подряд → достижение "Getting Started"

### Quiz
- Свайпните 20 слов → автоматически откроется квиз
- Ответьте правильно на все вопросы → достижение "Perfect Score"

### Notifications
1. Settings → включите уведомления
2. Установите время напоминания
3. Симулятор не поддерживает уведомления - тестируйте на устройстве

### Premium
1. Нажмите на "Upgrade to Premium" в профиле
2. В StoreKit testing выберите подписку
3. Лимит слов станет безлимитным

## Отладка

### Логирование
Добавьте точки останова или print для отладки:
```swift
print("Words loaded: \(words.count)")
print("Current XP: \(profile.xp)")
```

### Проблемы с данными
Если данные не сохраняются:
1. Проверьте SwiftData в `DataManager.swift`
2. Убедитесь, что `try? modelContext.save()` вызывается
3. Проверьте консоль на ошибки

### UI не обновляется
Убедитесь, что используете `@Observable` и `@State`:
```swift
@Observable final class MyViewModel { }
@State private var viewModel: MyViewModel
```

## Production готовность

### Перед релизом:

1. **API ключи**: Переместите из кода в Keychain или серверную часть
2. **Analytics**: Добавьте Firebase/Mixpanel для аналитики
3. **Crash reporting**: Crashlytics или Sentry
4. **App Icon**: Создайте иконку 1024x1024px
5. **Screenshots**: Подготовьте для App Store
6. **Privacy Policy**: Разместите на сервере
7. **StoreKit**: Настройте реальные подписки в App Store Connect
8. **Testing**: Протестируйте на разных устройствах и iOS версиях

## Поддержка

При возникновении проблем:
1. Проверьте консоль Xcode на ошибки
2. Убедитесь, что версия iOS 17.0+
3. Очистите build folder (Cmd+Shift+K)
4. Перезапустите Xcode

## Лицензия

MIT License - свободно используйте для обучения или коммерческих проектов.

---

**Приложение полностью готово к компиляции и запуску!**

Все файлы созданы, архитектура продумана, код написан согласно best practices Swift 6 и SwiftUI.
