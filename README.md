Gemini for Legacy iOS
The native Google Gemini client for legacy iOS devices.
Gemini for Legacy iOS is a client designed for classic versions of iOS, allowing you to interact directly with the Google Gemini API on vintage Apple hardware. Built on top of the classic iOS design language, the app brings modern LLM capabilities to retro devices while preserving the authentic feel of iOS 6.

Features
Native conversation flow with conversational context retention.

In-App dynamic model selection directly from the chat title (supports Gemini 2.0 Flash, Gemini 2.5 Flash, etc.).

Custom manual model input support.

Chat history automatically saved to local storage.

Authentic iOS 6 skeuomorphic user interface and dedicated icon assets.

Compatibility
Compatibility	iOS Version	Tested Devices / Remarks
Incompatible	5.x	Not supported
Compatible	6.x	Optimized for iOS 6.0 – 6.1.3 (e.g., iPhone 4S)
Compatible	7.x	Compatible
Untested	8+	Functional, but UI is unoptimized for larger screens
How do I log in?
Logging into Gemini for Legacy iOS requires a Google Gemini API key:

Obtain your API key from Google AI Studio.

Enter the key into the application when prompted on initial launch (or pass it through application settings).

Google AI Studio provides a free usage tier for individual developers. Please refer to Google's official pricing and terms of service regarding rate limits and region availability.

Installation
Ready-to-use IPA (Jailbroken Devices)
Download the latest Gemini.ipa release from the Releases section.

Ensure your device has AppSync Unified installed from Cydia.

Install the IPA package using your preferred tool (such as 3uTools, iFunBox, or directly on-device via iFile / Filza).

Building from Source
Environment: OS X Mavericks (10.9) or compatible macOS running Xcode 6.2 (iOS 6 / 8.2 SDK).

Open ChatGPT.xcodeproj, set the active scheme to an iOS Device or Simulator, configure code signing settings (or set CODE_SIGNING_REQUIRED=NO), and compile.

Encountering issues, or need support?
If you run into crashes or network errors:

Note the exact behavior, your iOS version, your device model, and the selected Gemini model.

If you receive API connection or region errors, ensure your network DNS configuration supports calls to Google API endpoints.

Open a ticket in the Issues tab.

Credits & Acknowledgments
Original Project & Base Code: bag.xml — creator of ChatGPT-for-Legacy-iOS, upon which this Gemini adaptation was built.

Porting & Modernization: Adapted to Google Gemini API by Ivan Guzhov.

Third-Party Libraries Used
APLSlideMenu

Base64

NSURLConnection+FoundationCompletions (Custom OpenSSL and cURL implementation for legacy TLS support)

TSMarkdownParser

SVProgressHUD
