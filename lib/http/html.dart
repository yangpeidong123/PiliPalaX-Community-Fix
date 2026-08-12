import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:html/dom.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart';
import 'index.dart';

class HtmlHttp {
  // article
  static Future reqHtml(id, dynamicType) async {
    var response = await Request().get(
      "https://www.bilibili.com/opus/$id",
      extra: {'ua': 'pc'},
    );

    if (response.data.contains('Redirecting to')) {
      RegExp regex = RegExp(r'//([\w\.]+)/(\w+)/(\w+)');
      Match match = regex.firstMatch(response.data)!;
      String matchedString = match.group(0)!;
      response = await Request().get(
        'https:$matchedString/',
        extra: {'ua': 'pc'},
      );
    }
    try {
      Document rootTree = parse(response.data);
      // log(response.data.body.toString());
      Element body = rootTree.body!;
      Element appDom = body.querySelector('#app')!;
      Element authorHeader = appDom.querySelector('.fixed-author-header')!;
      // 头像
      String avatar = authorHeader.querySelector('img')!.attributes['src']!;
      avatar = 'https:${avatar.split('@')[0]}';
      String uname = authorHeader
          .querySelector('.fixed-author-header__author__name')!
          .text;

      // 动态详情
      Element opusDetail = appDom.querySelector('.opus-detail')!;
      // 发布时间
      String updateTime =
          opusDetail.querySelector('.opus-module-author__pub__text')!.text;
      //
      String opusContent =
          opusDetail.querySelector('.opus-module-content')!.innerHtml;
      String? test;
      test = opusDetail
              .querySelector('.horizontal-scroll-album__pic__img')
              ?.innerHtml ??
          '';

      String commentId = opusDetail
          .querySelector('.bili-comment-container')!
          .className
          .split(' ')[1]
          .split('-')[2];
      // List imgList = opusDetail.querySelectorAll('bili-album__preview__picture__img');
      return {
        'status': true,
        'avatar': avatar,
        'uname': uname,
        'updateTime': updateTime,
        'content': test + opusContent,
        'commentId': int.parse(commentId)
      };
    } catch (err) {
      print('err: $err');
    }
  }

  // read
  static Future reqReadHtml(id, dynamicType) async {
    var response = await Request().get(
      "https://www.bilibili.com/$dynamicType/$id/",
      options: Options(headers: {
        HttpHeaders.userAgentHeader: 'Mozilla/5.0',
        HttpHeaders.refererHeader: 'https://www.bilibili.com/',
        HttpHeaders.cookieHeader: 'opus-goback=1',
      }),
    );
    Document rootTree = parse(response.data);
    Element body = rootTree.body!;
    Element appDom = body.querySelector('#app')!;
    Element authorHeader = appDom.querySelector('.up-left')!;
    // 头像
    // String avatar =
    //     authorHeader.querySelector('.bili-avatar-img')!.attributes['data-src']!;
    // 正则寻找形如"author":{"mid":\d+,"name":".*","face":"xxxx"的匹配项
    String avatar = RegExp(r'"author":\{"mid":\d+?,"name":".+?","face":"(.+?)"')
        .firstMatch(response.data)!
        .group(1)!
        .replaceAll(r'\u002F', '/')
        .split('@')[0];
    print("avatar: $avatar");
    String uname = authorHeader.querySelector('.up-name')!.text.trim();
    print("uname: $uname");
    // 动态详情
    Element opusDetail = appDom.querySelector('.article-content')!;
    // 发布时间
    // String updateTime =
    //     opusDetail.querySelector('.opus-module-author__pub__text')!.text;
    // print(updateTime);

    //
    String opusContent =
        opusDetail.querySelector('#read-article-holder')?.innerHtml ?? '';
    print("opusContent: $opusContent");
    if (opusContent.isEmpty) {
      // 查找形如"dyn_id_str":"(\d+)"的id
      String opusid =
          RegExp(r'"dyn_id_str":"(\d+)"').firstMatch(response.data)!.group(1)!;
      print("opusid: $opusid");
      return await reqHtml(opusid, 'opus');
    }
    RegExp digitRegExp = RegExp(r'\d+');
    Iterable<Match> matches = digitRegExp.allMatches(id);
    String number = matches.first.group(0)!;
    return {
      'status': true,
      'avatar': avatar,
      'uname': uname,
      'updateTime': '',
      'content': opusContent,
      'commentId': int.parse(number)
    };
  }
}
