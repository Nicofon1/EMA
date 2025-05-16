import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:gemini/api_manager.dart';
// Importa el paquete path_provider si aún no lo tienes
import 'package:path_provider/path_provider.dart';
import 'dart:io';
typedef ResultadoSondeo = Map<String, dynamic>;

enum tipo {
  SI_NO,
  MULTIPLE,
  ESCALA,
}

class SondeoManager {
  
  static final SondeoManager _instance = SondeoManager._internal();
  factory SondeoManager() => _instance;
  SondeoManager._internal();
  Function(double, String)? onResultadoSondeo;

  List<SondeoPregunta> _preguntas = [];
  List<SondeoPregunta> get preguntas => _preguntas;
  bool _cargado = false;
  Map<int, dynamic> _respuestasActual = {}; // Para guardar las respuestas del sondeo actual
  List<Sondeo> _historialSondeos = [];
  final String _nombreArchivoHistorial = 'historial_sondeos.json';
  Map<int, int> _respuestasBaseScale =
      {}; // Nuevo: Para guardar los valores de la escala base

  Future<void> loadPreguntas() async {
    if (_cargado) return;
    final jsondata = await rootBundle.loadString('jsonfile/sondeo.json');
    final list = json.decode(jsondata) as List<dynamic>;
    _preguntas = list.map((e) => SondeoPregunta.fromJson(e)).toList();
    _cargado = true;
    await _cargarHistorialSondeos(); // Cargar el historial al cargar las preguntas
  }

void registrarRespuesta(int preguntaId, dynamic respuesta) {
  _respuestasActual[preguntaId] = respuesta;
  //  Encontrar la pregunta para obtener el tipoPregunta
  final pregunta = _preguntas.firstWhere((p) => p.id == preguntaId);
  int baseScaleValue = _calcularBaseScale(respuesta, pregunta.tipoPregunta!); //  Usamos '!' porque sabemos que tipoPregunta no será nulo
  _respuestasBaseScale[preguntaId] = baseScaleValue;
  print(
      'Respuesta registrada para la pregunta $preguntaId: $respuesta, Escala Base: $baseScaleValue');
}

  // Nueva función: Calcula el valor de la escala base según la respuesta
int _calcularBaseScale(dynamic respuesta, tipo tipoPregunta) {
  switch (tipoPregunta) {
    case tipo.SI_NO:
      if (respuesta == 'Sí') {
        return 2;
      } else if (respuesta == 'No') {
        return 0;
      } else if (respuesta == 'No sé') {
        return 1;
      }
      return 0;

    case tipo.MULTIPLE:
      if (respuesta == 'Siempre') {
        return 2;
      } else if (respuesta == 'A veces') {
        return 1;
      } else if (respuesta == 'Nunca') {
        return 0;
      }
      return 0;

    case tipo.ESCALA:
      if (respuesta is num) {
        return (respuesta / 5).round();
      }
      return 0;
  }
}
  double calcularPuntajeSondeo() {
    double totalScore = 0;
    for (var pregunta in _preguntas) {
      int baseScale = _respuestasBaseScale[pregunta.id] ??
          0; // 0 si no hay respuesta para esta pregunta
      double peso = pregunta.peso ??
          1.0; // Peso por defecto de 1.0 si es nulo
      totalScore += baseScale * peso;
    }
    print(totalScore);
    return totalScore;
  }

