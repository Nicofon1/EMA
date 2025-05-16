import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:gemini/sondeo_manager.dart';
import 'package:gemini/const.dart';

import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle; // Para cargar fuentes
import 'package:printing/printing.dart'; // O tu método preferido para guardar/mostrar el PDF


class ApiManager {
  static final ApiManager _instance = ApiManager._internal();
  factory ApiManager() => _instance;

  // Instancia principal (chat, botones, etc.)
  final Gemini _gemini = Gemini.instance;

  // Instancia secundaria para el reporte (modelo más potente)
  final Gemini _geminiReporte = Gemini.init(
    apiKey: GEMINI_API_KEY,
    version: "gemini-2.0-flash",
    generationConfig: GenerationConfig(maxOutputTokens: 8000),
  );

  ApiManager._internal() {
    // Aquí podrías hacer más configuración si quieres
    // _geminiReporte.model = "gemini-1.5-pro"; // innecesario si ya lo diste en init
  }

 


   void Function()? onIniciarSondeo;

  final ValueNotifier<String?> _infoReporte = ValueNotifier(null);
  ValueNotifier<String?> get infoReporte => _infoReporte;
  
  
static final String Contexto_Ema =
  "Nombre: Ema\n"
  "Rol: Asistente virtual de chat en una app para profesores contra el ESCNNA.\n"
  "Objetivo principal: Ayudar a los profesores a identificar posibles casos de ESCNNA en sus estudiantes y activar la ruta de apoyo de manera adecuada.\n"
  "Tu envío: Tus respuestas deben ceñirse estrictamente al formato de comunicación, llenando los campos correspondientemente, sin comillas ni ningún carácter adicional. La doble línea || es exclusiva para el formato de comunicación, no la uses para comunicarte con el usuario (usa // si necesitas referirte a ella). Si no sigues el formato, la app podría fallar.\n"
  "Personalidad: Amable, educada, comprensiva y siempre dispuesta a ayudar a proteger a los niños, niñas y adolescentes.\n"
  "Contexto chat: Utiliza esta información adicional (que no se guarda en el historial) para comprender mejor la situación actual y tomar decisiones informadas. Recuerda que solo tienes acceso a los últimos mensajes., aunq este bacio debes llenarlo, si no la app fallara\n"
  "Función: \n"
  "  - '-': Indica que no se requiere ejecutar ninguna función.\n"
  "  - 'iniciar_sondeo': Se usa EXCLUSIVAMENTE para desplegar un botón en el *próximo* mensaje para INICIAR EL SONDEO, **ÚNICAMENTE SI, BASÁNDOTE EN LA CONVERSACIÓN, EXISTEN SOSPECHAS FUNDADAS DE UN POSIBLE CASO DE ESCNNA.** No uses '*' si la solicitud del profesor fue previa o si no has identificado suficientes indicios de alerta en la conversación actual.\n"
  /*"  - 'solicitar_info': Se usará internamente para indicar que debes comenzar a solicitar la información del estudiante (nombre, edad, colegio, etc.) a través del chat, después de que el resultado del sondeo lo amerite.\n"
  "  - 'generar_reporte': Se usará internamente para indicar que debes generar el reporte en PDF con la información recopilada.\n"
  "Respuesta al usuario: Aquí debes incluir tu próximo mensaje directo al profesor, guiándolo y respondiendo a sus preguntas.\n"*/
  "Hstorial funciones: auqi reciviras las ultimas funciones que activaste para asegurarte que no estes repitiendo inecesariamente.\n"
  "Estado actual: En pruebas, el usuario es un desarrollador.\n"
  "Importante: Actúa con la máxima responsabilidad y prioriza la protección de los estudiantes. No dudes en activar el protocolo de sondeo si tienes sospechas razonables.\n";

static String Contexto_Temporal =
  "Contexto chat: \n"
  "";

static final String formato_de_comunicacion =
  "formato_de_comunicacion: \n"
  "<funcion>||<contexto chat>||<respuesta al usuario>\n"
  "Ejemplo (inicio de conversación): -||El profesor ha iniciado una conversación sobre un estudiante.||Hola profesor, ¿en qué puedo ayudarle hoy?\n"
  "Ejemplo (activación de sondeo): iniciar_sondeo||Basándome en la descripción de la situación, considero importante realizar un sondeo para evaluar el riesgo.||He activado un botón para iniciar el sondeo. Por favor, haga clic en él para continuar.\n"
  "Ejemplo (sin acción inmediata): -||El profesor ha descrito una situación que requiere más información.||Entiendo, profesor. ¿Podría darme más detalles sobre...? "
  "Ejemplo DE HISTORIAL ERRONEO (reiterar sondeos inesesariamente): 1. iniciar _sondeo 2.inicar_sondeo 3.- 4.- 5.- 6.- \n"
  ;

static String Temp = "";

