import 'package:flutter/material.dart';
import 'package:kanban_board/src/board_inputs.dart';
import 'package:kanban_board/src/helpers/board_state_controller_storage.dart';
import 'package:kanban_board/src/widgets/textfield.dart';
import 'package:uuid/uuid.dart';

import 'controllers.dart';

class KanbanBoardController {
  late final String boardId;

  /// [KanbanBoardController] controls the behavior of some operations in [KanbanBoard].
  /// operations include adding a [group], adding a [group-item], etc.
  KanbanBoardController() : boardId = const Uuid().v4();

  /// [addGroup] adds a group to the board.
  void addGroup(String id, dynamic groupData) {
    final boardController =
        BoardStateControllerStorage.I.getStateController(boardId);
    if (boardController == null) {
      throw Exception('Board controller not found');
    }
    final groupName = groupData?.toString() ?? id;
    final groups = [...boardController.groups];
    groups.add(
      IKanbanBoardGroup(
        scrollController: ScrollController(),
        id: id,
        name: groupName,
        items: const [],
        customData: groupData,
        index: groups.length,
        setState: () => {},
        key: GlobalKey(),
      ),
    );
    boardController.setGroups(groups);
  }

  /// [addGroupItem] adds a group-item to the board at a specific index. If the index is not provided, it will be added at the end.
  void addGroupItem({
    required String groupId,
    required KanbanBoardGroupItem groupItem,
    int? index,
  }) {
    final boardController =
        BoardStateControllerStorage.I.getStateController(boardId);
    if (boardController == null) {
      throw Exception('Board controller not found');
    }
    final group = boardController.groups.firstWhere(
        (element) => element.id == groupId,
        orElse: (() => throw Exception('Group not found')));

    final insertIndex = index ?? group.items.length;
    final context = boardController.boardContext;
    final builder = boardController.groupItemBuilder;
    final fallbackWidget = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Text(groupItem.id),
    );
    final itemWidget = context != null && builder != null
        ? builder(context, groupId, insertIndex)
        : fallbackWidget;
    group.items.insert(
      insertIndex,
      IKanbanBoardGroupItem(
        groupIndex: group.index,
        id: groupItem.id,
        index: insertIndex,
        key: GlobalKey(),
        addedBySystem: false,
        itemWidget: itemWidget,
        ghost: itemWidget,
        setState: () {},
      ),
    );
    _syncItemIndices(group);
    group.setState();
  }

  /// [removeGroup] removes a group from the board.
  void removeGroup(String groupId) {
    final boardController =
        BoardStateControllerStorage.I.getStateController(boardId);
    if (boardController == null) {
      throw Exception('Board controller not found');
    }
    boardController.groups.removeWhere((element) => element.id == groupId);
    boardController.notify();
  }

  /// Removes a item from the group in the board.
  void removeGroupItem(String groupId, String itemId) {
    final boardController =
        BoardStateControllerStorage.I.getStateController(boardId);
    if (boardController == null) {
      throw Exception('Board controller not found');
    }
    final group = boardController.groups.firstWhere(
        (element) => element.id == groupId,
        orElse: (() => throw Exception('Group not found with id: $groupId')));

    group.items.removeWhere((element) => element.id == itemId);
    group.setState();
  }

  /// [showNewCard] shows a new card in the group.
  void showNewCard({
    required final String groupId,
    final int? position,
    final void Function(String)? onCardAdded,
  }) {
    final boardController =
        BoardStateControllerStorage.I.getStateController(boardId);
    if (boardController == null) {
      throw Exception('Board controller not found');
    }
    final group = boardController.groups.firstWhere(
        (element) => element.id == groupId,
        orElse: (() => throw Exception('Group not found')));

    final insertIndex = position ?? group.items.length;
    final newItemId = const Uuid().v4();
    final context = boardController.boardContext;
    final newCardBuilder = boardController.newCardWidgetBuilder;
    Widget newCard = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      height: 120,
      child: CardWithTextField(
        onCompleteEditing: (value) {
          final removeIndex = group.items.indexWhere(
            (element) => element.id == newItemId,
          );
          if (removeIndex != -1) {
            group.items.removeAt(removeIndex);
            _syncItemIndices(group);
            group.setState();
          }
          onCardAdded?.call(value);
        },
      ),
    );
    if (context != null && newCardBuilder != null) {
      newCard = newCardBuilder(context, groupId, newItemId);
    }
    group.items.insert(
      insertIndex,
      IKanbanBoardGroupItem(
        groupIndex: group.index,
        id: newItemId,
        index: insertIndex,
        key: GlobalKey(),
        addedBySystem: true,
        setState: () {},
        itemWidget: newCard,
        ghost: newCard,
      ),
    );
    _syncItemIndices(group);
    group.setState();
  }

  void _syncItemIndices(IKanbanBoardGroup group) {
    for (var i = 0; i < group.items.length; i++) {
      group.items[i].index = i;
      group.items[i].groupIndex = group.index;
    }
  }
}
