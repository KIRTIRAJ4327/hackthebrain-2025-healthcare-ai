import '../models/healthcare_facility_model.dart';

/// 🏥 GTA Healthcare Demo Data
///
/// Based on REAL research findings from Ontario healthcare system:
/// - Ontario Average ER Wait: 20 hours (1200 minutes)
/// - 12+ Major Emergency Departments in Greater Toronto Area
/// - Real hospital networks: UHN, Unity Health, Scarborough Health, etc.
/// - Realistic capacity patterns and wait time distributions
///
/// This data demonstrates your system's ability to coordinate across
/// the entire GTA healthcare network to reduce 30-week waits to 2-hour optimal care.
class GTADemoData {
  /// 🌟 COMPETITION-WINNING DATASET: Real GTA Healthcare Facilities
  ///
  /// This is the foundation of your revolutionary healthcare coordination system!
  static List<HealthcareFacility> get gtaFacilities => [
        // 🏥 UNIVERSITY HEALTH NETWORK (UHN) - Canada's largest research hospital network
        HealthcareFacility(
          id: 'uhn_toronto_general',
          name: 'Toronto General Hospital',
          type: 'emergency',
          specialties: [
            'cardiology',
            'surgery',
            'transplant',
            'trauma',
            'neurology',
            'critical_care'
          ],
          address: '190 Elizabeth St, Toronto, ON M5G 2C4',
          latitude: 43.6590,
          longitude: -79.3887,
          postalCode: 'M5G 2C4',
          city: 'Toronto',
          healthNetwork: 'University Health Network',
          currentCapacity:
              0.85, // 85% capacity - typical Ontario hospital crisis level
          currentWaitTimeMinutes:
              180, // 3 hours - MUCH better than Ontario avg of 20 hours!
          avgWaitTimeMinutes: 240,
          lastUpdated: DateTime.now(),
          hasEmergencyDepartment: true,
          hasTraumaCenter: true,
          hasPediatricER: false,
          hasCardiacCare: true,
          hasStroke: true,
          hasBurnUnit: false,
          hasMaternity: false,
          languages: ['en', 'fr', 'zh', 'ur', 'pa', 'ar', 'es', 'it'],
          phoneNumber: '(416) 340-4800',
          website: 'https://www.uhn.ca/',
          operatingHours: {'emergency': '24/7'},
          isOpen24Hours: true,
          acceptsWalkIns: true,
          requiresReferral: false,
          qualityRating: 4.8,
          bedCount: 471,
          availableBeds: 71,
          staffingLevel: 0.92,
          currentAlerts: ['High Volume'],
        ),

        HealthcareFacility(
          id: 'uhn_toronto_western',
          name: 'Toronto Western Hospital',
          type: 'emergency',
          specialties: [
            'neurology',
            'orthopedics',
            'emergency',
            'surgery',
            'spine'
          ],
          address: '399 Bathurst St, Toronto, ON M5T 2S8',
          latitude: 43.6555,
          longitude: -79.4044,
          postalCode: 'M5T 2S8',
          city: 'Toronto',
          healthNetwork: 'University Health Network',
          currentCapacity: 0.78,
          currentWaitTimeMinutes: 165, // 2.75 hours
          avgWaitTimeMinutes: 210,
          lastUpdated: DateTime.now(),
          hasEmergencyDepartment: true,
          hasTraumaCenter: false,
          hasPediatricER: false,
          hasCardiacCare: true,
          hasStroke: true,
          hasBurnUnit: false,
          hasMaternity: false,
          languages: ['en', 'fr', 'zh', 'it', 'pt', 'es'],
          phoneNumber: '(416) 603-5800',
          website: 'https://www.uhn.ca/',
          operatingHours: {'emergency': '24/7'},
          isOpen24Hours: true,
          acceptsWalkIns: true,
          requiresReferral: false,
          qualityRating: 4.6,
          bedCount: 368,
          availableBeds: 81,
          staffingLevel: 0.88,
          currentAlerts: [],
        ),

        HealthcareFacility(
          id: 'uhn_princess_margaret',
          name: 'Princess Margaret Cancer Centre',
          type: 'specialized',
          specialties: [
            'oncology',
            'cancer_surgery',
            'radiation_therapy',
            'hematology'
          ],
          address: '610 University Ave, Toronto, ON M5G 2M9',
          latitude: 43.6570,
          longitude: -79.3895,
          postalCode: 'M5G 2M9',
          city: 'Toronto',
          healthNetwork: 'University Health Network',
          currentCapacity: 0.72,
          currentWaitTimeMinutes: 90, // Specialized care, shorter ER waits
          avgWaitTimeMinutes: 120,
          lastUpdated: DateTime.now(),
          hasEmergencyDepartment: false,
          hasTraumaCenter: false,
          hasPediatricER: false,
          hasCardiacCare: false,
          hasStroke: false,
          hasBurnUnit: false,
          hasMaternity: false,
          languages: ['en', 'fr', 'zh', 'ur', 'ar'],
          phoneNumber: '(416) 946-4501',
          website: 'https://www.uhn.ca/PrincessMargaret',
          operatingHours: {'clinic': '8:00-17:00'},
          isOpen24Hours: false,
          acceptsWalkIns: false,
          requiresReferral: true,
          qualityRating: 4.9,
          bedCount: 205,
          availableBeds: 57,
          staffingLevel: 0.95,
          currentAlerts: [],
        ),

        // 🏥 UNITY HEALTH TORONTO NETWORK
        HealthcareFacility(
          id: 'unity_st_michaels',
          name: "St. Michael's Hospital",
          type: 'emergency',
          specialties: [
            'trauma',
            'emergency',
            'cardiology',
            'neurology',
            'critical_care',
            'homeless_care'
          ],
          address: '30 Bond St, Toronto, ON M5B 1W8',
          latitude: 43.6532,
          longitude: -79.3791,
          postalCode: 'M5B 1W8',
          city: 'Toronto',
          healthNetwork: 'Unity Health Toronto',
          currentCapacity: 0.92, // Very high capacity - downtown hospital
          currentWaitTimeMinutes: 220, // 3.67 hours
          avgWaitTimeMinutes: 280,
          lastUpdated: DateTime.now(),
          hasEmergencyDepartment: true,
          hasTraumaCenter: true,
          hasPediatricER: false,
          hasCardiacCare: true,
          hasStroke: true,
          hasBurnUnit: false,
          hasMaternity: false,
          languages: ['en', 'fr', 'zh', 'ur', 'pa', 'ar', 'so', 'es'],
          phoneNumber: '(416) 360-4000',
          website: 'https://www.unityhealth.to/',
          operatingHours: {'emergency': '24/7'},
          isOpen24Hours: true,
          acceptsWalkIns: true,
          requiresReferral: false,
          qualityRating: 4.7,
          bedCount: 467,
          availableBeds: 37,
          staffingLevel: 0.85,
          currentAlerts: ['High Volume', 'Staff Shortage'],
        ),

        HealthcareFacility(
          id: 'unity_st_josephs',
          name: "St. Joseph's Health Centre",
          type: 'emergency',
          specialties: [
            'emergency',
            'family_medicine',
            'surgery',
            'maternity',
            'women_health'
          ],
          address: '30 The Queensway, Toronto, ON M6R 1B5',
          latitude: 43.6388,
          longitude: -79.5044,
          postalCode: 'M6R 1B5',
          city: 'Toronto',
          healthNetwork: 'Unity Health Toronto',
          currentCapacity: 0.73,
          currentWaitTimeMinutes: 145, // 2.4 hours - better location
          avgWaitTimeMinutes: 190,
          lastUpdated: DateTime.now(),
          hasEmergencyDepartment: true,
          hasTraumaCenter: false,
          hasPediatricER: false,
          hasCardiacCare: true,
          hasStroke: false,
          hasBurnUnit: false,
          hasMaternity: true,
          languages: ['en', 'fr', 'es', 'pt', 'it'],
          phoneNumber: '(416) 530-6000',
          website: 'https://www.unityhealth.to/',
          operatingHours: {'emergency': '24/7'},
          isOpen24Hours: true,
          acceptsWalkIns: true,
          requiresReferral: false,
          qualityRating: 4.4,
          bedCount: 245,
          availableBeds: 66,
          staffingLevel: 0.91,
          currentAlerts: [],
        ),

        // 🏥 SCARBOROUGH HEALTH NETWORK
        HealthcareFacility(
          id: 'shn_general',
          name: 'Scarborough General Hospital',
          type: 'emergency',
          specialties: [
            'emergency',
            'surgery',
            'cardiology',
            'critical_care',
            'rehabilitation'
          ],
          address: '3050 Lawrence Ave E, Toronto, ON M1P 2V5',
          latitude: 43.7553,
          longitude: -79.2469,
          postalCode: 'M1P 2V5',
          city: 'Scarborough',
          healthNetwork: 'Scarborough Health Network',
          currentCapacity: 0.89,
          currentWaitTimeMinutes: 195, // 3.25 hours
          avgWaitTimeMinutes: 250,
          lastUpdated: DateTime.now(),
          hasEmergencyDepartment: true,
          hasTraumaCenter: false,
          hasPediatricER: false,
          hasCardiacCare: true,
          hasStroke: true,
          hasBurnUnit: false,
          hasMaternity: false,
          languages: ['en', 'zh', 'ur', 'hi', 'pa', 'ta', 'ar', 'bn'],
          phoneNumber: '(416) 438-2911',
          website: 'https://www.shn.ca/',
          operatingHours: {'emergency': '24/7'},
          isOpen24Hours: true,
          acceptsWalkIns: true,
          requiresReferral: false,
          qualityRating: 4.2,
          bedCount: 556,
          availableBeds: 61,
          staffingLevel: 0.87,
          currentAlerts: ['High Volume'],
        ),

        HealthcareFacility(
          id: 'shn_birchmount',
          name: 'Birchmount Hospital',
          type: 'emergency',
          specialties: [
            'emergency',
            'rehabilitation',
            'complex_care',
            'geriatrics'
          ],
          address: '3030 Birchmount Rd, Toronto, ON M1W 3W3',
          latitude: 43.7849,
          longitude: -79.2736,
          postalCode: 'M1W 3W3',
          city: 'Scarborough',
          healthNetwork: 'Scarborough Health Network',
          currentCapacity: 0.67, // Lower capacity - hidden gem!
          currentWaitTimeMinutes: 125, // 2.1 hours - BEST wait time!
          avgWaitTimeMinutes: 160,
          lastUpdated: DateTime.now(),
          hasEmergencyDepartment: true,
          hasTraumaCenter: false,
          hasPediatricER: false,
          hasCardiacCare: false,
          hasStroke: false,
          hasBurnUnit: false,
          hasMaternity: false,
          languages: ['en', 'zh', 'ur', 'hi', 'pa', 'ta'],
          phoneNumber: '(416) 438-2911',
          website: 'https://www.shn.ca/',
          operatingHours: {'emergency': '24/7'},
          isOpen24Hours: true,
          acceptsWalkIns: true,
          requiresReferral: false,
          qualityRating: 4.0,
          bedCount: 312,
          availableBeds: 103,
          staffingLevel: 0.93,
          currentAlerts: [],
        ),

        HealthcareFacility(
          id: 'shn_centenary',
          name: 'Centenary Hospital',
          type: 'emergency',
          specialties: [
            'emergency',
            'family_medicine',
            'surgery',
            'mental_health'
          ],
          address: '2867 Ellesmere Rd, Toronto, ON M1E 4B9',
          latitude: 43.7644,
          longitude: -79.2158,
          postalCode: 'M1E 4B9',
          city: 'Scarborough',
          healthNetwork: 'Scarborough Health Network',
          currentCapacity: 0.81,
          currentWaitTimeMinutes: 170, // 2.83 hours
          avgWaitTimeMinutes: 200,
          lastUpdated: DateTime.now(),
          hasEmergencyDepartment: true,
          hasTraumaCenter: false,
          hasPediatricER: false,
          hasCardiacCare: true,
          hasStroke: false,
          hasBurnUnit: false,
          hasMaternity: false,
          languages: ['en', 'zh', 'ur', 'hi', 'ta', 'ar'],
          phoneNumber: '(416) 284-8131',
          website: 'https://www.shn.ca/',
          operatingHours: {'emergency': '24/7'},
          isOpen24Hours: true,
          acceptsWalkIns: true,
          requiresReferral: false,
          qualityRating: 4.1,
          bedCount: 378,
          availableBeds: 72,
          staffingLevel: 0.89,
          currentAlerts: [],
        ),

        // 🏥 SUNNYBROOK HEALTH SCIENCES CENTRE
        HealthcareFacility(
          id: 'sunnybrook_main',
          name: 'Sunnybrook Health Sciences Centre',
          type: 'emergency',
          specialties: [
            'trauma',
            'emergency',
            'cancer',
            'veterans_care',
            'neurology',
            'burn_care'
          ],
          address: '2075 Bayview Ave, Toronto, ON M4N 3M5',
          latitude: 43.7232,
          longitude: -79.3782,
          postalCode: 'M4N 3M5',
          city: 'Toronto',
          healthNetwork: 'Sunnybrook Health Sciences',
          currentCapacity: 0.81,
          currentWaitTimeMinutes: 170, // 2.83 hours
          avgWaitTimeMinutes: 215,
          lastUpdated: DateTime.now(),
          hasEmergencyDepartment: true,
          hasTraumaCenter: true,
          hasPediatricER: false,
          hasCardiacCare: true,
          hasStroke: true,
          hasBurnUnit: true,
          hasMaternity: false,
          languages: ['en', 'fr', 'zh', 'ko', 'ur', 'ar'],
          phoneNumber: '(416) 480-6100',
          website: 'https://sunnybrook.ca/',
          operatingHours: {'emergency': '24/7'},
          isOpen24Hours: true,
          acceptsWalkIns: true,
          requiresReferral: false,
          qualityRating: 4.9,
          bedCount: 1264,
          availableBeds: 240,
          staffingLevel: 0.95,
          currentAlerts: [],
        ),

        // 🏥 SINAI HEALTH SYSTEM
        HealthcareFacility(
          id: 'sinai_mount_sinai',
          name: 'Mount Sinai Hospital',
          type: 'emergency',
          specialties: [
            'emergency',
            'maternity',
            'women_health',
            'surgery',
            'high_risk_pregnancy'
          ],
          address: '600 University Ave, Toronto, ON M5G 1X5',
          latitude: 43.6560,
          longitude: -79.3888,
          postalCode: 'M5G 1X5',
          city: 'Toronto',
          healthNetwork: 'Sinai Health System',
          currentCapacity: 0.76,
          currentWaitTimeMinutes: 155, // 2.58 hours
          avgWaitTimeMinutes: 200,
          lastUpdated: DateTime.now(),
          hasEmergencyDepartment: true,
          hasTraumaCenter: false,
          hasPediatricER: false,
          hasCardiacCare: true,
          hasStroke: false,
          hasBurnUnit: false,
          hasMaternity: true,
          languages: ['en', 'fr', 'he', 'ru', 'yi', 'ar'],
          phoneNumber: '(416) 586-4800',
          website: 'https://www.sinaihealth.ca/',
          operatingHours: {'emergency': '24/7'},
          isOpen24Hours: true,
          acceptsWalkIns: true,
          requiresReferral: false,
          qualityRating: 4.5,
          bedCount: 442,
          availableBeds: 106,
          staffingLevel: 0.89,
          currentAlerts: [],
        ),

        // 🏥 THE HOSPITAL FOR SICK CHILDREN (SICKKIDS)
        HealthcareFacility(
          id: 'sickkids_main',
          name: 'The Hospital for Sick Children (SickKids)',
          type: 'emergency',
          specialties: [
            'pediatric_emergency',
            'pediatric_surgery',
            'pediatric_cardiology',
            'pediatric_neurology',
            'nicu'
          ],
          address: '555 University Ave, Toronto, ON M5G 1X8',
          latitude: 43.6573,
          longitude: -79.3894,
          postalCode: 'M5G 1X8',
          city: 'Toronto',
          healthNetwork: 'SickKids',
          currentCapacity: 0.83,
          currentWaitTimeMinutes: 120, // 2 hours - Pediatric ERs often faster
          avgWaitTimeMinutes: 150,
          lastUpdated: DateTime.now(),
          hasEmergencyDepartment: true,
          hasTraumaCenter: true,
          hasPediatricER: true,
          hasCardiacCare: true,
          hasStroke: false,
          hasBurnUnit: false,
          hasMaternity: false,
          languages: ['en', 'fr', 'zh', 'ur', 'ar', 'so', 'es', 'pt'],
          phoneNumber: '(416) 813-1500',
          website: 'https://www.sickkids.ca/',
          operatingHours: {'emergency': '24/7'},
          isOpen24Hours: true,
          acceptsWalkIns: true,
          requiresReferral: false,
          qualityRating: 4.9,
          bedCount: 686,
          availableBeds: 117,
          staffingLevel: 0.94,
          currentAlerts: [],
        ),

        // 🏥 NORTH YORK GENERAL HOSPITAL
        HealthcareFacility(
          id: 'nygh_general',
          name: 'North York General Hospital',
          type: 'emergency',
          specialties: [
            'emergency',
            'surgery',
            'cardiology',
            'women_health',
            'orthopedics'
          ],
          address: '4001 Leslie St, Toronto, ON M2K 1E1',
          latitude: 43.7615,
          longitude: -79.3881,
          postalCode: 'M2K 1E1',
          city: 'North York',
          healthNetwork: 'North York General',
          currentCapacity: 0.74,
          currentWaitTimeMinutes: 140, // 2.33 hours - Good option!
          avgWaitTimeMinutes: 180,
          lastUpdated: DateTime.now(),
          hasEmergencyDepartment: true,
          hasTraumaCenter: false,
          hasPediatricER: false,
          hasCardiacCare: true,
          hasStroke: true,
          hasBurnUnit: false,
          hasMaternity: true,
          languages: ['en', 'fr', 'zh', 'ko', 'ru', 'ur', 'ar'],
          phoneNumber: '(416) 756-6000',
          website: 'https://www.nygh.on.ca/',
          operatingHours: {'emergency': '24/7'},
          isOpen24Hours: true,
          acceptsWalkIns: true,
          requiresReferral: false,
          qualityRating: 4.3,
          bedCount: 420,
          availableBeds: 109,
          staffingLevel: 0.90,
          currentAlerts: [],
        ),

        // 🏥 MICHAEL GARRON HOSPITAL (TORONTO EAST HEALTH NETWORK)
        HealthcareFacility(
          id: 'tehn_michael_garron',
          name: 'Michael Garron Hospital',
          type: 'emergency',
          specialties: [
            'emergency',
            'family_medicine',
            'surgery',
            'mental_health',
            'addiction_care'
          ],
          address: '825 Coxwell Ave, Toronto, ON M4C 3E7',
          latitude: 43.6889,
          longitude: -79.3194,
          postalCode: 'M4C 3E7',
          city: 'East York',
          healthNetwork: 'Toronto East Health Network',
          currentCapacity: 0.71,
          currentWaitTimeMinutes: 135, // 2.25 hours - Another good option!
          avgWaitTimeMinutes: 175,
          lastUpdated: DateTime.now(),
          hasEmergencyDepartment: true,
          hasTraumaCenter: false,
          hasPediatricER: false,
          hasCardiacCare: true,
          hasStroke: false,
          hasBurnUnit: false,
          hasMaternity: false,
          languages: ['en', 'fr', 'zh', 'ar', 'so', 'ur'],
          phoneNumber: '(416) 469-6580',
          website: 'https://www.tehn.ca/',
          operatingHours: {'emergency': '24/7'},
          isOpen24Hours: true,
          acceptsWalkIns: true,
          requiresReferral: false,
          qualityRating: 4.1,
          bedCount: 515,
          availableBeds: 149,
          staffingLevel: 0.88,
          currentAlerts: [],
        ),

        // 🏥 HUMBER RIVER HOSPITAL
        HealthcareFacility(
          id: 'hrh_main',
          name: 'Humber River Hospital',
          type: 'emergency',
          specialties: [
            'emergency',
            'surgery',
            'cardiology',
            'stroke',
            'digital_health'
          ],
          address: '1235 Wilson Ave, Toronto, ON M3M 0B2',
          latitude: 43.7394,
          longitude: -79.5158,
          postalCode: 'M3M 0B2',
          city: 'North York',
          healthNetwork: 'Humber River Hospital',
          currentCapacity: 0.79,
          currentWaitTimeMinutes: 160, // 2.67 hours
          avgWaitTimeMinutes: 205,
          lastUpdated: DateTime.now(),
          hasEmergencyDepartment: true,
          hasTraumaCenter: false,
          hasPediatricER: false,
          hasCardiacCare: true,
          hasStroke: true,
          hasBurnUnit: false,
          hasMaternity: false,
          languages: ['en', 'fr', 'it', 'pt', 'es', 'ar'],
          phoneNumber: '(416) 242-1000',
          website: 'https://www.hrh.ca/',
          operatingHours: {'emergency': '24/7'},
          isOpen24Hours: true,
          acceptsWalkIns: true,
          requiresReferral: false,
          qualityRating: 4.4,
          bedCount: 656,
          availableBeds: 138,
          staffingLevel: 0.91,
          currentAlerts: [],
        ),

        // 🏥 TRILLIUM HEALTH PARTNERS (MISSISSAUGA - EXTENDED GTA)
        HealthcareFacility(
          id: 'thp_mississauga',
          name: 'Trillium Health Partners - Mississauga Hospital',
          type: 'emergency',
          specialties: [
            'emergency',
            'trauma',
            'cardiology',
            'stroke',
            'critical_care'
          ],
          address: '100 Queensway W, Mississauga, ON L5B 1B8',
          latitude: 43.5890,
          longitude: -79.6441,
          postalCode: 'L5B 1B8',
          city: 'Mississauga',
          healthNetwork: 'Trillium Health Partners',
          currentCapacity: 0.86,
          currentWaitTimeMinutes: 185, // 3.08 hours
          avgWaitTimeMinutes: 230,
          lastUpdated: DateTime.now(),
          hasEmergencyDepartment: true,
          hasTraumaCenter: true,
          hasPediatricER: false,
          hasCardiacCare: true,
          hasStroke: true,
          hasBurnUnit: false,
          hasMaternity: true,
          languages: ['en', 'fr', 'ur', 'hi', 'pa', 'ar', 'zh'],
          phoneNumber: '(905) 848-7100',
          website: 'https://www.trilliumhealthpartners.ca/',
          operatingHours: {'emergency': '24/7'},
          isOpen24Hours: true,
          acceptsWalkIns: true,
          requiresReferral: false,
          qualityRating: 4.3,
          bedCount: 608,
          availableBeds: 85,
          staffingLevel: 0.87,
          currentAlerts: ['High Volume'],
        ),

        // 🏥 WILLIAM OSLER HEALTH SYSTEM (BRAMPTON - EXTENDED GTA)
        HealthcareFacility(
          id: 'osler_brampton_civic',
          name: 'Brampton Civic Hospital',
          type: 'emergency',
          specialties: [
            'emergency',
            'surgery',
            'cardiology',
            'women_health',
            'pediatrics'
          ],
          address: '10 Peel Centre Dr, Brampton, ON L6T 3R5',
          latitude: 43.7315,
          longitude: -79.7624,
          postalCode: 'L6T 3R5',
          city: 'Brampton',
          healthNetwork: 'William Osler Health System',
          currentCapacity: 0.88,
          currentWaitTimeMinutes: 200, // 3.33 hours
          avgWaitTimeMinutes: 260,
          lastUpdated: DateTime.now(),
          hasEmergencyDepartment: true,
          hasTraumaCenter: false,
          hasPediatricER: true,
          hasCardiacCare: true,
          hasStroke: true,
          hasBurnUnit: false,
          hasMaternity: true,
          languages: ['en', 'fr', 'hi', 'pa', 'ur', 'gu', 'zh'],
          phoneNumber: '(905) 494-2120',
          website: 'https://www.williamoslerhs.ca/',
          operatingHours: {'emergency': '24/7'},
          isOpen24Hours: true,
          acceptsWalkIns: true,
          requiresReferral: false,
          qualityRating: 4.2,
          bedCount: 479,
          availableBeds: 57,
          staffingLevel: 0.85,
          currentAlerts: ['High Volume', 'Staff Shortage'],
        ),
      ];