  static String F_4="";
  static String F_3="";
  static String F_2="";
  static String F_1="";
  static String Ultima="";



static String Ult_Sondeo ="";

String Ult_fun(){
   F_4=F_3;
   F_3=F_2;
   F_2=F_1;
   F_1=Ultima;
  String Ultimo="Historial de funciones:\n"
  "1. $F_1 \n"
  "2. $F_2 \n"
  "3. $F_3 \n"
  "4. $F_4 \n";
  return Ultimo;
}


  Future<String> getChatMessage( String historial) async {
    String Hist_Fun=Ult_fun();
    String Cont_Temp = Contexto_Temporal + Temp;
    final List<Part> parts = [
      TextPart(Contexto_Ema),
      TextPart(Cont_Temp),
      TextPart(Hist_Fun),
      TextPart(historial),
      TextPart(formato_de_comunicacion),
      ];
    
    
    try {
      final response = await _gemini.prompt(parts: parts);
      
      if (response?.output != null) {
        final completeResponse = response!.output!;
        String resp = T_recepcion(completeResponse);
        return resp; // Devuelve el texto de la respuesta
      } else {


        print('--- RESPUESTA (ERROR O SIN CONTENIDO) ---');
        print(response);
        if (response?.finishReason != null) {
          print('Error de Gemini (finishReason): ${response!.finishReason}');
        } else {
          print('Respuesta de Gemini sin contenido ni error aparente.');
        }
        return "null"; // Indica que no se pudo obtener un ChatMessage válido
      }
    } catch (e) {
      print('Error en ApiManager: $e');
      return "null"; // Indica que hubo un error
    }
  }



  String T_Envio(String question){
    return question;
  }



  String T_recepcion(String respuesta){
    
    List<String> elementos = respuesta.split('||');
    Ultima=elementos[0];
    Temp=elementos[1];
// aqui quiero enviar el boton de sondeo al home page

    if (Ultima.trim() == "iniciar_sondeo" && onIniciarSondeo != null) {
    onIniciarSondeo!(); // ← esto lanza la función desde el HomePage
    }

    print(respuesta);
    print("|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");
    return elementos[2];
  }




// En ApiManager:
Future<void> enviarResultadoSondeo(ResultadoSondeo resultado, List<SondeoPregunta> preguntas) async {
  // Formatear el resultado para la IA
  String historialParaIA = "Resultado del Sondeo:\n"
      "Puntaje Total: ${resultado['puntajeTotal']}\n"
      "Nivel de Riesgo: ${resultado['nivelRiesgo']}\n\n"
      "Preguntas y Respuestas:\n";

  for (var respuesta in (resultado['respuestas'] as List)) {
    historialParaIA +=
        "- Pregunta: ${respuesta['pregunta']}\n"  //  Incluimos la pregunta
        "  Tipo: ${respuesta['tipoPregunta']}, "
        "  Respuesta: ${respuesta['respuesta']}, "
        "  Peso: ${respuesta['peso']}\n";
  }
Ult_Sondeo = historialParaIA;


  // Llamar a getChatMessage con el historial formateado
  String respuestaDeLaIA = await getChatMessage(historialParaIA);

  // Manejar la respuesta de la IA
  print("Respuesta de la IA al Sondeo: $respuestaDeLaIA");
}


