part of 'hooks.dart';

class _TextEditingControllerHookCreator implements Hookable {
  const _TextEditingControllerHookCreator();

  /// Creates a [TextEditingController] that will be disposed automatically.
  ///
  /// The [text] parameter can be used to set the initial value of the
  /// controller.
  TextEditingController call({String text, List<Object> keys}) {
    return use(_TextEditingControllerHook(text, keys));
  }

  /// Creates a [TextEditingController] from the initial [value] that will
  /// be disposed automatically.
  TextEditingController fromValue(TextEditingValue value, [List<Object> keys]) {
    return use(_TextEditingControllerHook.fromValue(value, keys));
  }
}

/// Creates a [TextEditingController], either via an initial text or an initial
/// [TextEditingValue].
///
/// To use a [TextEditingController] with an optional initial text, use
/// ```dart
/// final controller = useTextEditingController(text: 'initial text');
/// ```
///
/// To use a [TextEditingController] with an optional inital value, use
/// ```dart
/// final controller = useTextEditingController
///   .fromValue(TextEditingValue.empty);
/// ```
///
/// Changing the text or initial value after the widget has been built has no
/// effect whatsoever. To update the value in a callback, for instance after a
/// button was pressed, use the [TextEditingController.text] or
/// [TextEditingController.text] setters. To have the [TextEditingController]
/// reflect changing values, you can use `useEffect`. This example will update
/// the [TextEditingController.text] whenever a provided [ValueListenable]
/// changes:
/// ```dart
/// final controller = useTextEditingController();
/// final update = useValueListenable(myTextControllerUpdates);
///
/// useEffect(() {
///   controller.text = update;
///   return null; // we don't need to have a special dispose logic
/// }, [update]);
/// ```
///
/// See also:
/// - [TextEditingController], which this hook creates.
const useTextEditingController = _TextEditingControllerHookCreator();

class _TextEditingControllerHook extends Hook<TextEditingController> {
  const _TextEditingControllerHook(
    this.initialText, [
    List<Object> keys,
  ])  : initialValue = null,
        super(keys: keys);

  const _TextEditingControllerHook.fromValue(
    this.initialValue, [
    List<Object> keys,
  ])  : initialText = null,
        assert(initialValue != null, "initialValue can't be null"),
        super(keys: keys);

  final String initialText;
  final TextEditingValue initialValue;

  @override
  _TextEditingControllerHookState createState() {
    return _TextEditingControllerHookState();
  }
}

class _TextEditingControllerHookState
    extends HookState<TextEditingController, _TextEditingControllerHook> {
  TextEditingController _controller;

  @override
  void initHook() {
    if (hook.initialValue != null) {
      _controller = TextEditingController.fromValue(hook.initialValue);
    } else {
      _controller = TextEditingController(text: hook.initialText);
    }
  }

  @override
  TextEditingController build(BuildContext context) => _controller;

  @override
  void dispose() => _controller?.dispose();

  @override
  String get debugLabel => 'useTextEditingController';
}
