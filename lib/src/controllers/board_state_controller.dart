import 'package:flutter/material.dart';
import 'controllers.dart';

class BoardStateController extends ChangeNotifier {
  BoardStateController({
    required this.controller,
    this.groups = const [],
  });

  /// These are the list of internal group-state of the board.
  /// Each group-state holds the state of group and its items.
  List<IKanbanBoardGroup> groups = [];

  /// The controller for the board.
  KanbanBoardController controller;

  /// It holds whether the board is currently scrolling or not.
  bool isScrolling = false;

  /// It holds the state of widget currently being dragged.
  DraggableState draggingState = DraggableState.initial();

  /// It holds the board position
  Offset boardOffset = Offset.zero;

  /// A cached BuildContext for rendering new items via controller actions.
  BuildContext? boardContext;

  /// The builder used to render group items.
  Widget Function(BuildContext, String, int)? groupItemBuilder;

  /// The builder used to render the new-card widget.
  Widget Function(BuildContext, String, String)? newCardWidgetBuilder;

  // It holds the user's input ghost widget for the item.
  Widget? itemGhost;

  // It holds the user's input ghost widget for the group.
  Widget? groupGhost;

  void setScrolling(
    bool value, {
    bool notify = false,
  }) {
    isScrolling = value;
    if (notify) notifyListeners();
  }

  void setGroups(List<IKanbanBoardGroup> value) {
    groups = value;
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }
}
