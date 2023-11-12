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

### Features
**File Format**:
- Original Scope: Allow users to import books in various file formats, ensuring versatility and compatibility (PDF, Epub, txt)
- Currently supporting text and pdf files

**OCR**: 
- Original Scope: Our app will utilise OCR technology to extract text from documents in cases where the text may be difficult to read due to scanning or other factors.
- Current implementation: when the camera is opened in emulator, instead of showing the default 3d environment, a picture is shown. 
  - When the capture button is pressed the user can choose to retake the photo or submit it to the ocr. 

**AI Text to Speech**: 
- Original Scope: Use an AI text to speech to generate high-quality, natural-sounding voices for reading the books.
- Current implementation is not using AI tts but rather Flutter TTS for time sake 

**Text Summary**: 
- Original Scope: Allow users to get a summary of the text that has been read so far.

**Offline Mode** (Working): 
- Original Scope: Implement ability for users to download audio versions of books for offline listening.

**Accessibility**: 
- Original Scope: Include text-to-speech for book descriptions or summaries.
- Removed for the time being.

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

**Favourites** (Not Implemented): 
- Original Scope: Users can favourite a book for quick access the next time they open the app.

_Some UI design is reworked from the proposal_