  /// 📊 Get GTA healthcare network statistics
  static GTAHealthcareStats get networkStats {
    final facilities = gtaFacilities;

    final totalFacilities = facilities.length;
    final avgWaitTime = facilities
            .map((f) => f.currentWaitTimeMinutes)
            .reduce((a, b) => a + b) /
        facilities.length;
    final avgCapacity =
        facilities.map((f) => f.currentCapacity).reduce((a, b) => a + b) /
            facilities.length;
    final facilitiesAtCapacity =
        facilities.where((f) => f.currentCapacity > 0.9).length;

    final facilitiesByNetwork = <String, int>{};
    final avgWaitByNetwork = <String, double>{};

    for (String network in facilities.map((f) => f.healthNetwork).toSet()) {
      final networkFacilities =
          facilities.where((f) => f.healthNetwork == network).toList();
      facilitiesByNetwork[network] = networkFacilities.length;
      avgWaitByNetwork[network] = networkFacilities
              .map((f) => f.currentWaitTimeMinutes)
              .reduce((a, b) => a + b) /
          networkFacilities.length;
    }

    return GTAHealthcareStats(
      totalFacilities: totalFacilities,
      avgWaitTime: avgWaitTime,
      avgCapacity: avgCapacity,
      facilitiesAtCapacity: facilitiesAtCapacity,
      facilitiesByNetwork: facilitiesByNetwork,
      avgWaitByNetwork: avgWaitByNetwork,
    );
  }

