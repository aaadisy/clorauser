import 'dart:convert';
import 'package:clora_user/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../../extensions/new_colors.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../main.dart';
import '../../model/user/category_models/all_category_model.dart';
import '../../network/network_utils.dart';
import '../../network/rest_api.dart';
import '../../utils/app_common.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  FocusNode mEmailFocus = FocusNode();
  List<AllCategory> _categories = [];
  AllCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _GetCategories();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    mEmailFocus.dispose();
    super.dispose();
  }

  Future<void> _GetCategories() async {
    try {
      appStore.setLoading(true);
      AllCategoryList response = await fetchAllCategoryApi();
      setState(() {
        _categories = response.data ?? [];
      });
    } catch (e) {
    } finally {
      appStore.setLoading(false);
    }
  }

  Future<AllCategory?> _showCategoryDialog() async {
    AllCategory? localSelected = _selectedCategory;
    final result = await showDialog<AllCategory>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(language.selectCategory, style: boldTextStyle(size: 16, color: mainColorText)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StatefulBuilder(
                    builder: (context, setStateDialog) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                        child: _categories.isEmpty
                            ? Center(child: Text(language.noCategoriesFound, style: primaryTextStyle()))
                            : SingleChildScrollView(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _categories.map((cat) {
                              final isSelected = localSelected?.id == cat.id;
                              return ChoiceChip(
                                labelPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                label: Text(
                                  cat.name ?? '',
                                  style: primaryTextStyle(
                                    size: 14,
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: mainColor,
                                backgroundColor: whiteShade,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(38),
                                ),
                                onSelected: (sel) {
                                  setStateDialog(() {
                                    localSelected = sel ? cat : null;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: whiteShade),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(language.cancel, style: primaryTextStyle()),
                        ),
                      ),
                      12.width,
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (localSelected != null) {
                              Navigator.of(context).pop(localSelected);
                            } else {
                              toast('Please select a category');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(language.Done, style: boldTextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return result;
  }

  Future<bool> _handlePost() async {
    if (_selectedCategory != null && _descriptionController.text.isNotEmpty) {
      appStore.setLoading(true);
      try {
        MultipartRequest multipartRequest = await getMultiPartRequest('save-userchat');
        multipartRequest.fields['category_id'] = _selectedCategory!.id.toString();
        multipartRequest.fields['description'] = _descriptionController.text.trim();
        multipartRequest.headers.addAll(buildHeaderTokens());

        await sendMultiPartRequest(
          multipartRequest,
          onSuccess: (data) async {
            try {
              Map<String, dynamic> decodedData = jsonDecode(data);
              bool status = decodedData['status'] == true || decodedData['success'] == true;
              String message = decodedData['message']?.toString() ?? 'Post submitted successfully';
              if (status) {
                toast(message);
                _descriptionController.clear();
                setState(() {
                  _selectedCategory = null;
                });
                return true; // Indicate success
              }
            } catch (e) {
              toast('Error parsing response');
            }
            return false;
          },
          onError: (error) {
            toast('Error submitting post');
            return false;
          },
        );
        return true;
      } catch (e) {
        toast('Error submitting post');
        return false;
      } finally {
        appStore.setLoading(false);
      }
    } else {
      toast('Please fill all fields');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColorLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: mainColorText),
          onPressed: () {
            appStore.setLoading(false); // Ensure loader is reset
            Navigator.pop(context);
          },
        ),
        title: Text(language.newPost, style: boldTextStyle(size: 18, color: mainColorText)),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              language.letTheCommunityKnow,
              style: primaryTextStyle(size: 16),
            ),
            8.height,
            AppTextField(
              controller: _descriptionController,
              readOnly: false,
              textFieldType: TextFieldType.NAME,
              isValidationRequired: false,
              focus: mEmailFocus,
              decoration: defaultInputDecoration(context, label: language.WriteYourPost),
              maxLines: 6,
            ),
            32.height,
            AppButton(
              color: mainColor,
              disabledColor: mainColor,
              width: context.width(),
              elevation: 0,
              text: language.Post,
              onTap: () async {
                if (_descriptionController.text.isNotEmpty) {
                  final selected = await _showCategoryDialog();
                  if (selected != null) {
                    setState(() {
                      _selectedCategory = selected;
                    });
                    final success = await _handlePost();
                    if (success) {
                      Navigator.pop(context, true); // Return true to indicate post was added
                    }
                  }
                } else {
                  toast('Please enter a post description');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}