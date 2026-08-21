import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_form_widgets.dart';

class EditUserScreen extends StatefulWidget {
  final User user;

  const EditUserScreen({super.key, required this.user});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final UserService _userService = UserService();

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _ageController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _usernameController;

  late String _gender;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController(text: widget.user.firstName);

    _lastNameController = TextEditingController(text: widget.user.lastName);

    _ageController = TextEditingController(text: widget.user.age.toString());

    _emailController = TextEditingController(text: widget.user.email);

    _phoneController = TextEditingController(text: widget.user.phone);

    _usernameController = TextEditingController(text: widget.user.username);

    _gender = widget.user.gender;
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _userService.updateUser(
        userId: widget.user.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        gender: _gender,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        username: _usernameController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not update user: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text(
          'Edit User',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.sm,
            AppSpacing.screenH,
            AppSpacing.xxl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFormIntro(
                  text: 'Update the information for this user.',
                  badges: [
                    AppMetaBadge(label: 'User ID: ${widget.user.id}'),
                    AppMetaBadge(label: '@${widget.user.username}'),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                AppFormSection(
                  title: 'Personal Information',
                  children: [
                    AppLabeledField(
                      label: 'First Name',
                      child: TextFormField(
                        controller: _firstNameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Enter first name',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'First name is required.';
                          }

                          return null;
                        },
                      ),
                    ),

                    AppLabeledField(
                      label: 'Last Name',
                      child: TextFormField(
                        controller: _lastNameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Enter last name',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Last name is required.';
                          }

                          return null;
                        },
                      ),
                    ),

                    AppLabeledField(
                      label: 'Age',
                      child: TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Enter age',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Age is required.';
                          }

                          final age = int.tryParse(value.trim());

                          if (age == null) {
                            return 'Enter a valid age.';
                          }

                          if (age <= 0) {
                            return 'Age must be greater than 0.';
                          }

                          return null;
                        },
                      ),
                    ),

                    AppLabeledField(
                      label: 'Gender',
                      child: DropdownButtonFormField<String>(
                        initialValue: _genderValue(),
                        borderRadius: BorderRadius.circular(AppRadius.field),
                        decoration: const InputDecoration(),
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('Male')),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text('Female'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _gender = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                AppFormSection(
                  title: 'Contact',
                  children: [
                    AppLabeledField(
                      label: 'Email',
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'name@example.com',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required.';
                          }

                          if (!value.contains('@')) {
                            return 'Enter a valid email address.';
                          }

                          return null;
                        },
                      ),
                    ),

                    AppLabeledField(
                      label: 'Phone',
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: '+1 555 000 0000',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone is required.';
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                AppFormSection(
                  title: 'Account',
                  children: [
                    AppLabeledField(
                      label: 'Username',
                      child: TextFormField(
                        controller: _usernameController,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          hintText: 'Choose a username',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username is required.';
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl),

                AppPrimaryButton(
                  label: 'Save Changes',
                  loadingLabel: 'Saving...',
                  icon: Icons.save_outlined,
                  isLoading: _isLoading,
                  onPressed: _updateUser,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// DummyJSON bazı kullanıcılarda farklı gender değerleri döndürebiliyor;
  /// dropdown'ın çökmemesi için bilinen değerlere indirgiyoruz.
  String _genderValue() {
    return _gender == 'female' ? 'female' : 'male';
  }
}
