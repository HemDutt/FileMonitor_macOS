# FileMonitor_macOS

This is a Swift sample app to showcase File access event monitoring on macOS using GCD (DispatchSourceFileSystemObject).
This sample uses a minimal UI to add directories for access monitoring on the files inside the directory.
Application logs file access events with details such as Timestamp, User and Access Type.
App use Core data to store list of monitored directories.

This sample app is not the best design for File Access Monitoring and it is understood that a Daemon which launches on startup is better suited for this work.
Considering the Code signing set up required with a Daemon, This sample is intended for a simple demonstartion of File access monitoring in a Cocoa app.