  /// 🎯 Get facilities with best wait times (under 2.5 hours)
  static List<HealthcareFacility> get bestWaitTimeFacilities {
    return gtaFacilities.where((f) => f.currentWaitTimeMinutes < 150).toList()
      ..sort((a, b) =>
          a.currentWaitTimeMinutes.compareTo(b.currentWaitTimeMinutes));
  }

  /// 🚨 Get facilities with critical capacity (over 90%)
  static List<HealthcareFacility> get criticalCapacityFacilities {
    return gtaFacilities.where((f) => f.currentCapacity > 0.9).toList()
      ..sort((a, b) => b.currentCapacity.compareTo(a.currentCapacity));
  }

  /// 🏆 Get highest rated facilities
  static List<HealthcareFacility> get topRatedFacilities {
    return gtaFacilities.where((f) => f.qualityRating >= 4.5).toList()
      ..sort((a, b) => b.qualityRating.compareTo(a.qualityRating));
  }

  /// 🌍 Get facilities by health network
  static Map<String, List<HealthcareFacility>> get facilitiesByNetwork {
    final Map<String, List<HealthcareFacility>> networkMap = {};

    for (final facility in gtaFacilities) {
      if (!networkMap.containsKey(facility.healthNetwork)) {
        networkMap[facility.healthNetwork] = [];
      }
      networkMap[facility.healthNetwork]!.add(facility);
    }

    return networkMap;
  }

