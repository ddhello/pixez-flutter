/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:pixez/component/text_selection_toolbar.dart';
import 'package:pixez/er/leader.dart';
import 'package:pixez/main.dart';
import 'package:pixez/supportor_plugin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

mixin SelectableHtmlTextFactory on WidgetFactory {
  bool get selectableText => true;

  SelectionChangedCallback? get selectableTextOnChanged => null;

  @override
  Widget? buildText(BuildMetadata meta, TextStyleHtml tsh, InlineSpan text) {
    if (selectableText &&
        meta.overflow == TextOverflow.clip &&
        text is TextSpan) {
      return SelectableText.rich(
        text,
        maxLines: meta.maxLines > 0 ? meta.maxLines : null,
        textAlign: tsh.textAlign ?? TextAlign.start,
        textDirection: tsh.textDirection,
        textScaleFactor: 1.0,
        selectionControls: TranslateTextSelectionControls(),
        onSelectionChanged: selectableTextOnChanged,
      );
    }

    return super.buildText(meta, tsh, text);
  }
}

class SelectableHtmlWidgetFactory extends WidgetFactory with SelectableHtmlTextFactory {
  @override
  SelectionChangedCallback? get selectableTextOnChanged => (selection, cause) {};
}

class SelectableHtml extends StatefulWidget {
  final String data;

  const SelectableHtml({Key? key, required this.data}) : super(key: key);

  @override
  _SelectableHtmlState createState() => _SelectableHtmlState();
}

class _SelectableHtmlState extends State<SelectableHtml> {
  @override
  void initState() {
    super.initState();
    initMethod();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
            widget.data,
            customStylesBuilder: (e) {
              if (e.attributes.containsKey('href')) {
                final color = userSetting.themeData.colorScheme.primary;
                return {
                  'color': '#${color.value.toRadixString(16).substring(2, 8)}'
                };
              }
              return null;
            },
            factoryBuilder: supportTranslate? () => SelectableHtmlWidgetFactory():(null),
            isSelectable: true,
            onTapUrl: (String url) async {
              try {
                if (url.startsWith("pixiv")) {
                  Leader.pushWithUri(context, Uri.parse(url));
                } else
                  await launchUrl(Uri.parse(url));
              } catch (e) {
                Share.share(url);
              }
              return true;
            },
          );
  }

  bool supportTranslate = false;

  Future<void> initMethod() async {
    if (!Platform.isAndroid) return;
    bool results = await SupportorPlugin.processText();
    setState(() {
      supportTranslate = results;
    });
  }
}
