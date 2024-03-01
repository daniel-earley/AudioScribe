# AudioScribe

### Project Objective
The goal of AudioScribe is to develop an innovative audio book app
that enhances the reading experience. The app’s main objective is to provide the users with
a convenient way to read and/or listen to books. The primary objective is to
create a platform where users can import books in various file formats, including PDF, EPUB
and others, and have the app read the text using an AI-generated voice. The app will accept
uploads of all book file types and use an OCR to make all the text readable. From there an
AI voice recording will be made reading all of the text and stored in an audio file format for
playback. When the recording is finished, a notification will be sent out to let the user know
their book is ready to be listened to.

### How to run
1. `git clone` the project onto your local machine
2. Run `flutter pub get` to get all the dependencies
3. Make sure to have `firebase cli` set up as you will need firebase authentication in order to login
4. Run the project in Android studio using an emulator with Google Play

### Demonstration
Something to run to try out the current features.

1. Once you have the app running, sign up (or log in if you somehow already have an account).
2. Once you sign up a notification should appear letting you know of your login.
3. You can press on one of the books in the recommendation, then press on the bookmark symbol on the book to bookmark it
4. Once every minute, a notification will pop out to recommend you to read a book.

- The login page you can login or signup (use a the username: devalp2401@gmail.com and the password: pass123 if you wish)
- The homepage lets you navigate your selected items and the system (API) items
  - can upload items from the homepage from the bottom floating action button or if the uploads container is empty then the '+' symbol box in the uploads section
  - search bar lets you navigate through items specific to the page your are on and can select on the items
- The collections page lets you see your personalized collection (favourited, bookmarked, or uploaded items)
- The details page (when you select an item), shows the book details in depth, including the summary, rating, whether its favourited or bookmarked
  - can bookmark, favourite, and rate items on this page
  - can listen to the selected item
- The audiopage lets you listen to selected item
  - can navigate to chapters if the audiobook uploaded has chapters or API books which have chapters
  - basic functionalities include, play, pause, forward, rewind and exiting the audio while listening to it allows saving the audio player state allowing you to return to where you last left off


### Features
**File Format**: (Implemented)
- Original Scope: Allow users to import books in various file formats, ensuring versatility and compatibility (PDF, Epub, txt)
- Currently supporting text and pdf files
- Summative: Allowed support for txt, pdf, and mp3 files

**OCR**: (Implemented)
- Original Scope: Our app will utilise OCR technology to extract text from documents in cases where the text may be difficult to read due to scanning or other factors.
- Current implementation: when the camera is opened in emulator, instead of showing the default 3d environment, a picture is shown. 
  - When the capture button is pressed the user can choose to retake the photo or submit it to the ocr. 

**AI Text to Speech** (Implemented**): 
- Original Scope: Use an AI text to speech to generate high-quality, natural-sounding voices for reading the books.
- Current implementation is not using AI tts but rather Flutter TTS for time sake
- Summative: **implemented the text to speech portion but used the default text to speech 

**Text Summary** (Implemented): 
- Original Scope: Allow users to get a summary of the text that has been read so far.

**Offline Mode** (Implemented): 
- Original Scope: Implement ability for users to download audio versions of books for offline listening.

**User Accounts** (Implemented): 
- Original Scope: Users can create an account.

**Book Information** (Implemented): 
- Original Scope: Users will easily be able to learn information about the book’s author, date of publication, etc.

**Book Blurb** (Implemented): 
- Original Scope: Users will be able to read the back cover (aka blurb) of the book they’re about to listen to.

**Recommendations** (Implemented): 
- Orignal Scope: A horizontal recommendations bar will give the users quick access to books they may enjoy.
- Reworked Scope: A horizontal row of books within the system. Additional goal would be to have multiple rows of books split by genre.

**Library/Saved Books** (Implemented): 
- Original Scope: Users can save books that they have uploaded to the app.

**Favourites** (Implemented): 
- Original Scope: Users can favourite a book for quick access the next time they open the app.

_Some UI design is reworked from the proposal_

