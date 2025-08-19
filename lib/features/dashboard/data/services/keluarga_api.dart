import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppnpm_dpr/app/config.dart';
import 'package:ppnpm_dpr/features/dashboard/data/models/family_member.dart';

class KeluargaApi {
  final http.Client _client;
  final String _baseUrl;

  KeluargaApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<List<FamilyMemberDto>> fetchMembers({String? search}) async {
    final uri = _uri(
      '/keluarga${search != null && search.isNotEmpty ? '?q=${Uri.encodeQueryComponent(search)}' : ''}',
    );
    final res = await _client.get(uri, headers: await _headers());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = json.decode(res.body);
      final list = (body is List) ? body : (body['data'] as List? ?? []);
      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => FamilyMemberDto.fromJson(e))
          .toList();
    }
    throw HttpException(
      'Failed to load members',
      statusCode: res.statusCode,
      body: res.body,
    );
  }

  Future<void> deleteMember(String id) async {
    final res = await _client.delete(
      _uri('/keluarga/$id'),
      headers: await _headers(),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw HttpException(
        'Failed to delete member',
        statusCode: res.statusCode,
        body: res.body,
      );
    }
  }

  Future<FamilyMemberDto> getMember(String id) async {
    final res = await _client.get(
      _uri('/keluarga/$id'),
      headers: await _headers(),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = json.decode(res.body);
      final map =
          (body is Map<String, dynamic>) ? (body['data'] ?? body) : body;
      return FamilyMemberDto.fromJson(Map<String, dynamic>.from(map));
    }
    throw HttpException(
      'Failed to load member',
      statusCode: res.statusCode,
      body: res.body,
    );
  }

  Future<void> createMember(Map<String, dynamic> payload) async {
    final res = await _client.post(
      _uri('/keluarga'),
      headers: await _headers(),
      body: json.encode(payload),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw HttpException(
        'Failed to create member',
        statusCode: res.statusCode,
        body: res.body,
      );
    }
  }

  Future<void> updateMember(String id, Map<String, dynamic> payload) async {
    final res = await _client.put(
      _uri('/keluarga/$id'),
      headers: await _headers(),
      body: json.encode(payload),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw HttpException(
        'Failed to update member',
        statusCode: res.statusCode,
        body: res.body,
      );
    }
  }

  Future<Map<String, String>> _headers() async {
    // TODO: inject token if available from secure storage
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // 'Authorization': 'Bearer YOUR_TOKEN',
    };
  }
}

class HttpException implements Exception {
  final String message;
  final int statusCode;
  final String? body;

  HttpException(this.message, {required this.statusCode, this.body});

  @override
  String toString() => 'HttpException($statusCode): $message';
}

final keluargaApiProvider = Provider<KeluargaApi>((ref) {
  return KeluargaApi();
});
