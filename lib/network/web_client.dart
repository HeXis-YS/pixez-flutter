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

// import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:intl/intl.dart';
// import 'package:pixez/models/account.dart';
// import 'package:pixez/network/oauth_client.dart';

class WebClient {
  late Dio httpClient;
  // final String hashSalt =
  //     "28c1fdd170a5204386cb1313c7077b34f83e4aaf4aa829ce78c231e05b0bae2c";
  static const BASE_API_URL_HOST = 'www.pixiv.net';

  Future<Response> getIllustDetail(int illust_id) async {
    return httpClient.get("/ajax/illust/${illust_id}");
  }

  WebClient() {
    // String time = getIsoDate();
    this.httpClient = Dio()
      ..options.baseUrl = "https://210.140.131.219"
      ..options.headers = {
        // "X-Client-Time": time,
        // "X-Client-Hash": getHash(time + hashSalt),
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/118.0",
        HttpHeaders.acceptLanguageHeader: "zh-CN",
        // "App-OS": "Android",
        // "App-OS-Version": "Android 6.0",
        // "App-Version": "5.0.166",
        "Host": BASE_API_URL_HOST
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
