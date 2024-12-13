import 'package:hugues_final_project24/utils/http_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MovieCodeScreen extends StatefulWidget {
  const MovieCodeScreen({super.key});

  @override
  State<MovieCodeScreen> createState() => _MovieCodeScreenState();
}

class _MovieCodeScreenState extends State<MovieCodeScreen> {
  final String baseUrl = 'https://api.themoviedb.org/3/movie/popular';
  final String imageBaseUrl = 'https://image.tmdb.org/t/p/';

  List movies = [];
  List selected = [];
  bool isLoading = true;
  bool matchFound = false;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Movie Choice',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              )
            : !matchFound
                ? _buildSwipeCard()
                : _buildSelectedMovie(),
      ),
    );
  }

  Widget _buildSwipeCard() {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(movies[0]['id'].toString()),
      onDismissed: (direction) {
        setState(() {
          if (selected.isNotEmpty) {
            selected.removeLast();
            selected.add(movies[0]);
          } else {
            selected.add(movies[0]);
          }
          movies.removeAt(0);
        });

        if (direction == DismissDirection.endToStart) {
          _voteMovies(movies[0]['id'], false);
        } else {
          _voteMovies(movies[0]['id'], true);
        }
      },
      background: _buildDismissBackground(Icons.thumb_up),
      secondaryBackground: _buildDismissBackground(Icons.thumb_down),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: theme.colorScheme.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMovieImage(movies[0]['poster_path']),
              _buildMovieDetails(movies[0]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedMovie() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Selected Movie",
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: theme.colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMovieImage(selected[0]['poster_path']),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected[0]['title'],
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          selected[0]['overview'],
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMovieMetadata(selected[0]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDismissBackground(IconData icon) {
    final theme = Theme.of(context);

    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: theme.colorScheme.primary,
        size: 48,
      ),
    );
  }

  Widget _buildMovieImage(String posterPath) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Image.network(
        '$imageBaseUrl/w500/$posterPath',
        height: 400,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 400,
            color: theme.colorScheme.surfaceVariant,
            child: Icon(
              Icons.error,
              size: 50,
              color: theme.colorScheme.error,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMovieDetails(Map<String, dynamic> movie) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie['title'],
            style: theme.textTheme.titleLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          _buildMovieMetadata(movie),
        ],
      ),
    );
  }

  Widget _buildMovieMetadata(Map<String, dynamic> movie) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            movie['release_date'],
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.star,
                color: theme.colorScheme.onSecondaryContainer,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                movie['vote_average'].toStringAsFixed(1),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _voteMovies(int movieId, bool vote) async {
    try {
      final pref = await SharedPreferences.getInstance();
      final String? sessionId = pref.getString("sessionId");

      if (sessionId == null) {
        throw MovieApiException('No active session found');
      }

      final response = await HttpHelper.voteMovie(
        sessionId: sessionId,
        movieId: movieId,
        vote: vote,
      );

      setState(() {
        matchFound = response.isNotEmpty;
      });
    } on MovieApiException catch (e) {
      print('Vote Error: ${e.message}');
      // You might want to show a snackbar or dialog here
    } catch (e) {
      print('Unexpected error while voting: $e');
    }
  }

  Future<void> fetchMovies() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await HttpHelper.fetchMovies(baseUrl);
      final results = response['results'] as List<dynamic>;

      if (results.isEmpty) {
        throw MovieApiException('No movies found');
      }

      setState(() {
        movies = [...results]..shuffle();
        isLoading = false;
      });
    } on MovieApiException catch (e) {
      print('Failed to fetch movies: ${e.message}');
      // You might want to show an error message to the user
    } catch (e) {
      print('Unexpected error while fetching movies: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
