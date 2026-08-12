import 'package:PiliPalaX/models/video/ai.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/utils/utils.dart';

import 'package:PiliPalaX/pages/rank/zone/view.dart';

import '../../../../http/video.dart';
import '../../widgets/ai_detail.dart';
import 'package:PiliPalaX/common/widgets/my_dialog.dart';

class IntroDetail extends StatelessWidget {
  const IntroDetail({
    super.key,
    this.videoDetail,
    required this.enableAi,
    required this.aiConclusion,
  });
  final dynamic videoDetail;
  final bool enableAi;
  final Future<dynamic> Function() aiConclusion;

  @override
  Widget build(BuildContext context) {
    InlineSpan? span = buildContent(context, videoDetail!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 4),
        Row(children: [
          if (videoDetail!.tname != null && videoDetail.tid != null)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Text(videoDetail!.tname!,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      body: ZonePage(tid: videoDetail!.tid!),
                    ),
                  ),
                );
              },
              // 移除按钮外边距
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                minimumSize: WidgetStateProperty.all(Size.zero),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                        width: 1, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
              child: Text(
                videoDetail!.tname ?? '',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 13,
                  height: 1,
                ),
              ),
            ),
          const SizedBox(width: 8),
          SelectableText(
            key: PageStorageKey<String>(videoDetail!.bvid!),
            videoDetail!.bvid!,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(width: 5),
          if (enableAi)
            Semantics(
                label: 'AI总结',
                child: GestureDetector(
                  onTap: () async {
                    final res = await aiConclusion();
                    if (res['status'] && context.mounted) {
                      showAiBottomSheet(context, res['data'].modelResult);
                    }
                  },
                  child: Image.asset('assets/images/ai.png', height: 24),
                )),
        ]),
        if (span != null) ...[
          const SizedBox(height: 4),
          SelectableText.rich(
            key: PageStorageKey<String>('${videoDetail!.bvid!}intro'),
            style: const TextStyle(
              height: 1.4,
              // fontSize: 13,
            ),
            TextSpan(
              children: [span],
            ),
          ),
        ],
      ],
    );
  }

  InlineSpan? buildContent(BuildContext context, content) {
    final List descV2 = content.descV2;
    if (descV2.isEmpty) {
      return null;
    }
    if (descV2.length == 1 && descV2[0].type == 1 && descV2[0].rawText == '-') {
      return null;
    }
    // 1 普通文本
    // 2 @用户
    final List<TextSpan> spanChildren = List.generate(descV2.length, (index) {
      final currentDesc = descV2[index];
      switch (currentDesc.type) {
        case 1:
          final List<InlineSpan> spanChildren = <InlineSpan>[];
          final RegExp urlRegExp = RegExp(r'https?://\S+\b');
          final Iterable<Match> matches =
              urlRegExp.allMatches(currentDesc.rawText);

          int previousEndIndex = 0;
          for (final Match match in matches) {
            if (match.start > previousEndIndex) {
              spanChildren.add(TextSpan(
                  text: currentDesc.rawText
                      .substring(previousEndIndex, match.start)));
            }
            spanChildren.add(
              TextSpan(
                text: match.group(0),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary), // 设置颜色为蓝色
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // 处理点击事件
                    try {
                      Get.toNamed(
                        '/webview',
                        parameters: {
                          'url': match.group(0)!,
                          'type': 'url',
                          'pageTitle': match.group(0)!,
                        },
                      );
                    } catch (err) {
                      SmartDialog.showToast(err.toString());
                    }
                  },
              ),
            );
            previousEndIndex = match.end;
          }

          if (previousEndIndex < currentDesc.rawText.length) {
            spanChildren.add(TextSpan(
                text: currentDesc.rawText.substring(previousEndIndex)));
          }

          final TextSpan result = TextSpan(children: spanChildren);
          return result;
        case 2:
          final Color colorSchemePrimary =
              Theme.of(context).colorScheme.primary;
          final String heroTag = Utils.makeHeroTag(currentDesc.bizId);
          return TextSpan(
            text: '@${currentDesc.rawText}',
            style: TextStyle(color: colorSchemePrimary),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Get.toNamed(
                  '/member?mid=${currentDesc.bizId}',
                  arguments: {'face': '', 'heroTag': heroTag},
                );
              },
          );
        default:
          return const TextSpan();
      }
    });
    return TextSpan(children: spanChildren);
  }

  // ai总结
  showAiBottomSheet(context, modelResult) {
    // showBottomSheet(
    //   context: context,
    //   enableDrag: true,
    //   builder: (BuildContext context) {
    MyDialog.showCorner(context, AiDetail(modelResult: modelResult));
  }
}
