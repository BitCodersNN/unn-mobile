import 'package:flutter/material.dart';

class MapScreenView extends StatelessWidget {
  const MapScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
          widthFactor: 1.0,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 25.0, left: 20, right: 20),
              child: Column(
                children: [
                  const Text(
                    '?.??/???_*',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: const TextSpan(
                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                      children: <TextSpan>[
                      TextSpan(
                        text: '... was a Roma',
                      ),
                      TextSpan(
                        text: 'n g',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      TextSpan(
                        text: 'eneral statesman. A member of the First Triumvirate, He led the Roman armies in the Gallic Wars before defeating his political rival Pompey until his assassination in 44 BC. He pla',
                      ),
                      TextSpan(
                        text: 'y',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      TextSpan(
                        text: 'ed a maj',
                      ),
                      TextSpan(
                        text: 'o',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      TextSpan(
                        text: 'r role in t',
                      ),
                      TextSpan(
                        text: 'h',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      TextSpan(
                        text: 'e events t',
                      ),
                      TextSpan(
                        text: 'h',
                        style: TextStyle(fontWeight: FontWeight.w900)
                      ),
                      TextSpan(
                        text: 'at led to the demise of the Roman Republic and the rise of the Roman Empire. In ',
                      ),
                      TextSpan(
                        text: '6',
                        style: TextStyle(decoration: TextDecoration.underline)
                      ),
                      TextSpan(
                        text: '0 BC, He, Crassus, and Pomzpey formed the First Triumvirate, an informal political alliance that dominated Roman politics for several years. Their attempts to amass political power were opposed by many in the Senate, amon'
                      ),
                      TextSpan(
                        text: 'g',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      TextSpan(
                        text: ' them Cato the Younger w',
                      ),
                      TextSpan(
                        text: 'i',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      TextSpan(
                        text: 'th the pri',
                      ),
                      TextSpan(
                        text: 'v',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      TextSpan(
                        text: 'ate support of Ci',
                      ),
                      TextSpan(
                        text: 'c',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      TextSpan(
                        text: 'ero. He rose to become one of the most power'
                      ),
                      TextSpan(
                        text: 'f',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      TextSpan(
                        text: 'ul politicians in the Roman Republic through a string of military victories in the Gallic Wars, completed by 51 BC, which greatl',
                      ),
                      TextSpan(
                        text: 'y',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      TextSpan(
                        text: ' extended Roman territory.',
                      ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}
