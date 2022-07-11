// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static String m0(howMany) =>
      "${Intl.plural(howMany, one: '你有一条消息', other: 'You have ${howMany} messages')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "_locale": MessageLookupByLibrary.simpleMessage("zh"),
        "clickTop": MessageLookupByLibrary.simpleMessage("你一共点击了这么多次按钮："),
        "future": MessageLookupByLibrary.simpleMessage("未来"),
        "history": MessageLookupByLibrary.simpleMessage("过去"),
        "inc": MessageLookupByLibrary.simpleMessage("增加"),
        "now": MessageLookupByLibrary.simpleMessage("现在"),
        "pageHomeSamplePlural": m0,
        "star": MessageLookupByLibrary.simpleMessage("点赞"),
        "taskTitle": MessageLookupByLibrary.simpleMessage("心系于你"),
        "titleBarTitle": MessageLookupByLibrary.simpleMessage("心系于你")
      };
}
