# DuoX
_Online shopping, geosocial application_

<img src="https://user-images.githubusercontent.com/39606745/158277172-fb08d9f4-fa0b-4eef-b51c-f56e6fd4844b.gif" width="250" />

## Description
DuoX is an IOS App, which is a Tinder-like online shopping and social platform based on a user’s geographical location. To be more specific, users of our application are able to see card views(one at a time) of different items posted by other users living nearby. Our users can swipe right or left to show likes or dislikes towards the current item on the main screen. 

## Features

Basically, our application, DuoX, is a Tinder-like online shopping and social platform based on a user’s geographical location. To be more specific, users of our application are able to see card views(one at a time) of different items posted by other users living nearby. Our users can swipe right or left to show likes or dislikes towards the current item on the main screen. 

Moreover, each user has a list of the items he or she has liked. Each user can be either seller or buyer or both. For example, sellers can make posts about the items they are selling so that other users living just a few blocks away are able to see them. Also, the items that users are swiping are not necessarily just items or merchandise, they could also be any social activities such as “playing cards”, “go hiking”, “go fishing”, etc. 

Some other basic features are logins and logouts, account registration, posting and deleting items, chatting with other users, viewing chatting history, etc. 

## How to run the app 

git clone or download the repository. And open the inner folder with Xcode, so that this app can be ran on the simulator or deployed on the Iphone. To successfully run this app on Xcode simulator, please select the correct “Architectures” in the project Build Settings (Default is arm64). 

## High-level overview of  Tech

The app applies the Model-View-ViewModel (MVVM) architecture pattern. The main advantage of using this architecture pattern is that we can significantly reduce the code reuse in our home controller. CardViewModel can act as the ‘middleman’ for storing necessary information as well as the attribute text ui patterns.

This app provides registration and login functionality by using FirebaseAuth.

This app allows users to upload up to three images, name, description and price per item. That information will be stored in the firebase and other users will get that information as Cards in the main screen when they use this app.

This app uses the pan gesture to allow users to swipe the items right or left in order to like or dislike. A threshold being provided to check whether or not to remove the card. 

This app provides real-time chat between two users. Chat history will be recorded on the firebase. To achieve real-time chat for both sides, except storing the message we also use ​​FIRlistener to fetch the changes as need.


## Reference

https://firebase.google.com/docs/ios/setup?authuser=0
https://developer.apple.com/documentation/uikit/uivisualeffectview
https://developer.apple.com/documentation/uikit/uiview/1622418-animate
https://developer.apple.com/documentation/uikit/uinavigationcontroller/1621887-pushviewcontroller
https://developer.apple.com/documentation/quartzcore/caanimation/1412458-isremovedoncompletion
https://stackoverflow.com/questions/34735707/swift-pause-cabasicanimation-for-calayer
https://stackoverflow.com/questions/28197079/swift-addsubview-and-remove-it
https://developer.apple.com/documentation/uikit/uiview/1622554-addkeyframe
https://www.hackingwithswift.com/example-code/language/what-are-lazy-variables
https://stackoverflow.com/questions/45402639/pinch-pan-and-rotate-text-simultaneously-like-snapchat-swift-3
https://github.com/JonasGessner/JGProgressHUD
https://www.letsbuildthatapp.com/course/Tinder%20Firestore%20Swipe%20and%20Match
https://developer.apple.com/documentation/quartzcore/cabasicanimation
https://stackoverflow.com/questions/68147044/how-to-translate-localize-a-variable-in-swift
https://firebase.google.com/docs/auth/ios/manage-users
https://firebase.google.com/docs/auth/ios/password-auth
https://firebase.google.com/docs/database/ios/read-and-write
https://firebase.google.com/docs/database/ios/lists-of-data
https://firebase.google.com/docs/reference/swift/firebasefirestore/api/reference/Classes
https://github.com/bhlvoong/LBTATools
https://stackoverflow.com/questions/61016476/how-to-fix-duplication-error-of-googleutilities-swift
https://github.com/SDWebImage/SDWebImage
https://stackoverflow.com/questions/6059054/cabasicanimation-resets-to-initial-value-after-animation-completes
https://developer.apple.com/documentation/uikit/uiview/1622618-sendsubviewtoback
https://developer.apple.com/documentation/uikit/uiviewcontroller/1621355-modalpresentationstyle
https://developer.apple.com/documentation/uikit/uiview/1622541-bringsubviewtofront
https://developer.apple.com/documentation/uikit/uiview/1622566-layoutmargins

