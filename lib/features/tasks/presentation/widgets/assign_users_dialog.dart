import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/task.dart';
import '../providers/task_provider.dart';

/// Dialog élégant et moderne pour assigner des utilisateurs à une tâche
class AssignUsersDialog extends StatefulWidget {
  final Task task;

  const AssignUsersDialog({super.key, required this.task});

  @override
  State<AssignUsersDialog> createState() => _AssignUsersDialogState();
}

class _AssignUsersDialogState extends State<AssignUsersDialog>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Sauvegarder l'état initial pour permettre l'annulation
  late List<String> _initialAssignedUsers;

  @override
  void initState() {
    super.initState();
    
    // Sauvegarder l'état initial des assignations
    _initialAssignedUsers = List<String>.from(widget.task.assignedTo);
    
    _loadUsers();

    // Animations d'entrée
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final provider = context.read<TaskProvider>();
      final users = await provider.getAllUsers();
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers.where((user) {
          final name = (user['name'] as String? ?? '').toLowerCase();
          final email = (user['email'] as String? ?? '').toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || email.contains(searchLower);
        }).toList();
      }
    });
  }

  /// Annule toutes les modifications et restaure l'état initial
  Future<void> _cancelChanges() async {
    try {
      final provider = context.read<TaskProvider>();
      final currentTask = provider.allTasks.firstWhere((t) => t.id == widget.task.id);
      final currentAssignedUsers = currentTask.assignedTo;

      // Trouver les utilisateurs à retirer (qui ont été ajoutés)
      final usersToRemove = currentAssignedUsers
          .where((userId) => !_initialAssignedUsers.contains(userId))
          .toList();

      // Trouver les utilisateurs à rajouter (qui ont été retirés)
      final usersToAdd = _initialAssignedUsers
          .where((userId) => !currentAssignedUsers.contains(userId))
          .toList();

      // Effectuer les modifications pour restaurer l'état initial
      for (final userId in usersToRemove) {
        await provider.unassignUserFromTask(widget.task.id, userId);
      }

      for (final userId in usersToAdd) {
        await provider.assignUserToTask(widget.task.id, userId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.undo, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Modifications annulées',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.getOnSurface(context).withOpacity(0.8),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        
        // Fermer le dialog après avoir annulé
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'annulation: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleUserAssignment(String userId, bool isAssigned) async {
    try {
      final provider = context.read<TaskProvider>();
      if (isAssigned) {
        // L'utilisateur EST déjà assigné → on le RETIRE
        await provider.unassignUserFromTask(widget.task.id, userId);
      } else {
        // L'utilisateur N'EST PAS assigné → on l'AJOUTE
        await provider.assignUserToTask(widget.task.id, userId);
      }

      // Animation de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isAssigned ? Icons.person_remove : Icons.person_add,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isAssigned
                        ? 'Utilisateur retiré avec succès'
                        : 'Utilisateur assigné avec succès',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erreur: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildContent(),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // Récupérer la tâche à jour depuis le Provider
    final currentTask = context.watch<TaskProvider>().allTasks.firstWhere(
      (t) => t.id == widget.task.id,
      orElse: () => widget.task,
    );
    final assignedCount = currentTask.assignedTo.length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gérer l\'équipe',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$assignedCount membre${assignedCount > 1 ? 's' : ''} assigné${assignedCount > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Fermer',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.task_alt, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.task.title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: _filterUsers,
        decoration: InputDecoration(
          hintText: 'Rechercher un utilisateur...',
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterUsers('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.getSurfaceVariant(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.getOutline(context),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : _filteredUsers.isEmpty
          ? _buildEmptyState()
          : _buildUsersList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getOnSurface(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(color: AppColors.getOnSurfaceVariant(context)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
            size: 64,
            color: AppColors.getOnSurfaceVariant(context),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Aucun utilisateur disponible'
                : 'Aucun résultat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getOnSurface(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Invitez des utilisateurs à rejoindre votre espace'
                : 'Essayez une autre recherche',
            style: TextStyle(color: AppColors.getOnSurfaceVariant(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _buildUserTile(user);
      },
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final userId = user['id'] as String;
    final userName = user['name'] as String? ?? 'Sans nom';
    final userEmail = user['email'] as String? ?? '';

    // Récupérer la tâche à jour depuis le Provider
    final currentTask = context.watch<TaskProvider>().allTasks.firstWhere(
      (t) => t.id == widget.task.id,
      orElse: () => widget.task,
    );
    final isAssigned = currentTask.assignedTo.contains(userId);

    // Couleur de l'avatar basée sur le nom
    final avatarColor = _getAvatarColor(userName);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isAssigned
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAssigned
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.getOutline(context),
          width: isAssigned ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Hero(
          tag: 'user_avatar_$userId',
          child: Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: avatarColor,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              if (isAssigned)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        title: Text(
          userName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.getOnSurface(context),
          ),
        ),
        subtitle: Text(
          userEmail,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getOnSurfaceVariant(context),
          ),
        ),
        trailing: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isAssigned
              ? GestureDetector(
                  key: const ValueKey('assigned'),
                  onTap: () => _toggleUserAssignment(userId, isAssigned),
                  child: Chip(
                    label: const Text(
                      'Assigné',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                    onDeleted: () => _toggleUserAssignment(userId, isAssigned),
                    backgroundColor: AppColors.success,
                    padding: EdgeInsets.zero,
                  ),
                )
              : OutlinedButton(
                  key: const ValueKey('assign'),
                  onPressed: () => _toggleUserAssignment(userId, isAssigned),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Assigner'),
                ),
        ),
        onTap: () => _toggleUserAssignment(userId, isAssigned),
      ),
    );
  }

  Widget _buildFooter() {
    // Récupérer la tâche à jour depuis le Provider
    final currentTask = context.watch<TaskProvider>().allTasks.firstWhere(
      (t) => t.id == widget.task.id,
      orElse: () => widget.task,
    );
    final assignedCount = currentTask.assignedTo.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceVariant(context),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$assignedCount membre${assignedCount > 1 ? 's' : ''} dans l\'équipe',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getOnSurfaceVariant(context),
              ),
            ),
          ),
          // Bouton Annuler - Restaure l'état initial
          TextButton(
            onPressed: _cancelChanges,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.getOnSurface(context).withOpacity(0.7),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Annuler'),
          ),
          const SizedBox(width: 8),
          // Bouton Modifier - Ferme le dialog (changements déjà appliqués)
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  /// Génère une couleur d'avatar basée sur le nom
  Color _getAvatarColor(String name) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.error,
      AppColors.warning,
      AppColors.success,
      AppColors.info,
    ];

    final index = name.isNotEmpty ? name.codeUnitAt(0) % colors.length : 0;

    return colors[index];
  }
}
