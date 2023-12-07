import 'package:audioscribe/app_constants.dart';
import 'package:audioscribe/components/BookCard.dart';
import 'package:audioscribe/components/home_page_separator.dart';
import 'package:audioscribe/components/search_bar.dart';
import 'package:audioscribe/data_classes/librivox_book.dart';
import 'package:audioscribe/pages/details_page.dart';
import 'package:audioscribe/pages/uploadBook_page.dart';
import 'package:audioscribe/services/internet_archive_service.dart';
import 'package:audioscribe/utils/database/book_model.dart';
import 'package:audioscribe/utils/database/cloud_storage_manager.dart';
import 'package:audioscribe/utils/file_ops/book_storage_manager.dart';
import 'package:audioscribe/utils/interface/custom_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // list of users book
  List<Map<String, dynamic>> userBooks = [];

  // list of fetched books
  List<LibrivoxBook> books = [];

  @override
  void initState() {
    super.initState();
    fetchUserBooks();
    fetchApiBooks().then((allBooks) async {
      BookModel model = BookModel();
      List<LibrivoxBook> processedBooks = [];
      for (var book in allBooks) {
        // check if book exists in db
        var bookExists = await model.getBooksByTitle(book.title);
        if (bookExists.isNotEmpty) {
          // is book exists then return
          continue;
        } else {
          var imageLocation = await downloadAndSaveImage(
              "https://archive.org/services/get-item-image.php?identifier=${book.identifier}",
              '${getImageName("https://archive.org/services/get-item-image.php?identifier=${book.identifier}")}_img.png');
          LibrivoxBook processedBook = LibrivoxBook(
              id: book.id,
              author: book.author,
              title: book.title,
              identifier: book.identifier,
              description: book.description,
              date: book.date,
              downloads: book.downloads,
              numberReviews: book.numberReviews,
              rating: book.rating,
              runtime: book.runtime,
              size: book.size,
              imageFileLocation: imageLocation!);
          processedBooks.add(processedBook);

          // SQLite storage
          await model.insertAPIBook(processedBook);

          // Firestore storage
          await addBookToFirestore(
              processedBook.id,
              processedBook.title,
              processedBook.author,
              processedBook.description,
              '',
              processedBook.bookType,
              processedBook.rating,
              processedBook.numberReviews);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF303030),
      body: _buildHomePage(context),
    );
  }

  Widget _buildHomePage(BuildContext context) {
    // fallback for device back button
    setState(() {});

    /// combine both results for search bar
    List<Map<String, dynamic>> combinedBooksMapped = [
      ...userBooks,
      ...books
          .map((book) => {
                'id': book.id,
                'title': book.title,
                'author': book.author,
                'image': book.imageFileLocation,
                'bookType': book.bookType,
                'identifier': book.identifier,
                'runtime': book.runtime,
                'description': book.description,
                'rating': book.rating,
                'numberReviews': 0,
                'downloads': 0,
                'size': 0,
                'isBookmark': book.isBookmark,
                'isFavourite': book.isFavourite,
                'audioBookPath': book.audioFileLocation
              })
          .toList(),
    ]
        .map((book) => {
              'id': book['id'],
              'item': book['title'],
              'image': book['image'],
              'author': book['author'],
              'bookType': book['bookType'],
              'identifier': book['identifier'],
              'runtime': book['runtime'],
              'summary': book['description'] ?? book['summary'],
              'rating': book['rating'],
              'numberReviews': 0,
              'downloads': 0,
              'size': 0,
              'isBookmark': book['isBookmark'],
              'isFavourite': book['isFavourite'],
              'audioBookPath':
                  book['audioBookPath'] ?? book['audioFileLocation']
            })
        .toList();

    return Stack(
      children: [
        SafeArea(
          // prevent overflow
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Search bar
                AppSearchBar(
                  hintText: "search",
                  allItems: combinedBooksMapped,
                ),

                // Separator
                const Separator(text: "Your uploads"),
                _buildBookRow(),

                // Separator
                const Separator(text: "See our collection"),
                _buildBooklist(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// get the current instance of the user that is logged In
  String getCurrentUserId() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      return uid;
    } else {
      return 'No user is currently signed in';
    }
  }

  void bookSelected(LibrivoxBook book, String? audioBookPath) {
    Navigator.of(context).push(CustomRoute.routeTransitionBottom(DetailsPage(
        book: book,
        audioBookPath: audioBookPath,
        onChange: () async {
          await fetchUserBooks();
        })));
  }

  /// get all the books that the user has uploaded or bookmarked
  Future<void> fetchUserBooks() async {
    String userId = getCurrentUserId();

    // fetch books from firestore that are uploaded
    List<Map<String, dynamic>> booksUpload =
        await getBooksForUser(userId, 'UPLOAD');
    List<Map<String, dynamic>> booksAudio =
        await getBooksForUser(userId, 'AUDIO');

    List<Map<String, dynamic>> books = [...booksUpload, ...booksAudio];

    // transform for proper usage
    List<Map<String, dynamic>> transformedBooks = books.map((book) {
      return {
        'id': book['id'],
        'title': book['title'] ?? 'Unknown title',
        'author': book['author'] ?? 'Unknown author',
        'image': 'lib/assets/books/Default/textFile.png',
        'summary': book['summary'] ?? 'No summary available',
        'bookType': book['bookType'],
        'audioBookPath': book['audioBookPath'] ?? 'No Path Found'
      };
    }).toList();

    setState(() {
      userBooks = transformedBooks;
    });
  }

  /// fetches book from internet archive
  Future<List<LibrivoxBook>> fetchApiBooks() async {
    print('fetching books...');
    var apiBooksDb = await BookModel().getBooksByType('API');

    if (apiBooksDb.isNotEmpty) {
      // if API books exist then return them
      setState(() {
        books = apiBooksDb;
      });
      return apiBooksDb;
    } else {
      print("fetching from API");
      // if API books do not exist fetch from url
      ArchiveApiProvider archiveApiProvider = ArchiveApiProvider();
      var allBooks = await archiveApiProvider.fetchTopDownloads();
      setState(() {
        books = allBooks;
      });
      return allBooks;
    }
  }

  /// build a book row for uploaded books
  Widget _buildBookRow() {
    var screenWidth = MediaQuery.of(context).size.width;

    var bookWidth = screenWidth / 3;
    var bookHeight = bookWidth / 0.8;

    Widget uploadContainer = Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
        height: bookHeight + 50,
        child: GestureDetector(
          onTap: () {
            // go to upload screen on device
            uploadBook().then((data) {
              // if a file is selected then navigate to upload book page
              if (data.isNotEmpty) {
                Navigator.of(context)
                    .push(CustomRoute.routeTransitionBottom(UploadBookPage(
                  text: data,
                  onUpload: () {
                    fetchUserBooks();
                  },
                )));
              }
            });
          },
          child: Container(
            width: bookWidth + 20,
            decoration: const BoxDecoration(
                color: AppColors.secondaryAppColor,
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: const Icon(Icons.add_box_rounded,
                color: AppColors.primaryAppColorBrighter, size: 42.0),
          ),
        ),
      ),
    );

    Widget bookList = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
      height: bookHeight + 100,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: userBooks.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                var book = userBooks[index];

                print('CURRENT BOOK TYPE ${book['bookType']}');

                // get book mark status
                bool isBookmark =
                    await getUserBookmarkStatus(getCurrentUserId(), book['id']);
                bool isFavourite =
                    await getUserFavouriteBook(getCurrentUserId(), book['id']);

                // print('audioBookPath ${book['audioBookPath']}');
                LibrivoxBook selectedBook = LibrivoxBook(
                    id: book['id'],
                    title: book['title'],
                    author: book['author'],
                    imageFileLocation: book['image'],
                    bookType: book['bookType'],
                    date: DateTime.now().toLocal().toString(),
                    identifier: '',
                    runtime: '',
                    description: book['summary'],
                    rating: 0.0,
                    numberReviews: 0,
                    downloads: 0,
                    size: 0,
                    isBookmark: isBookmark == true ? 1 : 0,
                    isFavourite: isFavourite == true ? 1 : 0);

                bookSelected(selectedBook, book['audioBookPath']);
              },
              child: Container(
                width: bookWidth + 50,
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 0.7,
                      child: BookCard(
                          bookTitle: userBooks[index]['title'],
                          bookAuthor: userBooks[index]['author'],
                          bookImage: userBooks[index]['image'],
                          bookType: userBooks[index]['bookType']),
                    )
                  ],
                ),
              ),
            );
          }),
    );

    return userBooks.isEmpty ? uploadContainer : bookList;
  }

  /// build a grid pattern for books fetched from librivox
  Widget _buildBooklist() {
    return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.7),
        itemCount: books.length,
        itemBuilder: (context, index) {
          var book = books[index];
          return GestureDetector(
            onTap: () async {
              bookSelected(book, null);
            },
            child: Container(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 0.7,
                    child: BookCard(
                        bookTitle: book.title,
                        bookAuthor: book.author,
                        bookImage: book.imageFileLocation),
                  )
                ],
              ),
            ),
          );
        });
  }
}
