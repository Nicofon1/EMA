import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

// Definición de las estructuras de datos (Modulo, Pregunta, ModuloManager)
// ... (Tu código para Modulo, Pregunta y ModuloManager va aquí, asumo que no necesita cambios urgentes para el video)
// Asegúrate que ModuloManager procese bien la videoUrl como lo tenías:
//  if (modulo.videoUrl != null && !modulo.videoUrl!.startsWith('http')) {
//    final fileName = modulo.videoUrl!.split('/').last;
//    modulo.videoUrl = 'videos/$fileName'; // CONFIRMA 'videos/'
//  }
// Voy a pegar tus clases Modulo, Pregunta y ModuloManager para que el bloque sea completo
// y puedas copiar y pegar directamente.

  //_______________________________________________________________Backend_______________________________________________________________
  // todas estas classes son para el backend saltate hasta la prox linea
class Modulo {
  String? titulo;
  String? descripcion;
  String? videoUrl;
  List<Pregunta> preguntas = [];

  Modulo({this.titulo, this.descripcion, this.videoUrl, List<Pregunta>? preguntas})
      : preguntas = preguntas ?? [];

  factory Modulo.fromJson(Map<String, dynamic> json) {
    return Modulo(
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      videoUrl: json['videoUrl'],
      preguntas: (json['preguntas'] as List<dynamic>?)?.map((p) => Pregunta.fromJson(p)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'videoUrl': videoUrl,
      'preguntas': preguntas.map((p) => p.toJson()).toList(),
    };
  }
}

class Pregunta {
  String? pregunta;
  List<String>? opciones;
  int? respuestaCorrecta;

  Pregunta({this.pregunta, this.opciones, this.respuestaCorrecta});

  factory Pregunta.fromJson(Map<String, dynamic> json) {
    return Pregunta(
      pregunta: json['pregunta'],
      opciones: (json['opciones'] as List<dynamic>?)?.map((o) => o.toString()).toList(),
      respuestaCorrecta: json['respuestaCorrecta'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pregunta': pregunta,
      'opciones': opciones,
      'respuestaCorrecta': respuestaCorrecta,
    };
  }
}

class ModuloManager {
  static final ModuloManager _instance = ModuloManager._internal();
  factory ModuloManager() => _instance;
  ModuloManager._internal();

  List<Modulo> _modulos = [];
  List<Modulo> get modulos => _modulos;
  bool _cargado = false;

  Future<void> loadModulos() async {
    if (_cargado) return;

    try {
      final jsonString = await rootBundle.loadString('jsonfile/modulos.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _modulos = jsonList.map((json) {
        final modulo = Modulo.fromJson(json);
        // DESCOMENTA y VERIFICA ESTOS PRINTS si sigues con problemas de "Video no disponible"
        // print("ModuloManager: Leyendo módulo '${modulo.titulo}', videoUrl original: ${json['videoUrl']}");
        if (modulo.videoUrl != null && modulo.videoUrl!.isNotEmpty && !modulo.videoUrl!.startsWith('http')) {
          final fileName = modulo.videoUrl!.split('/').last;
          modulo.videoUrl = 'videos/$fileName'; // Asegúrate que esta sea la ruta correcta a tus assets
           // print("ModuloManager: videoUrl transformado a: ${modulo.videoUrl}");
        }
        return modulo;
      }).toList();

      _cargado = true;
    } catch (e) {
      print('Error al cargar los módulos: $e');
      // Considera lanzar el error o manejarlo de forma que la UI sepa que falló la carga
      _modulos = []; // Asegurar que _modulos esté vacío si hay error
    }
  }

  Modulo? getModulo(int index) {
    if (index >= 0 && index < _modulos.length) {
      return _modulos[index];
    }
    return null;
  }

  void resetear() {
    _modulos.clear();
    _cargado = false;
  }

  int evaluarRespuesta(int moduloIndex, int preguntaIndex, String respuestaSeleccionada) {
    final modulo = getModulo(moduloIndex);
    if (modulo != null &&
        preguntaIndex >= 0 &&
        preguntaIndex < modulo.preguntas.length) {
      final pregunta = modulo.preguntas[preguntaIndex];
      final respuestaCorrecta = pregunta.respuestaCorrecta;
      final opcionSeleccionadaIndex = pregunta.opciones?.indexOf(respuestaSeleccionada);
      if (opcionSeleccionadaIndex == respuestaCorrecta) {
        return 1; // Respuesta correcta
      } else {
        return 0; // Respuesta incorrecta
      }
    }
    return -1; // Error, módulo o pregunta no válida
  }
}

