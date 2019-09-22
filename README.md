# Flight Rider
As my first Swift project for iOS, this is a demo project based on an own idea. Check the vision statement below to get the idea of the app.

## Vision statement
This application is designed for travelers, who usually travels with low-budget airlines. On these kinds of airlines you must pay for literally everything, almost nothing is included in the ticket, even if you want to sit next to the one(s) who you are travelling with you have to pay extra fee. 

This application helps to save this extra cost. With this application, people on the same flight can connect with each other from the moment they get their random seat given by the airline, but they can negotiate the seats even in flight. Unlike any other application on the market, this product is able to help people connect with each other, to be able to sit next to their travel mates without spending extra money, or just contact random people on the plane if they are bored in-flight using the app’s Bluetooth based chat.

## Installation and configuration

First, you need to clone this repository in order to fetch the code

```
$ git clone https://github.com/Clearinx/SeatExchangerApp.git
```

The project uses Firebase Authentication, so in order to compile your code, you need to install the dependencies first (FirebaseAuth). You can simply do this by running the following command in the root folder of the project (where the Podfile is located):

```
$ pod update
```

If you're not familiar with Cocoapods, [check their website](https://guides.cocoapods.org/using/getting-started.html")
, to see how you can install it.

Once the pods were installed properly, open **FlightRider.xcworkspace** with Xcode and run the project.

**Important!** The app uses iCloud to store and fetch data, so in order to be able to use it, you have to be signed in to iCloud. 

# Documentation

In the **Docs** folder, you can find further documentation and specification of the application, flowcharts which 
describe the operation of the different modules, etc. As this is an unfinished version yet, there may be some difference 
between the documentation and the implementation.

# Remarkable features/technologies used in the implementation

- CoreData
- CloudKit
- Keeping the integrity of the local and cloud DB with syncronization
- Firebase (Authentication)
- AviationEdge API (to check flight number validity and fetch departure date)
- Async thread handling
- CoreSpotlight
- UIKit
- AutoLayout

# Major features which will be implemented in the future

- Final design
- Push notifications
- Offline mode using local DB only
- Bluetooth based chat and minigames (to be able to interact offline during the flight)
- A server that handles some tasks like deleting obsolate flights from the cloud, handling push notifications, etc...

# Tests

Currently only UI tests are available, which you can find in the FlightRiderUITests folder. To run the tests, you have to make sure
that the "Remember me" switch in the main screen is switched off, and the E-mail and Password fields should be empty.
If everything is installed correctly, these tests should run successfully.

Non-ui tests will be available soon.
