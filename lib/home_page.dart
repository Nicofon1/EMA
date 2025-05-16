import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:gemini/api_manager.dart';
import 'package:gemini/sondeo_manager.dart';
import 'package:gemini/sondeo_page.dart';
import 'package:gemini/modulos.dart'; // Importa la página de módulos


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Variables
  ChatUser currentUser = ChatUser(id: '0', firstName: 'User');
  ChatUser geminiUser = ChatUser(
    id: '1',
    firstName: 'Gemini',
    profileImage: 'assets/bot.webp',
  );
  List<ChatMessage> messages = [];
  final Gemini gemini = Gemini.instance;

  void initState() {
    super.initState();

    // Asignar el callback para recibir la orden de crear el botón
    ApiManager().onIniciarSondeo = _enviarMensajeConBotonSondeo;

     SondeoManager().onResultadoSondeo = _manejarResultadoSondeo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Gemini Chat '),
        actions: [
          IconButton( // Agrega un IconButton en el AppBar
            icon: const Icon(Icons.book), // Usa un icono de libro o similar
            onPressed: () {
              // Navega a la ModuloPage al hacer clic
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ModuloPage()),
              );
            },
          ),
        ],
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
      messageOptions: MessageOptions(
        messageRowBuilder: (ChatMessage message, ChatMessage? previousMessage,
            ChatMessage? nextMessage, bool isAfterDateSeparator,
            bool isBeforeDateSeparator) {
          if (message.customProperties?['type'] == 'button') {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SondeoPage()), // Navega a SondeoPage
                  );
                },
                child: Text(message.text),
              ),
            );
          }else if (message.customProperties?['type'] == 'formulario_reporte') {
            return _buildFormularioReporte();}
          return null;
        },
      ),
    );
  }

  void _sendMessage(ChatMessage chatMessage) async {
    // Marcamos la función como async
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      //_______________________________________________________________Backend_______________________________________________________________
      ApiManager apiManager = ApiManager();
      final contextoString =
          Ch_contexto(messages, currentUser.id, geminiUser.id);

      final response = await apiManager
          .getChatMessage(contextoString); // Usamos await para esperar la respuesta completa
      //_____________________________________________________________________________________________________________________________________


      final completeResponse = response;
      ChatMessage message = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: completeResponse, // Usamos la respuesta completa
      );

      setState(() {
        messages = [message, ...messages];
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  //_______________________________________________________________Backend_______________________________________________________________
  // esta funcion se ejecuta desde el back para enviar el mensaje con el boton de sondeo

  void _enviarMensajeConBotonSondeo() {
    final ChatMessage mensajeBotonSondeo = ChatMessage(
      user: geminiUser,
      createdAt: DateTime.now(),
      text: "Haz clic aquí para ir al Sondeo", // Cambié el texto del botón
      customProperties: {
        'type': 'button',
      },
    );

    setState(() {
      messages = [mensajeBotonSondeo, ...messages];
    });
  }
  //_____________________________________________________________________________________________________________________________________










  
  //_______________________________________________________________Backend_______________________________________________________________
  // Toda esta funcion si es full de back, pero por facilidad se puso aqui, lo que hace es recoplar en un solo string los ultimos 7 mensajes

  String Ch_contexto(List<ChatMessage> chatMessage, String currentUserId,
      String geminiUserId,
      {int limit = 5}) {
    List<String> contexto = [];
    String pContexto = "historial de chat:\n\n";

    if (chatMessage.length < 7) {
      limit = chatMessage.length;
    } else {
      limit = 7;
    }

    // Iteramos hacia atrás desde el penúltimo hasta startIndex
    for (int i = 0; i < limit; i++) {
      final ChatMessage previousMessage = chatMessage[(limit - 1) - i];
      if (previousMessage.user.id == currentUserId) {
        contexto.add("Usuario: ${previousMessage.text}");
      } else if (previousMessage.user.id == geminiUserId) {
        contexto.add("Ema: ${previousMessage.text}");
      }
    }

    pContexto += contexto.join("\n");
    pContexto += "\n"; // Añadir una línea al final del contexto
    print(
        "______________________________________________________________________________"); // Imprimir el contexto para depuración
    print(pContexto); // Imprimir el contexto para depuración
    return pContexto;
  }
  //_____________________________________________________________________________________________________________________________________ 



   void _manejarResultadoSondeo(double puntaje, String nivelRiesgo) {
    // Enviar el mensaje genérico
    final mensajeGenerico = ChatMessage(
      user: geminiUser,
      createdAt: DateTime.now(),
      text:
          "El sondeo ha arrojado un puntaje de ${puntaje.toStringAsFixed(1)}, lo que indica un nivel de riesgo $nivelRiesgo.",
    );
    setState(() {
      messages = [mensajeGenerico, ...messages];
    });

    // Si el nivel de riesgo es moderado o alto, mostrar el formulario
    if (nivelRiesgo == "Moderado" || nivelRiesgo == "Alto") {
      _mostrarFormularioReporte();
    } else {
      // Si el riesgo es bajo o intermedio, podrías enviar el resultado del sondeo a ApiManager aquí si lo necesitas para la IA.
      // Ejemplo:
      // ApiManager().enviarResultadoSondeo(generarResultadoParaApi(puntaje, nivelRiesgo), SondeoManager().preguntas);
    }
  }

  void _mostrarFormularioReporte() {
    final ChatMessage mensajeFormulario = ChatMessage(
      user: geminiUser,
      createdAt: DateTime.now(),
      text: "Por favor, completa la siguiente información:",
      customProperties: {'type': 'formulario_reporte'},
    );
    setState(() {
      messages = [mensajeFormulario, ...messages];
    });
  }



  Widget _buildFormularioReporte() {
    final _nombreController = TextEditingController();
    final _edadController = TextEditingController();
    final _gradoController = TextEditingController();
    final _salonController = TextEditingController();
    final _correoController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre del estudiante'),
              validator: (value) =>
                  value?.isEmpty == true ? 'Campo requerido' : null,
            ),
            TextFormField(
              controller: _edadController,
              decoration: InputDecoration(labelText: 'Edad'),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty == true
                  ? 'Campo requerido'
                  : int.tryParse(value!) == null
                      ? 'Ingrese un número válido'
                      : null,
            ),
            TextFormField(
              controller: _gradoController,
              decoration: InputDecoration(labelText: 'Grado'),
              validator: (value) =>
                  value?.isEmpty == true ? 'Campo requerido' : null,
            ),
            TextFormField(
              controller: _salonController,
              decoration: InputDecoration(labelText: 'Salón'),
              validator: (value) =>
                  value?.isEmpty == true ? 'Campo requerido' : null,
            ),
            TextFormField(
              controller: _correoController,
              decoration:
                  InputDecoration(labelText: 'Correo institucional del docente'),
              validator: (value) => value?.isEmpty == true
                  ? 'Campo requerido'
                  : !value!.contains('@')
                      ? 'Ingrese un correo válido'
                      : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final infoReporte =
                      'Nombre: ${_nombreController.text}, Edad: ${_edadController.text}, Grado: ${_gradoController.text}, Salón: ${_salonController.text}, Correo Docente: ${_correoController.text}';
                  ApiManager().guardarInformacionReporte(infoReporte);
                  // Opcional: Puedes enviar un mensaje al chat indicando que la información se guardó
                  final mensajeInfoGuardada = ChatMessage(
                    user: geminiUser,
                    createdAt: DateTime.now(),
                    text: "La información del reporte ha sido guardada.",
                  );
                  setState(() {
                    messages = [mensajeInfoGuardada, ...messages];
                  });
                }
              },
              child: const Text('Completar'),
            ),
          ],
        ),
      ),
    );
  }

  // ... (otras funciones) ...

}
