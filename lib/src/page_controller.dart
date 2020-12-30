part of 'hooks.dart';

extension UsePageControllerHook on Hookable {
  /// Creates and disposes a [PageController].
  ///
  /// See also:
  /// - [PageController]
  PageController usePageController({
    int initialPage = 0,
    bool keepPage = true,
    double viewportFraction = 1.0,
    List<Object> keys,
  }) {
    return use(
      _PageControllerHook(
        initialPage: initialPage,
        keepPage: keepPage,
        viewportFraction: viewportFraction,
        keys: keys,
      ),
    );
  }
}

class _PageControllerHook extends Hook<PageController> {
  const _PageControllerHook({
    this.initialPage,
    this.keepPage,
    this.viewportFraction,
    List<Object> keys,
  }) : super(keys: keys);

  final int initialPage;
  final bool keepPage;
  final double viewportFraction;

  @override
  HookState<PageController, Hook<PageController>> createState() =>
      _PageControllerHookState();
}

class _PageControllerHookState
    extends HookState<PageController, _PageControllerHook> {
  PageController controller;

  @override
  void initHook() {
    controller = PageController(
      initialPage: hook.initialPage,
      keepPage: hook.keepPage,
      viewportFraction: hook.viewportFraction,
    );
  }

  @override
  PageController build(BuildContext context) => controller;

  @override
  void dispose() => controller.dispose();

  @override
  String get debugLabel => 'usePageController';
}
