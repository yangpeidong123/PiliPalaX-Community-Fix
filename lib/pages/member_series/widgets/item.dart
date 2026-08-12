import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/constants.dart';
import 'package:PiliPalaX/common/widgets/badge.dart';
import 'package:PiliPalaX/common/widgets/network_img_layer.dart';
import 'package:PiliPalaX/common/widgets/stat/view.dart';
import 'package:PiliPalaX/http/search.dart';
import 'package:PiliPalaX/utils/utils.dart';

class MemberSeriesItem extends StatelessWidget {
  final dynamic seriesItem;

  const MemberSeriesItem({
    super.key,
    required this.seriesItem,
  });

  @override
  Widget build(BuildContext context) {
    String heroTag = Utils.makeHeroTag(seriesItem.aid);
    return Card(
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () async {
          int cid =
              await SearchHttp.ab2c(aid: seriesItem.aid, bvid: seriesItem.bvid);
          Get.toNamed('/video?bvid=${seriesItem.bvid}&cid=$cid',
              arguments: {'videoItem': seriesItem, 'heroTag': heroTag});
        },
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: StyleString.aspectRatio,
              child: LayoutBuilder(builder: (context, boxConstraints) {
                double maxWidth = boxConstraints.maxWidth;
                double maxHeight = boxConstraints.maxHeight;
                return Stack(
                  children: [
                    Hero(
                      tag: heroTag,
                      child: NetworkImgLayer(
                        src: seriesItem.pic,
                        width: maxWidth,
                        height: maxHeight,
                      ),
                    ),
                    if (seriesItem.pubdate != null)
                      PBadge(
                        bottom: 6,
                        right: 6,
                        type: 'gray',
                        text: Utils.CustomStamp_str(
                            timestamp: seriesItem.pubdate, date: 'YY-MM-DD'),
                      )
                  ],
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 6, 0, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seriesItem.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      StatView(
                        view: seriesItem.view,
                        theme: 'gray',
                      ),
                      const Spacer(),
                      Text(
                        Utils.CustomStamp_str(
                            timestamp: seriesItem.pubdate, date: 'YY-MM-DD'),
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 6)
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
