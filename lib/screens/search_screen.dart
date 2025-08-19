import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/car_provider.dart';
import '../models/car.dart';
import '../widgets/car_card.dart';
import '../widgets/app_logo.dart';
import '../utils/theme.dart';
import 'car_detail_screen.dart';
import '../services/database_service.dart'; // Added import for DatabaseService

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarProvider>().loadCars();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(size: 28, showText: false),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CarProvider>().loadCars();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search cars by make, model, or description...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<CarProvider>().setSearchQuery('');
                  },
                ),
              ),
              onChanged: (value) {
                context.read<CarProvider>().setSearchQuery(value);
              },
            ),
          ),

          // Filters
          if (_showFilters) _buildFilters(),

          // Results
          Expanded(
            child: Consumer<CarProvider>(
              builder: (context, carProvider, child) {
                if (carProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final cars = carProvider.filteredCars;

                if (cars.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchController.text.isEmpty &&
                                  carProvider.selectedMake.isEmpty &&
                                  carProvider.selectedCondition.isEmpty
                              ? Icons.directions_car
                              : Icons.search_off,
                          size: 64,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty &&
                                  carProvider.selectedMake.isEmpty &&
                                  carProvider.selectedCondition.isEmpty
                              ? 'No cars available'
                              : 'No cars found',
                          style: AppTheme.headline3.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchController.text.isEmpty &&
                                  carProvider.selectedMake.isEmpty &&
                                  carProvider.selectedCondition.isEmpty
                              ? 'The database is empty. Add some cars to get started!'
                              : 'Try adjusting your search criteria or filters',
                          style: AppTheme.body2.copyWith(
                            color: AppTheme.textLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        if (_searchController.text.isNotEmpty ||
                            carProvider.selectedMake.isNotEmpty ||
                            carProvider.selectedCondition.isNotEmpty)
                          ElevatedButton(
                            onPressed: () {
                              carProvider.clearFilters();
                              _searchController.clear();
                            },
                            child: const Text('Clear Filters'),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<CarProvider>().loadCars();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Results Count
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'Found ${context.watch<CarProvider>().filteredCars.length} cars',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    // Cars Grid
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: cars.length,
                        itemBuilder: (context, index) {
                          final car = cars[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CarDetailScreen(car: car),
                                ),
                              );
                            },
                            child: CarCard(car: car),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Consumer<CarProvider>(
      builder: (context, carProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filters',
                style: AppTheme.headline4,
              ),
              const SizedBox(height: 16),

              // Make Filter
              Text(
                'Make',
                style: AppTheme.body1.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: carProvider.selectedMake.isEmpty
                    ? null
                    : carProvider.selectedMake,
                decoration: const InputDecoration(
                  hintText: 'Select Make',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Makes'),
                  ),
                  ...carProvider.uniqueMakes.map((make) {
                    return DropdownMenuItem<String>(
                      value: make,
                      child: Text(make),
                    );
                  }),
                ],
                onChanged: (value) {
                  carProvider.setSelectedMake(value ?? '');
                },
              ),

              const SizedBox(height: 16),

              // Condition Filter
              Text(
                'Condition',
                style: AppTheme.body1.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: carProvider.selectedCondition.isEmpty
                    ? null
                    : carProvider.selectedCondition,
                decoration: const InputDecoration(
                  hintText: 'Select Condition',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Conditions'),
                  ),
                  ...carProvider.uniqueConditions.map((condition) {
                    return DropdownMenuItem<String>(
                      value: condition,
                      child: Text(condition),
                    );
                  }),
                ],
                onChanged: (value) {
                  carProvider.setSelectedCondition(value ?? '');
                },
              ),

              const SizedBox(height: 16),

              // Price Range Filter
              Text(
                'Price Range',
                style: AppTheme.body1.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              RangeSlider(
                values: RangeValues(
                  carProvider.minPrice,
                  carProvider.maxPrice == double.infinity
                      ? carProvider.maxPriceInData
                      : carProvider.maxPrice,
                ),
                min: 0,
                max: carProvider.maxPriceInData,
                divisions: 100,
                labels: RangeLabels(
                  '\$${carProvider.minPrice.toStringAsFixed(0)}',
                  carProvider.maxPrice == double.infinity
                      ? '\$${carProvider.maxPriceInData.toStringAsFixed(0)}'
                      : '\$${carProvider.maxPrice.toStringAsFixed(0)}',
                ),
                onChanged: (values) {
                  carProvider.setPriceRange(values.start, values.end);
                },
              ),

              const SizedBox(height: 16),

              // Filter Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        carProvider.clearFilters();
                        _searchController.clear();
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showFilters = false;
                        });
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
