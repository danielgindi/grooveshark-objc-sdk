grooveshark-objc-sdk
===================

An ObjC Grooveshark SDK for iOS.

In order to use it you could either:
* Drag the compiled `GroovesharkSDK.framework` to your project, and add in the "Embedded Binaries" section under the General tab of your target.
* Or drag the `GroovesharkSDK.xcodeproj` into your project, and add the `GroovesharkSDK.framework` to your target's Build Phases

For some reason, Frameworks built with Xcode 6 need to be added to the "Embedded Binaries" section in the target, otherwise you get a "Library not found" error when trying to run your app.

## Building

You can simply run the `build-framework.sh` script, and it will build all the architectures needed and pack them as one Framework under the `dist` folder.
`bash build-framework.sh`

## Me
* Hi! I am Daniel Cohen Gindi. Or in short- Daniel.
* danielgindi@gmail.com is my email address.
* That's all you need to know.

## License

All the code here is under MIT license. Which means you could do virtually anything with the code.
I will appreciate it very much if you keep an attribution where appropriate.

    The MIT License (MIT)
    
    Copyright (c) 2013 Daniel Cohen Gindi (danielgindi@gmail.com)
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

