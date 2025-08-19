import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/car.dart';
import '../models/user.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'car_trading.db');
    debugPrint('DatabaseService: Initializing database at $path');

    // Check if database already exists
    final exists = await databaseExists(path);
    debugPrint('DatabaseService: Database exists: $exists');

    if (!exists) {
      debugPrint('DatabaseService: Creating new database...');
      // Only create new database if it doesn't exist
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    } else {
      debugPrint('DatabaseService: Opening existing database...');
      // Open existing database and check if it needs upgrade
      final db = await openDatabase(path);

      // Check if cars table exists and has the right structure
      try {
        final tables = await db.query('sqlite_master',
            where: 'type = ? AND name = ?', whereArgs: ['table', 'cars']);
        debugPrint('DatabaseService: Cars table exists: ${tables.isNotEmpty}');

        if (tables.isEmpty) {
          debugPrint(
              'DatabaseService: Cars table missing, recreating database...');
          // Table doesn't exist, recreate database
          await db.close();
          await deleteDatabase(path);
          return await openDatabase(
            path,
            version: 1,
            onCreate: _onCreate,
          );
        }

        // Check if cars table has data
        final carCount =
            await db.rawQuery('SELECT COUNT(*) as count FROM cars');
        final count = carCount.first['count'] as int;
        debugPrint('DatabaseService: Cars in database: $count');

        if (count == 0) {
          debugPrint(
              'DatabaseService: No cars found, inserting sample data...');
          // Table exists but no data, insert sample data
          try {
            await _insertSampleData(db);
            debugPrint('DatabaseService: Sample data inserted successfully');
          } catch (e) {
            debugPrint('DatabaseService: Error inserting sample data: $e');
            // If sample data insertion fails, recreate database
            await db.close();
            await deleteDatabase(path);
            return await openDatabase(
              path,
              version: 1,
              onCreate: _onCreate,
            );
          }
        }

        return db;
      } catch (e) {
        debugPrint('DatabaseService: Error checking database: $e');
        // Error occurred, recreate database
        await db.close();
        await deleteDatabase(path);
        return await openDatabase(
          path,
          version: 1,
          onCreate: _onCreate,
        );
      }
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Cars table
    await db.execute('''
      CREATE TABLE cars(
        id TEXT PRIMARY KEY,
        make TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER NOT NULL,
        price REAL NOT NULL,
        description TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        sellerId TEXT NOT NULL,
        sellerName TEXT NOT NULL,
        location TEXT NOT NULL,
        condition TEXT NOT NULL,
        mileage INTEGER NOT NULL,
        fuelType TEXT NOT NULL,
        transmission TEXT NOT NULL,
        color TEXT NOT NULL,
        features TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isSold INTEGER NOT NULL
      )
    ''');

    // Users table
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        phone TEXT NOT NULL,
        location TEXT NOT NULL,
        avatarUrl TEXT NOT NULL,
        favoriteCarIds TEXT NOT NULL,
        listedCarIds TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isVerified INTEGER NOT NULL,
        isAdmin INTEGER NOT NULL
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    // Sample cars
    final sampleCars = [
      {
        'id': '1',
        'make': 'Toyota',
        'model': 'Camry',
        'year': 2020,
        'price': 25000.0,
        'description':
            'Excellent condition Toyota Camry with low mileage. Well-maintained with full service history. Features include Bluetooth connectivity, backup camera, and leather seats. Perfect for daily commuting or family use.',
        'imageUrl':
            'https://i.pinimg.com/736x/6f/a2/62/6fa262c235ff500a9a08b3a341c300df.jpg',
        'sellerId': 'user1',
        'sellerName': 'John Doe',
        'location': 'New York, NY',
        'condition': 'Excellent',
        'mileage': 35000,
        'fuelType': 'Gasoline',
        'transmission': 'Automatic',
        'color': 'Silver',
        'features':
            '["Bluetooth", "Backup Camera", "Leather Seats", "Navigation", "Sunroof"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isSold': 0,
      },
      {
        'id': '2',
        'make': 'Honda',
        'model': 'Civic',
        'year': 2019,
        'price': 22000.0,
        'description':
            'Well-maintained Honda Civic with great fuel economy. Single owner, clean title. Includes Apple CarPlay, lane assist, and advanced safety features. Ideal for city driving.',
        'imageUrl':
            'https://i.pinimg.com/1200x/b2/6a/3d/b26a3d89c9eff9b3f003c1e964c26828.jpg',
        'sellerId': 'user2',
        'sellerName': 'Jane Smith',
        'location': 'Los Angeles, CA',
        'condition': 'Good',
        'mileage': 42000,
        'fuelType': 'Gasoline',
        'transmission': 'Automatic',
        'color': 'Blue',
        'features':
            '["Bluetooth", "Apple CarPlay", "Lane Assist", "Backup Camera", "Blind Spot Monitor"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isSold': 0,
      },
      {
        'id': '3',
        'make': 'BMW',
        'model': '3 Series',
        'year': 2021,
        'price': 45000.0,
        'description':
            'Luxury BMW 3 Series with premium features. Low mileage, pristine condition. Includes leather seats, navigation system, premium sound system, and panoramic sunroof.',
        'imageUrl':
            'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=400',
        'sellerId': 'user3',
        'sellerName': 'Mike Johnson',
        'location': 'Chicago, IL',
        'condition': 'Excellent',
        'mileage': 28000,
        'fuelType': 'Gasoline',
        'transmission': 'Automatic',
        'color': 'Black',
        'features':
            '["Leather Seats", "Navigation", "Premium Sound", "Sunroof", "Heated Seats", "Wireless Charging"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isSold': 0,
      },
      {
        'id': '4',
        'make': 'Tesla',
        'model': 'Model 3',
        'year': 2022,
        'price': 55000.0,
        'description':
            'Electric Tesla Model 3 with autopilot capabilities. Zero emissions, instant torque. Features glass roof, premium interior, supercharging capability, and advanced autopilot.',
        'imageUrl':
            'https://images.unsplash.com/photo-1536700503339-1e4b06520771?w=400',
        'sellerId': 'user4',
        'sellerName': 'Sarah Wilson',
        'location': 'San Francisco, CA',
        'condition': 'Excellent',
        'mileage': 15000,
        'fuelType': 'Electric',
        'transmission': 'Automatic',
        'color': 'White',
        'features':
            '["Autopilot", "Glass Roof", "Premium Interior", "Supercharging", "Wireless Charging", "360° Camera"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isSold': 0,
      },
      {
        'id': '5',
        'make': 'Ford',
        'model': 'Mustang',
        'year': 2018,
        'price': 32000.0,
        'description':
            'Classic Ford Mustang with powerful V8 engine. Sport suspension and performance tires. Perfect for enthusiasts who want power and style. Well-maintained with regular service.',
        'imageUrl':
            'https://i.pinimg.com/1200x/81/27/44/812744ee1d46b67903ec5dfaf7ed9ec7.jpg',
        'sellerId': 'user5',
        'sellerName': 'David Brown',
        'location': 'Miami, FL',
        'condition': 'Good',
        'mileage': 55000,
        'fuelType': 'Gasoline',
        'transmission': 'Manual',
        'color': 'Red',
        'features':
            '["V8 Engine", "Sport Suspension", "Performance Tires", "Leather Seats", "Premium Sound"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isSold': 0,
      },
      {
        'id': '6',
        'make': 'Mercedes-Benz',
        'model': 'C-Class',
        'year': 2020,
        'price': 38000.0,
        'description':
            'Elegant Mercedes-Benz C-Class with luxury features. Premium interior with ambient lighting, heated and ventilated seats. Advanced driver assistance systems included.',
        'imageUrl':
            'https://i.pinimg.com/736x/f8/b4/30/f8b4302c4ab287b689d5d77ef4a1dcfe.jpg',
        'sellerId': 'user6',
        'sellerName': 'Emma Davis',
        'location': 'Dallas, TX',
        'condition': 'Excellent',
        'mileage': 32000,
        'fuelType': 'Gasoline',
        'transmission': 'Automatic',
        'color': 'Gray',
        'features':
            '["Ambient Lighting", "Heated Seats", "Ventilated Seats", "Navigation", "Premium Sound", "Lane Assist"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isSold': 0,
      },
      {
        'id': '7',
        'make': 'Audi',
        'model': 'A4',
        'year': 2021,
        'price': 42000.0,
        'description':
            'Sophisticated Audi A4 with quattro all-wheel drive. Virtual cockpit, premium audio system, and advanced safety features. Perfect blend of performance and luxury.',
        'imageUrl':
            'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=400',
        'sellerId': 'user7',
        'sellerName': 'Alex Chen',
        'location': 'Seattle, WA',
        'condition': 'Excellent',
        'mileage': 25000,
        'fuelType': 'Gasoline',
        'transmission': 'Automatic',
        'color': 'Silver',
        'features':
            '["Quattro AWD", "Virtual Cockpit", "Premium Audio", "Navigation", "Heated Seats", "Backup Camera"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isSold': 0,
      },
      {
        'id': '8',
        'make': 'Lexus',
        'model': 'RX 350',
        'year': 2019,
        'price': 35000.0,
        'description':
            'Reliable Lexus RX 350 SUV with premium comfort features. Spacious interior, smooth ride, and excellent reliability. Perfect for families and long-distance travel.',
        'imageUrl':
            'https://i.pinimg.com/1200x/29/04/4d/29044d0c78ee6669d75122377da40166.jpg',
        'sellerId': 'user8',
        'sellerName': 'Lisa Wang',
        'location': 'Boston, MA',
        'condition': 'Good',
        'mileage': 48000,
        'fuelType': 'Gasoline',
        'transmission': 'Automatic',
        'color': 'White',
        'features':
            '["Leather Seats", "Navigation", "Premium Sound", "Sunroof", "Heated Seats", "Blind Spot Monitor"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isSold': 0,
      },
      {
        'id': '9',
        'make': 'Volkswagen',
        'model': 'Golf GTI',
        'year': 2020,
        'price': 28000.0,
        'description':
            'Sporty Volkswagen Golf GTI with turbocharged engine. Fun to drive with excellent handling. Includes sport seats, premium audio, and performance features.',
        'imageUrl':
            'https://i.pinimg.com/1200x/56/ee/04/56ee048856bfa6a70a8909d09e9a3cd6.jpg',
        'sellerId': 'user9',
        'sellerName': 'Carlos Rodriguez',
        'location': 'Austin, TX',
        'condition': 'Good',
        'mileage': 38000,
        'fuelType': 'Gasoline',
        'transmission': 'Manual',
        'color': 'Blue',
        'features':
            '["Turbo Engine", "Sport Seats", "Premium Audio", "Performance Suspension", "Backup Camera"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isSold': 0,
      },
      {
        'id': '10',
        'make': 'Hyundai',
        'model': 'Tucson',
        'year': 2021,
        'price': 26000.0,
        'description':
            'Modern Hyundai Tucson with advanced safety features and comfortable interior. Great fuel economy and spacious cargo area. Perfect for daily use and weekend trips.',
        'imageUrl':
            'https://i.pinimg.com/1200x/04/17/95/0417950c978d1892fb1f806343e92056.jpg',
        'sellerId': 'user10',
        'sellerName': 'Maria Garcia',
        'location': 'Phoenix, AZ',
        'condition': 'Excellent',
        'mileage': 22000,
        'fuelType': 'Gasoline',
        'transmission': 'Automatic',
        'color': 'Gray',
        'features':
            '["Advanced Safety", "Apple CarPlay", "Android Auto", "Backup Camera", "Blind Spot Monitor", "Lane Assist"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isSold': 0,
      },
      {
        'id': '11',
        'make': 'Porsche',
        'model': '911 Carrera',
        'year': 2020,
        'price': 120000.0,
        'description':
            'Iconic Porsche 911 Carrera with exceptional performance and precision engineering. Low mileage, pristine condition. Includes sport chrono package, premium audio, and performance features.',
        'imageUrl':
            'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400',
        'sellerId': 'user11',
        'sellerName': 'Robert Taylor',
        'location': 'Las Vegas, NV',
        'condition': 'Excellent',
        'mileage': 18000,
        'fuelType': 'Gasoline',
        'transmission': 'Automatic',
        'color': 'Black',
        'features':
            '["Sport Chrono", "Premium Audio", "Performance Tires", "Carbon Fiber", "Heated Seats", "Navigation"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isSold': 0,
      },
      {
        'id': '12',
        'make': 'Subaru',
        'model': 'Outback',
        'year': 2021,
        'price': 32000.0,
        'description':
            'Reliable Subaru Outback with all-wheel drive capability. Perfect for outdoor adventures and daily commuting. Includes EyeSight safety system and spacious interior.',
        'imageUrl':
            'https://i.pinimg.com/736x/c8/01/0f/c8010f2804a7f206cac1715e60dc6bbc.jpg',
        'sellerId': 'user12',
        'sellerName': 'Jennifer Lee',
        'location': 'Denver, CO',
        'condition': 'Good',
        'mileage': 35000,
        'fuelType': 'Gasoline',
        'transmission': 'Automatic',
        'color': 'Silver',
        'features':
            '["AWD", "EyeSight Safety", "Apple CarPlay", "Android Auto", "Backup Camera", "Roof Rails"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isSold': 0,
      },
      {
        'id': '13',
        'make': 'Chevrolet',
        'model': 'Corvette Stingray',
        'year': 2021,
        'price': 75000.0,
        'description':
            'American muscle meets modern technology. Chevrolet Corvette Stingray with mid-engine design and exceptional performance. Includes premium interior and advanced driving modes.',
        'imageUrl':
            'https://i.pinimg.com/1200x/14/ba/60/14ba60f9563657254904b5ede6f4405f.jpg',
        'sellerId': 'user13',
        'sellerName': 'Michael Davis',
        'location': 'Detroit, MI',
        'condition': 'Excellent',
        'mileage': 12000,
        'fuelType': 'Gasoline',
        'transmission': 'Automatic',
        'color': 'Red',
        'features':
            '["Mid-Engine", "Performance Modes", "Premium Interior", "Heads-Up Display", "Bose Audio", "Performance Suspension"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isSold': 0,
      },
      {
        'id': '14',
        'make': 'Jaguar',
        'model': 'F-PACE',
        'year': 2020,
        'price': 48000.0,
        'description':
            'Luxury Jaguar F-PACE SUV with British elegance and performance. Features premium leather interior, panoramic sunroof, and advanced driver assistance systems.',
        'imageUrl':
            'https://i.pinimg.com/1200x/0a/f0/ab/0af0abe913fe355c17b714e54c862065.jpg',
        'sellerId': 'user14',
        'sellerName': 'Amanda Wilson',
        'location': 'Atlanta, GA',
        'condition': 'Good',
        'mileage': 42000,
        'fuelType': 'Gasoline',
        'transmission': 'Automatic',
        'color': 'Gray',
        'features':
            '["Premium Leather", "Panoramic Sunroof", "Navigation", "Premium Audio", "Heated Seats", "Lane Assist"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isSold': 0,
      },
      {
        'id': '15',
        'make': 'Nissan',
        'model': 'Leaf',
        'year': 2022,
        'price': 28000.0,
        'description':
            'Electric Nissan Leaf with zero emissions and great range. Perfect for eco-conscious drivers. Features ProPilot assist, e-Pedal, and spacious interior.',
        'imageUrl':
            'https://i.pinimg.com/736x/6e/3c/40/6e3c40fe599adb75efb9b5c0cccc015f.jpg',
        'sellerId': 'user15',
        'sellerName': 'David Chen',
        'location': 'Portland, OR',
        'condition': 'Excellent',
        'mileage': 8000,
        'fuelType': 'Electric',
        'transmission': 'Automatic',
        'color': 'White',
        'features':
            '["ProPilot Assist", "E-Pedal", "Apple CarPlay", "Android Auto", "360° Camera", "Wireless Charging"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isSold': 0,
      },
    ];

    for (final car in sampleCars) {
      await db.insert('cars', car);
    }

    // Sample users
    final sampleUsers = [
      {
        'id': 'admin',
        'name': 'Admin User',
        'email': 'admin@apex.com',
        'username': 'admin',
        'password': 'password',
        'phone': '+1-555-0000',
        'location': 'System',
        'avatarUrl':
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
        'favoriteCarIds': '[]',
        'listedCarIds': '[]',
        'createdAt': DateTime.now().toIso8601String(),
        'isVerified': 1,
        'isAdmin': 1,
      },
      {
        'id': 'user1',
        'name': 'John Doe',
        'email': 'john@example.com',
        'username': 'johndoe',
        'password': 'password123',
        'phone': '+1-555-0101',
        'location': 'New York, NY',
        'avatarUrl':
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
        'favoriteCarIds': '["2", "3"]',
        'listedCarIds': '["1"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isVerified': 1,
        'isAdmin': 0,
      },
      {
        'id': 'user2',
        'name': 'Jane Smith',
        'email': 'jane@example.com',
        'username': 'janesmith',
        'password': 'password123',
        'phone': '+1-555-0102',
        'location': 'Los Angeles, CA',
        'avatarUrl':
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
        'favoriteCarIds': '["1", "4"]',
        'listedCarIds': '["2"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isVerified': 1,
        'isAdmin': 0,
      },
      {
        'id': 'user3',
        'name': 'Mike Johnson',
        'email': 'mike@example.com',
        'username': 'mikejohnson',
        'password': 'password123',
        'phone': '+1-555-0103',
        'location': 'Chicago, IL',
        'avatarUrl':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        'favoriteCarIds': '["4", "5"]',
        'listedCarIds': '["3"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isVerified': 1,
        'isAdmin': 0,
      },
      {
        'id': 'user4',
        'name': 'Sarah Wilson',
        'email': 'sarah@example.com',
        'username': 'sarahwilson',
        'password': 'password123',
        'phone': '+1-555-0104',
        'location': 'San Francisco, CA',
        'avatarUrl':
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
        'favoriteCarIds': '["1", "6"]',
        'listedCarIds': '["4"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isVerified': 1,
        'isAdmin': 0,
      },
      {
        'id': 'user5',
        'name': 'David Brown',
        'email': 'david@example.com',
        'username': 'davidbrown',
        'password': 'password123',
        'phone': '+1-555-0105',
        'location': 'Miami, FL',
        'avatarUrl':
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
        'favoriteCarIds': '["2", "7"]',
        'listedCarIds': '["5"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isVerified': 1,
        'isAdmin': 0,
      },
      {
        'id': 'user6',
        'name': 'Emma Davis',
        'email': 'emma@example.com',
        'username': 'emmadavis',
        'password': 'password123',
        'phone': '+1-555-0106',
        'location': 'Dallas, TX',
        'avatarUrl':
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
        'favoriteCarIds': '["3", "8"]',
        'listedCarIds': '["6"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isVerified': 1,
        'isAdmin': 0,
      },
      {
        'id': 'user7',
        'name': 'Alex Chen',
        'email': 'alex@example.com',
        'username': 'alexchen',
        'password': 'password123',
        'phone': '+1-555-0107',
        'location': 'Seattle, WA',
        'avatarUrl':
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
        'favoriteCarIds': '["5", "9"]',
        'listedCarIds': '["7"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isVerified': 1,
        'isAdmin': 0,
      },
      {
        'id': 'user8',
        'name': 'Lisa Wang',
        'email': 'lisa@example.com',
        'username': 'lisawang',
        'password': 'password123',
        'phone': '+1-555-0108',
        'location': 'Boston, MA',
        'avatarUrl':
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
        'favoriteCarIds': '["4", "10"]',
        'listedCarIds': '["8"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isVerified': 1,
        'isAdmin': 0,
      },
      {
        'id': 'user9',
        'name': 'Carlos Rodriguez',
        'email': 'carlos@example.com',
        'username': 'carlosrodriguez',
        'password': 'password123',
        'phone': '+1-555-0109',
        'location': 'Austin, TX',
        'avatarUrl':
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
        'favoriteCarIds': '["1", "6"]',
        'listedCarIds': '["9"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isVerified': 1,
        'isAdmin': 0,
      },
      {
        'id': 'user10',
        'name': 'Maria Garcia',
        'email': 'maria@example.com',
        'username': 'mariagarcia',
        'password': 'password123',
        'phone': '+1-555-0110',
        'location': 'Phoenix, AZ',
        'avatarUrl':
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
        'favoriteCarIds': '["2", "7"]',
        'listedCarIds': '["10"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isVerified': 1,
        'isAdmin': 0,
      },
      {
        'id': 'user11',
        'name': 'Robert Taylor',
        'email': 'robert@example.com',
        'username': 'roberttaylor',
        'password': 'password123',
        'phone': '+1-555-0111',
        'location': 'Las Vegas, NV',
        'avatarUrl':
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
        'favoriteCarIds': '["11"]',
        'listedCarIds': '["11"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isVerified': 1,
        'isAdmin': 0,
      },
      {
        'id': 'user12',
        'name': 'Jennifer Lee',
        'email': 'jennifer@example.com',
        'username': 'jenniferlee',
        'password': 'password123',
        'phone': '+1-555-0112',
        'location': 'Denver, CO',
        'avatarUrl':
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
        'favoriteCarIds': '["12"]',
        'listedCarIds': '["12"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isVerified': 1,
        'isAdmin': 0,
      },
      {
        'id': 'user13',
        'name': 'Michael Davis',
        'email': 'michael@example.com',
        'username': 'michaeldavis',
        'password': 'password123',
        'phone': '+1-555-0113',
        'location': 'Detroit, MI',
        'avatarUrl':
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
        'favoriteCarIds': '["13"]',
        'listedCarIds': '["13"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isVerified': 1,
        'isAdmin': 0,
      },
      {
        'id': 'user14',
        'name': 'Amanda Wilson',
        'email': 'amanda@example.com',
        'username': 'amandawilson',
        'password': 'password123',
        'phone': '+1-555-0114',
        'location': 'Atlanta, GA',
        'avatarUrl':
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
        'favoriteCarIds': '["14"]',
        'listedCarIds': '["14"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isVerified': 1,
        'isAdmin': 0,
      },
      {
        'id': 'user15',
        'name': 'David Chen',
        'email': 'david@example.com',
        'username': 'davidchen',
        'password': 'password123',
        'phone': '+1-555-0115',
        'location': 'Portland, OR',
        'avatarUrl':
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
        'favoriteCarIds': '["15"]',
        'listedCarIds': '["15"]',
        'createdAt': DateTime.now().toIso8601String(),
        'isVerified': 1,
        'isAdmin': 0,
      },
    ];

    for (final user in sampleUsers) {
      await db.insert('users', user);
    }
  }

  // Force reset database (for development/testing)
  Future<void> resetDatabase() async {
    String path = join(await getDatabasesPath(), 'car_trading.db');
    await deleteDatabase(path);
    _database = null;
    await database; // This will recreate the database
  }

  // Force reset database with new schema
  Future<void> forceResetDatabase() async {
    String path = join(await getDatabasesPath(), 'car_trading.db');
    await deleteDatabase(path);
    _database = null;
    await database; // This will recreate the database with new schema
  }

  // Complete database reset (for development/testing)
  Future<void> completeResetDatabase() async {
    String path = join(await getDatabasesPath(), 'car_trading.db');
    debugPrint('DatabaseService: Starting complete database reset...');

    // Close existing database connection
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    // Delete the database file
    await deleteDatabase(path);
    debugPrint('DatabaseService: Database file deleted');

    // Force recreation with new schema
    final newDb = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    debugPrint('DatabaseService: New database created with schema');

    // Verify sample data was inserted
    final carCount = await newDb.rawQuery('SELECT COUNT(*) as count FROM cars');
    final count = carCount.first['count'] as int;
    debugPrint('DatabaseService: New database has $count cars');

    await newDb.close();
    debugPrint('Database completely reset and recreated');
  }

  // Check and fix database issues
  Future<void> checkAndFixDatabase() async {
    debugPrint('DatabaseService: Checking database health...');
    final db = await database;

    try {
      // Check cars table
      final carCount = await db.rawQuery('SELECT COUNT(*) as count FROM cars');
      final carsCount = carCount.first['count'] as int;
      debugPrint('DatabaseService: Cars in database: $carsCount');

      // Check users table
      final userCount =
          await db.rawQuery('SELECT COUNT(*) as count FROM users');
      final usersCount = userCount.first['count'] as int;
      debugPrint('DatabaseService: Users in database: $usersCount');

      if (carsCount == 0 || usersCount == 0) {
        debugPrint('DatabaseService: Database is missing data, fixing...');
        await completeResetDatabase();
      } else {
        debugPrint('DatabaseService: Database is healthy');
      }
    } catch (e) {
      debugPrint('DatabaseService: Database check failed: $e');
      await completeResetDatabase();
    }
  }

  // Recreate sample users if needed
  Future<void> ensureSampleUsers() async {
    final db = await database;
    final usersExist = await hasUsers();

    if (!usersExist) {
      debugPrint('No users found, recreating sample users...');
      await _insertSampleData(db);
    }
  }

  // Ensure database is initialized
  Future<void> ensureInitialized() async {
    await database;
  }

  // Check if database has users
  Future<bool> hasUsers() async {
    final db = await database;
    final result = await db.query('users', limit: 1);
    return result.isNotEmpty;
  }

  // Check if database has cars
  Future<bool> hasCars() async {
    final db = await database;
    final result = await db.query('cars', limit: 1);
    return result.isNotEmpty;
  }

  // Car operations
  Future<List<Car>> getAllCars() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cars');
    debugPrint('DatabaseService: Found ${maps.length} cars in database');

    if (maps.isNotEmpty) {
      debugPrint('DatabaseService: First car data: ${maps.first}');
    }

    final cars = List.generate(maps.length, (i) {
      try {
        return Car.fromJson(maps[i]);
      } catch (e) {
        debugPrint('DatabaseService: Error parsing car at index $i: $e');
        debugPrint('DatabaseService: Raw data: ${maps[i]}');
        rethrow;
      }
    });

    debugPrint('DatabaseService: Successfully parsed ${cars.length} cars');
    return cars;
  }

  Future<Car?> getCarById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cars',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Car.fromJson(maps.first);
    }
    return null;
  }

  Future<void> insertCar(Car car) async {
    final db = await database;
    await db.insert('cars', car.toJson());
  }

  Future<void> updateCar(Car car) async {
    final db = await database;
    await db.update(
      'cars',
      car.toJson(),
      where: 'id = ?',
      whereArgs: [car.id],
    );
  }

  Future<void> deleteCar(String id) async {
    final db = await database;
    await db.delete(
      'cars',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Add new car
  Future<void> addCar(Car car) async {
    final db = await database;
    await db.insert('cars', car.toJson());
  }

  // Generate unique ID for new cars
  Future<String> generateCarId() async {
    final db = await database;
    final result = await db
        .rawQuery('SELECT MAX(CAST(id AS INTEGER)) as max_id FROM cars');
    final maxId = result.first['max_id'] as int?;
    return (maxId != null ? maxId + 1 : 1).toString();
  }

  // Generate unique ID for new users
  Future<String> generateUserId() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT MAX(CAST(id AS INTEGER)) as max_id FROM users WHERE id != "admin"');
    final maxId = result.first['max_id'] as int?;
    return (maxId != null ? maxId + 1 : 1).toString();
  }

  // Update existing car

  // User operations
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromJson(maps[i]));
  }

  Future<User?> getUserById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toJson());
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}
