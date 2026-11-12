import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../core/strings.dart';
import '../../core/theme/tokens.dart';
import '../../data/demo_map.dart';
import '../../domain/map_zone.dart';
import '../plantation/device_position.dart';
import '../plantation/plantation_draft.dart';

/// Fonds de carte proposes : plan et images satellitales.
enum BaseMap {
  osm(
    name: 'Plan OpenStreetMap',
    url: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: '© OpenStreetMap contributors',
    satellite: false,
  ),
  esriImagery(
    name: 'Esri World Imagery',
    url:
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    attribution: '© Esri, Maxar, Earthstar Geographics',
    satellite: true,
  ),
  esriClarity(
    name: 'Esri World Imagery Clarity',
    url:
        'https://clarity.maptiles.arcgis.com/arcgis/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    attribution: '© Esri, Maxar, Earthstar Geographics',
    satellite: true,
  ),
  sentinel(
    name: 'Sentinel-2 cloudless',
    url: 'https://tiles.maps.eox.at/wmts/1.0.0/s2cloudless-2020_3857/default/g/{z}/{y}/{x}.jpg',
    attribution: '© EOX, Copernicus Sentinel data 2020',
    satellite: true,
  );

  const BaseMap({
    required this.name,
    required this.url,
    required this.attribution,
    required this.satellite,
  });

  final String name;
  final String url;
  final String attribution;
  final bool satellite;
}

/// Carte : fond de plan (ou satellite), position de l'appareil et contours
/// des plantations releves. Hors ligne, les tuiles manquantes restent vides.
class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  static const _defaultCenter = LatLng(5.36, -4.03); // Abidjan, faute de GPS

  final _controller = MapController();
  BaseMap _base = BaseMap.osm;
  bool _basePanelOpen = false;
  bool _panelOpen = false;
  bool _showPlantations = true;
  bool _showSectors = true;
  bool _showLots = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _zoom(double delta) {
    final cam = _controller.camera;
    _controller.move(cam.center, cam.zoom + delta);
  }

  void _locate() {
    final pos = ref.read(livePositionProvider).value;
    if (pos != null) {
      _controller.move(LatLng(pos.point.lat, pos.point.lng), 16);
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text(S.gpsUnavailable)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final pos = ref.watch(livePositionProvider).value;
    // Boussole d'abord (marche a l'arret), cap GPS en secours.
    final heading = ref.watch(compassHeadingProvider).value ?? pos?.heading;
    final drafts = ref.watch(plantationDraftsProvider);
    final zones = ref.watch(mapZonesProvider);
    final t = context.tokens;
    final center = pos == null ? _defaultCenter : LatLng(pos.point.lat, pos.point.lng);

    ref.listen(livePositionProvider, (previous, next) {
      final p = next.value;
      if (p != null && previous?.value == null) {
        _controller.move(LatLng(p.point.lat, p.point.lng), 16);
      }
    });

    return Stack(
      fit: StackFit.expand,
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(initialCenter: center, initialZoom: pos == null ? 11 : 16),
          children: [
            TileLayer(
              urlTemplate: _base.url,
              userAgentPackageName: 'sysde_mobile',
              errorTileCallback: (tile, error, stackTrace) {},
            ),
            // Du plus grand au plus petit : secteur, lot, puis plantations.
            PolygonLayer(
              polygons: [
                for (final z in zones)
                  if (z.kind == MapZoneKind.sector ? _showSectors : _showLots)
                    Polygon(
                      points: [for (final p in z.points) LatLng(p.lat, p.lng)],
                      color: (z.kind == MapZoneKind.sector ? t.training : t.meeting)
                          .withValues(alpha: z.kind == MapZoneKind.sector ? 0.08 : 0.16),
                      borderColor: z.kind == MapZoneKind.sector ? t.training : t.meeting,
                      borderStrokeWidth: z.kind == MapZoneKind.sector ? 3 : 2,
                      label: z.name,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: z.kind == MapZoneKind.sector ? t.training : t.meeting,
                      ),
                    ),
                if (_showPlantations)
                  for (final d in drafts)
                    if (d.points.length >= 3)
                      Polygon(
                        points: [for (final p in d.points) LatLng(p.lat, p.lng)],
                        color: scheme.primary.withValues(alpha: 0.28),
                        borderColor: scheme.primary,
                        borderStrokeWidth: 3,
                      ),
              ],
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
                ],
              ),
            if (pos != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(pos.point.lat, pos.point.lng),
                    width: 48,
                    height: 48,
                    child: _PositionMarker(heading: heading),
                  ),
                ],
              ),
            RichAttributionWidget(
              alignment: AttributionAlignment.bottomLeft,
              showFlutterMapAttribution: false,
              attributions: [TextSourceAttribution(_base.attribution)],
            ),
          ],
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MapButton(
                        icon: Icons.layers,
                        tooltip: S.toolMapLayers,
                        selected: _panelOpen,
                        onTap: () => setState(() => _panelOpen = !_panelOpen),
                      ),
                      const SizedBox(height: 8),
                      _MapButton(icon: Icons.my_location, tooltip: S.toolLocate, onTap: _locate),
                    ],
                  ),
                ),
                if (_panelOpen)
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 48),
                      child: _LayersPanel(
                        plantations: _showPlantations,
                        sectors: _showSectors,
                        lots: _showLots,
                        onPlantations: (v) => setState(() => _showPlantations = v),
                        onSectors: (v) => setState(() => _showSectors = v),
                        onLots: (v) => setState(() => _showLots = v),
                      ),
                    ),
                  ),
                // En bas a droite (la mention de source est en bas a gauche).
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (_basePanelOpen) ...[
                          _BaseMapPanel(
                            selected: _base,
                            onSelect: (b) => setState(() {
                              _base = b;
                              _basePanelOpen = false;
                            }),
                          ),
                          const SizedBox(height: 8),
                        ],
                        _MapButton(
                          icon: Icons.satellite_alt,
                          tooltip: S.toolLayers,
                          selected: _basePanelOpen,
                          onTap: () => setState(() => _basePanelOpen = !_basePanelOpen),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MapButton(icon: Icons.add, tooltip: S.zoomIn, onTap: () => _zoom(1)),
                      const SizedBox(height: 4),
                      _MapButton(icon: Icons.remove, tooltip: S.zoomOut, onTap: () => _zoom(-1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: scheme.primary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: selected ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: scheme.onPrimary, size: 21),
          ),
        ),
      ),
    );
  }
}