    void guardarInformacionReporte(String info) {
    _infoReporte.value = info;
    print('Información del reporte guardada en ApiManager: $info');
    // Una vez que tenemos la info del reporte, generamos el reporte completo
    _generarReporteCompleto();
  }
/*
  Future<void> _generarReporteCompleto() async {
    if (Ult_Sondeo.isNotEmpty && _infoReporte.value != null) {
      // Construir el prompt para Gemini con ambas informaciones
      String prompt = """
Genera un breve reporte basado en el siguiente resultado del sondeo y la información adicional proporcionada por el profesor.

Resultado del Sondeo:
$Ult_Sondeo

Información Adicional del Profesor:
${_infoReporte.value}

Considerando esta información, genera un resumen conciso de los hallazgos y proporciona algunas recomendaciones iniciales para el profesor sobre los siguientes pasos a seguir en el protocolo de apoyo contra el ESCNNA. El tono debe ser amable, educado y de apoyo.
""";

      final List<Part> parts = [TextPart(prompt)];

      try {
        final response = await _gemini.prompt(parts: parts);

        if (response?.output != null) {
          final reporteGenerado = response!.output!;
          print("Reporte completo generado por Gemini:\n$reporteGenerado");
          // Aquí podrías activar un callback para enviar este reporte al HomePage
          // para que se muestre en el chat. Por ahora, solo lo imprimimos.
        } else {
          print('--- ERROR AL GENERAR EL REPORTE COMPLETO (SIN CONTENIDO) ---');
          print(response);
          // Manejar el error si es necesario
        }
      } catch (e) {
        print('Error al llamar a Gemini para generar el reporte completo: $e');
        // Manejar el error si es necesario
      }
      // Limpiar la información después de generar el reporte (opcional)
      Ult_Sondeo = "";
      _infoReporte.value = null;
    } else {
      print(
          'Aún no se tiene toda la información para generar el reporte completo.');
    }
  }

*/
  
Future<void> _generarReporteCompleto() async {
  if (Ult_Sondeo.isNotEmpty && _infoReporte.value != null) {
    try {
      String prompt = """
Genera un informe en formato JSON basado en el siguiente resultado del sondeo y la información adicional proporcionada por el profesor. El informe debe tener una estructura institucional y una extensión aproximada de una página.

Resultado del Sondeo:
$Ult_Sondeo

Información Adicional del Profesor:
${_infoReporte.value}

Utiliza la siguiente estructura JSON para el informe:

{
"informe": {
"titulo": {
"texto": "Título del Informe",
"estilos": ["lista de estilos"]
},
"secciones": [
{
"titulo": {
"texto": "Título de la Sección",
"estilos": ["lista de estilos"]
},
"contenido": [
{"tipo": "parrafo", "texto": "Texto del párrafo", "estilos": ["lista de estilos opcional"]},
{"tipo": "lista", "estilos": ["bullet" | "numbered"], "items": ["elemento 1", "elemento 2", ...]}
]
},
{"tipo": "parrafo", "texto": "Párrafo final", "estilos": ["lista de estilos opcional"]}
]
}
}


Los estilos disponibles son: "negrita", "cursiva", "subrayado", "justificado", "centrado", "izquierda", "derecha", "tamañoPequeño", "tamañoNormal", "tamañoGrande", "h1", "h2", "h3", "subtitulo", "bullet", "numbered".

Por favor, rellena esta estructura JSON con la información disponible y genera un informe coherente y de carácter institucional sobre la situación del estudiante, incluyendo un análisis narrativo y recomendaciones. Asegúrate de que el JSON sea válido y la respuesta contenga **únicamente el JSON**, sin ningún otro texto o explicación.
""";

_geminiReporte.countTokens(prompt)
    .then((value) => print(value))
    .catchError((e) => print('info $e'));
    
     /// output like: `6` or `null
      final List<Part> parts = [TextPart(prompt)];
      final response = await _geminiReporte.prompt(parts: parts);
_geminiReporte.info(model: 'gemini-2.0-flash')
    .then((info) => print(info))
    .catchError((e) => print('info $e'));

      if (response?.output != null ) {
       final content = response?.output;
    print("✅ JSON del reporte generado (raw):\n$content");
    print("rason de fin:\n${response?.finishReason}");
    _geminiReporte.countTokens(content!)
        .then((value) => print(value))
        .catchError((e) => print('info $e'));
    print("Longitud total del JSON recibido: ${content.length}");
    printEnBloques(content);

    // Limpiar la respuesta JSON
    final String cleanedJson = limpiarRespuestaJson(content);
    print("✅ JSON del reporte generado (limpio):\n$cleanedJson");

    try {
      final Map<String, dynamic> jsonData = jsonDecode(cleanedJson);
      print("✅ JSON parseado exitosamente!");

      // Generar el PDF
      Uint8List pdfBytes = await _generarPdfDesdeJson(jsonData);
      print("✅ Bytes del PDF generados. Longitud: ${pdfBytes.length}");

      // Guardar o mostrar el PDF (ejemplo usando printing package)
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
        return pdfBytes;
      }).catchError((error) {
        print("❌ Error al mostrar la vista previa del PDF: $error");
        // Aquí podrías mostrar un mensaje al usuario o registrar el error de otra manera
      });

    } catch (e) {
      print('❌ Error al parsear el JSON: $e');
      print('JSON que falló:\n$cleanedJson');
    }

        // Aquí puedes parsear el JSON y generar el PDF si es necesario
      } else {
        print('❌ ERROR: La respuesta del reporte vino vacía o sin candidatos.');
        print(response?.finishReason); // Imprime la razón de finalización si está disponible
      }
    } catch (e) {
      print('❌ Error al generar el JSON del reporte: $e');
    }
  } else {
    print('⚠️ Aún no se tiene toda la información para generar el JSON del reporte.');
  }
}