  //_____________________________________________________________________________________________________________________________________



class ModuloPage extends StatefulWidget {
  const ModuloPage({Key? key}) : super(key: key);

  @override
  _ModuloPageState createState() => _ModuloPageState();
}

class _ModuloPageState extends State<ModuloPage> {
  late ModuloManager _moduloManager;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  int _moduloIndex = 0;
  int _preguntaIndex = 0;
  String? _respuestaSeleccionada;
  bool _mostrarRespuesta = false;
  int _correctas = 0;
  bool _moduloCompletado = false;
  List<Modulo> _modulos = [];
  bool _loading = true;


  //_______________________________________________________________Backend_______________________________________________________________
  // en este pedazo estan las funciones de puente con el back y tmbn algunas coass de inicializar la libreria de reproduccion de video y cargar videos
  
  @override
  void initState() {
    super.initState();
    _moduloManager = ModuloManager();
    _loadModulosAndInitialVideo();
  }

  @override
  void dispose() {
    // Pausar y liberar recursos de los controladores de video
    _chewieController?.pause();
    _videoPlayerController?.pause();
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _loadModulosAndInitialVideo() async {
    await _moduloManager.loadModulos();
    if (!mounted) return;

    _modulos = _moduloManager.modulos;
    if (_modulos.isNotEmpty) {
      await _loadVideo(); // Carga el video para el primer módulo (_moduloIndex = 0)
    } else {
      print("_loadModulosAndInitialVideo: No hay módulos cargados o la lista está vacía.");
    }
    _loading = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadModulo(int index) async {
    if (_moduloIndex == index && _chewieController != null) {
      // Ya estamos en este módulo y el video está cargado (o intentando cargar)
      // Podrías decidir no hacer nada o forzar un reinicio si es necesario.
      // Por ahora, no hacemos nada si es el mismo índice para evitar recargas innecesarias.
      return;
    }

    await _videoPlayerController?.pause(); // Pausa el video actual si existe

    _moduloIndex = index;
    _preguntaIndex = 0;
    _respuestaSeleccionada = null;
    _mostrarRespuesta = false;
    _correctas = 0;
    _moduloCompletado = false;
    
    if (mounted) {
      // Actualiza la UI para reflejar el cambio de módulo (ej. título del AppBar)
      // y potencialmente mostrar un indicador de carga para el nuevo video/contenido.
      setState(() {}); 
    }

    await _loadVideo(); // Carga el video para el nuevo módulo
  }
  
  Future<void> _loadVideo() async {
    // PRINTS DE DEPURACIÓN (descomenta si sigues viendo "Video no disponible")
    // print("_loadVideo: Iniciando carga para _moduloIndex: $_moduloIndex");

    // 1. Disponer controladores existentes para liberar recursos
    if (_chewieController != null) {
      await _chewieController!.videoPlayerController.pause(); // Pausa interna
      _chewieController!.dispose();
      _chewieController = null;
       // print("_loadVideo: _chewieController dispuesto y puesto a null");
    }
    if (_videoPlayerController != null) {
      await _videoPlayerController!.pause();
      await _videoPlayerController!.dispose();
      _videoPlayerController = null;
      // print("_loadVideo: _videoPlayerController dispuesto y puesto a null");
    }

    if (!mounted) return;

    // 2. Obtener el módulo actual
    Modulo? currentModulo;
    if (_modulos.isNotEmpty && _moduloIndex >= 0 && _moduloIndex < _modulos.length) {
      currentModulo = _modulos[_moduloIndex];
    } else {
      print("_loadVideo: Lista de módulos vacía o índice fuera de rango. _moduloIndex: $_moduloIndex, _modulos.length: ${_modulos.length}");
      if (mounted) setState(() {}); // Actualiza UI para reflejar que no hay video
      return;
    }

    // 3. Verificar URL del video
    if (currentModulo.videoUrl != null && currentModulo.videoUrl!.isNotEmpty) {
      final String videoUrlString = currentModulo.videoUrl!;
      // print("_loadVideo: URL del video para cargar: '$videoUrlString'");
      bool isNetworkUrl = videoUrlString.startsWith('http');

      if (isNetworkUrl) {
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrlString));
      } else {
        // Asume que ModuloManager ya preparó la ruta del asset (ej. 'videos/nombre.mp4')
        _videoPlayerController = VideoPlayerController.asset(videoUrlString);
      }

      try {
        await _videoPlayerController!.initialize();
        // print("_loadVideo: _videoPlayerController inicializado para '$videoUrlString'");
        if (!mounted) {
          await _videoPlayerController?.dispose();
          return;
        }
        
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: false,
          looping: false,
          placeholder: Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorBuilder: (context, errorMessage) {
            print("_loadVideo: Chewie errorBuilder: $errorMessage");
            return Center(
              child: Text(
                'Error al reproducir el video: $errorMessage',
                style: const TextStyle(color: Colors.red),
              ),
            );
          },
        );
        // print("_loadVideo: _chewieController creado.");
        if (mounted) setState(() {}); // Actualiza UI para mostrar el video
      } catch (e) {
        print("_loadVideo: ERROR al inicializar VideoPlayerController para '$videoUrlString': $e");
        await _videoPlayerController?.dispose();
        _videoPlayerController = null;
        _chewieController = null; 
        if (mounted) setState(() {}); // Actualiza UI para reflejar el error
      }
    } else {
      print("_loadVideo: URL del video es null o vacía para _moduloIndex: $_moduloIndex");
      _videoPlayerController = null; // Asegurar que estén null si no hay URL
      _chewieController = null;
      if (mounted) setState(() {}); // Actualiza UI
    }
  }

