import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../models/incident_model.dart';
import '../models/telemetry_model.dart';
import '../providers/incident_provider.dart';
import '../providers/telemetry_provider.dart';
import '../theme/app_theme.dart';

class FleetMapView extends ConsumerStatefulWidget {
  final double height;
  final bool isOfficerTerminal;
  final TelemetryModel? focusedVehicle;

  const FleetMapView({
    super.key,
    this.height = 360,
    this.isOfficerTerminal = false,
    this.focusedVehicle,
  });

  @override
  ConsumerState<FleetMapView> createState() => _FleetMapViewState();
}

class _FleetMapViewState extends ConsumerState<FleetMapView> {
  final MapController _mapController = MapController();
  bool _isRadarMode = false;
  double _currentZoom = 11.5;
  LatLng _currentCenter = const LatLng(32.7804, 72.7058); // Kallar Kahar / Salt Range KM 148
  TelemetryModel? _selectedVehicle;

  @override
  void didUpdateWidget(covariant FleetMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusedVehicle != null &&
        widget.focusedVehicle != oldWidget.focusedVehicle &&
        !_isRadarMode) {
      final target = LatLng(
        widget.focusedVehicle!.latitude,
        widget.focusedVehicle!.longitude,
      );
      _currentCenter = target;
      _mapController.move(target, 13.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeFleetAsync = ref.watch(activeFleetStreamProvider);
    final activeIncidentsAsync = ref.watch(activeIncidentsStreamProvider);

    // 1. Resolve Fleet Vehicles
    final fleetData = activeFleetAsync.value ?? [];
    final displayFleet = List<TelemetryModel>.from(fleetData);
    if (displayFleet.isEmpty) {
      displayFleet.addAll([
        TelemetryModel(
          driverId: "mock_1",
          driverName: "Tariq Mehmood",
          vehicleReg: "ICT-TL-2940",
          vehicleType: "Heavy Freight",
          latitude: 32.7840,
          longitude: 72.7090,
          speedKmh: 78.5,
          heading: 140.0,
          timestamp: DateTime.now(),
        ),
        TelemetryModel(
          driverId: "mock_2",
          driverName: "Farhan Saeed",
          vehicleReg: "LHR-AX-5511",
          vehicleType: "Oil Tanker",
          latitude: 32.8120,
          longitude: 72.7420,
          speedKmh: 126.0, // Overspeeding
          isOverspeeding: true,
          heading: 155.0,
          timestamp: DateTime.now(),
        ),
      ]);
    }

    if (widget.focusedVehicle != null) {
      displayFleet.removeWhere((v) => v.driverId == widget.focusedVehicle!.driverId);
      displayFleet.add(widget.focusedVehicle!);
    }

    // 2. Resolve Active Incidents
    final incidentsData = activeIncidentsAsync.value ?? [];
    final activeIncidents = incidentsData
        .where((inc) => inc.status != 'resolved' && inc.status != 'false_alarm')
        .toList();

    // Fallback demo incident for visual verification if Firestore is empty
    final displayIncidents = List<IncidentModel>.from(activeIncidents);
    if (displayIncidents.isEmpty) {
      displayIncidents.add(
        IncidentModel(
          incidentId: "demo_inc_1",
          driverId: "drv_salt_1",
          driverName: "Muhammad Bilal",
          vehicleReg: "MN-9920",
          type: "drowsiness",
          severity: "critical",
          latitude: 32.7750,
          longitude: 72.7120,
          speedKmh: 84.0,
          description: "Salt Range KM 146: Commercial Bus driver severe drowsiness alert.",
          status: "pending",
          createdAt: DateTime.now(),
        ),
      );
    }

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark radar slate
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // 1. Primary Map Layer: Real OpenStreetMap OR Radar Canvas
            Positioned.fill(
              child: _isRadarMode
                  ? CustomPaint(
                      painter: _MotorwayCorridorPainter(),
                    )
                  : FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentCenter,
                        initialZoom: _currentZoom,
                        minZoom: 6.0,
                        maxZoom: 18.0,
                        onPositionChanged: (camera, hasGesture) {
                          _currentCenter = camera.center;
                          _currentZoom = camera.zoom;
                        },
                      ),
                      children: [
                        // Layer 1 - OpenStreetMap Tiles
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.nhmp.ivms_app',
                        ),

                        // Layer 2 - Geofenced Zones (M-2 Salt Range + Balkassar + Patrol Sector)
                        CircleLayer(
                          circles: [
                            // 40 km/h Downhill Commercial Bus Speed Zone & Brake-Failure Black Spot
                            CircleMarker(
                              point: const LatLng(32.7804, 72.7058),
                              radius: 4200,
                              useRadiusInMeter: true,
                              color: const Color(0xFFEF4444).withValues(alpha: 0.22),
                              borderColor: const Color(0xFFEF4444).withValues(alpha: 0.85),
                              borderStrokeWidth: 2.0,
                            ),
                            // Secondary Caution Zone at Balkassar
                            CircleMarker(
                              point: const LatLng(32.8450, 72.6700),
                              radius: 2500,
                              useRadiusInMeter: true,
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.20),
                              borderColor: const Color(0xFFF59E0B).withValues(alpha: 0.85),
                              borderStrokeWidth: 1.5,
                            ),
                            // Officer Terminal Patrol Area Overlay (SRS FR-O-11)
                            if (widget.isOfficerTerminal)
                              CircleMarker(
                                point: const LatLng(32.7900, 72.7200),
                                radius: 7500,
                                useRadiusInMeter: true,
                                color: AppTheme.blue500.withValues(alpha: 0.15),
                                borderColor: AppTheme.blue400.withValues(alpha: 0.70),
                                borderStrokeWidth: 2.0,
                              ),
                          ],
                        ),

                        // Layer 3 - M-2 Motorway Corridor Polyline
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: const [
                                LatLng(32.9300, 72.6500), // Balkassar Interchange
                                LatLng(32.8350, 72.6800), // Kallar Kahar North Approach
                                LatLng(32.7804, 72.7058), // Salt Range Steep Gradient KM 148
                                LatLng(32.7250, 72.7450), // Kallar Kahar South / Khushab Exit
                                LatLng(32.6200, 72.8200), // Lilla Interchange
                                LatLng(32.4800, 72.9100), // Bhera Service Area
                              ],
                              strokeWidth: 4.5,
                              color: const Color(0xFF2563EB),
                              borderStrokeWidth: 2.0,
                              borderColor: const Color(0xFF1E3A8A),
                            ),
                          ],
                        ),

                        // Layer 4 - Checkpoints, Emergency Incidents, and Live Fleet Markers
                        MarkerLayer(
                          markers: [
                            // Landmark Checkpoints
                            Marker(
                              point: const LatLng(32.9300, 72.6500),
                              width: 110,
                              height: 28,
                              child: _buildCheckpointBadge("Balkassar Exit", Icons.alt_route),
                            ),
                            Marker(
                              point: const LatLng(32.7804, 72.7058),
                              width: 160,
                              height: 28,
                              child: _buildCheckpointBadge(
                                "Salt Range (40 km/h)",
                                Icons.warning_amber_rounded,
                                isHazard: true,
                              ),
                            ),
                            Marker(
                              point: const LatLng(32.4800, 72.9100),
                              width: 120,
                              height: 28,
                              child: _buildCheckpointBadge("Bhera Rest Area", Icons.local_gas_station_rounded),
                            ),

                            // Active Emergency Incident Pins
                            ...displayIncidents.map((incident) {
                              final lat = (incident.latitude == 0.0) ? 32.7750 : incident.latitude;
                              final lng = (incident.longitude == 0.0) ? 72.7120 : incident.longitude;
                              return Marker(
                                point: LatLng(lat, lng),
                                width: 84,
                                height: 54,
                                child: GestureDetector(
                                  onTap: () => _showIncidentDetails(context, incident),
                                  child: _buildIncidentPin(incident),
                                ),
                              );
                            }),

                            // Live Commercial Fleet Vehicle Pins
                            ...displayFleet.map((vehicle) {
                              return Marker(
                                point: LatLng(vehicle.latitude, vehicle.longitude),
                                width: 100,
                                height: 58,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedVehicle = vehicle);
                                    _showVehicleDetails(context, vehicle);
                                  },
                                  child: _buildVehiclePin(vehicle),
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
            ),

            // 2. Tactical Radar Grid Vehicle Overlays (Only active when _isRadarMode is true)
            if (_isRadarMode)
              Stack(
                children: displayFleet.asMap().entries.map((entry) {
                  final index = entry.key;
                  final vehicle = entry.value;

                  // Compute normalized coordinates across M-2 corridor
                  // Lat range: 32.65 to 32.90, Lng range: 72.60 to 72.85
                  final normX = ((vehicle.longitude - 72.60) / 0.25).clamp(0.1, 0.85);
                  final normY = (1.0 - ((vehicle.latitude - 32.65) / 0.25)).clamp(0.1, 0.85);

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final left = constraints.maxWidth * normX + (index * 15);
                      final top = constraints.maxHeight * normY + (index * 10);

                      return Positioned(
                        left: left.clamp(20.0, constraints.maxWidth - 120.0),
                        top: top.clamp(20.0, constraints.maxHeight - 60.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedVehicle = vehicle);
                            _showVehicleDetails(context, vehicle);
                          },
                          child: _buildVehiclePin(vehicle),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),

            // 3. Top-Left Status Badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF334155)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.green400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isRadarMode
                          ? "M-2 CORRIDOR • RADAR GRID"
                          : "M-2 CORRIDOR • SALT RANGE LIVE GPS",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "${displayFleet.length} Buses • ${displayIncidents.length} Alerts",
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Top-Right Mode Toggle Button (Live M-2 Map vs Radar Grid)
            Positioned(
              top: 12,
              right: 12,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isRadarMode = !_isRadarMode;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isRadarMode
                          ? const Color(0xFF1E293B)
                          : AppTheme.blue600.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isRadarMode ? const Color(0xFF475569) : AppTheme.blue400,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isRadarMode ? Icons.map_outlined : Icons.radar,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isRadarMode ? "OSM Map" : "Radar View",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 5. Bottom-Right Zoom & Recenter Controls
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF334155)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white, size: 16),
                      tooltip: "Zoom In",
                      onPressed: () {
                        if (!_isRadarMode) {
                          final newZoom = (_currentZoom + 1).clamp(6.0, 18.0);
                          _mapController.move(_currentCenter, newZoom);
                        }
                      },
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                    const Divider(height: 1, color: Color(0xFF334155)),
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white, size: 16),
                      tooltip: "Zoom Out",
                      onPressed: () {
                        if (!_isRadarMode) {
                          final newZoom = (_currentZoom - 1).clamp(6.0, 18.0);
                          _mapController.move(_currentCenter, newZoom);
                        }
                      },
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                    const Divider(height: 1, color: Color(0xFF334155)),
                    IconButton(
                      icon: const Icon(Icons.my_location, color: AppTheme.blue400, size: 16),
                      tooltip: "Center Salt Range Patrol Zone",
                      onPressed: () {
                        const saltRangeCenter = LatLng(32.7804, 72.7058);
                        if (!_isRadarMode) {
                          _currentCenter = saltRangeCenter;
                          _currentZoom = 11.5;
                          _mapController.move(saltRangeCenter, 11.5);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Auto-centered on Salt Range Patrol Zone (KM 148)"),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckpointBadge(String label, IconData icon, {bool isHazard = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isHazard
            ? const Color(0xFF7F1D1D).withValues(alpha: 0.90)
            : const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isHazard ? AppTheme.danger : const Color(0xFF475569),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: isHazard ? Colors.amber : Colors.white70),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isHazard ? Colors.amberAccent : Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentPin(IncidentModel incident) {
    final String label;
    final FaIconData icon;
    final Color bg;

    switch (incident.type.toLowerCase()) {
      case 'crash':
        label = 'CRASH';
        icon = FontAwesomeIcons.carBurst;
        bg = const Color(0xFFDC2626);
        break;
      case 'drowsiness':
        label = 'DROWSY';
        icon = FontAwesomeIcons.eyeSlash;
        bg = const Color(0xFFEA580C);
        break;
      case 'manual_sos':
      case 'sos':
        label = 'SOS';
        icon = FontAwesomeIcons.triangleExclamation;
        bg = const Color(0xFFB91C1C);
        break;
      default:
        label = 'HAZARD';
        icon = FontAwesomeIcons.triangleExclamation;
        bg = const Color(0xFFD97706);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white, width: 1),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(icon, size: 8, color: Colors.white),
              const SizedBox(width: 3),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: bg.withValues(alpha: 0.6),
                blurRadius: 8,
                spreadRadius: 2,
              )
            ],
          ),
          child: Center(
            child: FaIcon(icon, size: 10, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _showIncidentDetails(BuildContext context, IncidentModel incident) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isCritical = incident.severity.toLowerCase() == 'critical' ||
            incident.severity.toLowerCase() == 'high';
        final badgeColor = isCritical ? AppTheme.danger : AppTheme.warning;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: badgeColor),
                        ),
                        child: Text(
                          incident.type.toUpperCase().replaceAll('_', ' '),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          incident.vehicleReg,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      incident.status.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Driver: ${incident.driverName}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              if (incident.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  incident.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.muted,
                  ),
                ),
              ],
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _detailMetric("Severity", incident.severity.toUpperCase()),
                  _detailMetric("Speed", "${incident.speedKmh.toStringAsFixed(1)} km/h"),
                  _detailMetric(
                    "GPS Coords",
                    "${incident.latitude.toStringAsFixed(4)}, ${incident.longitude.toStringAsFixed(4)}",
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text("Close Incident View"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.navy900,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVehiclePin(TelemetryModel vehicle) {
    final isSelected = _selectedVehicle?.driverId == vehicle.driverId;
    final isAlert = vehicle.isOverspeeding;
    final pinColor = isSelected ? AppTheme.gold : (isAlert ? AppTheme.danger : AppTheme.green500);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tag badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: pinColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                vehicle.vehicleReg,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "${vehicle.speedKmh.toStringAsFixed(0)}kph",
                style: TextStyle(
                  color: isAlert ? Colors.redAccent : AppTheme.green400,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        // Pin icon
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: pinColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: pinColor.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              )
            ],
          ),
          child: Center(
            child: FaIcon(
              vehicle.vehicleType.contains("Truck")
                  ? FontAwesomeIcons.truck
                  : FontAwesomeIcons.car,
              size: 12,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _showVehicleDetails(BuildContext context, TelemetryModel vehicle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.vehicleReg,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Driver: ${vehicle.driverName}",
                        style: const TextStyle(color: AppTheme.muted, fontSize: 13),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: vehicle.isOverspeeding
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${vehicle.speedKmh.toStringAsFixed(1)} km/h",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: vehicle.isOverspeeding ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _detailMetric("Latitude", vehicle.latitude.toStringAsFixed(4)),
                  _detailMetric("Longitude", vehicle.longitude.toStringAsFixed(4)),
                  _detailMetric("Status", vehicle.isOverspeeding ? "VIOLATION" : "NORMAL"),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _detailMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _MotorwayCorridorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Radar Grid Lines
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Motorway Highway Path (Curving through Salt Range)
    final highwayPaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final highwayInnerPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.2)
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.1);
    path.cubicTo(
      size.width * 0.45,
      size.height * 0.35,
      size.width * 0.3,
      size.height * 0.65,
      size.width * 0.85,
      size.height * 0.9,
    );

    canvas.drawPath(path, highwayPaint);
    canvas.drawPath(path, highwayInnerPaint);

    // Landmarks / Sector checkpoints
    _drawLandmark(canvas, Offset(size.width * 0.2, size.height * 0.18), "Balkasar Exit");
    _drawLandmark(canvas, Offset(size.width * 0.42, size.height * 0.48), "Kallar Kahar (Salt Range)");
    _drawLandmark(canvas, Offset(size.width * 0.72, size.height * 0.82), "Bhera Service Area");
  }

  void _drawLandmark(Canvas canvas, Offset offset, String name) {
    final dotPaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawCircle(offset, 3, dotPaint);

    final textSpan = TextSpan(
      text: name,
      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w600),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(offset.dx + 6, offset.dy - 5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
