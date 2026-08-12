import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/utils/storage.dart';

import 'package:PiliPalaX/plugin/pl_player/models/player_middle_gesture.dart';
import 'package:PiliPalaX/plugin/pl_player/models/player_gesture_action.dart';

class GestureSelectPage extends StatefulWidget {
  const GestureSelectPage({super.key});

  @override
  State<GestureSelectPage> createState() => _GestureSelectPageState();
}

class _GestureSelectPageState extends State<GestureSelectPage> {
  Box setting = GStorage.setting;
  late Map<PlayerMiddleGesture, PlayerGestureAction> gestureAction;
  late Map<int, int> gestureCodeMap;

  @override
  void initState() {
    super.initState();
    gestureCodeMap = Map<int, int>.from(
        setting.get(SettingBoxKey.playerGestureActionMap, defaultValue: {
      PlayerMiddleGesture.nonFullScreenUp.code:
          PlayerGestureAction.toggleFullScreen.code,
      PlayerMiddleGesture.nonFullScreenDown.code:
          PlayerGestureAction.pipInside.code,
      PlayerMiddleGesture.fullScreenUp.code: PlayerGestureAction.pipInside.code,
      PlayerMiddleGesture.fullScreenDown.code:
          PlayerGestureAction.toggleFullScreen.code,
    }));
    gestureAction = Map.fromEntries(
      PlayerMiddleGesture.values.map(
        (e) => MapEntry(
          e,
          PlayerGestureActionCode.fromCode(gestureCodeMap[e.code]!)!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getGestureActionDescription(
      PlayerMiddleGesture gesture, PlayerGestureAction action) {
    if (action == PlayerGestureAction.toggleFullScreen) {
      if (gesture == PlayerMiddleGesture.nonFullScreenUp ||
          gesture == PlayerMiddleGesture.nonFullScreenDown) {
        return '进入全屏';
      } else if (gesture == PlayerMiddleGesture.fullScreenUp ||
          gesture == PlayerMiddleGesture.fullScreenDown) {
        return '退出全屏';
      }
    }
    return action.description;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!;
    TextStyle subTitleStyle = Theme.of(context)
        .textTheme
        .titleMedium!
        .copyWith(color: Theme.of(context).colorScheme.outline);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          '播放器中部手势设置',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView(
        children: [
          for (var gesture in PlayerMiddleGesture.values)
            ListTile(
                title: Text(gesture.description, style: titleStyle),
                trailing: PopupMenuButton(
                  initialValue: gestureAction[gesture],
                  onSelected: (action) async {
                    gestureAction[gesture] = action;
                    gestureCodeMap[gesture.code] = action.code;
                    await setting.put(
                        SettingBoxKey.playerGestureActionMap, gestureCodeMap);
                    setState(() {});
                  },
                  itemBuilder: (context) => PlayerGestureAction.values
                      .map((action) => PopupMenuItem<PlayerGestureAction>(
                            value: action,
                            child: Text(
                                getGestureActionDescription(gesture, action)),
                          ))
                      .toList(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        getGestureActionDescription(
                            gesture, gestureAction[gesture]!),
                        style: subTitleStyle,
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
