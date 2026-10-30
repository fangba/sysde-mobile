import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/back_circle_button.dart';
import '../../domain/geo.dart';
import 'device_position.dart';
import 'plantation_draft.dart';

/// Releve du contour d'une nouvelle plantation sur la carte.
/// Outils : 1 tracer (toucher la carte), 2 ajouter ma position, 3 enregistrer.
class NewPlantationPage extends ConsumerStatefulWidget {
  const NewPlantationPage({super.key, this.backPath = '/activite/visite/verger'});

  final String backPath;

  @override
  ConsumerState<NewPlantationPage> createState() => _NewPlantationPageState();
}

class _NewPlantationPageState extends ConsumerState<NewPlantationPage> {
  static const _osm = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const _satellite =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  static const _defaultCenter = LatLng(5.36, -4.03); // Abidjan, faute de GPS

  final _controller = MapController();
  final _points = <GeoPoint>[];
  bool _tracing = false;
  bool _satelliteOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _addPoint(GeoPoint p) => setState(() => _points.add(p));

  void _addMyPosition(DevicePosition? pos) {
    if (pos == null) {
      _snack(S.gpsUnavailable);
      return;
    }
    _addPoint(pos.point);
  }

  void _undo() {
    if (_points.isNotEmpty) setState(_points.removeLast);
  }

  void _locate() {
    ref.invalidate(devicePositionProvider);
    final pos = ref.read(devicePositionProvider).value;
    if (pos != null) {
      _controller.move(LatLng(pos.point.lat, pos.point.lng), 17);
    }
  }

  void _save() {
    if (_points.length < 3) {
      _snack(S.plantationNeedsPoints);
      return;
    }
    ref.read(plantationDraftsProvider.notifier).add(
          PlantationDraft(
            points: List.of(_points),
            areaHectares: polygonAreaHectares(_points),
          ),
        );
    context.go(widget.backPath);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(S.plantationSaved)));
  }

  void _zoom(double delta) {
    final cam = _controller.camera;
    _controller.move(cam.center, cam.zoom + delta);
  }

  @override
  Widget build(BuildContext context) {
    final pos = ref.watch(devicePositionProvider).value;
    final scheme = context.scheme;
    final latLngs = [for (final p in _points) LatLng(p.lat, p.lng)];
    final center = pos == null ? _defaultCenter : LatLng(pos.point.lat, pos.point.lng);

    ref.listen(devicePositionProvider, (previous, next) {
      final p = next.value;
      if (p != null && previous?.value == null) {
        _controller.move(LatLng(p.point.lat, p.point.lng), 17);
      }
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: center,
              initialZoom: pos == null ? 12 : 17,
              onTap: (tapPosition, point) {
                if (_tracing) _addPoint((lat: point.latitude, lng: point.longitude));
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _satelliteOn ? _satellite : _osm,
                userAgentPackageName: 'sysde_mobile',
                // Hors ligne : une tuile manquante n'est pas une erreur.
                errorTileCallback: (tile, error, stackTrace) {},
              ),
              if (pos != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(pos.point.lat, pos.point.lng),
                      radius: pos.accuracy,
                      useRadiusInMeter: true,
                      color: const Color(0x331E88E5),
                      borderColor: const Color(0xFF1E88E5),
                      borderStrokeWidth: 1,
                    ),
                    CircleMarker(
                      point: LatLng(pos.point.lat, pos.point.lng),
                      radius: 7,
                      color: const Color(0xFF1E88E5),
                      borderColor: Colors.white,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              if (latLngs.length >= 3)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: latLngs,
                      color: scheme.primary.withValues(alpha: 0.25),
                      borderColor: scheme.primary,
                      borderStrokeWidth: 3,
                    ),
                  ],
                )
              else if (latLngs.length == 2)
                PolylineLayer(
                  polylines: [
                    Polyline(points: latLngs, color: scheme.primary, strokeWidth: 3),
                  ],
                ),
              MarkerLayer(
                markers: [
                  for (final p in latLngs)
                    Marker(
                      point: p,
                      width: 16,
                      height: 16,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: scheme.primary, width: 3),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BackCircleButton(onPressed: () => context.go(widget.backPath)),
                        const SizedBox(height: 12),
                        _MapButton(icon: Icons.add, tooltip: S.zoomIn, onTap: () => _zoom(1)),
                        const SizedBox(height: 4),
                        _MapButton(icon: Icons.remove, tooltip: S.zoomOut, onTap: () => _zoom(-1)),
                        const SizedBox(height: 16),
                        _MapButton(
                          icon: Icons.pentagon_outlined,
                          tooltip: S.toolTrace,
                          selected: _tracing,
                          onTap: () => setState(() => _tracing = !_tracing),
                        ),
                        const SizedBox(height: 8),
                        _MapButton(
                          icon: Icons.add_location_alt_outlined,
                          tooltip: S.toolAddPosition,
                          onTap: () => _addMyPosition(pos),
                        ),
                        const SizedBox(height: 8),
                        _MapButton(
                          icon: Icons.undo,
                          tooltip: S.toolUndo,
                          onTap: _points.isEmpty ? null : _undo,
                        ),
                        const SizedBox(height: 8),
                        _MapButton(icon: Icons.save_outlined, tooltip: S.toolSave, onTap: _save),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MapButton(
                          icon: Icons.layers_outlined,
                          tooltip: S.toolLayers,
                          selected: _satelliteOn,
                          onTap: () => setState(() => _satelliteOn = !_satelliteOn),
                        ),
                        const SizedBox(height: 8),
                        _MapButton(
                          icon: Icons.my_location,
                          tooltip: S.toolLocate,
                          onTap: _locate,
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: _Summary(points: _points),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.points});

  final List<GeoPoint> points;

  @override
  Widget build(BuildContext context) {
    final area = polygonAreaHectares(points);
    final text = points.isEmpty
        ? S.plantationTapToTrace
        : S.pointsCount(points.length) +
            (points.length >= 3 ? ' · ${area.toStringAsFixed(2).replaceAll('.', ',')} ha' : '');
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.scheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: onTap == null ? scheme.primary.withValues(alpha: 0.5) : scheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: selected
              ? const BorderSide(color: Colors.white, width: 3)
              : BorderSide.none,
        ),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: scheme.onPrimary, size: 26),
          ),
        ),
      ),
    );
  }
}
