import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:built_collection/built_collection.dart';
import 'package:mudeo/.env.dart';
import 'package:mudeo/data/models/artist_model.dart';
import 'package:mudeo/data/models/entities.dart';
import 'package:mudeo/data/models/serializers.dart';
import 'package:mudeo/data/web_client.dart';
import 'package:mudeo/redux/auth/auth_state.dart';

class ArtistRepository {
  const ArtistRepository({
    this.webClient = const WebClient(),
  });

  final WebClient webClient;

  Future<ArtistEntity> loadItem(AuthState auth, int entityId) async {
    String url = '${Config.API_URL}/users/$entityId?include=songs';

    final dynamic response = await webClient.get(url, auth.artist.token);

    final ArtistItemResponse artistResponse =
        serializers.deserializeWith(ArtistItemResponse.serializer, response);

    return artistResponse.data;
  }

  Future<BuiltList<ArtistEntity>> loadList(
      AuthState auth, int updatedAt) async {
    return null;

    /*

    String url = '$kAppURL/users?';

    if (updatedAt > 0) {
      url += '&updated_at=${updatedAt - kUpdatedAtBufferSeconds}';
    }


    final dynamic response = await webClient.get(url, company.token);

    final ArtistListResponse artistResponse =
        serializers.deserializeWith(ArtistListResponse.serializer, response);

    return artistResponse.data;
    */
  }

  Future<ArtistEntity> saveData(AuthState auth, ArtistEntity artist,
      [EntityAction action]) async {
    final data = serializers.serializeWith(ArtistEntity.serializer, artist);

    var url = '${Config.API_URL}/users/${artist.id}?';
    if (action != null) {
      url += '&action=' + action.toString();
    }
    dynamic response =
        await webClient.put(url, auth.artist.token, json.encode(data));

    final ArtistItemResponse artistResponse =
        serializers.deserializeWith(ArtistItemResponse.serializer, response);

    return artistResponse.data;
  }

  Future<ArtistEntity> saveImage(
      AuthState auth, String path, String imageType) async {
    dynamic response = await webClient.post(
        '${Config.API_URL}/user/$imageType', auth.artist.token,
        filePath: path, fileField: 'image');

    final ArtistItemResponse artistResponse =
        serializers.deserializeWith(ArtistItemResponse.serializer, response);

    return artistResponse.data;
  }

  Future<ArtistFollowingEntity> followArtist(AuthState auth, ArtistEntity artist,
      {ArtistFollowingEntity artistFollowing}) async {
    dynamic response;

    if (artistFollowing != null) {
      var url = '${Config.API_URL}/user_follow/${artist.id}';
      response = await webClient.delete(url, auth.artist.token);

      return artistFollowing;
    } else {
      var url = '${Config.API_URL}/user_follow?user_following_id=${artist.id}';
      response = await webClient.post(url, auth.artist.token);

      final ArtistFollowingItemResponse songResponse =
      serializers.deserializeWith(ArtistFollowingItemResponse.serializer, response);

      return songResponse.data;
    }
  }

}
