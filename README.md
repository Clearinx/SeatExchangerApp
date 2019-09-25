# Flight Rider
Thank you for showing interest in my project. As my first Swift project for iOS, this is a demo project based on an own idea. Check the vision statement below to get the idea of the app. If you are interested in more project related documents, diagrams, flowcharts, you can check the **Docs** folder.

## Vision statement
This application is designed for travelers, who usually travels with low-budget airlines. On these kind of airlines you must pay for literally everything, almost nothing is included in the ticket, even if you want to sit next to the one(s) who you are travelling with you have to pay extra fee. 

The application helps to save this extra cost. With this app, people on the same flight can connect with each other from the moment they get their random seat given by the airline, but they can negotiate the seats even in flight. Unlike any other application on the market, this software is able to help connecting people, to be able to sit next to their travel mates without spending extra money or just contact random people on the plane if they are bored in-flight using the app’s Bluetooth based chat.

## Installation and configuration

First, you need to clone this repository in order to fetch the code

```
$ git clone https://github.com/Clearinx/SeatExchangerApp.git
```

The project uses Firebase Authentication, so in order to compile your code, you need to install the dependencies first (FirebaseAuth). You can simply do this by running the following command in the root folder of the project (where the Podfile is located):

```
$ pod install
```

If you're not familiar with Cocoapods, [check their website](https://guides.cocoapods.org/using/getting-started.html")
, to see how you can install it.

Once the pods were installed properly, open **FlightRider.xcworkspace** with Xcode and run the project.

### Important! 

As the app uses iCloud to store and fetch data, in order to be able to use it, you have to be signed in to iCloud on your device (or simulator). 

## Documentation

In the **Docs** folder, you can find further documentation and specification of the application, flowcharts which 
describe the operation of the different modules, etc. As this is an unfinished version yet, there may be some difference 
between the documentation and the implementation.

## Remarkable features/technologies used in the implementation

- CoreData
- CloudKit
- Keeping the integrity of the local and cloud DB with syncronization
- Firebase (Authentication)
- AviationEdge API (to check flight number validity and fetch departure date)
- UserDefaults
- Async thread handling
- CoreSpotlight
- UIKit
- AutoLayout

## Major features which will be implemented in the future

- Final design
- Push notifications
- Offline mode using local DB only
- Bluetooth based chat and minigames (to be able to interact offline during the flight)
- A server that handles some tasks like deleting obsolate flights from the cloud, handling push notifications, etc...

## Basic info of the application/possible scenarios and use cases you may try

Basic info:

- Multiple user accounts can be created, and users' data are handled separatley.
- Only valid, existing flight numbers can be added. 
-There is a constant integrity among the local database and iCloud, so the app could have ran based on the local data as well. As there isn't any offline feature implemented yet, offline mode is not available.

In this phase basically you can do in the app is the following:

### Create a new user

