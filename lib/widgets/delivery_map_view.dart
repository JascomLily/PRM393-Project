import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class DeliveryMapView extends StatelessWidget {
  // Toa do Tru so chinh Furni3D: Toa nha Landmark 81, TP. HCM
  static const double hqLat = 10.7950;
  static const double hqLng = 106.7218;
  static const String hqAddress = 'Toa nha Landmark 81, 720A Dien Bien Phu, P. 22, Binh Thanh, TP. HCM';

  final double? destinationLat;
  final double? destinationLng;
  final String? destinationAddress;
  final double distanceKm;
  final int shippingFee;
  final VoidCallback? onRefreshLocation;

  const DeliveryMapView({
    super.key,
    required this.destinationLat,
    required this.destinationLng,
    this.destinationAddress,
    required this.distanceKm,
    required this.shippingFee,
    this.onRefreshLocation,
  });

  Future<void> _openExternalDirections() async {
    final destLat = destinationLat ?? hqLat;
    final destLng = destinationLng ?? hqLng;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$hqLat,$hqLng&destination=$destLat,$destLng&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'd');
    final hqPoint = const LatLng(hqLat, hqLng);
    final userPoint = (destinationLat != null && destinationLng != null)
        ? LatLng(destinationLat!, destinationLng!)
        : const LatLng(10.7769, 106.7009); // Default trung tam TP.HCM neu chua bat GPS

    // Tinh trung diem de map can giua ca 2 toa do
    final centerLat = (hqPoint.latitude + userPoint.latitude) / 2;
    final centerLng = (hqPoint.longitude + userPoint.longitude) / 2;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: const Color(0xFFF1F5F9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.map_outlined, size: 18, color: AppTheme.primary),
                    SizedBox(width: 8),
                    Text(
                      'Lo trinh van chuyen (OpenStreetMap)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (onRefreshLocation != null)
                  InkWell(
                    onTap: onRefreshLocation,
                    child: const Row(
                      children: [
                        Icon(Icons.my_location, size: 14, color: AppTheme.primary),
                        SizedBox(width: 4),
                        Text(
                          'Dinh vi',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // OpenStreetMap View
          SizedBox(
            height: 190,
            width: double.infinity,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(centerLat, centerLng),
                    initialZoom: 12.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'io.supabase.furni3d',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [hqPoint, userPoint],
                          color: AppTheme.primary,
                          strokeWidth: 3.5,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        // Marker Tru so Furni3D Landmark 81
                        Marker(
                          point: hqPoint,
                          width: 42,
                          height: 42,
                          child: const Icon(
                            Icons.store,
                            color: Color(0xFF005BA9),
                            size: 32,
                          ),
                        ),
                        // Marker Vi tri khach hang
                        Marker(
                          point: userPoint,
                          width: 42,
                          height: 42,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.redAccent,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Map Legend Overlay
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Text(
                      'Xanh: Kho Landmark 81 | Do: Ban',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // Button open directions
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF005BA9),
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.directions, size: 14),
                    label: const Text(
                      'Chi duong',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _openExternalDirections,
                  ),
                ),
              ],
            ),
          ),

          // Route Details & Shipping Fee Calculation Banner
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.route, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'Quang duong: ${distanceKm.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      currencyFormatter.format(shippingFee),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  distanceKm <= 20
                      ? 'Pham vi <= 20 km: Ap dung cuoc co ban 20.000 d'
                      : 'Vuot qua 20 km: 20.000 d + (${(distanceKm - 20).ceil()} km vuot x 5.000 d)',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
