import 'package:chat_bot/models/expression_view_model.dart';
import 'package:chat_bot/util/expression.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

/// An example showing how to drive a StateMachine via one numeric input.
class ExpressionView extends StatefulWidget {
  const ExpressionView({Key? key}) : super(key: key);

  @override
  State<ExpressionView> createState() => _ExpressionViewState();
}

class _ExpressionViewState extends State<ExpressionView> {
  /// Tracks if the animation is playing by whether controller is running.
  // bool get isPlaying => _controller?.isActive ?? false;
  //
  // Artboard? _riveArtboard;
  // StateMachineController? _controller;
  // SMIInput<double>? _expressionValue;

  Expression expression = Expression();

  @override
  void initState() {
    super.initState();
    // Load the animation file from the bundle, note that you could also
    // download this. The RiveFile just expects a list of bytes.
    // rootBundle.load('assets/robot.riv').then(
    //   (data) async {
    //     // Load the RiveFile from the binary data.
    //     final file = RiveFile.import(data);
    //
    //     // The artboard is the root of the animation and gets drawn in the
    //     // Rive widget.
    //     final artboard = file.mainArtboard;
    //     var controller =
    //         StateMachineController.fromArtboard(artboard, 'robot_state_machine');
    //     if (controller != null) {
    //       artboard.addController(controller);
    //       _expressionValue = controller.findInput('expression');
    //       _expressionValue?.value = 0;
    //     }
    //     setState(() => _riveArtboard = artboard);
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: const Text('Skills Machine'),
      ),
      body: StreamProvider<ExpressionViewModel>(
        updateShouldNotify: (previous, current) => true,
        create: (_) {
          return expression.stream;
        },
        initialData: expression.viewModel,
        child: Consumer<ExpressionViewModel>(
          builder: (BuildContext context, model, Widget? child) {
            return Center(
              child: model.riveArtboard == null
                  ? const SizedBox()
                  : Stack(
                      children: [
                        SizedBox(
                          width: 370,
                          height: 370,
                          child: Rive(
                            artboard: model.riveArtboard!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                child: const Text('idle'),
                                onPressed: () => expression.idle(),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                child: const Text('thinking'),
                                onPressed: () => expression.thinking(),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                child: const Text('saying'),
                                onPressed: () => expression.saying(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
