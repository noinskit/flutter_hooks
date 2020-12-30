// ignore_for_file: close_sinks

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'mock.dart';

/// port of [StreamBuilder]
///
void main() {
  testWidgets('debugFillProperties', (tester) async {
    final stream = Stream.value(42);

    await tester.pumpWidget(
      HookBuilder(builder: (context, h) {
        h.useStream(stream);
        return const SizedBox();
      }),
    );

    await tester.pump();

    final element = tester.element(find.byType(HookBuilder));

    expect(
      element
          .toDiagnosticsNode(style: DiagnosticsTreeStyle.offstage)
          .toStringDeep(),
      equalsIgnoringHashCodes(
        'HookBuilder\n'
        ' │ useStream: AsyncSnapshot<int>(ConnectionState.done, 42, null)\n'
        ' └SizedBox(renderObject: RenderConstrainedBox#00000)\n',
      ),
    );
  });

  testWidgets('default preserve state, changing stream keeps previous value',
      (tester) async {
    AsyncSnapshot<int> value;
    Widget Function(BuildContext, Hookable) builder(Stream<int> stream) {
      return (context, h) {
        value = h.useStream(stream);
        return Container();
      };
    }

    var stream = Stream.fromFuture(Future.value(0));
    await tester.pumpWidget(HookBuilder(builder: builder(stream)));
    expect(value.data, null);
    await tester.pumpWidget(HookBuilder(builder: builder(stream)));
    expect(value.data, 0);

    stream = Stream.fromFuture(Future.value(42));
    await tester.pumpWidget(HookBuilder(builder: builder(stream)));
    expect(value.data, 0);
    await tester.pumpWidget(HookBuilder(builder: builder(stream)));
    expect(value.data, 42);
  });
  testWidgets('If preserveState == false, changing stream resets value',
      (tester) async {
    AsyncSnapshot<int> value;
    Widget Function(BuildContext, Hookable) builder(Stream<int> stream) {
      return (context, h) {
        value = h.useStream(stream, preserveState: false);
        return Container();
      };
    }

    var stream = Stream.fromFuture(Future.value(0));
    await tester.pumpWidget(HookBuilder(builder: builder(stream)));
    expect(value.data, null);
    await tester.pumpWidget(HookBuilder(builder: builder(stream)));
    expect(value.data, 0);

    stream = Stream.fromFuture(Future.value(42));
    await tester.pumpWidget(HookBuilder(builder: builder(stream)));
    expect(value.data, null);
    await tester.pumpWidget(HookBuilder(builder: builder(stream)));
    expect(value.data, 42);
  });

  Widget Function(BuildContext, Hookable) snapshotText(Stream<String> stream,
      {String initialData}) {
    return (context, h) {
      final snapshot = h.useStream(stream, initialData: initialData);
      return Text(snapshot.toString(), textDirection: TextDirection.ltr);
    };
  }

  testWidgets('gracefully handles transition from null stream', (tester) async {
    await tester.pumpWidget(HookBuilder(builder: snapshotText(null)));
    expect(find.text('AsyncSnapshot<String>(ConnectionState.none, null, null)'),
        findsOneWidget);
    final controller = StreamController<String>();
    await tester
        .pumpWidget(HookBuilder(builder: snapshotText(controller.stream)));
    expect(
        find.text('AsyncSnapshot<String>(ConnectionState.waiting, null, null)'),
        findsOneWidget);
  });
  testWidgets('gracefully handles transition to null stream', (tester) async {
    final controller = StreamController<String>();
    await tester
        .pumpWidget(HookBuilder(builder: snapshotText(controller.stream)));
    expect(
        find.text('AsyncSnapshot<String>(ConnectionState.waiting, null, null)'),
        findsOneWidget);
    await tester.pumpWidget(HookBuilder(builder: snapshotText(null)));
    expect(find.text('AsyncSnapshot<String>(ConnectionState.none, null, null)'),
        findsOneWidget);
  });
  testWidgets('gracefully handles transition to other stream', (tester) async {
    final controllerA = StreamController<String>();
    final controllerB = StreamController<String>();
    await tester
        .pumpWidget(HookBuilder(builder: snapshotText(controllerA.stream)));
    expect(
        find.text('AsyncSnapshot<String>(ConnectionState.waiting, null, null)'),
        findsOneWidget);
    await tester
        .pumpWidget(HookBuilder(builder: snapshotText(controllerB.stream)));
    controllerB.add('B');
    controllerA.add('A');
    await eventFiring(tester);
    expect(find.text('AsyncSnapshot<String>(ConnectionState.active, B, null)'),
        findsOneWidget);
  });
  testWidgets('tracks events and errors of stream until completion',
      (tester) async {
    final controller = StreamController<String>();
    await tester
        .pumpWidget(HookBuilder(builder: snapshotText(controller.stream)));
    expect(
        find.text('AsyncSnapshot<String>(ConnectionState.waiting, null, null)'),
        findsOneWidget);
    controller..add('1')..add('2');
    await eventFiring(tester);
    expect(find.text('AsyncSnapshot<String>(ConnectionState.active, 2, null)'),
        findsOneWidget);
    controller
      ..add('3')
      ..addError('bad');
    await eventFiring(tester);
    expect(
        find.text('AsyncSnapshot<String>(ConnectionState.active, null, bad)'),
        findsOneWidget);
    controller.add('4');
    await controller.close();
    await eventFiring(tester);
    expect(find.text('AsyncSnapshot<String>(ConnectionState.done, 4, null)'),
        findsOneWidget);
  });
  testWidgets('runs the builder using given initial data', (tester) async {
    final controller = StreamController<String>();
    await tester.pumpWidget(HookBuilder(
      builder: snapshotText(controller.stream, initialData: 'I'),
    ));
    expect(find.text('AsyncSnapshot<String>(ConnectionState.waiting, I, null)'),
        findsOneWidget);
  });
  testWidgets('ignores initialData when reconfiguring', (tester) async {
    await tester.pumpWidget(HookBuilder(
      builder: snapshotText(null, initialData: 'I'),
    ));
    expect(find.text('AsyncSnapshot<String>(ConnectionState.none, I, null)'),
        findsOneWidget);
    final controller = StreamController<String>();
    await tester.pumpWidget(HookBuilder(
      builder: snapshotText(controller.stream, initialData: 'Ignored'),
    ));
    expect(find.text('AsyncSnapshot<String>(ConnectionState.waiting, I, null)'),
        findsOneWidget);
  });
}

Future<void> eventFiring(WidgetTester tester) async {
  await tester.pump(Duration.zero);
}
