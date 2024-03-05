// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:teresina_info/pages/geo_utils/point_info.dart';

void exportPointsAsKML(BuildContext context, List<PointInfo> points) async {
  // Cria o conteúdo do arquivo KML
  String kmlContent = '<?xml version="1.0" encoding="UTF-8"?>\n'
      '<kml xmlns="http://www.opengis.net/kml/2.2">\n'
      '<Document>\n'
      '<name>Points</name>\n';

  for (var point in points) {
    kmlContent += '<Placemark>\n'
        '<name>${point.name}</name>\n'
        '<Point>\n'
        '<coordinates>${point.coordinates.longitude},${point.coordinates.latitude}</coordinates>\n'
        '</Point>\n'
        '</Placemark>\n';
  }

  kmlContent += '</Document>\n'
      '</kml>';

  // Obtem o diretório de documentos do dispositivo
  Directory? directory = await getExternalStorageDirectory();
  if (directory != null) {
    String filePath = '${directory.path}/pontos.kml';

    // Escreve o conteúdo do arquivo KML no armazenamento local
    File file = File(filePath);
    await file.writeAsString(kmlContent);

    // Exibe uma mensagem para o usuário
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pontos exportados com sucesso como KML: $filePath'),
      ),
    );
  } else {
    // Exibe uma mensagem de erro se não for possível obter o diretório
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erro ao exportar os pontos como KML.'),
      ),
    );
  }
}
