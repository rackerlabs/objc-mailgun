The Mailgun SDK allows your Mac OS X or iOS application to connect with the [Mailgun](http://www.mailgun.com) programmable email platform. Send and manage mailing list subscriptions from your desktop or mobile applications and connect with your users directly in your application.
 
**Requirements** [AFNetworking 3.0](https://github.com/AFNetworking/AFNetworking/tree/3_0_0_branch) library is required for the `Mailgun` client library. Current implementation uses the beta1 branch.
 
Easy Image Attaching
====================
 
Using MGMessage will allow you to attach `UIImage` or `NSImage` instances to a message. It will handle converting the image for you and attaching it either inline or to the message header.

API Support
===========

At this time the full Mailgun REST API is not supported. Currently support is only provided to send messages, subscribe/unsubscribe from mailing lists and to check mailing lists subscriptions.

*Note* These features may be implemented at a later date.
 
Sending Example
===============

     Mailgun *mailgun = [Mailgun clientWithDomain:@"samples.mailgun.org" apiKey:@"key-3ax6xnjp29jd6fds4gc373sgvjxteol0"];
     [mailgun sendMessageTo:@"Jay Baird <jay.baird@rackspace.com>" 
                       from:@"Excited User <someone@sample.org>" 
                    subject:@"Mailgun is awesome!" 
                       body:@"A unicode snowman for you! ☃"];
 
Installation
============

Install via Cocoapods - Add:

        ```
        pod 'mailgun', :git => 'git://github.com/KomodoHQ/objc-mailgun'
        ```

to your Podfile.