void printEnBloques(String texto, [int tam = 800]) {
  for (var i = 0; i < texto.length; i += tam) {
    print(texto.substring(i, i + tam > texto.length ? texto.length : i + tam));
  }
}



String limpiarRespuestaJson(String respuesta) {
  int startIndex = respuesta.indexOf('{');
  if (startIndex == -1) {
    startIndex = respuesta.indexOf('[');
  }

  int endIndex = respuesta.lastIndexOf('}');
  if (endIndex == -1) {
    endIndex = respuesta.lastIndexOf(']');
  }

  if (startIndex != -1 && endIndex > startIndex) {
    return respuesta.substring(startIndex, endIndex + 1).trim();
  } else {
    return ''; // No se encontró un JSON válido
  }
}

Future<Uint8List> _generarPdfDesdeJson(Map<String, dynamic> jsonData) async {
  final pdf = pw.Document();
  final font = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
  final ttf = pw.Font.ttf(font);

  final informeData = jsonData['informe'];

  if (informeData == null) {
    print('Error: El nodo "informe" no se encontró en el JSON.');
    return pdf.save();
  }

  // --- Título Principal y todas las secciones en la misma página (flujo continuo) ---
  final tituloData = informeData['titulo'];
  final seccionesData = informeData['secciones'] as List?;

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (tituloData != null && tituloData['texto'] != null)
              pw.Center(
                child: pw.Text(tituloData['texto'] as String, style: _getTextStyle(tituloData['estilos'] as List<dynamic>?, ttf, 24)),
              ),
            pw.SizedBox(height: 16), // Espacio después del título

            if (seccionesData != null)
              for (var seccionData in seccionesData)
                ..._buildSeccion(seccionData, ttf), // Incluimos todas las secciones
          ],
        );
      },
    ),
  );

  return pdf.save();
}

// (Las funciones _getTextStyle y _buildContenido permanecen igual)
// (La función _buildSeccion también permanece igual)


