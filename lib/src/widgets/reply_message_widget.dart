/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:chatview/chatview.dart';
import 'package:chatview/src/extensions/extensions.dart';
import 'package:chatview/src/utils/package_strings.dart';
import 'package:flutter/material.dart';

import '../utils/constants/constants.dart';
import 'vertical_line.dart';

class ReplyMessageWidget extends StatefulWidget {
  /// Provides message instance of chat.
  final Message message;

  /// Provides configurations related to replied message such as textstyle
  /// padding, margin etc. Also, this widget is located upon chat bubble.
  final RepliedMessageConfiguration? repliedMessageConfig;

  /// Provides call back when user taps on replied message.
  final VoidCallback? onTap;

  const ReplyMessageWidget({
    Key? key,
    required this.message,
    this.repliedMessageConfig,
    this.onTap,
  }) : super(key: key);

  @override
  ReplyMessageWidgetState createState() => ReplyMessageWidgetState();
}

class ReplyMessageWidgetState extends State<ReplyMessageWidget> {
  ChatController? chatController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (provide != null) {
      chatController = provide!.chatController;
    }
  }

  @override
  Widget build(BuildContext context) {
    final replyBySender = chatController?.isCurrentUser(widget.message.replyMessage.replyBy) ?? false;
    final textTheme = Theme.of(context).textTheme;
    final replyMessage = widget.message.replyMessage.message;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: widget.repliedMessageConfig?.margin ??
            const EdgeInsets.only(
              right: horizontalPadding,
              left: horizontalPadding,
              bottom: 4,
            ),
        constraints: BoxConstraints(maxWidth: widget.repliedMessageConfig?.maxWidth ?? 280),
        child: Column(
          crossAxisAlignment: replyBySender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              "${PackageStrings.repliedBy}",
              style: widget.repliedMessageConfig?.replyTitleTextStyle ?? textTheme.bodyMedium!.copyWith(fontSize: 14, letterSpacing: 0.3),
            ),
            const SizedBox(height: 6),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: replyBySender ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  if (!replyBySender)
                    VerticalLine(
                      verticalBarWidth: widget.repliedMessageConfig?.verticalBarWidth,
                      verticalBarColor: widget.repliedMessageConfig?.verticalBarColor,
                      rightPadding: 4,
                    ),
                  Flexible(
                    child: Opacity(
                      opacity: widget.repliedMessageConfig?.opacity ?? 0.8,
                      child: widget.message.replyMessage.messageType.isImage
                          ? Container(
                              height: widget.repliedMessageConfig?.repliedImageMessageHeight ?? 100,
                              width: widget.repliedMessageConfig?.repliedImageMessageWidth ?? 80,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(replyMessage),
                                  fit: BoxFit.fill,
                                ),
                                borderRadius: widget.repliedMessageConfig?.borderRadius ?? BorderRadius.circular(14),
                              ),
                            )
                          : Container(
                              constraints: BoxConstraints(
                                maxWidth: widget.repliedMessageConfig?.maxWidth ?? 280,
                              ),
                              padding: widget.repliedMessageConfig?.padding ??
                                  const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                              decoration: BoxDecoration(
                                borderRadius: _borderRadius(
                                  replyMessage: replyMessage,
                                  replyBySender: replyBySender,
                                ),
                                color: widget.repliedMessageConfig?.backgroundColor ?? Colors.grey.shade500,
                              ),
                              child: widget.message.replyMessage.messageType.isVoice
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.mic,
                                          color: widget.repliedMessageConfig?.micIconColor ?? Colors.white,
                                        ),
                                        const SizedBox(width: 2),
                                        if (widget.message.replyMessage.voiceMessageDuration != null)
                                          Text(
                                            widget.message.replyMessage.voiceMessageDuration!.toHHMMSS(),
                                            style: widget.repliedMessageConfig?.textStyle,
                                          ),
                                      ],
                                    )
                                  : Text(
                                      replyMessage,
                                      style: widget.repliedMessageConfig?.textStyle ?? textTheme.bodyMedium!.copyWith(color: Colors.black),
                                    ),
                            ),
                    ),
                  ),
                  if (replyBySender)
                    VerticalLine(
                      verticalBarWidth: widget.repliedMessageConfig?.verticalBarWidth,
                      verticalBarColor: widget.repliedMessageConfig?.verticalBarColor,
                      leftPadding: 4,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BorderRadiusGeometry _borderRadius({
    required String replyMessage,
    required bool replyBySender,
  }) =>
      replyBySender
          ? widget.repliedMessageConfig?.borderRadius ??
              (replyMessage.length < 37 ? BorderRadius.circular(replyBorderRadius1) : BorderRadius.circular(replyBorderRadius2))
          : widget.repliedMessageConfig?.borderRadius ??
              (replyMessage.length < 29 ? BorderRadius.circular(replyBorderRadius1) : BorderRadius.circular(replyBorderRadius2));
}