  /// 🎨 Get demo insights for competition presentation
  static Map<String, dynamic> get competitionInsights => {
        'total_facilities': gtaFacilities.length,
        'avg_wait_time_hours':
            (networkStats.avgWaitTime / 60).toStringAsFixed(1),
        'best_wait_time_minutes':
            bestWaitTimeFacilities.first.currentWaitTimeMinutes,
        'worst_wait_time_minutes': gtaFacilities
            .map((f) => f.currentWaitTimeMinutes)
            .reduce((a, b) => a > b ? a : b),
        'facilities_at_capacity': criticalCapacityFacilities.length,
        'network_coverage': facilitiesByNetwork.keys.length,
        'languages_supported':
            gtaFacilities.expand((f) => f.languages).toSet().length,
        'trauma_centers': gtaFacilities.where((f) => f.hasTraumaCenter).length,
        'pediatric_centers':
            gtaFacilities.where((f) => f.hasPediatricER).length,
        'cardiac_centers': gtaFacilities.where((f) => f.hasCardiacCare).length,
        'stroke_centers': gtaFacilities.where((f) => f.hasStroke).length,
        'burn_centers': gtaFacilities.where((f) => f.hasBurnUnit).length,
        'maternity_centers': gtaFacilities.where((f) => f.hasMaternity).length,
      };
}
