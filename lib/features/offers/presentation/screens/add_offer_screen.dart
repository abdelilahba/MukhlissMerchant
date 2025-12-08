import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/features/offers/domain/entities/offer_entity.dart';
import 'package:mukhlissmagasin/features/offers/presentation/managers/offer_manager.dart';
import 'package:mukhlissmagasin/features/offers/presentation/widgets/offer_form.dart';
import 'package:mukhlissmagasin/features/offers/presentation/cubit/offer_cubit.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';

class AddOfferScreen extends StatefulWidget {
  final Offer? offer;

  const AddOfferScreen({Key? key, this.offer}) : super(key: key);

  @override
  State<AddOfferScreen> createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final OfferManager _manager;
  late AnimationController _animationController;
  late AnimationController _submitAnimationController;
  late AnimationController _floatingActionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingScaleAnimation;
  late Animation<double> _headerAnimation;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _manager = OfferManager(context.read<OfferCubit>());
    _initializeAnimations();
    _populateFieldsForEditing();
  }

  void _populateFieldsForEditing() {
    if (widget.offer != null) {
      _manager.amountController.text = widget.offer!.minAmount.toString();
      _manager.pointsController.text = widget.offer!.pointsGiven.toString();
      _manager.isactive = widget.offer!.isActive;
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _submitAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _floatingActionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _submitAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _floatingScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _floatingActionController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _floatingActionController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _submitAnimationController.dispose();
    _floatingActionController.dispose();
    _manager.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    _submitAnimationController.forward();

    try {
      if (widget.offer == null) {
        await _manager.createOffer(
          amount: _manager.amountController.text,
          points: _manager.pointsController.text,
          isActive: _manager.isactive,
        );
      } else {
        await _manager.updateOffer(
          id: widget.offer!.id,
          amount: _manager.amountController.text,
          points: _manager.pointsController.text,
          isActive: _manager.isactive,
        );
      }

      if (mounted) {
        _showSuccessMessage(widget.offer != null);
        await Future.delayed(const Duration(milliseconds: 2000));
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

  void _showSuccessMessage(bool isEditing) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEditing
                          ? 'Offre mise à jour!'
                          : 'Offre créée avec succès!',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      isEditing
                          ? 'Les modifications ont été enregistrées'
                          : 'Votre offre est maintenant active',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Erreur survenue',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildEnhancedAppBar(),
            Expanded(child: _buildFormContent()),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingSubmitButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEnhancedAppBar() {
    final isEditing = widget.offer != null;
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - _headerAnimation.value)),
          child: Opacity(
            opacity: _headerAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                            ),
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade100,
                                Colors.cyan.shade50,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_offer_rounded,
                                color: Colors.blue.shade600,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Offre Spéciale',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing
                                    ? l10n.modifieroffre
                                    : l10n.nouvelleoffre,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isEditing
                                    ? l10n.modifieroffreexiste
                                    : l10n.credesoffre,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade600,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                child: Column(
                  children: [
                    _buildMotivationalCard(),
                    const SizedBox(height: 24),
                    _buildEnhancedFormCard(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMotivationalCard() {

    final isEditing = widget.offer != null;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade400,
            Colors.cyan.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    isEditing ? Icons.tune_rounded : Icons.trending_up_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? l10n.optimizeroffre : l10n.bostezlesventes,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isEditing ? l10n.ajouterdetails : l10n.credesoffre,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFormCard() {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              icon: Icons.settings_rounded,
              title: l10n.detailoffre,
              color: Colors.orange.shade600,
            ),
            const SizedBox(height: 32),
            _buildEnhancedOfferForm(),
            const SizedBox(height: 28),
            _buildEnhancedActiveToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedOfferForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: OfferForm(
        formKey: _formKey,
        onSubmit: _submitForm,
        manager: _manager,
      ),
    );
  }

  Widget _buildEnhancedActiveToggle() {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.stausoffre,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _manager.isactive
              ? l10n.cetteoffreestactuve
              : l10n.cetteoffreesttemporairement,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color:
                _manager.isactive ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  _manager.isactive
                      ? Colors.green.shade200
                      : Colors.red.shade200,
            ),
          ),
          child: SwitchListTile(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        _manager.isactive
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _manager.isactive
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: 18,
                    color:
                        _manager.isactive
                            ? Colors.green.shade600
                            : Colors.red.shade600,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  _manager.isactive ? l10n.active : l10n.inactif,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color:
                        _manager.isactive
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                  ),
                ),
              ],
            ),
            value: _manager.isactive,
            onChanged: (value) {
              setState(() {
                _manager.isactive = value;
              });
            },
            activeColor: Colors.green.shade600,
            inactiveTrackColor: Colors.red.shade300,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingSubmitButton() {
    final isEditing = widget.offer != null;
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_floatingScaleAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _floatingScaleAnimation.value * _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    _isSubmitting
                        ? [Colors.grey.shade400, Colors.grey.shade500]
                        : [Colors.green.shade600, Colors.green.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: (_isSubmitting ? Colors.grey : Colors.green)
                      .withValues(alpha: 0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isSubmitting ? null : _submitForm,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  height: 68,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSubmitting) ...[
                        SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Text(
                          isEditing
                              ? 'Modification en cours...'
                              : l10n.creationencours,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isEditing
                                ? Icons.save_rounded
                                : Icons.rocket_launch_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Text(
                          isEditing
                              ? l10n.enredisterlesmodifiaction
                              : l10n.creeoffre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
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