Create a new user by entering an e-mail address (it doesn't have to be valid, it only has to look like an e-mail address. For example `x@x.com` is fine) and password, then tapping on the sign up button. In the background, this will try create a user in the project's firebase account, and if it gets positive response from firebase, it will use that data to sign in.

<img src="https://github.com/Clearinx/SeatExchangerApp/blob/master/Docs/GIFs/signup.gif" width="247" height="417">

### Login with an existing user

Login with an existing user, using the e-mail and the password field, tapping on the login button. The scenario from the background side is the same, which is shown by the diagram below: 

<img src="https://github.com/Clearinx/SeatExchangerApp/blob/master/Docs/Diagrams/Flowchart/Keeping%20users%20in%20local%20and%20cloud%20DB%20in%20sync.jpg" width="464" height="642">

<img src="https://github.com/Clearinx/SeatExchangerApp/blob/master/Docs/GIFs/login.gif" width="247" height="417">

### Register on flights

After you signed in, you can register on flights by tapping the + sign on the top-right corner of the screen. Only valid, existing flight numbers will be accepted. The validity of the flight will be checked by a 3rd party website called AviationEdge through an API. Unfortunately not all airlines are present in their database, so there may be cases when the flight number you enter is valid, but the app will reject your request. Some airlines that are confirmed to be present in the AviationEdge database:

- Ryaniar 
- easyJet 
- Wizzair
- Eurowings 
- Vueling
- Aer Lingus

I'll leave some valid flightcodes here, so you can try the app:

- FR110, FR114, U2555, EI167, VY7105, EW2463, LS432, W62237, W62485, LH1336

Of course, you can use other flightnumbers (to be exact, officially these are called iata numbers) as well, as long as the airline is supported by the AviationEdge database.

When you tap on the + sign, you will be prompted for the flightcode, and the departure date. If you tap on the Submit button, in the background, the following procedure will happen:

<img src="https://github.com/Clearinx/SeatExchangerApp/blob/master/Docs/Diagrams/Flowchart/Keeping%20flights%20and%20seats%20in%20local%20and%20cloud%20DB%20in%20sync.jpg" width="590" height="1062">

As you can see from this diagram, in the current implementation the unique identifier of the flights is the iataNumber (flight number). This will be changed in the near future, because the iata number identifies a flight route, not an exact flight. This means that the iata number will be the same in case of the same flight routes in a different time. This it leads to the following things:

- For example flights FR110 on November 5th and November 6th are handled as identical
- As nothing deletes the flights if they become obsolate (the departure date passes), they will remain in iCloud. This causes the following: 
  - For example someone registers on a flight with an iataNumber FR110 and date 2019.10.25. This flight will be stored in iCloud with this date. If someone else wants to register on the same FR110 flight, but on 2019.11.03, the app will fetch the existing FR110 flight, with departure date 2019.10.25, as the unique identifier is FR110 in this case.
  
### Check the status of a flight

After you registered on a flight successfully, it will appear on your screen, as a tableview element. If you tap on tableview item, you can check the staus of that flight.

Every airline has different policy for checking-in with random seats. In this version, the app uses Ryanair's policy, that means that it will allow you to select your randomly received seat at least 48 hours before the departure date. According to this, 3 possible scenarios can happen, when you tap on a tableview element:

- It is too early, random seats are not available yet. You will see a screen showing the flight number and the days/hours/minutes left until random seats become available (48 hours before the departure date)

<img src="https://github.com/Clearinx/SeatExchangerApp/blob/master/Docs/GIFs/notavailable.gif" width="247" height="417">

- You are in time, and you haven't selected seat(s) yet. You will see a screen showing the flight number, and a pickerview, which you can use for selecting your randomly received seat. **At this point, the application assumes that you have already checked in using the airline's official application or website, and you have received your random seat(s). You are supposed to select these seats on this screen.** You can select any number of seats, by setting the picker to the desired value, and tapping on the update button. Every plane and every airline has different layout of seats, in the future this will be fetched from AviationEdge database (every module is prepared to handle more airplane types, only the data is missing). In the current version, it is assumed that the plane has 32 rows and 6 columns marked with ABCDEF letters. After selecting at least one seat, and you leave this screen by tapping the Done or Back button on the navigation bar, you won't be able to select seats again for this flight. This behaviour will be changed in the future. If you tap on the Done button, you will be navigated to a screen where you can check the seats of this flight. Check the details in the next bulletpoint.

<img src="https://github.com/Clearinx/SeatExchangerApp/blob/master/Docs/GIFs/selectseats.gif" width="247" height="417">

- You have already selected at least one seat. On this screen you can check the seats represented by squares with different colors (as mentioned above, 6x32 seats will be presented, as the data for current airplane types are not available yet). The meaning of the colors:
  - Blue: Empty seat. Non of the users of this application has this seat (but probably it will be occupied by someone).
  - Green: The seat is occupied by the current user.
  - Red: The seat is occupied by another user. If you tap on a red seat, an alert will pop up, and it offers you to contact the user. These functions will be implemented in the future.
  
<img src="https://github.com/Clearinx/SeatExchangerApp/blob/master/Docs/GIFs/selectedseats.gif" width="247" height="417">
  
### Delete a flight from your list

You can delete a flight from your list by swiping left on a tableview item, and tapping the newly appeared delete button. You will see that the flight number disappears from your list. In the background, from iCloud only your seats will be deleted (there likely to be more users registered on that flight, so it cannot be deleted from iCloud). From the local database first the seats you occupied, after the flight will be deleted (as it is unlikely that more users will use the application from the same device, the flight can be deleted as well). 

<img src="https://github.com/Clearinx/SeatExchangerApp/blob/master/Docs/GIFs/deleteflight.gif" width="247" height="417">

Some other basic info:

- Multiple user accounts can be created, and users' data are handled separatley.
- Only valid, existing flight numbers can be added. 
- There is a constant integrity among the local database and iCloud, so the app could have ran based on the local data as only. As there are no offline features implemented yet, offline mode is not available.

## Tests

Currently only UI tests are available, which you can find in the FlightRiderUITests folder. To run the tests, you have to make sure
that the "Remember me" switch in the main screen is switched off, and the E-mail and Password fields should be empty.
If everything is installed correctly, these tests should run successfully.

Non-ui tests will be available soon.
