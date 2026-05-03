# LikeALocal - Travel Like a Local

## Project Overview

**LikeALocal** is a mobile application designed to enrich a tourist's travel experience by providing personalized, local-like experiences when visiting a city. Unlike traditional travel apps, the system focuses on uncovering hidden gems and culturally authentic locations tailored to each user's preferences.

### Core Concept
- Create an international community where users can contribute by sharing posts about underrated destinations in their local area/country
- Share reviews on places visited
- Connect with post owners to acquire more detailed information and recommendations
- AI-driven recommendation algorithms generate tailored recommendations based on user data (interests, budget, travel style, time constraints)

---

## User Stories

### Authentication
| Story ID | User Story |
|----------|------------|
| AUTH-01 | As a guest, I can search and view places only |
| AUTH-02 | As a guest, I can create an account |
| AUTH-03 | As a user, I want to log out of my account to be secured on different devices |

### Browsing
| Story ID | User Story |
|----------|------------|
| BROWSE-01 | As a user or guest, I can search and apply filtering based on categories |
| BROWSE-02 | As a user, I can apply user preferences |
| BROWSE-03 | As a user, I want to search for places using name, keyword, etc. |

### Discover Places & Activities
| Story ID | User Story |
|----------|------------|
| DISCOVER-01 | As a user, I can display locations on a map with a "near me" feature |
| DISCOVER-02 | As a user, I can pin locations for later and set reminders based on location |
| DISCOVER-03 | As a user, I want to see details of a place (tips, reviews, pictures, etc.) |
| DISCOVER-04 | As a user, I want background functionality that triggers push notifications when physically near a recommended or hidden location |
| DISCOVER-05 | As a user, I can chat in the app with the post owner to get more personalized recommendations |
| DISCOVER-06 | As a user, I can check other users' profiles and their trips |
| DISCOVER-07 | As a user, I can set a privacy mode to turn chatting on/off with owners or create a schedule |
| DISCOVER-08 | As a user, I can add reviews in the review section of a post |
| DISCOVER-09 | As a user, I can edit/delete my own review |
| DISCOVER-10 | As a user, I can become a super user if I contribute a lot, chat a lot, help people, or have good reviews/feedback |
| DISCOVER-11 | As a super user, my posts appear first on home page or after searching for a place |

### User Settings
| Story ID | User Story |
|----------|------------|
| SETTINGS-01 | As a user, I can receive assistance from my AI assistant to learn my user style (preferred types of places, budget, atmosphere) and get personalized recommendations through a chatbot or smart suggestions |
| SETTINGS-02 | As a user, I want to receive clear error messages (no internet, invalid input, etc.) |
| SETTINGS-03 | As a user, I want to be able to enable/disable notifications |
| SETTINGS-04 | As a user, I can make my trips private for personal record only |

### Offline Support
| Story ID | User Story |
|----------|------------|
| OFFLINE-01 | As a user, I want access to recently viewed places (cached) when offline so I can use the app with no internet |

### Data & Backend
| Story ID | User Story |
|----------|------------|
| DATA-01 | As a user, I want my data to be stored securely using Firebase |
| DATA-02 | As a user, I want my images/videos to be uploaded and retrieved efficiently |
| DATA-03 | As a system, I want to sync real-time data so users see updates instantly |

### Extra Features
| Story ID | User Story |
|----------|------------|
| EXTRA-01 | As a user, I can activate "spontaneity mode" for random spontaneous location picks to explore |
| EXTRA-02 | As a user, I can earn badges for surpassing a number of explored destinations |

#### Badge Levels
| Badge Name | Requirement |
|------------|-------------|
| Newbie Traveler | 1-5 locations |
| Casual Explorer | 6-15 locations |
| Seasoned Traveler | 20+ locations |
| Dora The Explorer | 35+ locations |

### Monetization
| Story ID | User Story |
|----------|------------|
| MON-01 | To monetize the app, the user is allowed 5 pins before the app becomes paid |
| MON-02 | As a user, I can upgrade to premium to unlock unlimited pins and get rid of ads |
| MON-03 | As a user, I can see premium benefits clearly to understand the value |

---

## Core Features (Required)

### Must-Have Features
-  User accounts and authentication
- Several screens with navigation (bottom navigation bar, tabs)
- Online Database (Firebase)
- Push notifications
- Error handling (connection issues, wrong inputs)
- At least 2 features out of scope of the course
- Good UI and UX
- Comments/reviews can be edited or deleted

### Technical Requirements
- **State Management:** Provider package
- **Backend:** Firebase (Authentication, Firestore Database, Storage, Cloud Messaging)
- **AI Integration:** External API (Gemini/OpenAI/Hugging Face) for personalized recommendations
- **Caching:** Offline functionality for recently viewed places

---

## Technical Architecture

### Tech Stack
Frontend: Flutter (Dart)
State Management: Provider
Backend: Firebase

Authentication (Email/Password + Google Sign-in)

Cloud Firestore (Database)

Firebase Storage (Images/Videos)

Firebase Cloud Messaging (Notifications)
AI: External API (Gemini API / OpenAI)
Caching: Hive / SharedPreferences
Maps: Google Maps API