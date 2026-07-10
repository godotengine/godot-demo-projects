# Godot Google Play Billing Demo

This is a demo project (IAP store) showcasing how to use **Google Play Billing** with **Godot** using the [Godot Google Play Billing](https://github.com/godot-sdk-integrations) plugin.

The demo is intended as a sample implementation to help developers understand how to:

- Initialize Google Play Billing in Godot
- Query available in-app products
- Launch purchase flows
- Handle purchase updates
- Acknowledge and consume purchases correctly

---

## Requirements

- Godot Engine v4.2+
- Android gradle build setup (refer to [official documentation](https://docs.godotengine.org/en/stable/tutorials/export/android_gradle_build.html) for gradle build setup)
- A Google Play Console account
- An Android app created in Play Console (draft app is sufficient)
- At least one in-app product configured

---

## Running the Demo

1. Open the project in Godot.
2. Configure the Android export preset. Set the correct **package name** (must match Play Console).
3. Make sure the plugin is correctly installed in the project.
4. Build and install the app.
6. Make sure the app is uploaded to Play Console (Internal Testing is enough).

---

## Notes

- Billing works for apps installed via **Google Play**.
- Debug APKs installed manually will only work if the Google Play Store account on the device is added as a **license tester** in Play Console.

---

## Screenshots

<div align="center">
	<img src="https://github.com/user-attachments/assets/16ebca3e-2a4b-4324-915a-b8f78c407c7b" width="48%"/>
	<img src="https://github.com/user-attachments/assets/d30b5cf5-3b5c-40eb-97dd-f22b165792e2" width="48%"/>
	<img src="https://github.com/user-attachments/assets/e76701c7-4528-4c47-bc18-413ec31f4d43" width="48%"/>
	<img src="https://github.com/user-attachments/assets/fb36a947-6249-4289-8eb2-d74f1c700fd7" width="48%"/>
</div>
