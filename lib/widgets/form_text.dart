import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/helpers/formatter_phone.dart';

class FormText extends StatefulWidget {
  final TextEditingController controller;
  final String hint, errorMessage, idError;
  final Widget suffix, preffix;
  final TextInputType keyboard;
  final bool obscureText, readOnly, capitalize, phone, withClear;
  final Color fontColor, iconColor;
  final onChange, onClear;

  FormText(
      {this.controller,
      this.onChange,
      this.hint,
      this.keyboard,
      this.fontColor,
      this.iconColor,
      this.obscureText: false,
      this.readOnly: false,
      this.capitalize: false,
      this.phone: false,
      this.errorMessage,
      this.idError,
      this.suffix,
      this.preffix,
      this.withClear: false,
      this.onClear});
  @override
  _FormTextState createState() => _FormTextState();
}

class _FormTextState extends State<FormText> {
  bool obscureMode = true;
  FocusNode focusNode = FocusNode();

  void toggleObsecure() {
    setState(() {
      obscureMode = !obscureMode;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 45,
        // color: Colors.red,
        padding: EdgeInsets.only(left: 5, right: 5),
        child: TextField(
          focusNode: focusNode,
          style: TextStyle(
              fontSize: 16,
              color: widget.fontColor,
              fontWeight: FontWeight.w400,
              height: 1.5,
              fontFamily: "Poppins"),
          controller: widget.controller,
          keyboardType: widget.keyboard,
          readOnly: widget.readOnly,
          onChanged: (_) => widget.onChange(widget.idError),
          onTap: () => widget.onChange(widget.idError),
          cursorHeight: 22,
          cursorColor: widget.iconColor,
          obscureText: widget.obscureText && obscureMode,
          textCapitalization: widget.capitalize
              ? TextCapitalization.words
              : TextCapitalization.none,
          inputFormatters: widget.phone
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  new CustomInputFormatter()
                ]
              : null,
          decoration: InputDecoration(
            prefixIcon: widget.preffix != null ? widget.preffix : null,
            suffixIcon: widget.withClear &&
                    focusNode.hasFocus &&
                    widget.controller.text.length > 0
                ? GestureDetector(
                    onTap: () => widget.onClear(),
                    child: Container(
                      height: 16,
                      width: 16,
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/images/clear_form.svg",
                          height: 16,
                        ),
                      ),
                    ))
                : widget.suffix != null
                    ? widget.suffix
                    : widget.obscureText
                        ? obscureMode
                            ? GestureDetector(
                                onTap: () => toggleObsecure(),
                                child: Icon(CupertinoIcons.eye_slash_fill))
                            : GestureDetector(
                                onTap: () => toggleObsecure(),
                                child: Icon(CupertinoIcons.eye_fill))
                        : Container(
                            height: 16,
                            width: 16,
                          ),
            focusColor: widget.iconColor,
            hoverColor: widget.iconColor,
            contentPadding: EdgeInsets.zero,
            // hintText: "${widget.hint}",
            labelText:
                "${widget.errorMessage != "" ? widget.errorMessage : widget.hint}",
            labelStyle: TextStyle(
                height:
                    (focusNode.hasFocus || widget.controller.text.length > 0)
                        ? 0.3
                        : 2,
                color: widget.errorMessage != ""
                    ? ColorsCustom.primaryRed
                    : Color(0xFFA1A4A8),
                fontWeight: FontWeight.w300),
            isDense: true,
            // hintStyle: TextStyle(
            //     fontSize: 16,
            //     height: 1.5,
            //     color: widget.colorHint,
            //     fontWeight: FontWeight.w300,
            //     fontFamily: "Poppins"),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: ColorsCustom.softGrey),
            ),
            focusedBorder: !widget.readOnly
                ? UnderlineInputBorder(
                    borderSide: BorderSide(color: ColorsCustom.primary),
                  )
                : UnderlineInputBorder(
                    borderSide: BorderSide(color: ColorsCustom.softGrey),
                  ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: ColorsCustom.softGrey),
            ),
          ),
        ));
  }
}
