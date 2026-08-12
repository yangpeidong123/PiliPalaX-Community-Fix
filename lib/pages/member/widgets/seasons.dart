import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/constants.dart';
import 'package:PiliPalaX/common/widgets/badge.dart';
import 'package:PiliPalaX/models/member/seasons.dart';

import '../../../common/widgets/network_img_layer.dart';
import '../../../utils/grid.dart';
import '../../../utils/utils.dart';

class MemberSeasonsAndSeriesPanel extends StatelessWidget {
  final List<MemberSeasonsList>? seasonsList;
  final List<MemberSeriesList>? seriesList;
  const MemberSeasonsAndSeriesPanel({super.key, this.seasonsList, this.seriesList});

  @override
  Widget build(BuildContext context) {
    int seasonListSize = (seasonsList?.length ?? 0);
    int seriesListSize = (seriesList?.length ?? 0);
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < seasonListSize) {
            return MemberSeasonOrSeriesItemList(
                list: seasonsList![index]);
          } else {
            return MemberSeasonOrSeriesItemList(
                list: seriesList![index - seasonListSize]);
          }
        },
        childCount: seasonListSize + seriesListSize,
      ),
      gridDelegate: SliverGridDelegateWithExtentAndRatio(
          crossAxisSpacing: StyleString.cardSpace,
          mainAxisSpacing: StyleString.cardSpace,
          maxCrossAxisExtent: Grid.maxRowWidth,
          childAspectRatio: StyleString.aspectRatio,
          mainAxisExtent: 50),
    );
  }
}

class MemberSeasonOrSeriesItemList extends StatelessWidget {
  final SeasonsOrSeriesList list;

  const MemberSeasonOrSeriesItemList({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    var meta = list.meta!;
    late String type;
    late GestureTapCallback onTap;
    if (meta is SeasonMeta) {
      type = "合集";
      onTap = () => Get.toNamed(
          '/memberSeason?mid=${meta.mid}&seasonId=${meta.seasonId}');
    } else if (meta is SeriesMeta) {
      type = "列表";
      onTap = () => Get.toNamed(
          '/memberSeries?mid=${meta.mid}&seriesId=${meta.seriesId}');
    }

    String heroTag = Utils.makeHeroTag(meta.mid!);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      src: meta.cover,
                      width: maxWidth,
                      height: maxHeight,
                    ),
                  ),
                  PBadge(
                    text: "$type:${meta.total}",
                    right: 6.0,
                    top: 6.0,
                    type: 'gray',
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 4.0),
          Text(
            meta.name ?? "",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
