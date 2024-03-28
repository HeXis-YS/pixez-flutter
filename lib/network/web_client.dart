/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:intl/intl.dart';
import 'package:pixez/network/api_client.dart';

class WebClient {
  late Dio httpClient;
  static const BASE_API_URL_HOST = 'www.pixiv.net';

  Future<Response> getIllustDetail(int illust_id) async {
    return httpClient.get('/ajax/illust/${illust_id}');
  }

  Future<Response> getIllustPages(int illust_id) async {
    return httpClient.get('/ajax/illust/${illust_id}/pages');
  }

  Future<void> updateWebIllust(Map illust) async {
    final int illustId = illust['id'];
    final Response webResponse = await getIllustDetail(illustId);
    final webIllust = webResponse.data['body'];
    safeUpdateArray(illust, [
        'title',
        'caption',
        'restrict',
        'create_date',
        'page_count',
        'width',
        'height',
        'sanity_level',
        'x_restrict',
        'total_view',
        'total_bookmarks',
        'illust_ai_type',
        'illust_book_style'
      ], webIllust, [
        'title', 
        'description', 
        'restrict',
        'createDate',
        'pageCount',
        'width',
        'height',
        'sl',
        'xRestrict',
        'bookmarkCount',
        'viewCount',
        'aiType',
        'bookStyle']);
    safeUpdateArray(illust['image_urls'], ['square_medium', 'medium', 'large'], webIllust['urls'], ['thumb', 'small', 'regular']);    
    safeUpdateArray(illust['user'], ['name', 'account'], webIllust, ['userName', 'userAccount']);
    final Response user = await apiClient.getUser(illust['user']['id']);
    safeUpdate(illust['user']['profile_image_urls'], 'medium', user.data['user']['profile_image_urls']['medium']);
    safeUpdate(illust['user'], 'is_followed', user.data['user']['is_followed']);
    for (var tag in webIllust['tags']['tags']) {
      if (tag['translation']['en'] != null) {
        illust['tags'].add({'name': tag['tag'], 'translated_name': tag['translation']['en']});
      } else {
        illust['tags'].add({'name': tag['tag']});
      }
    }
    if (illust['page_count'] > 1) {
      final Response pages = await WebClient().getIllustPages(illustId);
      for (var page in pages.data['body']) {
        illust['meta_pages'].add({'image_urls': {
            'square_medium': page['urls']['thumb_mini'],
            'medium': page['urls']['small'],
            'large': page['urls']['regular'],
            'original': page['urls']['original']}});
      }
    } else {
      illust['meta_single_page']['original_image_url'] = webIllust['urls']['original'];
    }
    illust['visible'] = true;
    // illust['type'] = Indirect
    // illust['tools'] = ?
    // illust['is_bookmarked'] = No need?
    // illust['is_muted'] = ?
  }

  void safeUpdate(Map dst, String key, dynamic newValue) {
    if (dst != null && newValue != null) {
      dst[key] = newValue;
    }
  }

  void safeUpdateArray(Map dst, var dstKeys, Map src, var srcKeys) {
    if (dst == null || src == null) {
      return;
    }

    int i = 0;
    for (String key in srcKeys) {
      if (src[key] != null) dst[dstKeys[i]] = src[key];
      i++;
    }
  }

  WebClient() {
    // String time = getIsoDate();
    this.httpClient = Dio()
      ..options.baseUrl = 'https://210.140.131.219'
      ..options.headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/118.0',
        HttpHeaders.acceptLanguageHeader: 'zh-CN',
        'Host': BASE_API_URL_HOST
      }
      ..options.connectTimeout = Duration(seconds: 5)
      ..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    httpClient.httpClientAdapter = IOHttpClientAdapter()
      ..onHttpClientCreate = (client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
  }
}