/// Point bleu de la position ; quand le cap est connu, un chevron indique la
/// direction du deplacement.
class _PositionMarker extends StatelessWidget {
  const _PositionMarker({required this.heading});

  final double? heading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (heading != null)
          Transform.rotate(
            angle: heading! * math.pi / 180,
            child: const CustomPaint(size: Size(48, 48), painter: _ChevronPainter()),
          ),
        const DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0xFF1E88E5),
            shape: BoxShape.circle,
            border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 3)),
            boxShadow: [BoxShadow(color: Color(0x55000000), blurRadius: 4)],
          ),
          child: SizedBox(width: 20, height: 20),
        ),
      ],
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final path = Path()
      ..moveTo(c.dx, c.dy - 22)
      ..lineTo(c.dx + 8, c.dy - 9)
      ..lineTo(c.dx - 8, c.dy - 9)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF1E88E5));
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => false;
}

/// Cases a cocher : plantations, contour du secteur, contour du lot.
class _LayersPanel extends StatelessWidget {
  const _LayersPanel({
    required this.plantations,
    required this.sectors,
    required this.lots,
    required this.onPlantations,
    required this.onSectors,
    required this.onLots,
  });

  final bool plantations;
  final bool sectors;
  final bool lots;
  final ValueChanged<bool> onPlantations;
  final ValueChanged<bool> onSectors;
  final ValueChanged<bool> onLots;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    Widget row(String label, Color color, bool value, ValueChanged<bool> onChanged) {
      return InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.25),
                  border: Border.all(color: color, width: 2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              SizedBox(
                width: 42,
                height: 30,
                child: FittedBox(
                  child: Switch(
                    value: value,
                    onChanged: onChanged,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      elevation: 4,
      color: context.scheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            row(S.layerSector, t.training, sectors, onSectors),
            row(S.layerLot, t.meeting, lots, onLots),
            row(S.layerPlantations, context.scheme.primary, plantations, onPlantations),
          ],
        ),
      ),
    );
  }
}

/// Liste des fonds de carte (plan, puis images satellitales par leur nom).
class _BaseMapPanel extends StatelessWidget {
  const _BaseMapPanel({required this.selected, required this.onSelect});

  final BaseMap selected;
  final ValueChanged<BaseMap> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final primary = context.scheme.primary;
    return Material(
      elevation: 4,
      color: context.scheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 270),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 4),
                child: Text(
                  S.baseMapTitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: t.inkMuted,
                  ),
                ),
              ),
              for (final b in BaseMap.values)
                InkWell(
                  onTap: () => onSelect(b),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    child: Row(
                      children: [
                        Icon(
                          b.satellite ? Icons.satellite_alt : Icons.map_outlined,
                          size: 20,
                          color: b == selected ? primary : t.inkMuted,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            b.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: b == selected ? FontWeight.w800 : FontWeight.w600,
                              color: b == selected ? primary : null,
                            ),
                          ),
                        ),
                        if (b == selected) Icon(Icons.check, size: 20, color: primary),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
