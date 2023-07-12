import 'dart:async';

import 'package:chat_bot/models/expression_view_model.dart';
import 'package:chat_bot/views/expression_view.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class Expression {
  bool get isPlaying => _controller?.isActive ?? false;

  StateMachineController? _controller;
  ExpressionViewModel viewModel = ExpressionViewModel();
  final StreamController<ExpressionViewModel> _streamController = StreamController<ExpressionViewModel>();

  Expression() {
    init();
  }

  Stream<ExpressionViewModel> get stream {
    return _streamController.stream;
  }

  void init() {
    rootBundle.load('assets/robot.riv').then(
      (data) async {
        // Load the RiveFile from the binary data.
        final file = RiveFile.import(data);

        // The artboard is the root of the animation and gets drawn in the
        // Rive widget.
        final artboard = file.mainArtboard;
        var controller = StateMachineController.fromArtboard(artboard, 'robot_state_machine');
        if (controller != null) {
          artboard.addController(controller);
          viewModel.expressionValue = controller.findInput('expression');
          viewModel.expressionValue?.value = 0;
          notifyUI();
        }
        viewModel.riveArtboard = artboard;
        notifyUI();
      },
    );
  }

  void dispose() {
    _streamController.close();
  }

  void notifyUI() {
    _streamController.add(viewModel);
  }

  void idle() {
    viewModel.expressionValue?.value = 0;
    notifyUI();
  }

  void thinking() {
    viewModel.expressionValue?.value = 1;
    notifyUI();
  }

  void saying() {
    viewModel.expressionValue?.value = 2;
    notifyUI();
  }
}
