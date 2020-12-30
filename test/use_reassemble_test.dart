import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'mock.dart';

void main() {
  testWidgets('useReassemble null callback throws', (tester) async {
    await tester.pumpWidget(
      HookBuilder(builder: (c, h) {
        h.useReassemble(null);
        return Container();
      }),
    );

    expect(tester.takeException(), isAssertionError);
  });

  testWidgets("hot-reload calls useReassemble's callback", (tester) async {
    final reassemble = MockReassemble();

    await tester.pumpWidget(HookBuilder(builder: (context, h) {
      h.useReassemble(reassemble);
      return Container();
    }));

    verifyNoMoreInteractions(reassemble);

    hotReload(tester);
    await tester.pump();

    verify(reassemble()).called(1);
    verifyNoMoreInteractions(reassemble);
  });

  testWidgets('debugFillProperties', (tester) async {
    await tester.pumpWidget(
      HookBuilder(builder: (context, h) {
        h.useReassemble(() {});
        return const SizedBox();
      }),
    );

    final element = tester.element(find.byType(HookBuilder));

    expect(
      element
          .toDiagnosticsNode(style: DiagnosticsTreeStyle.offstage)
          .toStringDeep(),
      equalsIgnoringHashCodes(
        'HookBuilder\n'
        ' │ useReassemble\n'
        ' └SizedBox(renderObject: RenderConstrainedBox#00000)\n',
      ),
    );
  });
}
