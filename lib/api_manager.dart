import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:gemini/sondeo_manager.dart';




class ApiManager {
  static final ApiManager _instance = ApiManager._internal();
  factory ApiManager() => _instance;
  ApiManager._internal();
 final Gemini _gemini = Gemini.instance;
  
  
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


  void Function()? onIniciarSondeo;



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



  // Llamar a getChatMessage con el historial formateado
  String respuestaDeLaIA = await getChatMessage(historialParaIA);

  // Manejar la respuesta de la IA
  print("Respuesta de la IA al Sondeo: $respuestaDeLaIA");
}
}