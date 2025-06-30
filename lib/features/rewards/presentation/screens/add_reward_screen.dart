// features/rewards/presentation/screens/add_reward_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/cubit/reward_cubit.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/managers/reward_manager.dart';

class AddRewardScreen extends StatefulWidget {
  final Reward? reward; // Add optional reward parameter for editing

  const AddRewardScreen({super.key, this.reward});

  @override
  State<AddRewardScreen> createState() => _AddRewardScreenState();
}

class _AddRewardScreenState extends State<AddRewardScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final RewardManager _manager;
  late AnimationController _animationController;
  late AnimationController _submitAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _manager = RewardManager(context.read<RewardCubit>());
    _initializeAnimations();
    _populateFieldsForEditing();
  }

  void _initializeAnimations() {
    // Main animation controller for entrance animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Submit button animation controller
    _submitAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Fade animation for content
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Slide animation for form
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    // Scale animation for submit button
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _submitAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start entrance animation
    _animationController.forward();
  }

  void _populateFieldsForEditing() {
    if (widget.reward != null) {
      _manager.titleController.text = widget.reward!.name;
      // _manager.descriptionController.text = widget.reward!.description ?? '';
      _manager.pointsController.text = widget.reward!.requiredPoints.toString();
      // _manager.setImagePath(widget.reward!.imageUrl);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _submitAnimationController.dispose();
    _manager.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    _submitAnimationController.forward();

    try {
      if (widget.reward == null) {
        // Adding a new reward
        await _manager.addReward();
      } else {
        // Editing an existing reward
        await _manager.updateReward(widget.reward!.id);
      }

      if (mounted) {
        _showSuccessMessage();
        await Future.delayed(const Duration(milliseconds: 1500));
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showErrorSnackbar(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _submitAnimationController.reverse();
      }
    }
  }

  void _showSuccessMessage() {
    final isEditing = widget.reward != null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text(isEditing 
                ? 'Récompense modifiée avec succès!' 
                : 'Récompense créée avec succès!'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text('Erreur: $message')),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildModernAppBar(),
            Expanded(
              child: _buildFormContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    final isEditing = widget.reward != null;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new, size: 20),
                color: Colors.grey.shade700,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    isEditing ? 'Modifier Récompense' : 'Nouvelle Récompense',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    isEditing 
                        ? 'Modifiez votre récompense existante'
                        : 'Créez une récompense attractive pour fidéliser',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.card_giftcard,
                color: Colors.purple.shade600,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    SizedBox(height: 32),
                    _buildFormCard(),
                    SizedBox(height: 24),
                    _buildSubmitSection(),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    final isEditing = widget.reward != null;
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade600, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              isEditing ? Icons.edit : Icons.star_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Peaufinez votre récompense' : 'Fidélisez vos clients',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  isEditing
                      ? 'Ajustez les détails pour optimiser l\'engagement'
                      : 'Créez des récompenses qui incitent au retour',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.edit_note,
                      color: Colors.orange.shade600,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Détails de la Récompense',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              _buildRewardNameField(),
              SizedBox(height: 20),
              // _buildDescriptionField(),
              SizedBox(height: 20),
              _buildPointsField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.title_rounded,
              size: 18,
              color: Colors.purple.shade600,
            ),
            SizedBox(width: 8),
            Text(
              'Description de la récompense',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Ex: "1 burger gratuit", "Café offert", "10% de réduction"',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: _manager.titleController,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade800,
            ),
            decoration: InputDecoration(
              hintText: 'Entrez la description de la récompense...',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              prefixIcon: Icon(
                Icons.card_giftcard,
                color: Colors.purple.shade400,
                size: 20,
              ),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'La description est requise' : null,
          ),
        ),
      ],
    );
  }

 
  Widget _buildPointsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.stars_rounded,
              size: 18,
              color: Colors.amber.shade600,
            ),
            SizedBox(width: 8),
            Text(
              'Points requis',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: TextFormField(
            controller: _manager.pointsController,
            style: TextStyle(
        
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade700,
            ),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '100',
              hintStyle: TextStyle(
                color: Colors.amber.shade400,
                fontWeight: FontWeight.w600,

              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              prefixIcon: Icon(
                Icons.star,
                color: Colors.amber.shade600,

              ),
              suffixText: 'pts',
              suffixStyle: TextStyle(
                color: Colors.amber.shade600,
                fontWeight: FontWeight.w600,
  
              ),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Les points sont requis';
              if (int.tryParse(value!) == null) return 'Nombre invalide';
              if (int.parse(value) <= 0) return 'Doit être supérieur à 0';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitSection() {
    final isEditing = widget.reward != null;
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isSubmitting
                    ? [Colors.grey.shade400, Colors.grey.shade500]
                    : [Colors.green.shade600, Colors.green.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (_isSubmitting ? Colors.grey : Colors.green)
                      .withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isSubmitting ? null : _submitForm,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSubmitting) ...[
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          isEditing ? 'Modification en cours...' : 'Création en cours...',
                          style: TextStyle(
                            color: Colors.white,

                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else ...[
                        Icon(
                          isEditing ? Icons.save : Icons.card_giftcard,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Text(
                          isEditing ? 'Enregistrer les modifications' : 'Créer la récompense',
                          style: TextStyle(
                            color: Colors.white,
            
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}