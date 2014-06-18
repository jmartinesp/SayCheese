SayCheese
=========

A screenshot taking app written in Swift (thought its libraries are Objective-C).

#Why?

There are plenty of apps for taking screenshots in OSX out there. Why another one?

Well, it's true that there are many apps out there and the one I like the most is [LightShot](http://app.prntscr.com/en/), but they all lack something from this list:

* They upload your screenshots anonymously so you can't control them once they are uploaded.
* You can only take live-screenshots. What's that? If you are playing a game or trying to get a cropped screenshot of something that disappears, you will have a bad time.
* They only upload screenshots of the whole screen.

Also, I wanted to write an app in *Swift*.

#What can I do with it?

**SayCheese** has a few options:

* Assign custom hotkeys to taking a screenshot.
* Region-selection screenshot taking.
* Save that selection locally as JPG or PNG.
* Upload it to [imgur.com](http://imgur.com):
  * Anonymously.
  * Using your account. This way you can delete them whenever you want.

#Do you have a binary?

But of course! You can download the last version from [here](http://arasthel.com/files/SayCheese.app.zip).

#How does it work?

The app consist of a few main classes:

* **BackgroundApplication** controls the hotkey pressing, it's the core of the app.
* **ScreenshotWindow** is launched by *BackgroundApplication* when you take a screenshot. It contains a **CroppingNSImageView** instance, which allows you to select the region to upload and a **SelectActionView** which lets you decide what to do with that selection.
* **ImgurClient** controls the session and handles uploading of screenshots.
* **PreferencesWindowController** lets you change the hotkeys with an **HotkeyTextField** wether you want the app to start at login and the Imgur account.

#Can I contribute?

If you are insane enough to read and comprehend the code, then sure, do it. Just be sure that you submit pull requests to **development** branch.

# Libraries used

For this project I used the [Objective-C library provided by Imgur](https://github.com/geoffmacd/ImgurSession) which also provides [AFNetworking](https://github.com/AFNetworking/AFNetworking), everything using CocoaPods.

# License

This app is licensed under Apache v2, so basically you can do whatever you want with it. For more info: [see LICENSE file](https://raw.githubusercontent.com/Arasthel/SayCheese/master/LICENSE).
