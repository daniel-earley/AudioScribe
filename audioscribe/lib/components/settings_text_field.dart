import 'package:flutter/material.dart';

class SettingsEditableTextField extends StatefulWidget {
  final String initialText;
  final String titleText;

  const SettingsEditableTextField(
      {Key? key, required this.initialText, required this.titleText})
      : super(key: key);

  @override
  _InlineEditableTextFieldState createState() =>
      _InlineEditableTextFieldState();
}

class _InlineEditableTextFieldState extends State<SettingsEditableTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Text(widget.titleText,
                style: const TextStyle(color: Colors.white, fontSize: 24.0))),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1B1B1B).withOpacity(0.5),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  child: _isEditing
                      ? TextField(
                          focusNode: _focusNode,
                          controller: _controller,
                          autofocus: false,
                          decoration: const InputDecoration(
                            hintText: 'Enter your text',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.white54),
                          ),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 25.0),
                        )
                      : InkWell(
                          onTap: () {
                            setState(() => _isEditing = true);

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              FocusScope.of(context).requestFocus(_focusNode);
                            });
                          },
                          child: Text(
                            _controller.text.isEmpty
                                ? 'Enter your text'
                                : _controller.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                ),
              ),
              _isEditing
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                          });
                          if (_controller.text.isNotEmpty) {
                            Future.microtask(() => FocusScope.of(context)
                                .requestFocus(FocusNode()));
                          }
                        },
                      ))
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                          // focus text field when edit icon is tapped
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            FocusScope.of(context).requestFocus(_focusNode);
                          });
                        },
                      )),
            ],
          ),
        ),
      ],
    );
  }
}
