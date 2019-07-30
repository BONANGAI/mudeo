import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:mudeo/data/models/artist_model.dart';

part 'auth_state.g.dart';

abstract class AuthState implements Built<AuthState, AuthStateBuilder> {
  factory AuthState() {
    return _$AuthState._(
      artist: ArtistEntity(),
      isAuthenticated: false,
      isInitialized: false,
    );
  }

  AuthState._();

  ArtistEntity get artist;

  bool get isInitialized;

  bool get isAuthenticated;

  @nullable
  String get error;

  AuthState get reset => rebuild((b) => b
    ..artist.replace(ArtistEntity())
    ..isInitialized = true
    ..isAuthenticated = false);

  bool get hasValidToken => artist.token != null && artist.token.isNotEmpty;

  static Serializer<AuthState> get serializer => _$authStateSerializer;
}
