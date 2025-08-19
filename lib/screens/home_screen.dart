import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/car_provider.dart';
import '../services/database_service.dart';
import '../utils/theme.dart';
import '../widgets/car_card.dart';
import '../widgets/app_logo.dart';
import 'add_car_screen.dart';
import 'search_screen.dart';
import 'car_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  int _totalCars = 0;
  int _verifiedSellers = 0;
  int _totalCities = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarProvider>().loadCars();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh statistics when dependencies change
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      await _databaseService.ensureInitialized();

      // Get total cars
      final cars = await _databaseService.getAllCars();
      _totalCars = cars.length;
      debugPrint('HomeScreen: Loaded ${cars.length} cars');

      // Debug: Print first few car locations
      if (cars.isNotEmpty) {
        debugPrint('HomeScreen: First 3 car locations:');
        for (int i = 0; i < cars.length && i < 3; i++) {
          debugPrint('  Car ${i + 1}: ${cars[i].location}');
        }
      }

      // Get verified sellers (users with isVerified = 1)
      final users = await _databaseService.getAllUsers();
      _verifiedSellers = users.where((user) => user.isVerified).length;
      debugPrint('HomeScreen: Found $_verifiedSellers verified sellers');

      // Get unique cities from cars
      final cities =
          cars.map((car) => car.location.split(',')[0].trim()).toSet();
      _totalCities = cities.length;
      debugPrint(
          'HomeScreen: Found $_totalCities unique cities: ${cities.join(', ')}');

      // Debug: Print all car locations
      debugPrint('HomeScreen: All car locations:');
      for (int i = 0; i < cars.length; i++) {
        debugPrint(
            '  Car ${i + 1}: ${cars[i].location} -> ${cars[i].location.split(',')[0].trim()}');
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading statistics: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _refreshStatistics() async {
    await _loadStatistics();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Statistics refreshed'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title:
                const AppLogo(size: 32, color: Colors.white, showText: false),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryLight,
                    AppTheme.secondaryColor,
                  ],
                ),
              ),
              child: const Center(
                child: AppLogo(size: 80, color: Colors.white),
              ),
            ),
          ),
        ),

        // Welcome Section
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryLight],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Apex Car Trading!',
                  style: AppTheme.headline2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find your perfect car or sell your vehicle with confidence.',
                  style: AppTheme.body1.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddCarScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Sell Your Car'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.search),
                        label: const Text('Browse Cars'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Statistics Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Quick Statistics',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Compact debug controls
                          Consumer<CarProvider>(
                            builder: (context, carProvider, child) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Cars: ${carProvider.cars.length}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Compact debug buttons
                                  _buildCompactDebugButton(
                                    icon: Icons.refresh,
                                    tooltip: 'Refresh Cars',
                                    onPressed: () async {
                                      await carProvider.loadCars();
                                      await _refreshStatistics();
                                    },
                                  ),
                                  _buildCompactDebugButton(
                                    icon: Icons.health_and_safety,
                                    tooltip: 'Check Database Health',
                                    onPressed: () async {
                                      final databaseService = DatabaseService();
                                      await databaseService
                                          .checkAndFixDatabase();
                                      await carProvider.loadCars();
                                      await _refreshStatistics();

                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Database health check completed'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      // Add a subtle divider
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Consumer<CarProvider>(
                    builder: (context, carProvider, child) {
                      // Update statistics when cars change
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (carProvider.cars.isNotEmpty &&
                            (_totalCars == 0 || _totalCities == 0)) {
                          _loadStatistics();
                        }
                      });

                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'Total Cars',
                                carProvider.cars.length.toString(),
                                Icons.directions_car,
                                Colors.blue,
                              ),
                              _buildStatItem(
                                'Verified Sellers',
                                _verifiedSellers.toString(),
                                Icons.verified_user,
                                Colors.green,
                              ),
                              _buildStatItem(
                                'Cities',
                                _totalCities.toString(),
                                Icons.location_city,
                                Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // Featured Cars Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Featured Cars',
                  style: AppTheme.headline3,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
        ),

        // Featured Cars Grid
        Consumer<CarProvider>(
          builder: (context, carProvider, child) {
            if (carProvider.isLoading) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            final featuredCars = carProvider.cars.take(6).toList();

            if (featuredCars.isEmpty) {
              return SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 64,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No cars available',
                        style: AppTheme.headline4.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to list a car!',
                        style: AppTheme.body2.copyWith(
                          color: AppTheme.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddCarScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('List Your Car'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final car = featuredCars[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CarDetailScreen(car: car),
                          ),
                        );
                      },
                      child: CarCard(car: car),
                    );
                  },
                  childCount: featuredCars.length,
                ),
              ),
            );
          },
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTheme.headline2.copyWith(
                color: color,
              ),
            ),
            Text(
              title,
              style: AppTheme.body2.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 40, color: color),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Helper method for compact debug buttons
  Widget _buildCompactDebugButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 2),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        tooltip: tooltip,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(
          minWidth: 28,
          minHeight: 28,
        ),
        style: IconButton.styleFrom(
          backgroundColor: Colors.grey.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
