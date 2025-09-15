import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:neuroinsight/screens/users/controllers/user_profile_controllers.dart';
import 'package:neuroinsight/screens/users/models/user_profile_analysis_model.dart';
import 'package:neuroinsight/screens/users/views/user_reports_list_view.dart';
import 'package:numberpicker/numberpicker.dart';
import 'user_edit_profile_view.dart';

enum ActivePicker { none, birthYear, condition }

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileController _controller = ProfileController();
  final PageController _pageController = PageController();

  bool _isLoading = true;
  bool _isSetupComplete = false;
  int _currentPage = 0;

  ActivePicker _activePicker = ActivePicker.none;

  String? _selectedGender;
  int? _selectedBirthYear;
  String? _selectedCondition;
  String? _selectedExercise;
  String? _selectedDiet;

  final List<String> _conditionOptions = ["Alzheimer's", "No Conditions"];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
    _loadProfileStatus();
  }

  Future<void> _loadProfileStatus() async {
    bool exists = await _controller.checkProfileExists();
    if (mounted) {
      setState(() {
        _isSetupComplete = exists;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F7F5),
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.userChanges(),
          builder: (context, snapshot) {
            if (_isLoading || !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return _isSetupComplete
                ? _buildStandardProfile(snapshot.data!)
                : _buildSetupFlow();
          }),
    );
  }

  Widget _buildStandardProfile(User user) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F7F5),
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFE1F7F5),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
              user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null
                  ? const Icon(Icons.person, size: 60, color: Colors.black54)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.displayName ?? 'N/A',
              style: GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user.email ?? 'No email associated',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 40),
            _buildProfileButton(
              text: 'Edit Profile',
              icon: Icons.edit_outlined,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditProfileView()));
              },
            ),
            const SizedBox(height: 16),
            _buildProfileButton(
              text: 'My Reports',
              icon: Icons.article_outlined,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UserReportsListView()));
              },
            ),
            const Spacer(),
            _buildProfileButton(
              text: 'Logout',
              icon: Icons.logout,
              color: Colors.redAccent,
              onTap: () => _controller.confirmLogout(context),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(200),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildSetupFlow() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: _buildProgressIndicator(),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildGeneralInfoPage(),
                _buildHealthGoalsPage(),
                _buildFinalPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              "First, we need to know you just a little better"),
          const SizedBox(height: 24),

          _buildQuestionTitle("What's your gender?"),
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(
                  child: _buildAnimationCard(
                    animationPath: 'assets/animations/male.json',
                    label: "Male",
                    isSelected: _selectedGender == "Male",
                    onTap: () => setState(() => _selectedGender = "Male"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAnimationCard(
                    animationPath: 'assets/animations/female.json',
                    label: "Female",
                    isSelected: _selectedGender == "Female",
                    onTap: () => setState(() => _selectedGender = "Female"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildQuestionTitle("What year were you born?"),
          _buildPickerDisplayField(
            value: _selectedBirthYear?.toString(),
            hint: "e.g. 1945",
            isActive: _activePicker == ActivePicker.birthYear,
            onTap: () {
              setState(() {
                _activePicker = _activePicker == ActivePicker.birthYear
                    ? ActivePicker.none
                    : ActivePicker.birthYear;
              });
            },
          ),
          if (_activePicker == ActivePicker.birthYear) _buildBirthYearPicker(),

          const SizedBox(height: 24),

          _buildQuestionTitle("What is your current condition?"),
          _buildPickerDisplayField(
            value: _selectedCondition,
            hint: "Please choose",
            isActive: _activePicker == ActivePicker.condition,
            onTap: () {
              setState(() {
                _activePicker = _activePicker == ActivePicker.condition
                    ? ActivePicker.none
                    : ActivePicker.condition;
              });
            },
          ),
          if (_activePicker == ActivePicker.condition) _buildConditionPicker(),

          const SizedBox(height: 40),

          _buildContinueButton(
            onPressed: () {
              if (_selectedGender != null &&
                  _selectedBirthYear != null &&
                  _selectedCondition != null) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Please fill all fields to continue."),
                    backgroundColor: Colors.orange));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHealthGoalsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              "Next, we'd love to learn more about your health goals"),
          const SizedBox(height: 24),
          _buildQuestionTitle("How often do you exercise?"),
          SizedBox(
            height: 150,
            child: Row(
              children: [
                Expanded(
                    child: _buildAnimationCard(
                        animationPath:
                        'assets/animations/never.json',
                        label: "Never",
                        isSelected: _selectedExercise == "Never",
                        onTap: () =>
                            setState(() => _selectedExercise = "Never"))),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildAnimationCard(
                        animationPath:
                        'assets/animations/week.json',
                        label: "Weekly",
                        isSelected: _selectedExercise == "Weekly",
                        onTap: () =>
                            setState(() => _selectedExercise = "Weekly"))),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildAnimationCard(
                        animationPath:
                        'assets/animations/daily.json',
                        label: "Daily",
                        isSelected: _selectedExercise == "Daily",
                        onTap: () =>
                            setState(() => _selectedExercise = "Daily"))),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildQuestionTitle("How healthy do you eat?"),
          SizedBox(
            height: 150,
            child: Row(
              children: [
                Expanded(
                    child: _buildAnimationCard(
                        animationPath: 'assets/animations/bad.json',
                        label: "Bad",
                        isSelected: _selectedDiet == "Bad",
                        onTap: () => setState(() => _selectedDiet = "Bad"))),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildAnimationCard(
                        animationPath: 'assets/animations/avg.json',
                        label: "Avg.",
                        isSelected: _selectedDiet == "Avg",
                        onTap: () => setState(() => _selectedDiet = "Avg"))),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildAnimationCard(
                        animationPath: 'assets/animations/very.json',
                        label: "Very",
                        isSelected: _selectedDiet == "Very",
                        onTap: () => setState(() => _selectedDiet = "Very"))),
              ],
            ),
          ),

          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                  child: _buildBackButton(
                      onPressed: () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut))),
              const SizedBox(width: 16),
              Expanded(child: _buildContinueButton(onPressed: () {
                if (_selectedExercise != null && _selectedDiet != null) {
                  _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                      Text("Please select an option for both questions."),
                      backgroundColor: Colors.orange));
                }
              })),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinalPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/tick.json',
            height: 150,
            width: 150,
            repeat: false,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader("You're all set!"),
          const SizedBox(height: 8),
          Text(
            "Click Finish to complete your profile setup and proceed to the dashboard.",
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 40),
          _buildContinueButton(
            text: "Finish Setup",
            onPressed: _submitProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: _currentPage >= index ? Colors.black87 : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black87, width: 2),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: _currentPage >= index ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.lora(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildQuestionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.lora(
            fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  Widget _buildAnimationCard({
    required String animationPath,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black87 : Colors.grey.shade400,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Lottie.asset(
                animationPath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black87 : Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerDisplayField({
    String? value,
    required String hint,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.black87 : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? hint,
              style: TextStyle(
                color: value == null ? Colors.black54 : Colors.black87,
                fontSize: 16,
              ),
            ),
            Icon(
              isActive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthYearPicker() {
    int currentYear = DateTime.now().year;
    return Container(
      height: 150,
      alignment: Alignment.center,
      color: Colors.white.withOpacity(0.5),
      child: NumberPicker(
        value: _selectedBirthYear ?? currentYear - 30,
        minValue: currentYear - 100,
        maxValue: currentYear - 18,
        onChanged: (value) => setState(() => _selectedBirthYear = value),
        itemHeight: 50,
        selectedTextStyle: const TextStyle(
            color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildConditionPicker() {
    int initialIndex = _selectedCondition != null
        ? _conditionOptions.indexOf(_selectedCondition!)
        : 0;
    if (initialIndex == -1) initialIndex = 0;

    return Container(
      height: 150,
      color: Colors.white.withOpacity(0.5),
      child: CupertinoPicker(
        itemExtent: 50,
        scrollController: FixedExtentScrollController(initialItem: initialIndex),
        selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
          background: Colors.grey.withOpacity(0.2),
          capStartEdge: false,
          capEndEdge: false,
        ),
        onSelectedItemChanged: (int index) {
          setState(() {
            _selectedCondition = _conditionOptions[index];
          });
        },
        children: _conditionOptions
            .map((option) =>
            Center(child: Text(option, style: const TextStyle(fontSize: 20))))
            .toList(),
      ),
    );
  }

  Widget _buildContinueButton(
      {required VoidCallback onPressed, String text = "Continue"}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(200)),
          elevation: 2,
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ),
    );
  }

  Widget _buildBackButton({required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.black87, width: 2),
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(200)),
        ),
        child: const Text(
          "Back",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ),
    );
  }

  void _submitProfile() {
    if (_selectedGender != null &&
        _selectedBirthYear != null &&
        _selectedCondition != null &&
        _selectedExercise != null &&
        _selectedDiet != null) {
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Error: User not found."),
            backgroundColor: Colors.red));
        return;
      }

      final profileData = ProfileAnalysisModel(
        uid: uid,
        gender: _selectedGender!,
        birthYear: _selectedBirthYear!,
        currentCondition: _selectedCondition!,
        exerciseFrequency: _selectedExercise!,
        eatingHabits: _selectedDiet!,
        lastUpdated: Timestamp.now(),
      );

      _controller.saveProfileAnalysis(context, profileData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("An unexpected error occurred. Please try again.")),
      );
    }
  }
}