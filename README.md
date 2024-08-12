DOC_BOOK
Overview:
This Flutter app is designed to facilitate booking appointments or tokens with nearby hospitals.  The application features several pages, 
including:
Auth Page: Handles user authentication (login and registration).
Doctor Booking Page: Users can search for doctors based on their location, specialization, and preferred time.
Chatbot Page: A health assistant chatbot that provides users with information and answers to their queries.
History Page: Displays the user's visit history with doctors, including details such as name, specialization, hospital name, date of visit, and rating.
Hospitals Page: Helps users find hospitals in their vicinity based on their location.
Location Page: Manages location services to determine the user's current location.
Main Navigation: Provides navigation between different pages of the app.

Pages Overview
1. Auth Page
Manages user authentication, allowing users to log in or register for an account.
2. Doctor Booking Page
Allows users to input their location, specialization needed, and appointment time.
Displays a list of available doctors based on the search criteria.
Users can book an appointment, which generates a token number.
3. Chatbot Page
Users can interact with a health assistant chatbot.
Sends queries to a backend service and displays responses.
4. History Page
Displays a list of previously visited doctors along with details and ratings.
Users can view past appointments and rebook if desired.
5. Hospitals Page
Users can search for hospitals based on their current location.
Provides a list of nearby hospitals with relevant details.
6. Location Page
Manages and retrieves the user's current location for use in other pages.
7. Main Navigation
Contains the navigation logic to switch between the various pages of the application.

Files Included:

auth_page.dart: Implements user authentication functionality. 

doctor_booking_page.dart: Manages the doctor search and appointment booking process.

chatbot_page.dart: Contains the chatbot interface and logic to handle user queries.

history_page.dart: Displays the visit history functionality.

hospitals_page.dart: Helps users find nearby hospitals.

location_page.dart: Manages location services.

main_navigation.dart: Handles navigation between pages.

widgets/: Contains reusable UI components such as:

custom_input.dart: Custom input fields for forms.

custom_icons.dart: Custom icons used throughout the app.

