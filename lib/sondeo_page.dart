import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:gemini/sondeo_manager.dart';

class SondeoPage extends StatefulWidget {
  const SondeoPage({super.key});

  @override
  State<SondeoPage> createState() => _SondeoPageState();
}

class _SondeoPageState extends State<SondeoPage> {
  bool _loading = true;
  bool isSliding = false;
  double _currentSliderValue = 5.0;
  String? _selectedOptionSI_NO;
  String? _selectedOptionsMULTIPLE;
  final CardSwiperController _cardSwiperController = CardSwiperController();

  @override
  void initState() {
    super.initState();
    _cargarPreguntas();
  }



  
  //_______________________________________________________________Backend_______________________________________________________________
  // estas funciones se encargan de la comunicación con el backend

  Future<void> _cargarPreguntas() async {
    await SondeoManager().loadPreguntas();
    setState(() {
      _loading = false;
    });
  }

  void _registrarRespuesta(int preguntaId, dynamic respuesta) {
    SondeoManager().registrarRespuesta(preguntaId, respuesta);
  }

  Future<void> _finalizarSondeo() async {
    double puntaje = SondeoManager().calcularPuntajeSondeo();
    String nivelRiesgo = SondeoManager().determinarNivelRiesgo(puntaje);



    // Mostrar el resultado del sondeo en un diálogo
    // este es el unico q hace algo de front
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resultado del Sondeo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget> [
              Text('Puntaje Total: ${puntaje.toStringAsFixed(1)}'),
              Text('Nivel de Riesgo: $nivelRiesgo'),
              // Aquí podrías mostrar más detalles si lo deseas
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                Navigator.pop(context); // Volver a la pantalla de chat
              },
              child: const Text('Cerrar'),
            ),
            // Puedes agregar un botón para generar el reporte si es necesario
          ],
        );
      },
    );
    SondeoManager().finalizarSondeo(); // Guardar el sondeo en el historial
  }

  //_____________________________________________________________________________________________________________________________________










  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

  //_______________________________________________________________Backend_______________________________________________________________
  // autodescriptivo xd
    final preguntas = SondeoManager().preguntas;
  //_____________________________________________________________________________________________________________________________________

    return Scaffold(
      appBar: AppBar(title: const Text('Sondeo')),
      body: _buildCardSwiper(preguntas),
    );
  }

  Widget _buildCardSwiper(List<SondeoPregunta> preguntas) {
    return Center(
      child: SizedBox(
        width: 500,
        height: 600,
        child: CardSwiper(
          controller: _cardSwiperController,
          cardsCount: preguntas.length,
          numberOfCardsDisplayed: 3,
          isLoop: false,
          allowedSwipeDirection: AllowedSwipeDirection.all(),
          isDisabled: isSliding,
          onSwipe: (oldIndex, currentIndex, swipeDirection) {
            if (preguntas.isNotEmpty && oldIndex < preguntas.length) {
              // Registrar la respuesta antes de deslizar a la siguiente tarjeta
              final pregunta = preguntas[oldIndex];
              dynamic respuesta;
              // Dependiendo del tipo de pregunta, se obtiene la respuesta
              switch (pregunta.tipoPregunta) {
                case tipo.SI_NO:
                  respuesta = _selectedOptionSI_NO;
                  break;
                case tipo.MULTIPLE:
                  respuesta = _selectedOptionsMULTIPLE;
                  break;
                case tipo.ESCALA:
                  respuesta = _currentSliderValue.round();
                  break;
                default:
                  respuesta = null;
              }
              if (respuesta != null) {
                _registrarRespuesta(pregunta.id!, respuesta);
              }
              // Resetear las opciones seleccionadas para la siguiente pregunta
              _selectedOptionSI_NO = null;
              _selectedOptionsMULTIPLE = null;
              _currentSliderValue = 5.0;
            }
            return true;
          },
          onEnd: () {
            _finalizarSondeo();
          },
          cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
            return Card(
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Expanded(
                    // un 60% de la tarjeta muestra la pregunta
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      child: Text(
                        // Aquí se muestra la pregunta por cada tarjeta
                        preguntas[index].pregunta ?? '',
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    //el otro 40% parte muestra las respuestas
                    flex: 4,
                    child: _Respuestas(preguntas[index]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _Respuestas(SondeoPregunta pregunta) {
    switch (pregunta.tipoPregunta) {
      case tipo.SI_NO:
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Selecciona una opción:',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                RadioListTile<String>(
                  title: const Text('Sí'),
                  value: 'Sí',
                  groupValue: _selectedOptionSI_NO,
                  onChanged: (value) {
                    setState(() {
                      // Aquí se guarda la respuesta seleccionada
                      _selectedOptionSI_NO = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('No'),
                  value: 'No',
                  groupValue: _selectedOptionSI_NO,
                  onChanged: (value) {
                    setState(() {
                      _selectedOptionSI_NO = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('No sé'),
                  value: 'No sé',
                  groupValue: _selectedOptionSI_NO,
                  onChanged: (value) {
                    setState(() {
                      _selectedOptionSI_NO = value;
                    });
                  },
                ),
              ],
            );
          },
        );

      case tipo.MULTIPLE:
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Selecciona una opción:',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                RadioListTile<String>(
                  title: const Text('Siempre'),
                  value: 'Siempre',
                  groupValue: _selectedOptionsMULTIPLE,
                  onChanged: (value) {
                    setState(() {
                      _selectedOptionsMULTIPLE = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('A veces'),
                  value: 'A veces',
                  groupValue: _selectedOptionsMULTIPLE,
                  onChanged: (value) {
                    setState(() {
                      _selectedOptionsMULTIPLE = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Nunca'),
                  value: 'Nunca',
                  groupValue: _selectedOptionsMULTIPLE,
                  onChanged: (value) {
                    setState(() {
                      _selectedOptionsMULTIPLE = value;
                    });
                  },
                ),
              ],
            );
          },
        );

      case tipo.ESCALA:
        return Container(
          color: Colors.grey.shade200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¿Qué tan de acuerdo estás?',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 70,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Slider(
                    value: _currentSliderValue,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: _currentSliderValue.round().toString(),
                    onChangeStart: (_) {
                      setState(() {
                        isSliding = true;
                      });
                    },
                    onChangeEnd: (_) {
                      setState(() {
                        isSliding = false;
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        _currentSliderValue = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        return const Text('Tipo de pregunta no soportado');
    }
  }
}