import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/car.dart';
import '../providers/car_provider.dart';
import '../services/database_service.dart';
import 'dart:io';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _databaseService = DatabaseService();

  // Form fields
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _locationController = TextEditingController();
  final _conditionController = TextEditingController();
  final _mileageController = TextEditingController();
  final _fuelTypeController = TextEditingController();
  final _transmissionController = TextEditingController();
  final _colorController = TextEditingController();

  // Image picker
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _selectedImageUrl;

  // Seller info (will be loaded from database)
  String _sellerId = '';
  String _sellerName = '';

  // Dropdown options
  final List<String> _fuelTypes = ['Gasoline', 'Diesel', 'Electric', 'Hybrid'];
  final List<String> _transmissions = ['Automatic', 'Manual', 'CVT'];
  final List<String> _conditions = ['Excellent', 'Good', 'Fair', 'Poor'];
  final List<String> _availableFeatures = [
    'Bluetooth',
    'Backup Camera',
    'Navigation',
    'Leather Seats',
    'Sunroof',
    'Heated Seats',
    'Ventilated Seats',
    'Premium Sound',
    'Lane Assist',
    'Blind Spot Monitor',
    'Apple CarPlay',
    'Android Auto',
    'Wireless Charging',
    '360° Camera',
    'Autopilot',
    'Performance Tires',
    'Sport Suspension',
    'AWD',
    'Turbo Engine',
    'V8 Engine',
  ];
  List<String> _selectedFeatures = [];

  @override
  void initState() {
    super.initState();
    _loadSellerInfo();
    // Set default year to current year
    _yearController.text = DateTime.now().year.toString();
    // Set default values
    _fuelTypeController.text = _fuelTypes.first;
    _transmissionController.text = _transmissions.first;
    _conditionController.text = _conditions.first;
  }

  Future<void> _loadSellerInfo() async {
    try {
      await _databaseService.ensureInitialized();
      final users = await _databaseService.getAllUsers();
      if (users.isNotEmpty) {
        // Use first user as seller for demo
        final user = users.first;
        _sellerId = user.id;
        _sellerName = user.name;
      }
    } catch (e) {
      debugPrint('Error loading seller info: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _selectedImageUrl = null; // Clear URL when image is selected
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearSelectedImage() {
    setState(() {
      _imageFile = null;
      _selectedImageUrl = null;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Validate that either image is selected or URL is provided
      if (_imageFile == null &&
          (_imageUrlController.text.isEmpty ||
              _imageUrlController.text.trim().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide an image or image URL'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        debugPrint('Starting car submission...');

        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        debugPrint('Generating car ID...');
        // Create new car
        final car = Car(
          id: await _databaseService
              .generateCarId(), // Generate dynamic ID from database
          make: _makeController.text.trim(),
          model: _modelController.text.trim(),
          year: int.parse(_yearController.text),
          price: double.parse(_priceController.text),
          description: _descriptionController.text.trim(),
          imageUrl: _imageFile != null
              ? 'local_image_${DateTime.now().millisecondsSinceEpoch}' // Placeholder for local image
              : _imageUrlController.text.trim(),
          sellerId: _sellerId,
          sellerName: _sellerName,
          location: _locationController.text.trim(),
          condition: _conditionController.text,
          mileage: int.parse(_mileageController.text),
          fuelType: _fuelTypeController.text,
          transmission: _transmissionController.text,
          color: _colorController.text.trim(),
          features: _selectedFeatures,
          createdAt: DateTime.now(),
          isSold: false,
        );

        debugPrint('Car object created, adding to provider...');
        // Add car to provider
        await context.read<CarProvider>().addCar(car);

        debugPrint('Car added successfully, closing dialogs...');
        // Hide loading indicator
        if (mounted) {
          Navigator.pop(context); // Close loading dialog

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Car added successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to previous screen
          Navigator.pop(context);
        }
      } catch (e) {
        debugPrint('Error in _submitForm: $e');
        // Hide loading indicator
        if (mounted) {
          Navigator.pop(context); // Close loading dialog

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding car: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Car'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight -
                  32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Car Image',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Image Preview
                        if (_imageFile != null) ...[
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _showImageSourceDialog,
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Change Image'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _clearSelectedImage,
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Remove'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Image Upload Options
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _showImageSourceDialog,
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Upload Image'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _selectedImageUrl = null;
                                    });
                                  },
                                  icon: const Icon(Icons.link),
                                  label: const Text('Use URL'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                    side: const BorderSide(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // URL Input (only show when not using gallery image)
                          if (_selectedImageUrl == null) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _imageUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Image URL',
                                hintText: 'Enter image URL',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an image URL';
                                }
                                return null;
                              },
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Basic Information
                const Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _makeController,
                        decoration: const InputDecoration(
                          labelText: 'Make',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter make';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _modelController,
                        decoration: const InputDecoration(
                          labelText: 'Model',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter model';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _yearController,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter year';
                          }
                          final year = int.tryParse(value);
                          if (year == null ||
                              year < 1900 ||
                              year > DateTime.now().year + 1) {
                            return 'Please enter a valid year';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price (\$)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter price';
                          }
                          final price = double.tryParse(value);
                          if (price == null || price <= 0) {
                            return 'Please enter a valid price';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Additional Details
                const Text(
                  'Additional Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Location and Condition row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter location';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _conditionController.text.isEmpty
                            ? null
                            : _conditionController.text,
                        decoration: const InputDecoration(
                          labelText: 'Condition',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                        isExpanded: true,
                        menuMaxHeight: 200,
                        items: _conditions.map((condition) {
                          return DropdownMenuItem(
                            value: condition,
                            child: Text(
                              condition,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _conditionController.text = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select condition';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Mileage and Fuel Type row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _mileageController,
                        decoration: const InputDecoration(
                          labelText: 'Mileage',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter mileage';
                          }
                          final mileage = int.tryParse(value);
                          if (mileage == null || mileage < 0) {
                            return 'Please enter valid mileage';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _fuelTypeController.text.isEmpty
                            ? null
                            : _fuelTypeController.text,
                        decoration: const InputDecoration(
                          labelText: 'Fuel Type',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                        isExpanded: true,
                        menuMaxHeight: 200,
                        items: _fuelTypes.map((fuelType) {
                          return DropdownMenuItem(
                            value: fuelType,
                            child: Text(
                              fuelType,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _fuelTypeController.text = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select fuel type';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Transmission and Color row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _transmissionController.text.isEmpty
                            ? null
                            : _transmissionController.text,
                        decoration: const InputDecoration(
                          labelText: 'Transmission',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                        isExpanded: true,
                        menuMaxHeight: 200,
                        items: _transmissions.map((transmission) {
                          return DropdownMenuItem(
                            value: transmission,
                            child: Text(
                              transmission,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _transmissionController.text = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select transmission';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _colorController,
                        decoration: const InputDecoration(
                          labelText: 'Color',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter color';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Features
                const Text(
                  'Features',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableFeatures.map((feature) {
                    final isSelected = _selectedFeatures.contains(feature);
                    return FilterChip(
                      label: Text(feature),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedFeatures.add(feature);
                          } else {
                            _selectedFeatures.remove(feature);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Add Car',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
