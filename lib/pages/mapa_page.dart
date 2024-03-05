// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'geo_utils/export_kml.dart';
import 'geo_utils/point_info.dart';

class Mapa extends StatefulWidget {
  const Mapa({Key? key}) : super(key: key);

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  List<PointInfo> points = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [_buildMap()],
      ),
    );
  }

  Widget buildUserLocation() {
    return CurrentLocationLayer(
      alignPositionOnUpdate: AlignOnUpdate.always,
    );
  }

  Widget _buildMap() {
    String tileLayerUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    return Expanded(
      child: FlutterMap(
        options: MapOptions(
          initialZoom: 15.0,
          initialCenter: const LatLng(-5.073282, -42.800215),
          onTap: (tapPosition, latlng) {
            _addPoint(latlng);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: tileLayerUrl,
          ),
          buildUserLocation(),
          MarkerLayer(
            markers: [
              for (var pointInfo in points)
                Marker(
                  point: pointInfo.coordinates,
                  child: GestureDetector(
                    onLongPress: () {
                      _removePoint(pointInfo);
                    },
                    onDoubleTap: () {
                      _showPointNameScreen(context, pointInfo);
                    },
                    child: IconButton(
                      icon: const FaIcon(FontAwesomeIcons.locationDot,
                          color: Colors.red, size: 17),
                      onPressed: () {
                        _showPointNameDialog(context, pointInfo);
                      },
                    ),
                  ),
                ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton.filled(
              onPressed: () {
                exportPointsAsKML(context, points);
              },
              icon: const Icon(
                Icons.download,
                size: 30,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _addPoint(LatLng latlng) {
    setState(() {
      points.add(PointInfo(
        'Novo Ponto',
        latlng,
      ));
    });
  }

  void _removePoint(PointInfo point) {
    setState(() {
      points.remove(point);
    });
  }

  Future<void> _showPointNameDialog(
      BuildContext context, PointInfo point) async {
    String? newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nomePontoController = TextEditingController();
        return AlertDialog(
          title: const Text('Nome do Ponto'),
          content: TextField(
            controller: nomePontoController,
            decoration:
                const InputDecoration(hintText: 'Digite o nome do ponto'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(nomePontoController.text);
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName != point.name) {
      setState(() {
        point.name = newName;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nome do ponto atualizado para: $newName'),
        ),
      );
    }
  }

  Future<void> _showPointNameScreen(
      BuildContext context, PointInfo point) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes do Ponto'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailText('Nome do ponto:', 20, FontWeight.bold),
                const SizedBox(height: 8),
                _buildDetailText(point.name, 18),
                const SizedBox(height: 16),
                _buildDetailText('Latitude:', 20, FontWeight.bold),
                const SizedBox(height: 8),
                _buildDetailText(
                    point.coordinates.latitude.toStringAsFixed(6), 18),
                const SizedBox(height: 16),
                _buildDetailText('Longitude:', 20, FontWeight.bold),
                const SizedBox(height: 8),
                _buildDetailText(
                    point.coordinates.longitude.toStringAsFixed(6), 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailText(String text, double fontSize,
      [FontWeight fontWeight = FontWeight.normal]) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