pw.TextStyle _getTextStyle(List<dynamic>? estilos, pw.Font ttf, double fontSize, {pw.FontWeight? fontWeight}) {
  pw.TextStyle estilo = pw.TextStyle(font: ttf, fontSize: fontSize, fontWeight: fontWeight);
  if (estilos?.cast<String>().contains('negrita') == true) {
    estilo = estilo.copyWith(fontWeight: pw.FontWeight.bold);
  }
  if (estilos?.cast<String>().contains('cursiva') == true) {
    estilo = estilo.copyWith(fontStyle: pw.FontStyle.italic);
  }
  if (estilos?.cast<String>().contains('tamañoPequeño') == true) {
    estilo = estilo.copyWith(fontSize: 10);
  }
  if (estilos?.cast<String>().contains('tamañoGrande') == true) {
    estilo = estilo.copyWith(fontSize: 14);
  }
  return estilo;
}

List<pw.Widget> _buildContenido(List contenido, pw.Font ttf) {
  List<pw.Widget> widgets = [];
  for (var item in contenido) {
    pw.TextAlign align = pw.TextAlign.left;
    if (item['estilos']?.contains('justificado') == true) {
      align = pw.TextAlign.justify;
    } else if (item['estilos']?.contains('centrado') == true) {
      align = pw.TextAlign.center;
    } else if (item['estilos']?.contains('derecha') == true) {
      align = pw.TextAlign.right;
    }

    if (item['tipo'] == 'parrafo' && item['texto'] != null) {
      widgets.add(pw.Text(item['texto'] as String, style: _getTextStyle(item['estilos'], ttf, 12), textAlign: align));
      widgets.add(pw.SizedBox(height: 4));
    } else if (item['tipo'] == 'lista' && item['items'] != null) {
      if (item['estilos']?.contains('bullet') == true) {
        widgets.addAll((item['items'] as List).map((e) => pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('• ', style: pw.TextStyle(font: ttf, fontSize: 12)),
            pw.Expanded(child: pw.Text(e as String, style: pw.TextStyle(font: ttf, fontSize: 12))),
          ],
        )).toList());
        widgets.add(pw.SizedBox(height: 4));
      } else if (item['estilos']?.contains('numbered') == true) {
        for (var i = 0; i < (item['items'] as List).length; i++) {
          widgets.add(pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('${i + 1}. ', style: pw.TextStyle(font: ttf, fontSize: 12)),
              pw.Expanded(child: pw.Text((item['items'] as List)[i] as String, style: pw.TextStyle(font: ttf, fontSize: 12))),
            ],
          ));
        }
        widgets.add(pw.SizedBox(height: 4));
      }
    }
  }
  return widgets;
}
List<pw.Widget> _buildSeccion(Map<String, dynamic> seccionData, pw.Font ttf) {
  List<pw.Widget> widgets = [];

  // --- Título de la Sección ---
  final tituloSeccionData = seccionData['titulo'];
  if (tituloSeccionData != null && tituloSeccionData['texto'] != null) {
    pw.TextAlign align = pw.TextAlign.left;
    if (tituloSeccionData['estilos']?.cast<String>().contains('centrado') == true) {
      align = pw.TextAlign.center;
    } else if (tituloSeccionData['estilos']?.cast<String>().contains('derecha') == true) {
      align = pw.TextAlign.right;
    }
    widgets.add(pw.Text(tituloSeccionData['texto'] as String, style: _getTextStyle(tituloSeccionData['estilos'] as List<dynamic>?, ttf, 18, fontWeight: pw.FontWeight.bold), textAlign: align));
    widgets.add(pw.SizedBox(height: 8));
  }

  // --- Contenido de la Sección ---
  if (seccionData['contenido'] != null) {
    widgets.addAll(_buildContenido(seccionData['contenido'] as List, ttf));
    widgets.add(pw.SizedBox(height: 12)); // Espacio entre secciones
  }

  return widgets;
}
}