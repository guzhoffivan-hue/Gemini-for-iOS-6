# Gemini for iOS 6 (v2.0)

[English](#english) | [Русский](#russian)

---

<a name="english"></a>
## English

A native, lightweight client for the **Google Gemini API** built specifically for legacy Apple devices running **iOS 6.x** (such as iPhone 4S, iPhone 5, iPod touch 5G, and iPad 2/3/mini).

Version 2.0 represents a complete, ground-up rewrite in **100% native Objective-C**. All legacy C/OpenSSL/cURL wrappers and heavy third-party dependencies have been completely eliminated.

### Key Features
* **Zero External Dependencies:** Built entirely with native Apple frameworks (`UIKit`, `CoreGraphics`, `Foundation`) using standard asynchronous `NSURLConnection`.
* **Authentic iOS 6 Skeuomorphism:** Custom-rendered chat bubbles inspired by the classic iOS 6 Messages app (featuring 3D glass gloss highlights, outer outlines, and natural tail geometry).
* **Session History Drawer:** Fast, slide-down drawer with persistent local chat storage powered by `NSCoding`.
* **Dynamic Model Switching:** In-app selector that fetches current models directly from Google's endpoint with support for manual model ID entry.
* **System Localization:** Automatically adapts to device language settings (English and Russian supported out of the box).

### Installation
1. Go to the **[Releases](https://github.com/guzhoffivan-hue/Gemini-for-iOS-6/releases)** section and download `Gemini.ipa`.
2. Ensure your device is jailbroken and has **AppSync Unified** installed.
3. Install the `.ipa` using 3uTools, iFunBox, or on-device via iFile / Filza.

### Getting Started
1. Launch the application and enter your **Google Gemini API Key** when prompted (keys are stored locally in `NSUserDefaults` and never hardcoded).
2. Tap the top navigation title to switch between available models or refresh the list dynamically.

### Network Setup (Fixing "User location is not supported")
Because the Gemini API enforces geographical restrictions, connecting directly from unsupported regions may return a `User location is not supported` error.

Since iOS 6 lacks native support for modern VPN protocols or DoH/DoT profiles, the easiest workaround is configuring **SmartDNS** directly in your Wi-Fi settings:
1. Search online for `Xbox DNS` or `SmartDNS IPv4 addresses`.
2. Open **Settings** ➔ **Wi-Fi** on your iOS device.
3. Tap the **blue disclosure arrow (>)** next to your connected Wi-Fi network.
4. Tap the **DNS** field and enter functional SmartDNS addresses (separated by commas).
5. Tap **Wi-Fi** in the top bar to save, then relaunch the app.

### Credits
* **Developer & Maintainer:** [.PBL](https://github.com/guzhoffivan-hue)
* **Inspiration:** Early prototype ideas based on the legacy UI community.

---

<a name="russian"></a>
## Русский

Нативный легковесный клиент для **Google Gemini API**, созданный специально для устройств под управлением классической операционной системы **iOS 6.x** (iPhone 4S, iPhone 5, iPod touch 5G, iPad 2/3/mini).

Версия 2.0 — это полный рефакторинг кодовой базы с нуля на **100% чистом Objective-C**. Проект полностью очищен от сторонних фреймворков, тяжелых сборок cURL, OpenSSL и чужих зависимостей.

### Основные возможности
* **Полное отсутствие внешних библиотек:** Работает исключительно на системных фреймворках Apple (`UIKit`, `CoreGraphics`, `Foundation`) через проверенный нативный `NSURLConnection`.
* **Аутентичный скевоморфизм iOS 6:** Векторные бабблы сообщений в оригинальном глянцевом стиле iOS 6 Сообщений (со стеклянным 3D-бликом, контуром и правильной кривизной хвостиков).
* **Шторка истории диалогов:** Удобное выпадающее меню со списком бесед и локальным сохранением истории на диск устройства через `NSCoding`.
* **Динамический селектор моделей:** Подгрузка списка актуальных моделей Gemini Flash напрямую с серверов Google и возможность ручного ввода любого ID модели.
* **Системная локализация:** Автоматическая адаптация интерфейса под язык устройства (русский и английский).

### Установка
1. Перейдите во вкладку **[Releases](https://github.com/guzhoffivan-hue/Gemini-for-iOS-6/releases)** и скачайте файл `Gemini.ipa`.
2. Убедитесь, что на устройстве установлен джейлбрейк и твик **AppSync Unified**.
3. Установите `.ipa` через 3uTools, iFunBox или прямо на устройстве через iFile / Filza.

### Первый запуск и настройка
1. Запустите приложение и введите ваш **Google Gemini API Key** в появившемся диалоговом окне (ключ безопасно сохраняется в `NSUserDefaults` на устройстве).
2. Нажмите на заголовок в верхней панели навигации, чтобы выбрать рабочую модель, обновить список из сети или сменить ключ.

### Настройка сети (Обход ошибки «User location is not supported»)
Поскольку API Google Gemini ограничено в некоторых регионах, при прямом обращении приложение может возвращать ошибку `User location is not supported`.

Так как в iOS 6 нет поддержки современных VPN-протоколов и зашифрованных профилей DNS, самым простым решением является ручная настройка **SmartDNS** в параметрах Wi-Fi:
1. Найдите актуальные публичные адреса по запросу `xbox dns` или `comss dns`.
2. Откройте системные **«Настройки»** ➔ **Wi-Fi** на устройстве.
3. Нажмите на **синюю стрелочку (>)** справа от имени вашей сети.
4. В строке **DNS** сотрите старые адреса и введите найденные адреса SmartDNS (через запятую и пробел).
5. Вернитесь назад, чтобы сохранить настройки, и перезапустите Gemini.

### Авторы и благодарности
* **Разработка и адаптация:** [.PBL](https://github.com/guzhoffivan-hue)
