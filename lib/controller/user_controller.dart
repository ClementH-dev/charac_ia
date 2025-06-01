import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../service/api_service.dart';

class UserController extends ChangeNotifier {
  final ApiService apiService = ApiService();
  bool isLoading = false;
  bool isAuthenticated = false;
  String? errorMessage;
  User? currentUser;

  // 🔹 Inscription d'un nouvel utilisateur
  Future<void> registerUser(User user) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      User newUser = await apiService.createUser(user);

      // Stocker l'utilisateur et le connecter s'il y a un token
      currentUser = newUser;
      isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      errorMessage = "Échec de l'inscription : ${e.toString()}";
    }

    isLoading = false;
    notifyListeners();
  }

  // 🔹 Connexion d'un utilisateur existant
  Future<void> loginUser(String username, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      String token = await apiService.loginUser(username, password);

      // Stocker le token localement et connecter l'utilisateur
      await saveToken(token);
      isAuthenticated = true;
    } catch (e) {
      errorMessage = "Échec de la connexion : ${e.toString()}";
      isAuthenticated = false;
    }

    isLoading = false;
    notifyListeners();
  }

  // 🔹 Sauvegarder le token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // 🔹 Récupérer le token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // 🔹 Vérifier si l'utilisateur est connecté
  Future<void> checkLoginStatus() async {
    String? token = await getToken();
    isAuthenticated = token != null;
    notifyListeners();
  }

  // 🔹 Déconnexion de l'utilisateur
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    isAuthenticated = false;
    currentUser = null;
    notifyListeners();
  }
}
