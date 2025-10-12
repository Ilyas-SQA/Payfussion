import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/logic/blocs/setting/community_forum/community_form_bloc.dart';
import 'package:payfussion/logic/blocs/setting/community_forum/community_form_state.dart';

import '../../../core/constants/image_url.dart';
import '../../../core/widget/appbutton/app_button.dart';
import '../../../logic/blocs/setting/community_forum/community_form_event.dart';
import '../../widgets/auth_widgets/credential_text_field.dart';


class CreatePostScreen extends StatefulWidget {

  CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _titleController.dispose();
    _contentController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Posts',),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'logo',
                  child: Image.asset(TImageUrl.iconLogo, height: 100.h),
                ),
                SizedBox(height: 30.h),
                Text(
                  'Pay Fussion',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Create a new post',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff2D9CDB),
                  ),
                ),

                SizedBox(height: 35.h),

              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AppTextormField(
                      controller: _titleController,
                      isPasswordField: false,
                      helpText: 'Tile',
                    ),
                    SizedBox(height: 20.h),
                    AppTextormField(
                      controller: _contentController,
                      isPasswordField: false,
                      helpText: 'Content',
                    ),
                  ],
                ),
              ),
            ),
            BlocConsumer<CommunityFormBloc, CommunityFormState>(
              listener: (context, state) {
                if (state is PostAdded) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Post added successfully")),
                  );
                  // Optionally clear text fields
                  _titleController.clear();
                  _contentController.clear();

                  // Refresh posts
                  context.read<CommunityFormBloc>().add(GetPostsEvent());
                } else if (state is PostError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                return AppButton(
                  text: 'Post',
                  loading: state is PostLoading,
                  width: double.infinity,
                  onTap: () {
                    if (_titleController.text.trim().isEmpty ||
                        _contentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter both question and content")),
                      );
                      return;
                    }

                    context.read<CommunityFormBloc>().add(
                      AddPostEvent(
                        question: _titleController.text.trim(),
                        content: _contentController.text.trim(),
                      ),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
