import 'package:flutter/foundation.dart';
import '../models/car.dart';
import '../services/database_service.dart';

class CarProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Car> _cars = [];
  List<Car> _filteredCars = [];
  bool _isLoading = false;
  String? _error;

  // Filters
  String _searchQuery = '';
  String _selectedMake = '';
  String _selectedCondition = '';
  double _minPrice = 0;
  double _maxPrice = double.infinity;

  // Getters
  List<Car> get cars => _cars;
  List<Car> get filteredCars => _filteredCars;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters for filters
  String get searchQuery => _searchQuery;
  String get selectedMake => _selectedMake;
  String get selectedCondition => _selectedCondition;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;

  // Initialize cars
  Future<void> loadCars() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _databaseService.ensureInitialized();

      // Get cars from database
      final cars = await _databaseService.getAllCars();
      debugPrint('CarProvider: Loaded ${cars.length} cars from database');
      
      if (cars.isEmpty) {
        debugPrint('CarProvider: No cars found in database');
        // Don't automatically reset - let user decide
      }

      _cars = cars;
      _filteredCars = cars;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('CarProvider: Error loading cars: $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Add new car
  Future<void> addCar(Car car) async {
    try {
      debugPrint('CarProvider: Starting to add car with ID: ${car.id}');
      await _databaseService.addCar(car);
      debugPrint('CarProvider: Car added to database, reloading cars...');
      await loadCars(); // Reload cars to include the new one
      debugPrint('CarProvider: Cars reloaded successfully');
    } catch (e) {
      debugPrint('CarProvider: Error adding car: $e');
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Update existing car
  Future<void> updateCar(Car car) async {
    try {
      await _databaseService.updateCar(car);
      final index = _cars.indexWhere((c) => c.id == car.id);
      if (index != -1) {
        _cars[index] = car;
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating car: $e');
    }
  }

  // Delete car
  Future<void> deleteCar(String id) async {
    try {
      await _databaseService.deleteCar(id);
      _cars.removeWhere((car) => car.id == id);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting car: $e');
    }
  }

  // Search and filter methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setSelectedMake(String make) {
    _selectedMake = make;
    _applyFilters();
    notifyListeners();
  }

  void setSelectedCondition(String condition) {
    _selectedCondition = condition;
    _applyFilters();
    notifyListeners();
  }

  void setPriceRange(double min, double max) {
    _minPrice = min;
    _maxPrice = max;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedMake = '';
    _selectedCondition = '';
    _minPrice = 0;
    _maxPrice = double.infinity;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredCars = _cars.where((car) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!car.make.toLowerCase().contains(query) &&
            !car.model.toLowerCase().contains(query) &&
            !car.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Make filter
      if (_selectedMake.isNotEmpty && car.make != _selectedMake) {
        return false;
      }

      // Condition filter
      if (_selectedCondition.isNotEmpty &&
          car.condition != _selectedCondition) {
        return false;
      }

      // Price filter
      if (car.price < _minPrice || car.price > _maxPrice) {
        return false;
      }

      return true;
    }).toList();
  }

  // Get unique makes for filter dropdown
  List<String> get uniqueMakes {
    final makes = _cars.map((car) => car.make).toSet().toList();
    makes.sort();
    return makes;
  }

  // Get unique conditions for filter dropdown
  List<String> get uniqueConditions {
    final conditions = _cars.map((car) => car.condition).toSet().toList();
    conditions.sort();
    return conditions;
  }

  // Get price range for slider
  double get maxPriceInData {
    if (_cars.isEmpty) return 100000;
    return _cars.map((car) => car.price).reduce((a, b) => a > b ? a : b);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