  void _verificarRespuesta() {
    if (_respuestaSeleccionada != null) {
      final resultado = _moduloManager.evaluarRespuesta(
          _moduloIndex, _preguntaIndex, _respuestaSeleccionada!);
      setState(() {
        _mostrarRespuesta = true;
        if (resultado == 1) {
          _correctas++;
        }
      });
    }
  }

  void _siguientePregunta() {
    if (_mostrarRespuesta) {
      setState(() {
        _mostrarRespuesta = false;
        _respuestaSeleccionada = null;
        if (_modulos.isNotEmpty && _moduloIndex < _modulos.length && _preguntaIndex < _modulos[_moduloIndex].preguntas.length - 1) {
          _preguntaIndex++;
        } else {
          _moduloCompletado = true;
        }
      });
    }
  }

  //_____________________________________________________________________________________________________________________________________




  @override
  Widget build(BuildContext context) {
    // Si los módulos aún se están cargando (estado _loading es true),
    if (_loading) {
      // Muestra un indicador de carga en el centro de la pantalla.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
      // **COMUNICACIÓN BACKEND:** La variable `_loading` generalmente se gestiona
      // dentro de la función `_loadModulosAndInitialVideo()` que se comunica
      // con el backend (en este caso, simulado con la lectura de un archivo JSON local).
      // Cuando la carga comienza, `_loading` se establece a true y cuando termina (exitosamente
      // o con error), se establece a false.
    }
    // Si la lista de módulos está vacía (no se cargaron módulos),
    if (_modulos.isEmpty) {
      // Muestra un mensaje indicando que no hay módulos disponibles.
      return const Scaffold(
        body: Center(child: Text("No hay módulos disponibles.")),
      );
      // **COMUNICACIÓN BACKEND:** La lista `_modulos` se llena con los datos
      // obtenidos del backend (o archivo JSON local) en la función
      // `_loadModulosAndInitialVideo()`. Si esta lista está vacía, significa
      // que la comunicación con el backend falló o no se encontraron datos.
    }

    // Asegurarse de que _moduloIndex sea válido antes de intentar acceder a _modulos[_moduloIndex]
    if (_moduloIndex < 0 || _moduloIndex >= _modulos.length) {
      // Esto podría pasar si _modulos se modifica y _moduloIndex queda desactualizado.
      // Regresar a un estado seguro o mostrar un error.
      print("Build: _moduloIndex inválido: $_moduloIndex, _modulos tiene ${_modulos.length} elementos.");
      return Scaffold(
        appBar: AppBar(title: Text("Error de Módulo")),
        body: const Center(child: Text("Error: El módulo seleccionado no es válido."))
      );
      // **COMUNICACIÓN BACKEND:** La variable `_moduloIndex` se usa para acceder
      // a un módulo específico dentro de la lista `_modulos`, que fue poblada
      // por la comunicación con el backend. Un `_moduloIndex` inválido podría
      // indicar un problema en la gestión del estado después de una carga.
    }

    // Si no se cumplen las condiciones de carga, lista vacía o índice inválido,
    // construye la pantalla principal del módulo.
    return Scaffold(
      appBar: AppBar(title: Text(_modulos[_moduloIndex].titulo ?? 'Módulo')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Si el módulo actual se ha completado (todas las preguntas respondidas),
    if (_moduloCompletado) {
      // Muestra la pantalla de módulo completado.
      return _buildModuloCompletado();
      // **COMUNICACIÓN BACKEND:** La variable `_moduloCompletado` se establece
      // localmente en la función `_siguientePregunta()` cuando se llega a la
      // última pregunta. No implica una comunicación directa con el backend
      // en este fragmento. Sin embargo, en una aplicación más compleja, al
      // completar un módulo se podría enviar información al backend (ej., progreso
      // del usuario, resultados).
    }
    // Si el módulo actual tiene preguntas y estamos dentro del rango de preguntas,
    else if (_modulos.isNotEmpty &&
             _moduloIndex < _modulos.length &&
             _modulos[_moduloIndex].preguntas.isNotEmpty &&
             _preguntaIndex < _modulos[_moduloIndex].preguntas.length) {
      // Muestra el contenido del módulo (video y preguntas).
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección del VideoPlayer
              if (_videoPlayerController != null && _chewieController != null && _videoPlayerController!.value.isInitialized)
                AspectRatio(
                  aspectRatio: _videoPlayerController!.value.aspectRatio,
                  child: Chewie(controller: _chewieController!),
                )
              else if (_videoPlayerController != null && !_videoPlayerController!.value.isInitialized) // Está intentando cargar
                Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                )
              else // Video no disponible o error
                Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(child: Text('Video no disponible.')),
                ),

              const SizedBox(height: 20),
              Text(
                _modulos[_moduloIndex].descripcion ?? 'Sin descripción.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              _buildPreguntaCard(),
            ],
          ),
        ),
      );
      // **COMUNICACIÓN BACKEND:** La información del módulo actual (título,
      // descripción, URL del video, preguntas y opciones) se obtuvo previamente
      // del backend y está almacenada en la lista `_modulos`. Aquí, solo se
      // están mostrando los datos locales. La carga del video en sí (`_loadVideo()`)
      // podría implicar una comunicación (si la URL es remota), pero la gestión
      // de la URL se realiza localmente basándose en los datos del backend.
    } else if (_modulos.isNotEmpty && _modulos[_moduloIndex].preguntas.isEmpty && !_moduloCompletado) {
      // El módulo no tiene preguntas, se considera completado o muestra un mensaje
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_videoPlayerController != null && _chewieController != null && _videoPlayerController!.value.isInitialized)
              SizedBox( // Limitar altura del video si no hay preguntas
                height: MediaQuery.of(context).size.height * 0.3, // Ejemplo de altura
                child: AspectRatio(
                  aspectRatio: _videoPlayerController!.value.aspectRatio,
                  child: Chewie(controller: _chewieController!),
                ),
              )
            else if (_videoPlayerController != null && !_videoPlayerController!.value.isInitialized)
              Container(
                height: 200,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              )
            else
              Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: Text('Video no disponible.')),
              ),
            const SizedBox(height: 20),
            Text(_modulos[_moduloIndex].descripcion ?? 'Sin descripción.', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            const Text("Este módulo no tiene preguntas.", style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Decide qué hacer: ir al siguiente módulo, volver a la lista, etc.
                // Por ahora, simplemente volvemos a la lista de módulos (si la hubiera antes)
                // O si solo hay un ModuloPage, podría no hacer nada o permitir recargar.
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                } else {
                  // Si no puede hacer pop, quizás recargar el módulo inicial o la lista de módulos
                  _loadModulo(0); // Ejemplo: Cargar el primer módulo
                  // **COMUNICACIÓN BACKEND:** La llamada a `_loadModulo(0)` eventualmente
                  // llamará a `_loadVideo()` y podría implicar una nueva carga de video
                  // (si la URL es remota). Si `_loadModulo` también recarga la lista de
                  // módulos, entonces sí habría una comunicación con el backend.
                }
              },
              child: const Text('Continuar'),
            )
          ],
        ),
      );
    }
    else {
      // Fallback: Muestra la lista de módulos para seleccionar uno (si es la vista inicial o de error)
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _modulos.isEmpty
              ? const Text("No hay módulos cargados para seleccionar.")
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(_modulos.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _loadModulo(index);
                          // **COMUNICACIÓN BACKEND:** Al llamar a `_loadModulo(index)`,
                          // se inicia el proceso para mostrar un módulo específico.
                          // Esto incluye la posible carga del video de ese módulo
                          // (`_loadVideo()`) y la preparación de las preguntas,
                          // todos basados en los datos obtenidos del backend.
                        },
                        child: Text(_modulos[index].titulo ?? "Módulo ${index + 1}"),
                      ),
                    );
                  }),
                ),
        ),
      );
    }
  }

  Widget _buildPreguntaCard() {
    // Asegurarse de que haya preguntas y el índice sea válido
    if (_modulos.isEmpty || _moduloIndex >= _modulos.length || _modulos[_moduloIndex].preguntas.isEmpty || _preguntaIndex >= _modulos[_moduloIndex].preguntas.length) {
      return const Center(child: Text("No hay pregunta disponible."));
    }

    final pregunta = _modulos[_moduloIndex].preguntas[_preguntaIndex];
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pregunta.pregunta ?? 'Pregunta no definida',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: pregunta.opciones?.map((opcion) {
                    final esRespuestaSeleccionada = _respuestaSeleccionada == opcion;
                    return RadioListTile<String>(
                      title: Text(opcion),
                      value: opcion,
                      groupValue: _respuestaSeleccionada,
                      onChanged: _mostrarRespuesta
                          ? null
                          : (value) {
                              setState(() {
                                _respuestaSeleccionada = value;
                              });
                            },
                      activeColor: Colors.blue,
                      selected: esRespuestaSeleccionada,
                      tileColor: esRespuestaSeleccionada && _mostrarRespuesta
                          ? (_moduloManager.evaluarRespuesta(_moduloIndex, _preguntaIndex, _respuestaSeleccionada ?? "") == 1
                              ? Colors.green.shade100
                              : Colors.red.shade100)
                          : null,
                    );
                  }).toList() ??
                  [], // Si opciones es null, devuelve una lista vacía
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!_mostrarRespuesta)
                  ElevatedButton(
                    onPressed: _respuestaSeleccionada == null ? null : _verificarRespuesta,
                    child: const Text('Verificar'),
                    // **COMUNICACIÓN BACKEND:** Al presionar "Verificar", la función
                    // `_verificarRespuesta()` llama a `_moduloManager.evaluarRespuesta()`.
                    // En este código, `ModuloManager` realiza la evaluación localmente
                    // comparando la respuesta seleccionada con la respuesta correcta
                    // almacenada en los datos del módulo (que vinieron del backend).
                    // En una aplicación real, esta función podría enviar la respuesta
                    // del usuario al backend para su validación y para registrar el progreso.
                  ),
                if (_mostrarRespuesta)
                  ElevatedButton(
                    onPressed: _siguientePregunta,
                    child: (_modulos.isNotEmpty && _moduloIndex < _modulos.length && _preguntaIndex < _modulos[_moduloIndex].preguntas.length - 1)
                        ? const Text('Siguiente')
                        : const Text('Finalizar'),
                    // **COMUNICACIÓN BACKEND:** Al presionar "Siguiente" o "Finalizar",
                    // la función `_siguientePregunta()` actualiza el estado local
                    // para mostrar la siguiente pregunta o indicar que el módulo
                    // se completó. No hay una comunicación directa con el backend aquí.
                    // Sin embargo, al finalizar el módulo, se podría enviar una notificación
                    // de finalización y los resultados al backend.
                  ),
              ],
            ),
            if (_mostrarRespuesta) ...[
              const SizedBox(height: 20),
              Text(
                _moduloManager.evaluarRespuesta(_moduloIndex, _preguntaIndex, _respuestaSeleccionada ?? "") == 1
                    ? '¡Correcto!'
                    : 'Incorrecto. La respuesta correcta era: ${pregunta.opciones?[pregunta.respuestaCorrecta ?? 0]}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _moduloManager.evaluarRespuesta(_moduloIndex, _preguntaIndex, _respuestaSeleccionada ?? "") == 1
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModuloCompletado() {
    return Center( // Centrar la tarjeta de módulo completado
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.all(16.0), // Margen alrededor de la tarjeta
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Más padding interno
          child: Column(
            mainAxisSize: MainAxisSize.min, // Para que la tarjeta se ajuste al contenido
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '¡Módulo Completado!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Respuestas Correctas: $_correctas/${_modulos.isNotEmpty && _moduloIndex < _modulos.length ? _modulos[_moduloIndex].preguntas.length : 0}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  // Decide si volver a la lista de módulos (si existe una pantalla anterior)
                  // o ir al primer módulo/pantalla principal.
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  } else {
                    // Si no se puede hacer pop, podrías reiniciar el estado para mostrar la lista de módulos
                    setState(() {
                      _loading = true; // Para forzar la recarga de módulos o una vista de selección
                      _moduloIndex = 0; // O un índice que represente "no selección"
                      // Llamar a una función que reconstruya la vista de selección de módulos.
                      // Por ahora, simplemente recargamos los módulos y el video inicial.
                      _loadModulosAndInitialVideo();
                      // **COMUNICACIÓN BACKEND:** La llamada a `_loadModulosAndInitialVideo()`
                      // implica una nueva comunicación con el backend para obtener la
                      // lista de módulos.
                    });
                  }
                },
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}