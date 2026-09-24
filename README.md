# Gemini for iOS 6 (v2.0)

[English](#english) | [Русский](#russian)

---

<a name="english"></a>
## English

A native, lightweight client for the **Google Gemini API** built specifically for legacy Apple devices running **iOS 6.x** (such as iPhone 4S, iPhone 5, iPod touch 5G, and iPad 2/3/mini)[span_8](start_span)[span_8](end_span)[span_9](start_span)[span_9](end_span).

Version 2.0 represents a complete, ground-up rewrite in **100% native Objective-C**[span_10](start_span)[span_10](end_span). All legacy C/OpenSSL/cURL wrappers and heavy third-party dependencies have been completely eliminated[span_11](start_span)[span_11](end_span)[span_12](start_span)[span_12](end_span).

### Key Features
* **Zero External Dependencies:** Built entirely with native Apple frameworks (`UIKit`, `CoreGraphics`, `Foundation`) using standard asynchronous `NSURLConnection`[span_13](start_span)[span_13](end_span)[span_14](start_span)[span_14](end_span).
* **Authentic iOS 6 Skeuomorphism:** Custom-rendered chat bubbles inspired by the classic iOS 6 Messages app (featuring 3D glass gloss highlights, outer outlines, and natural tail geometry)[span_15](start_span)[span_15](end_span)[span_16](start_span)[span_16](end_span).
* **Session History Drawer:** Fast, slide-down drawer with persistent local chat storage powered by `NSCoding`[span_17](start_span)[span_17](end_span).
* **Dynamic Model Switching:** In-app selector that fetches current models directly from Google's endpoint with support for manual model ID entry[span_18](start_span)[span_18](end_span)[span_19](start_span)[span_19](end_span).
* **System Localization:** Automatically adapts to device language settings (English and Russian supported out of the box)[span_20](start_span)[span_20](end_span).

### Installation
1. Go to the **[Releases](https://github.com/guzhoffivan-hue/Gemini-for-iOS-6/releases)** section and download `Gemini.ipa`[span_21](start_span)[span_21](end_span)[span_22](start_span)[span_22](end_span).
2. Ensure your device is jailbroken and has **AppSync Unified** installed.
3. Install the `.ipa` using 3uTools, iFunBox, or on-device via iFile / Filza.

### Getting Started
1. Launch the application and enter your **Google Gemini API Key** when prompted (keys are stored locally in `NSUserDefaults` and never hardcoded)[span_23](start_span)[span_23](end_span)[span_24](start_span)[span_24](end_span).
2. Tap the top navigation title to switch between available models or refresh the list dynamically[span_25](start_span)[span_25](end_span)[span_26](start_span)[span_26](end_span).

### Network Setup (Fixing "User location is not supported")
Because the Gemini API enforces geographical restrictions, connecting directly from unsupported regions may return a `User location is not supported` error[span_27](start_span)[span_27](end_span)[span_28](start_span)[span_28](end_span).

Since iOS 6 lacks native support for modern VPN protocols or DoH/DoT profiles[span_29](start_span)[span_29](end_span)[span_30](start_span)[span_30](end_span), the easiest workaround is configuring **SmartDNS** directly in your Wi-Fi settings[span_31](start_span)[span_31](end_span)[span_32](start_span)[span_32](end_span):
1. Search online for `Xbox DNS` or `SmartDNS IPv4 addresses`[span_33](start_span)[span_33](end_span).
2. Open **Settings** ➔ **Wi-Fi** on your iOS device[span_34](start_span)[span_34](end_span).
3. Tap the **blue disclosure arrow (>)** next to your connected Wi-Fi network[span_35](start_span)[span_35](end_span).
4. Tap the **DNS** field and enter functional SmartDNS addresses (separated by commas)[span_36](start_span)[span_36](end_span).
5. Tap **Wi-Fi** in the top bar to save, then relaunch the app[span_37](start_span)[span_37](end_span)[span_38](start_span)[span_38](end_span).

### Credits
* **Developer & Maintainer:** [.PBL](https://github.com/guzhoffivan-hue)[span_39](start_span)[span_39](end_span)[span_40](start_span)[span_40](end_span)
* **Inspiration:** Early prototype ideas based on the legacy UI community.

---

<a name="russian"></a>
## Русский

Нативный легковесный клиент для **Google Gemini API**, созданный специально для устройств под управлением классической операционной системы **iOS 6.x** (iPhone 4S, iPhone 5, iPod touch 5G, iPad 2/3/mini)[span_41](start_span)[span_41](end_span)[span_42](start_span)[span_42](end_span).

Версия 2.0 — это полный рефакторинг кодовой базы с нуля на **100% чистом Objective-C**[span_43](start_span)[span_43](end_span). Проект полностью очищен от сторонних фреймворков, тяжелых сборок cURL, OpenSSL и чужих зависимостей[span_44](start_span)[span_44](end_span)[span_45](start_span)[span_45](end_span).

### Основные возможности
* **Полное отсутствие внешних библиотек:** Работает исключительно на системных фреймворках Apple (`UIKit`, `CoreGraphics`, `Foundation`) через проверенный нативный `NSURLConnection`[span_46](start_span)[span_46](end_span)[span_47](start_span)[span_47](end_span).
* **Аутентичный скевоморфизм iOS 6:** Векторные бабблы сообщений в оригинальном глянцевом стиле iOS 6 Сообщений (со стеклянным 3D-бликом, контуром и правильной кривизной хвостиков)[span_48](start_span)[span_48](end_span)[span_49](start_span)[span_49](end_span).
* **Шторка истории диалогов:** Удобное выпадающее меню со списком бесед и локальным сохранением истории на диск устройства через `NSCoding`[span_50](start_span)[span_50](end_span).
* **Динамический селектор моделей:** Подгрузка списка актуальных моделей Gemini Flash напрямую с серверов Google и возможность ручного ввода любого ID модели[span_51](start_span)[span_51](end_span)[span_52](start_span)[span_52](end_span).
* **Системная локализация:** Автоматическая адаптация интерфейса под язык устройства (русский и английский)[span_53](start_span)[span_53](end_span).

### Установка
1. Перейдите во вкладку **[Releases](https://github.com/guzhoffivan-hue/Gemini-for-iOS-6/releases)** и скачайте файл `Gemini.ipa`[span_54](start_span)[span_54](end_span)[span_55](start_span)[span_55](end_span).
2. Убедитесь, что на устройстве установлен джейлбрейк и твик **AppSync Unified**.
3. Установите `.ipa` через 3uTools, iFunBox или прямо на устройстве через iFile / Filza.

### Первый запуск и настройка
1. Запустите приложение и введите ваш **Google Gemini API Key** в появившемся диалоговом окне (ключ безопасно сохраняется в `NSUserDefaults` на устройстве)[span_56](start_span)[span_56](end_span)[span_57](start_span)[span_57](end_span).
2. Нажмите на заголовок в верхней панели навигации, чтобы выбрать рабочую модель, обновить список из сети или сменить ключ[span_58](start_span)[span_58](end_span)[span_59](start_span)[span_59](end_span).

### Настройка сети (Обход ошибки «User location is not supported»)
Поскольку API Google Gemini ограничено в некоторых регионах, при прямом обращении приложение может возвращать ошибку `User location is not supported`[span_60](start_span)[span_60](end_span)[span_61](start_span)[span_61](end_span).

Так как в iOS 6 нет поддержки современных VPN-протоколов и зашифрованных профилей DNS[span_62](start_span)[span_62](end_span)[span_63](start_span)[span_63](end_span), самым простым решением является ручная настройка **SmartDNS** в параметрах Wi-Fi[span_64](start_span)[span_64](end_span)[span_65](start_span)[span_65](end_span):
1. Найдите актуальные публичные адреса по запросу `xbox dns` или `comss dns`[span_66](start_span)[span_66](end_span).
2. Откройте системные **«Настройки»** ➔ **Wi-Fi** на устройстве[span_67](start_span)[span_67](end_span).
3. Нажмите на **синюю стрелочку (>)** справа от имени вашей сети[span_68](start_span)[span_68](end_span).
4. В строке **DNS** сотрите старые адреса и введите найденные адреса SmartDNS (через запятую и пробел)[span_69](start_span)[span_69](end_span).
5. Вернитесь назад, чтобы сохранить настройки, и перезапустите Gemini[span_70](start_span)[span_70](end_span)[span_71](start_span)[span_71](end_span).

### Авторы и благодарности
* **Разработка и адаптация:** [.PBL](https://github.com/guzhoffivan-hue)[span_72](start_span)[span_72](end_span)[span_73](start_span)[span_73](end_span)
