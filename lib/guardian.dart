library guardian;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guardian/constant.dart';
import 'package:http/http.dart' as http;

class Guardian extends StatefulWidget {
  final GuardianMode mode;
  final String appId;
  final Widget child;
  final bool showLogo;
  final String logoUrl;
  final double logoSize;
  final String message;
  final Color messageColor;
  final dynamic expDate;
  final String configUrl;
  final int maxCount;

  const Guardian(
      {Key? key,
      required this.appId,
      required this.child,
      this.mode = GuardianMode.config,
      this.showLogo = true,
      this.logoUrl = defaultLogoUrl,
      this.logoSize = defaultLogoSize,
      this.message = defaultMessage,
      this.messageColor = defaultMessageColor,
      this.expDate = defaultExpDate,
      this.configUrl = defaultConfigUrl,
      this.maxCount = defaultMaxCount})
      : super(key: key);

  @override
  State<Guardian> createState() => _GuardianState();
}

class _GuardianState extends State<Guardian> {
  bool isActive = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    switch (widget.mode) {
      case GuardianMode.dateTime:
        checkDateTime();
        break;
      case GuardianMode.count:
        break;
      default:
        checkConfig();
        break;
    }
  }

  void checkDateTime() {
    try {
      var expDate = DateTime.now();
      if (widget.expDate is DateTime) {
        expDate = widget.expDate;
      } else if (widget.expDate is String) {
        expDate = DateTime.tryParse(widget.expDate)!;
      } else {
        throw Error();
      }
      setState(() {
        isActive = expDate.isAfter(DateTime.now());
      });
    } catch (e) {
      handleError('checkDateTime', e);
    }
  }

  Future<void> checkConfig() async {
    try {
      http.Response response = await http.get(Uri.parse(widget.configUrl));
      List<dynamic> data = jsonDecode(response.body.toString());
      var config =
          data.firstWhere((element) => element['appId'] == widget.appId);
      if (config != null) {
        setState(() {
          isActive = config['active'];
        });
      }
    } catch (e) {
      handleError('checkConfig', e);
    }
  }

  Future<void> checkCount() async {
    try {} catch (e) {
      handleError('checkCount', e);
    }
  }

  void handleError(String message, e) {
    if (kDebugMode) {
      print(message);
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: widget.showLogo,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Image.network(
                  widget.logoUrl,
                  width: widget.logoSize,
                  height: widget.logoSize,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                widget.message,
                style: TextStyle(
                  fontSize: 16,
                  color: widget.messageColor,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      );
    }
    return widget.child;
  }
}