  String determinarNivelRiesgo(double puntajeTotal) {
    if (puntajeTotal <= 6.9) {
      return "Bajo";
    } else if (puntajeTotal <= 9.9) {
      return "Intermedio";
    } else if (puntajeTotal <= 13.9) {
      return "Moderado";
    } else {
      return "Alto";
    }
  }

Future<void> finalizarSondeo() async {
  if (_respuestasActual.isNotEmpty) {
    double puntajeTotal = calcularPuntajeSondeo();
    String nivelRiesgo = determinarNivelRiesgo(puntajeTotal);


        if (onResultadoSondeo != null) {
        onResultadoSondeo!(puntajeTotal, nivelRiesgo);
      }
    //  Construir el resultado para enviar a la IA
    ResultadoSondeo resultado = {
      "puntajeTotal": puntajeTotal,
      "nivelRiesgo": nivelRiesgo,
      "respuestas": _respuestasActual.map((preguntaId, respuesta) =>
          MapEntry(preguntaId.toString(), {
            "respuesta": respuesta,
            "tipoPregunta": _preguntas
                .firstWhere((p) => p.id == preguntaId)
                .tipoPregunta
                .toString(),
            "peso": _preguntas
                .firstWhere((p) => p.id == preguntaId)
                .peso,
            "pregunta": _preguntas
                .firstWhere((p) => p.id == preguntaId)
                .pregunta,
          })).values.toList()
    };

    final nuevoSondeo = Sondeo(
      respuestas: _respuestasActual
          .map((key, value) => MapEntry(key.toString(), value)),
      puntajeTotal: puntajeTotal,
      nivelRiesgo: nivelRiesgo,
    );
    _historialSondeos.add(nuevoSondeo);
    _respuestasActual.clear();
    _respuestasBaseScale.clear();

    await _guardarHistorialSondeos();
    print(
        'Sondeo finalizado y guardado en el historial. Puntaje: $puntajeTotal, Nivel: $nivelRiesgo');

    //  Enviar resultado a la IA
    ApiManager().enviarResultadoSondeo(resultado, _preguntas);  //  Asegúrate de que _apiManager esté inicializado
  } else {
    print('No se registraron respuestas para guardar el sondeo.');
  }
}

  Future<File> get _archivoLocalHistorial async {
    final directorio = await getApplicationDocumentsDirectory();
    return File('${directorio.path}/$_nombreArchivoHistorial');
  }

  Future<void> _cargarHistorialSondeos() async {
    try {
      final archivo = await _archivoLocalHistorial;
      final contenido = await archivo.readAsString();
      final lista = json.decode(contenido) as List<dynamic>;
      _historialSondeos = lista.map((e) => Sondeo.fromJson(e)).toList();
      print('Historial de sondeos cargado.');
    } catch (e) {
      // Si el archivo no existe o hay un error, inicializar una lista vacía
      _historialSondeos = [];
      print(
          'Error al cargar el historial de sondeos (puede que el archivo no exista): $e');
    }
  }

  Future<void> _guardarHistorialSondeos() async {
    try {
      final archivo = await _archivoLocalHistorial;
      final jsonData =
          json.encode(_historialSondeos.map((s) => s.toJson()).toList());
      await archivo.writeAsString(jsonData);
      print('Historial de sondeos guardado.');
    } catch (e) {
      print('Error al guardar el historial de sondeos: $e');
    }
  }

  void resetear() {
    _preguntas.clear();
    _cargado = false;
    _respuestasActual.clear();
    _respuestasBaseScale.clear(); // Limpiar el mapa de escala base también
  }
}

class SondeoPregunta {
  int? id;
  String? pregunta;
  double? peso;
  tipo? tipoPregunta;

  SondeoPregunta({this.id, this.pregunta, this.peso, this.tipoPregunta});

  SondeoPregunta.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pregunta = json['pregunta'];
    peso = json['peso'];
    tipoPregunta = tipo.values[json['tipoPregunta']];
  }
}

class Sondeo {
  Map<String, dynamic>? respuestas;
  double? puntajeTotal;
  String? nivelRiesgo;

  Sondeo({
    this.respuestas,
    this.puntajeTotal,
    this.nivelRiesgo,
  });

  Sondeo.fromJson(Map<String, dynamic> json) {
    respuestas = json['respuestas'] as Map<String, dynamic>?;
    puntajeTotal = (json['puntajeTotal'] as num?)?.toDouble();
    nivelRiesgo = json['nivelRiesgo'];
  }

  Map<String, dynamic> toJson() {
    return {
      'respuestas': respuestas,
      'puntajeTotal': puntajeTotal,
      'nivelRiesgo': nivelRiesgo,
    };
  }
}