import '../models/universe.dart';
import '../service/api_service_universe.dart';

class UniverseController {
  final ApiService apiService = ApiService();

  List<Universe> universes = [];
  String? errorMessage;

  // 🔹 Récupérer la liste des univers
  Future<void> getAllUniverses() async {
    try {
      universes = await apiService.getUniverses();
      errorMessage = null;
    } catch (e) {
      errorMessage = "Échec du chargement des univers : ${e.toString()}";
      universes = [];
    }
  }

  Future<void> createUniverse(name) async {
    try{
      await apiService.addUniverse(name);
    }catch (e) {
      errorMessage = "Échec de la création de l'univers : ${e.toString()}";
    }
  }

}