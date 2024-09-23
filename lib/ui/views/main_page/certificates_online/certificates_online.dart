import 'package:flutter/material.dart';

class OnlineCertificatesScreenView extends StatefulWidget {
  const OnlineCertificatesScreenView({super.key});

  @override
  State<OnlineCertificatesScreenView> createState() =>
      _OnlineCertificatesScreenViewState();
}

class _OnlineCertificatesScreenViewState
    extends State<OnlineCertificatesScreenView> {
  final List<bool> _isExpanded = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Справки онлайн'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCertificateCard(
              title: 'Справка об обучении',
              expandedText:
                  'Справка об обучении по месту требования, подписанная электронной цифровой подписью',
              index: 0,
              showDownloadECPButton: true,
            ),
            const SizedBox(height: 16.0),
            _buildCertificateCard(
              title: 'Справка в общежитие',
              expandedText:
                  'Справка для заселения в общежитие, подписанная электронной цифровой подписью',
              index: 1,
            ),
            const SizedBox(height: 16.0),
            _buildCertificateCard(
              title: 'Предписание на практику',
              expandedText:
                  'Предписание на практику, подписанное электронной цифровой подписью',
              index: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateCard({
    required String title,
    required String expandedText,
    required int index,
    bool showDownloadECPButton = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 0),
            blurRadius: 16.0,
            color: Color(0x20527DAF),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 15.0,
              left: 16.0,
              right: 16.0,
              bottom: _isExpanded[index] ? 0.0 : 15.0,
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Icon(
                _isExpanded[index]
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
              onTap: () {
                setState(() {
                  _isExpanded[index] = !_isExpanded[index];
                });
              },
            ),
          ),
          if (_isExpanded[index])
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expandedText,
                    style: const TextStyle(fontSize: 15.0),
                  ),
                  const SizedBox(height: 35.0),
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF1F70CD),
                            Color(0xFF185BA7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Получить',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (showDownloadECPButton) ...[
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF1F70CD),
                              Color(0xFF185BA7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Загрузить ЭЦП',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
